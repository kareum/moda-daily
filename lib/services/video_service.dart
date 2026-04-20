import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

import '../interfaces/i_video_service.dart';
import '../models/caption_style.dart';
import '../models/photo_caption.dart';
import '../models/video_edit_config.dart';

export '../interfaces/i_video_service.dart' show VideoProgressCallback;
export '../models/video_edit_config.dart';

/// FFmpeg 기반 영상 렌더링 서비스.
///
/// 책임:
/// - 사진 에셋 → 9:16 숏폼 MP4 생성
/// - 편집 옵션(속도, BGM, 트림) 적용하여 재렌더링
///
/// 이 클래스는 파일 I/O와 FFmpeg만 담당한다.
/// DB 저장·갤러리 저장은 각각 [ArchiveRepository], [GalleryService]가 담당.
class VideoService implements IVideoService {
  const VideoService();

  // ── 영상 생성 ──────────────────────────────────────────────────────────────

  @override
  Future<String> exportVideo({
    required List<AssetEntity> assets,
    double durationPerPhoto = 2.0,
    String outputFileName = 'travel_archive',
    Map<String, PhotoCaption>? captions,
    VideoProgressCallback? onProgress,
  }) async {
    final dir = await _outputDirectory();
    final outputPath =
        '${dir.path}/${outputFileName}_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final imagePaths = await _resolveImagePaths(assets);
    if (imagePaths.isEmpty) throw Exception('내보낼 사진이 없습니다.');

    final concatFile =
        await _writeConcatFile(imagePaths, durationPerPhoto, dir);

    final totalDuration = durationPerPhoto * imagePaths.length;
    FFmpegKitConfig.enableStatisticsCallback((stats) {
      final timeMs = stats.getTime();
      if (timeMs > 0 && onProgress != null) {
        onProgress((timeMs / 1000 / totalDuration).clamp(0.0, 1.0));
      }
    });

    final captionFilter = await _buildCaptionFilter(
      assets: assets,
      captions: captions,
      durationPerPhoto: durationPerPhoto,
    );

    const scaleFilter = 'scale=1080:1920:force_original_aspect_ratio=decrease,'
        'pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black';
    final vf = captionFilter.isEmpty
        ? scaleFilter
        : '$scaleFilter,$captionFilter';

    // executeWithArguments로 각 인자를 직접 전달 — 문자열 파싱 없이 FFmpeg에 넘어가
    // 므로 -vf 값 안의 따옴표·콤마 충돌이 없다.
    final session = await FFmpegKit.executeWithArguments([
      '-y',
      '-f', 'concat', '-safe', '0', '-i', concatFile.path,
      '-vf', vf,
      '-r', '30', '-c:v', 'libx264', '-preset', 'fast',
      '-crf', '23', '-pix_fmt', 'yuv420p',
      outputPath,
    ]);
    final returnCode = await session.getReturnCode();

    await concatFile.delete();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg 오류: $logs');
    }

    onProgress?.call(1.0);
    return outputPath;
  }

  // ── 영상 편집 (재렌더링) ────────────────────────────────────────────────────

  @override
  Future<String> applyEdit({
    required String sourceVideoPath,
    required VideoEditConfig config,
    VideoProgressCallback? onProgress,
  }) async {
    final dir = await _outputDirectory();
    final outputPath =
        '${dir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final filters = _buildFilterChain(config);

    final args = [
      '-y',
      '-i', sourceVideoPath,
      if (config.bgmPath != null) ...[ '-i', config.bgmPath! ],
      '-vf', filters,
      if (config.bgmPath != null) ...[ '-map', '0:v', '-map', '1:a', '-shortest' ]
      else ...[ '-an' ],
      '-c:v', 'libx264', '-preset', 'fast',
      '-crf', '23', '-pix_fmt', 'yuv420p',
      outputPath,
    ];

    final session = await FFmpegKit.executeWithArguments(args);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('편집 오류: $logs');
    }

    onProgress?.call(1.0);
    return outputPath;
  }

  // ── 썸네일 추출 ────────────────────────────────────────────────────────────

  @override
  Future<String> extractThumbnail(String videoPath) async {
    final dir = await _outputDirectory();
    final thumbPath =
        '${dir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final session = await FFmpegKit.executeWithArguments([
      '-y', '-i', videoPath, '-vframes', '1', '-q:v', '2', thumbPath,
    ]);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      throw Exception('썸네일 추출 실패');
    }
    return thumbPath;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static Future<Directory> _outputDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/video_exports');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// assets/fonts/NotoSansKR-Regular.ttf → 앱 문서 디렉토리에 복사 후 경로 반환.
  /// FFmpeg는 assets 번들을 직접 읽지 못하므로 파일 시스템 경로가 필요하다.
  static Future<String> _fontPath() async {
    final base = await getApplicationDocumentsDirectory();
    final fontFile = File('${base.path}/NotoSansKR-Regular.ttf');
    if (!await fontFile.exists()) {
      final data = await rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf');
      await fontFile.writeAsBytes(data.buffer.asUint8List());
    }
    return fontFile.path;
  }

  static Future<List<String>> _resolveImagePaths(
      List<AssetEntity> assets) async {
    final paths = <String>[];
    for (final asset in assets) {
      final file = await asset.file;
      if (file != null) paths.add(file.path);
    }
    return paths;
  }

  static Future<File> _writeConcatFile(
    List<String> imagePaths,
    double duration,
    Directory dir,
  ) async {
    final buffer = StringBuffer();
    for (final path in imagePaths) {
      buffer.writeln('file \'$path\'');
      buffer.writeln('duration $duration');
    }
    buffer.writeln('file \'${imagePaths.last}\'');

    final file = File('${dir.path}/concat_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(buffer.toString());
    return file;
  }

  static Future<String> _buildCaptionFilter({
    required List<AssetEntity> assets,
    required Map<String, PhotoCaption>? captions,
    required double durationPerPhoto,
  }) async {
    if (captions == null || captions.isEmpty) return '';

    final fontPath = await _fontPath();
    final escapedFontPath = fontPath.replaceAll(':', '\\:');
    final filters = <String>[];

    for (int i = 0; i < assets.length; i++) {
      final id = assets[i].id;
      final caption = captions[id];
      if (caption == null) continue;

      final start = i * durationPerPhoto;
      final end = (i + 1) * durationPerPhoto;
      final style = caption.style;

      final escapedText = _escapeDrawtext(caption.text);
      final textColor = _toFfmpegColor(style.textColorHex);
      final bgColor = _toFfmpegColor(style.bgColorHex);

      final y = switch (style.position) {
        CaptionPosition.bottom => '1620',
        CaptionPosition.center => '(h-text_h)/2',
        CaptionPosition.top => '120',
      };

      final fontSize = style.fontSize.toInt();
      final hasBox = (style.bgColorHex >> 24) & 0xFF > 0;
      final boxPart = hasBox
          ? 'box=1:boxcolor=$bgColor:boxborderw=12:'
          : '';

      filters.add(
        'drawtext=fontfile=\'$escapedFontPath\':'
        'text=\'$escapedText\':'
        'x=(w-text_w)/2:'
        'y=$y:'
        'fontsize=$fontSize:'
        'fontcolor=$textColor:'
        '$boxPart'
        "enable='between(t,$start,$end)'",
      );
    }

    return filters.join(',');
  }

  static String _escapeDrawtext(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll(':', '\\:');
  }

  static String _toFfmpegColor(int argb) {
    final a = (argb >> 24) & 0xFF;
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return '0x${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}'
        '${a.toRadixString(16).padLeft(2, '0')}';
  }

  static String _buildFilterChain(VideoEditConfig config) {
    final filters = <String>[];

    if (config.speed != 1.0) {
      filters.add('setpts=${(1.0 / config.speed).toStringAsFixed(3)}*PTS');
    }

    if (config.trimStart != null || config.trimEnd != null) {
      final start = config.trimStart ?? 0.0;
      final end = config.trimEnd;
      final trim = end != null ? 'trim=start=$start:end=$end' : 'trim=start=$start';
      filters.add(trim);
      filters.add('setpts=PTS-STARTPTS');
    }

    if (config.colorFilter != null) {
      filters.add(config.colorFilter!);
    }

    filters.add(
      'scale=1080:1920:force_original_aspect_ratio=decrease,'
      'pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black',
    );

    return filters.join(',');
  }
}
