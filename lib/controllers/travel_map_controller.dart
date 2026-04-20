import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_manager/photo_manager.dart' hide LatLng;

import '../models/marker_style.dart';
import '../models/photo_metadata.dart';

/// 지도 내 마커 그룹 (단독 사진 or 클러스터).
class MarkerGroup {
  final LatLng center;
  final List<PhotoMetadata> items;

  const MarkerGroup({required this.center, required this.items});

  bool get isCluster => items.length > 1;

  /// 단독 마커일 때만 유효
  PhotoMetadata? get single => isCluster ? null : items.first;
}

/// 지도 시각화 화면의 상태를 관리한다.
///
/// - 입력 데이터(metadata, assetMap)는 생성 시 1회 주입 후 불변.
/// - zoom 변화에 따라 클러스터를 재계산한다.
/// - 선택된 마커를 추적하여 하단 패널을 제어한다.
class TravelMapController extends ChangeNotifier {
  // ─── 입력 데이터 (불변) ─────────────────────────────────────────────────

  final List<PhotoMetadata> _allMetadata;
  final Map<String, AssetEntity> _assetMap;

  // 썸네일 캐시: assetId → Uint8List (마커 재생성 시 HTTP 재요청 방지)
  final Map<String, Uint8List> _thumbCache = {};

  // ─── 지도 상태 ──────────────────────────────────────────────────────────

  double _currentZoom = 5.0;
  PhotoMetadata? _selectedMetadata;
  List<MarkerGroup> _markerGroups = [];

  // ─── 마커 스타일 ────────────────────────────────────────────────────────

  MarkerStyle _markerStyle = MarkerStyle.thumbnail;

  // ─── 타임라인 재생 ──────────────────────────────────────────────────────

  bool _isPlaying = false;
  int _playIndex = 0;
  Timer? _playTimer;
  static const Duration _playInterval = Duration(seconds: 2);

  TravelMapController({
    required List<PhotoMetadata> metadata,
    required Map<String, AssetEntity> assetMap,
  })  : _allMetadata = metadata,
        _assetMap = assetMap {
    _recomputeClusters();
  }

  // ─── Getters ─────────────────────────────────────────────────────────────

  List<PhotoMetadata> get allMetadata => _allMetadata;
  Map<String, AssetEntity> get assetMap => _assetMap;
  List<MarkerGroup> get markerGroups => _markerGroups;
  PhotoMetadata? get selectedMetadata => _selectedMetadata;
  double get currentZoom => _currentZoom;
  MarkerStyle get markerStyle => _markerStyle;
  bool get isPlaying => _isPlaying;
  int get playIndex => _playIndex;

  /// 경로선용: capturedAt 기준 정렬된 전체 포인트 목록
  List<LatLng> get routePoints =>
      _allMetadata.map((m) => LatLng(m.latitude, m.longitude)).toList();

  /// 초기 카메라 중심 (전체 포인트 평균)
  LatLng get centerPoint {
    if (_allMetadata.isEmpty) return const LatLng(37.5665, 126.9780); // 서울 기본값
    final avgLat = _allMetadata.map((m) => m.latitude).reduce((a, b) => a + b) /
        _allMetadata.length;
    final avgLng = _allMetadata.map((m) => m.longitude).reduce((a, b) => a + b) /
        _allMetadata.length;
    return LatLng(avgLat, avgLng);
  }

  /// 카메라 초기 피팅 가능 여부 (단일 포인트는 bounds 피팅 불가)
  bool get canFitBounds => _allMetadata.length > 1;

  // ─── 액션 ────────────────────────────────────────────────────────────────

  /// zoom 변화 시 Screen에서 호출 → 클러스터 재계산
  void onZoomChanged(double zoom) {
    if ((zoom - _currentZoom).abs() < 0.3) return; // 미세 변화는 무시
    _currentZoom = zoom;
    _recomputeClusters();
  }

  /// 마커 탭 시 호출 (null = 패널 닫기)
  void selectMarker(PhotoMetadata? metadata) {
    _selectedMetadata = metadata;
    notifyListeners();
  }

  /// 썸네일 캐시 조회/저장
  Uint8List? getCachedThumb(String assetId) => _thumbCache[assetId];
  void cacheThumb(String assetId, Uint8List data) {
    _thumbCache[assetId] = data;
    // notifyListeners 호출 안 함 — 개별 마커 위젯이 setState로 처리
  }

  /// 마커 스타일 변경
  void setMarkerStyle(MarkerStyle style) {
    _markerStyle = style;
    notifyListeners();
  }

  // ─── 타임라인 재생 ──────────────────────────────────────────────────────

  void playTimeline() {
    if (_allMetadata.isEmpty) return;
    _isPlaying = true;
    _playIndex = 0;
    _selectedMetadata = _allMetadata[0];
    notifyListeners();
    _scheduleNext();
  }

  void pauseTimeline() {
    _isPlaying = false;
    _playTimer?.cancel();
    notifyListeners();
  }

  void resumeTimeline() {
    if (_allMetadata.isEmpty || _playIndex >= _allMetadata.length) return;
    _isPlaying = true;
    notifyListeners();
    _scheduleNext();
  }

  void stopTimeline() {
    _isPlaying = false;
    _playIndex = 0;
    _playTimer?.cancel();
    _selectedMetadata = null;
    notifyListeners();
  }

  void _scheduleNext() {
    _playTimer?.cancel();
    _playTimer = Timer(_playInterval, () {
      if (!_isPlaying) return;
      final next = _playIndex + 1;
      if (next >= _allMetadata.length) {
        _isPlaying = false;
        notifyListeners();
        return;
      }
      _playIndex = next;
      _selectedMetadata = _allMetadata[next];
      notifyListeners();
      _scheduleNext();
    });
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }

  // ─── 클러스터 계산 (private) ─────────────────────────────────────────────

  void _recomputeClusters() {
    final cellSize = _cellSizeForZoom(_currentZoom);

    if (cellSize == 0.0) {
      // zoom >= 12: 모든 마커 개별 표시
      _markerGroups = _allMetadata
          .map((m) => MarkerGroup(
                center: LatLng(m.latitude, m.longitude),
                items: [m],
              ))
          .toList();
      notifyListeners();
      return;
    }

    // 그리드 셀 기반 그룹화
    final Map<String, List<PhotoMetadata>> grid = {};
    for (final m in _allMetadata) {
      final key =
          '${(m.latitude / cellSize).floor()}_${(m.longitude / cellSize).floor()}';
      grid.putIfAbsent(key, () => []).add(m);
    }

    _markerGroups = grid.values.map((items) {
      final avgLat =
          items.map((m) => m.latitude).reduce((a, b) => a + b) / items.length;
      final avgLng =
          items.map((m) => m.longitude).reduce((a, b) => a + b) / items.length;
      return MarkerGroup(center: LatLng(avgLat, avgLng), items: items);
    }).toList();

    notifyListeners();
  }

  /// zoom 레벨 → 그리드 셀 크기 (도 단위, 0 = 클러스터 없음)
  static double _cellSizeForZoom(double zoom) {
    if (zoom < 5) return 10.0; // 대륙급
    if (zoom < 7) return 5.0;  // 국가급
    if (zoom < 9) return 1.0;  // 도시급
    if (zoom < 12) return 0.2; // 구역급
    return 0.0;                // 개별 마커
  }
}
