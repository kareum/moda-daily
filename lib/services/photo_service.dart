import 'package:exif/exif.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:photo_manager/photo_manager.dart';

import '../models/extraction_result.dart';
import '../models/photo_metadata.dart';

/// 갤러리 접근 및 EXIF 데이터 추출 서비스.
/// 외부 환경(디바이스 사진첩, 파일 시스템)과 통신하는 유일한 창구.
class PhotoService {
  PhotoService._();

  // ─── 권한 ────────────────────────────────────────────────────────────────

  static Future<PermissionState> requestPermission() =>
      PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          androidPermission: AndroidPermission(
            type: RequestType.common,
            mediaLocation: true,
          ),
        ),
      );

  static Future<void> openSettings() => PhotoManager.openSetting();

  // ─── 앨범 & 사진 목록 ────────────────────────────────────────────────────

  static Future<List<AssetPathEntity>> getAlbums() =>
      PhotoManager.getAssetPathList(
        type: RequestType.common,
        filterOption: FilterOptionGroup(
          imageOption: const FilterOption(
            sizeConstraint: SizeConstraint(ignoreSize: true),
          ),
          videoOption: const FilterOption(
            sizeConstraint: SizeConstraint(ignoreSize: true),
          ),
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );

  static Future<List<AssetEntity>> getPhotos(
    AssetPathEntity album, {
    int page = 0,
    int pageSize = 80,
  }) =>
      album.getAssetListPaged(page: page, size: pageSize);

  /// 날짜 범위로 필터링된 사진+영상 목록 반환
  static Future<List<AssetEntity>> getPhotosByDateRange(
    AssetPathEntity album,
    DateTimeRange range, {
    int page = 0,
    int pageSize = 80,
  }) async {
    final filtered = FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      videoOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      createTimeCond: DateTimeCond(
        min: range.start,
        max: range.end.add(const Duration(days: 1)),
      ),
      orders: [
        const OrderOption(type: OrderOptionType.createDate, asc: false),
      ],
    );

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      filterOption: filtered,
    );

    if (albums.isEmpty) return [];
    return albums.first.getAssetListPaged(page: page, size: pageSize);
  }

  // ─── 메타데이터 추출 ─────────────────────────────────────────────────────

  /// 선택된 사진에서 GPS + 시간 + 카메라 정보를 일괄 추출한다.
  ///
  /// [onProgress]: (현재 처리 인덱스, 전체) 콜백 — Controller에서 UI 업데이트용으로 활용.
  static Future<ExtractionResult> extractMetadata(
    List<AssetEntity> assets, {
    void Function(int current, int total)? onProgress,
  }) async {
    final List<PhotoMetadata> results = [];
    int skipped = 0;

    for (int i = 0; i < assets.length; i++) {
      onProgress?.call(i + 1, assets.length);

      final metadata = await _extractSingle(assets[i]);
      if (metadata != null) {
        results.add(metadata);
      } else {
        skipped++;
      }
    }

    results.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    return ExtractionResult(metadata: results, skippedCount: skipped);
  }

  // ─── Private: 단일 사진 처리 ─────────────────────────────────────────────

  static Future<PhotoMetadata?> _extractSingle(AssetEntity asset) async {
    try {
      if (asset.type == AssetType.video) {
        return await _extractVideo(asset);
      }
      return await _extractPhoto(asset);
    } catch (_) {
      return null;
    }
  }

  static Future<PhotoMetadata?> _extractPhoto(AssetEntity asset) async {
    final file = await asset.originFile;
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final exif = await readExifFromBytes(bytes);

    // GPS: EXIF 우선, 없으면 photo_manager fallback
    final lat = _parseGpsCoord(exif['GPS GPSLatitude'], exif['GPS GPSLatitudeRef']?.printable);
    final lng = _parseGpsCoord(exif['GPS GPSLongitude'], exif['GPS GPSLongitudeRef']?.printable);

    double? finalLat = lat;
    double? finalLng = lng;
    if (finalLat == null || finalLng == null) {
      final latlng = await asset.latlngAsync();
      if (latlng != null) {
        final pLat = latlng.latitude;
        final pLng = latlng.longitude;
        if (pLat != 0 || pLng != 0) {
          finalLat = pLat;
          finalLng = pLng;
        }
      }
    }

    if (finalLat == null || finalLng == null) return null;

    return PhotoMetadata(
      assetId: asset.id,
      fileName: asset.title,
      capturedAt: _parseDateTime(exif) ?? asset.createDateTime,
      latitude: finalLat,
      longitude: finalLng,
      altitude: _parseAltitude(exif),
      cameraMake: exif['Image Make']?.printable.trim(),
      cameraModel: exif['Image Model']?.printable.trim(),
      imageDirection: _parseDirection(exif),
      mediaType: AssetMediaType.photo,
    );
  }

  static Future<PhotoMetadata?> _extractVideo(AssetEntity asset) async {
    // 영상 GPS는 photo_manager의 latlngAsync()로만 읽음
    final latlng = await asset.latlngAsync();
    double? finalLat, finalLng;
    if (latlng != null) {
      final pLat = latlng.latitude;
      final pLng = latlng.longitude;
      if (pLat != 0 || pLng != 0) {
        finalLat = pLat;
        finalLng = pLng;
      }
    }

    if (finalLat == null || finalLng == null) return null;

    return PhotoMetadata(
      assetId: asset.id,
      fileName: asset.title,
      capturedAt: asset.createDateTime,
      latitude: finalLat,
      longitude: finalLng,
      mediaType: AssetMediaType.video,
      videoDurationSeconds: asset.duration,
    );
  }

  // ─── Private: EXIF 파싱 헬퍼 ─────────────────────────────────────────────

  /// IfdTag(DMS 형식) + 방향 ref → 10진수 위경도
  static double? _parseGpsCoord(IfdTag? tag, String? ref) {
    if (tag == null || ref == null) return null;
    try {
      final values = tag.values;
      if (values is! IfdRatios) return null;
      final list = values.toList();
      if (list.length < 3) return null;

      final deg = _ratio(list[0]);
      final min = _ratio(list[1]);
      final sec = _ratio(list[2]);
      if (deg == null || min == null || sec == null) return null;

      double decimal = deg + min / 60.0 + sec / 3600.0;
      if (ref == 'S' || ref == 'W') decimal = -decimal;
      return decimal;
    } catch (_) {
      return null;
    }
  }

  static double? _parseAltitude(Map<String, IfdTag> exif) {
    try {
      final tag = exif['GPS GPSAltitude'];
      if (tag == null) return null;
      final values = tag.values;
      if (values is! IfdRatios) return null;
      final list = values.toList();
      if (list.isEmpty) return null;
      double alt = _ratio(list[0]) ?? 0;

      final refTag = exif['GPS GPSAltitudeRef'];
      if (refTag != null) {
        final refValues = refTag.values;
        if (refValues is IfdBytes) {
          final refList = refValues.toList();
          if (refList.isNotEmpty && refList[0] == 1) alt = -alt;
        }
      }
      return alt;
    } catch (_) {
      return null;
    }
  }

  static double? _parseDirection(Map<String, IfdTag> exif) {
    try {
      final tag = exif['GPS GPSImgDirection'];
      if (tag == null) return null;
      final values = tag.values;
      if (values is! IfdRatios) return null;
      final list = values.toList();
      return list.isNotEmpty ? _ratio(list[0]) : null;
    } catch (_) {
      return null;
    }
  }

  /// DateTimeOriginal(가장 정확) → DateTime(파일 수정 시각) 순 fallback
  static DateTime? _parseDateTime(Map<String, IfdTag> exif) {
    final raw = exif['EXIF DateTimeOriginal']?.printable ??
        exif['Image DateTime']?.printable;
    if (raw == null) return null;
    try {
      // 형식: '2023:06:15 14:30:00'
      final parts = raw.trim().split(' ');
      if (parts.length != 2) return null;
      final d = parts[0].split(':');
      final t = parts[1].split(':');
      if (d.length != 3 || t.length != 3) return null;
      return DateTime(
        int.parse(d[0]), int.parse(d[1]), int.parse(d[2]),
        int.parse(t[0]), int.parse(t[1]), int.parse(t[2]),
      );
    } catch (_) {
      return null;
    }
  }

  static double? _ratio(Ratio r) =>
      r.denominator == 0 ? null : r.numerator / r.denominator;
}
