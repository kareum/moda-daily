import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/travel_map_controller.dart';
import '../models/marker_style.dart';
import '../models/photo_metadata.dart';

/// 지도 화면 ViewModel이 View에 노출하는 계약.
abstract class ITravelMapViewModel implements Listenable {
  // ── 마커 / 경로 상태 ──────────────────────────────────────────────────────

  List<MarkerGroup> get markerGroups;
  PhotoMetadata? get selectedMetadata;
  List<LatLng> get routePoints;
  double get currentZoom;

  // ── 마커 스타일 ───────────────────────────────────────────────────────────

  MarkerStyle get markerStyle;

  // ── 타임라인 재생 ─────────────────────────────────────────────────────────

  bool get isPlaying;
  int get playIndex;

  // ── 썸네일 캐시 ───────────────────────────────────────────────────────────

  Uint8List? getCachedThumb(String assetId);
  void cacheThumb(String assetId, Uint8List data);

  // ── 액션 ──────────────────────────────────────────────────────────────────

  void onZoomChanged(double zoom);
  void selectMarker(PhotoMetadata? metadata);
  void setMarkerStyle(MarkerStyle style);
  void playTimeline();
  void pauseTimeline();
  void resumeTimeline();
  void stopTimeline();
}
