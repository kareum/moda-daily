import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_manager/photo_manager.dart' hide LatLng;

import '../controllers/archive_controller.dart';
import '../controllers/travel_map_controller.dart';
import '../core/database/app_database.dart';
import '../models/extraction_result.dart';
import '../models/photo_metadata.dart';
import '../repositories/archive_repository.dart';
import '../widgets/components/index.dart';
import '../widgets/map_photo_marker.dart';
import '../widgets/map_route_layer.dart';
import '../widgets/photo_info_panel.dart';
import 'archive_list_screen.dart';

/// 여행 경로 지도 화면.
/// - TravelMapController를 구독하여 마커/경로선/하단 패널을 렌더링
/// - flutter_map의 MapController로 카메라를 제어
class TravelMapScreen extends StatefulWidget {
  final ExtractionResult result;
  final Map<String, AssetEntity> assetMap;

  const TravelMapScreen({
    super.key,
    required this.result,
    required this.assetMap,
  });

  @override
  State<TravelMapScreen> createState() => _TravelMapScreenState();
}

class _TravelMapScreenState extends State<TravelMapScreen> {
  late final TravelMapController _mapCtrl;
  late final MapController _flutterMapCtrl;
  late final ArchiveController _archiveCtrl;

  @override
  void initState() {
    super.initState();
    _flutterMapCtrl = MapController();
    _mapCtrl = TravelMapController(
      metadata: widget.result.metadata,
      assetMap: widget.assetMap,
    );
    _archiveCtrl = ArchiveController(
      ArchiveRepository(AppDatabase()),
    )..init();
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    _archiveCtrl.dispose();
    super.dispose();
  }

  // ─── 카메라 초기 설정 ────────────────────────────────────────────────────

  static const double _maxZoom = 18.0;

  MapOptions get _mapOptions {
    final points = _mapCtrl.routePoints;
    if (points.isEmpty) {
      return const MapOptions(
        initialCenter: LatLng(37.5665, 126.9780),
        initialZoom: 10,
        maxZoom: _maxZoom,
      );
    }
    if (points.length == 1) {
      return MapOptions(
        initialCenter: points.first,
        initialZoom: 14,
        maxZoom: _maxZoom,
        onMapEvent: _onMapEvent,
      );
    }
    return MapOptions(
      initialCameraFit: CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(56),
      ),
      maxZoom: _maxZoom,
      onMapEvent: _onMapEvent,
    );
  }

  // ─── 이벤트 핸들러 ───────────────────────────────────────────────────────

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd ||
        event is MapEventScrollWheelZoom ||
        event is MapEventDoubleTapZoom) {
      _mapCtrl.onZoomChanged(_flutterMapCtrl.camera.zoom);
    }
  }

  void _onClusterTap(MarkerGroup group) {
    // 클러스터 탭 → zoom+2 이동
    _flutterMapCtrl.move(
      group.center,
      (_flutterMapCtrl.camera.zoom + 2).clamp(1.0, 18.0),
    );
  }

  // ─── 마커 빌드 ──────────────────────────────────────────────────────────

  List<Marker> _buildMarkers(
    List<MarkerGroup> groups,
    PhotoMetadata? selected,
  ) {
    return groups.map((group) {
      if (group.isCluster) {
        return Marker(
          point: group.center,
          width: 52,
          height: 52,
          child: MapClusterMarker(
            count: group.items.length,
            onTap: () => _onClusterTap(group),
          ),
        );
      }

      final meta = group.single!;
      final isSelected = selected?.assetId == meta.assetId;
      return Marker(
        point: group.center,
        width: isSelected ? 60 : 52,
        height: isSelected ? 72 : 62,
        alignment: Alignment.bottomCenter,
        child: MapPhotoMarker(
          metadata: meta,
          asset: widget.assetMap[meta.assetId],
          isSelected: isSelected,
          controller: _mapCtrl,
          onTap: () {
            _mapCtrl.selectMarker(isSelected ? null : meta);
            if (!isSelected) {
              _flutterMapCtrl.move(
                LatLng(meta.latitude, meta.longitude),
                _flutterMapCtrl.camera.zoom,
              );
            }
          },
        ),
      );
    }).toList();
  }

  // ─── 빌드 ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: _mapCtrl,
        builder: (context, _) {
          return Stack(
            children: [
              // ── 지도 ──────────────────────────────────────────────────
              FlutterMap(
                mapController: _flutterMapCtrl,
                options: _mapOptions,
                children: [
                  // 베이스맵 (OpenStreetMap)
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.mora.daily.travel_map_archiver',
                    maxZoom: 19,
                  ),

                  // 여행 경로선
                  MapRouteLayer(routePoints: _mapCtrl.routePoints),

                  // 사진 마커 레이어
                  MarkerLayer(
                    markers: _buildMarkers(
                      _mapCtrl.markerGroups,
                      _mapCtrl.selectedMetadata,
                    ),
                  ),
                ],
              ),

              // ── 통계 칩 (우측 상단) ──────────────────────────────────
              _StatsChip(
                photoCount: widget.result.successCount,
                dayCount: _dayCount,
              ),

              // ── 하단 사진 정보 패널 ───────────────────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                bottom: _mapCtrl.selectedMetadata != null ? 0 : -220,
                left: 0,
                right: 0,
                child: PhotoInfoPanel(
                  metadata: _mapCtrl.selectedMetadata,
                  asset: _mapCtrl.selectedMetadata != null
                      ? widget.assetMap[_mapCtrl.selectedMetadata!.assetId]
                      : null,
                  onClose: () => _mapCtrl.selectMarker(null),
                  onPrevious: () => _moveToAdjacentPhoto(-1),
                  onNext: () => _moveToAdjacentPhoto(1),
                ),
              ),

              // ── 영상 만들기 버튼 ──────────────────────────────────────
              if (_mapCtrl.selectedMetadata == null)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: PrimaryCtaButton(
                    label: '영상 만들기',
                    icon: Icons.movie_creation_outlined,
                    onPressed: _onCreateVideo,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _moveToAdjacentPhoto(int direction) {
    final list = widget.result.metadata; // 시간순 정렬된 목록
    final current = _mapCtrl.selectedMetadata;
    if (current == null || list.isEmpty) return;

    final idx = list.indexWhere((m) => m.assetId == current.assetId);
    if (idx == -1) return;

    final nextIdx = (idx + direction).clamp(0, list.length - 1);
    if (nextIdx == idx) return;

    final next = list[nextIdx];
    _mapCtrl.selectMarker(next);
    _flutterMapCtrl.move(
      LatLng(next.latitude, next.longitude),
      _flutterMapCtrl.camera.zoom,
    );
  }

  Future<void> _onCreateVideo() async {
    final assets = widget.result.metadata
        .map((m) => widget.assetMap[m.assetId])
        .whereType<AssetEntity>()
        .toList();

    if (assets.isEmpty) return;

    // 진행 시트 열기
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => ListenableBuilder(
        listenable: _archiveCtrl,
        builder: (_, __) => VideoProgressSheet(
          state: _archiveCtrl.state,
          onDone: () => Navigator.pop(context),
          onCancel: () {
            _archiveCtrl.resetState();
            Navigator.pop(context);
          },
          onGoToArchives: () {
            Navigator.pop(context); // 바텀시트 닫기
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArchiveListScreen()),
            );
          },
        ),
      ),
    );

    // 영상 생성 시작
    await _archiveCtrl.create(
      assets: assets,
      metadataList: widget.result.metadata,
      title: '여행 ${_travelDateRange()}',
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('여행 경로', style: TextStyle(fontSize: 17)),
          if (widget.result.metadata.isNotEmpty)
            Text(
              _travelDateRange(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
        ],
      ),
    );
  }

  // ─── ���퍼 ─────────────────────────────────────────────────────────────────

  String _travelDateRange() {
    final list = widget.result.metadata;
    if (list.isEmpty) return '';
    final first = list.first.capturedAt;
    final last = list.last.capturedAt;
    if (first.year == last.year &&
        first.month == last.month &&
        first.day == last.day) {
      return '${first.year}.${first.month.toString().padLeft(2, '0')}.${first.day.toString().padLeft(2, '0')}';
    }
    String fmt(DateTime d) =>
        '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
    return '${fmt(first)} ~ ${fmt(last)}';
  }

  int get _dayCount {
    final list = widget.result.metadata;
    if (list.isEmpty) return 0;
    final first = list.first.capturedAt;
    final last = list.last.capturedAt;
    return last.difference(first).inDays + 1;
  }
}

// ─── 통계 칩 위젯 ──────────────────────────────────────────────────────────

class _StatsChip extends StatelessWidget {
  final int photoCount;
  final int dayCount;

  const _StatsChip({required this.photoCount, required this.dayCount});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + kToolbarHeight + 4,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(140),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library_outlined,
                size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Text('$photoCount장',
                style: const TextStyle(fontSize: 12, color: Colors.white)),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today_outlined,
                size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Text('$dayCount일',
                style: const TextStyle(fontSize: 12, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
