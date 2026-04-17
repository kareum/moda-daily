import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

/// 진행률 콜백 (0.0 ~ 1.0)
typedef VideoProgressCallback = void Function(double progress);

/// FFmpeg 기반 영상 렌더링 서비스.
///
/// 책임:
/// - 사진 에셋 → 9:16 숏폼 MP4 생성
/// - 편집 옵션(속도, BGM, 트림) 적용하여 재렌더링
///
/// 이 클래스는 파일 I/O와 FFmpeg만 담당한다.
/// DB 저장·갤러리 저장은 각각 [ArchiveRepository], [GalleryService]가 담당.
class VideoService {
  VideoService._();

  // ── 영상 생성 ──────────────────────────────────────────────────────────────

  /// 선택된 사진 에셋으로 9:16 세로형 MP4를 생성한다.
  ///
  /// - [assets]: 촬영 순서대로 정렬된 AssetEntity 목록
  /// - [durationPerPhoto]: 사진 1장 노출 시간 (초)
  /// - [outputFileName]: 저장 파일명 (확장자 제외)
  /// - [onProgress]: 0.0~1.0 진행률 콜백
  ///
  /// 반환값: 생성된 MP4 파일의 절대 경로.
  static Future<String> exportVideo({
    required List<AssetEntity> assets,
    double durationPerPhoto = 2.0,
    String outputFileName = 'travel_archive',
    VideoProgressCallback? onProgress,
  }) async {
    final dir = await _outputDirectory();
    final outputPath = '${dir.path}/${outputFileName}_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // 1. 사진 파일 경로 수집
    final imagePaths = await _resolveImagePaths(assets);
    if (imagePaths.isEmpty) throw Exception('내보낼 사진이 없습니다.');

    // 2. concat 입력 파일 작성 (FFmpeg concat demuxer 형식)
    final concatFile = await _writeConcatFile(imagePaths, durationPerPhoto, dir);

    // 3. 진행률 추적 설정
    final totalDuration = durationPerPhoto * imagePaths.length;
    FFmpegKitConfig.enableStatisticsCallback((stats) {
      final timeMs = stats.getTime();
      if (timeMs > 0 && onProgress != null) {
        onProgress((timeMs / 1000 / totalDuration).clamp(0.0, 1.0));
      }
    });

    // 4. FFmpeg 실행
    // - 9:16 (1080×1920), 30fps, libx264, scale+pad로 비율 맞춤
    final command = '-y '
        '-f concat -safe 0 -i "${concatFile.path}" '
        '-vf "scale=1080:1920:force_original_aspect_ratio=decrease,'
        'pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black" '
        '-r 30 -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p '
        '"$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    // 임시 파일 정리
    await concatFile.delete();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg 오류: $logs');
    }

    onProgress?.call(1.0);
    return outputPath;
  }

  // ── 영상 편집 (재렌더링) ────────────────────────────────────────────────────

  /// 기존 영상에 편집 옵션을 적용해 새 MP4를 생성한다.
  ///
  /// 원본 파일은 건드리지 않고 새 파일로 저장.
  /// 편집 결과는 [ArchiveRepository.saveEdit]으로 이력에 저장할 것.
  static Future<String> applyEdit({
    required String sourceVideoPath,
    required VideoEditConfig config,
    VideoProgressCallback? onProgress,
  }) async {
    final dir = await _outputDirectory();
    final outputPath =
        '${dir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final filters = _buildFilterChain(config);
    final bgmInput = config.bgmPath != null ? '-i "${config.bgmPath}"' : '';
    final audioMap = config.bgmPath != null
        ? '-map 0:v -map 1:a -shortest'
        : '-an'; // 오디오 없음

    final command = '-y '
        '-i "$sourceVideoPath" $bgmInput '
        '-vf "$filters" '
        '$audioMap '
        '-c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p '
        '"$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('편집 오류: $logs');
    }

    onProgress?.call(1.0);
    return outputPath;
  }

  // ── 썸네일 추출 ────────────────────────────────────────────────────────────

  /// 영상 첫 프레임을 JPEG 썸네일로 추출한다.
  static Future<String> extractThumbnail(String videoPath) async {
    final dir = await _outputDirectory();
    final thumbPath =
        '${dir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final session = await FFmpegKit.execute(
      '-y -i "$videoPath" -vframes 1 -q:v 2 "$thumbPath"',
    );
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
    // 마지막 항목은 duration 없이 한 번 더 추가 (FFmpeg concat 요구사항)
    buffer.writeln('file \'${imagePaths.last}\'');

    final file = File('${dir.path}/concat_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(buffer.toString());
    return file;
  }

  static String _buildFilterChain(VideoEditConfig config) {
    final filters = <String>[];

    // 재생 속도
    if (config.speed != 1.0) {
      filters.add('setpts=${(1.0 / config.speed).toStringAsFixed(3)}*PTS');
    }

    // 트림 (setpts 이후 적용)
    if (config.trimStart != null || config.trimEnd != null) {
      final start = config.trimStart ?? 0.0;
      final end = config.trimEnd;
      final trim = end != null ? 'trim=start=$start:end=$end' : 'trim=start=$start';
      filters.add(trim);
      filters.add('setpts=PTS-STARTPTS');
    }

    // 컬러 필터
    if (config.colorFilter != null) {
      filters.add(config.colorFilter!);
    }

    // 최소 9:16 스케일 보장
    filters.add(
      'scale=1080:1920:force_original_aspect_ratio=decrease,'
      'pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black',
    );

    return filters.join(',');
  }
}

// ── 편집 설정 모델 ─────────────────────────────────────────────────────────────

/// 영상 편집 옵션.
/// JSON 직렬화는 [toJson]/[fromJson]으로 처리하여 DB에 저장한다.
class VideoEditConfig {
  /// 재생 속도 (1.0 = 기본, 2.0 = 2배속)
  final double speed;

  /// BGM 파일 경로 (앱 번들 또는 로컬 경로)
  final String? bgmPath;

  /// 트림 시작 시간 (초)
  final double? trimStart;

  /// 트림 종료 시간 (초)
  final double? trimEnd;

  /// FFmpeg 컬러 필터 문자열 (예: "hue=s=0" = 흑백)
  final String? colorFilter;

  const VideoEditConfig({
    this.speed = 1.0,
    this.bgmPath,
    this.trimStart,
    this.trimEnd,
    this.colorFilter,
  });

  Map<String, dynamic> toJson() => {
        'speed': speed,
        if (bgmPath != null) 'bgmPath': bgmPath,
        if (trimStart != null) 'trimStart': trimStart,
        if (trimEnd != null) 'trimEnd': trimEnd,
        if (colorFilter != null) 'colorFilter': colorFilter,
      };

  factory VideoEditConfig.fromJson(Map<String, dynamic> json) =>
      VideoEditConfig(
        speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
        bgmPath: json['bgmPath'] as String?,
        trimStart: (json['trimStart'] as num?)?.toDouble(),
        trimEnd: (json['trimEnd'] as num?)?.toDouble(),
        colorFilter: json['colorFilter'] as String?,
      );

  /// DB 저장용 JSON 문자열
  String toJsonString() {
    final m = toJson();
    return m.entries.map((e) => '"${e.key}":${e.value is String ? '"${e.value}"' : e.value}').join(',');
  }
}
