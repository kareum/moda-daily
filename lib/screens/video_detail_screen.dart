import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/archive_controller.dart';
import '../core/database/app_database.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../repositories/archive_repository.dart';
import '../services/video_service.dart';
import '../widgets/components/index.dart';

/// 영상 상세 화면 — 재생 + GPS 경로 리플레이 + 편집 진입.
///
/// [initialEditMode] = true이면 화면 진입 시 편집 패널을 바로 연다.
class VideoDetailScreen extends StatefulWidget {
  final VideoArchive archive;
  final ArchiveController controller;
  final bool initialEditMode;

  const VideoDetailScreen({
    super.key,
    required this.archive,
    required this.controller,
    this.initialEditMode = false,
  });

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  List<VideoGpsPoint> _gpsPoints = [];
  List<VideoEditHistoryData> _editHistory = [];
  bool _showEditPanel = false;

  // 편집 설정 (현재 슬라이더 값)
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.initialEditMode) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => setState(() => _showEditPanel = true));
    }
  }

  Future<void> _loadData() async {
    final repo = ArchiveRepository(AppDatabase());
    final points = await repo.getGpsPoints(widget.archive.id);
    final history =
        await widget.controller.loadEditHistory(widget.archive.id);
    if (mounted) {
      setState(() {
        _gpsPoints = points;
        _editHistory = history;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        onBack: () => Navigator.maybePop(context),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined,
              color: AppColors.primary, size: 22),
          onPressed: () => setState(() => _showEditPanel = !_showEditPanel),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          // 편집/생성 진행 중이면 진행 시트만 표시
          final state = widget.controller.state;
          if (state is ArchiveStateCreating || state is ArchiveStateEditing) {
            return Center(
              child: VideoProgressSheet(
                state: state,
                onDone: () => widget.controller.resetState(),
                onCancel: () => widget.controller.resetState(),
              ),
            );
          }

          return Stack(
            children: [
              _buildContent(),
              if (_showEditPanel) _buildEditPanel(),
            ],
          );
        },
      ),
    );
  }

  // ── 본문 ────────────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: _showEditPanel ? 320 : AppSpacing.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 영상 플레이어
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: VideoPlayerCard(
              videoPath: widget.archive.videoPath,
              title: widget.archive.title,
            ),
          ),

          // 메타 정보
          _MetaSection(archive: widget.archive),

          // GPS 경로 미니맵
          if (_gpsPoints.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.s4, 0, AppSpacing.s4, 0),
              child: _DataLabel('GPS Route'),
            ),
            const SizedBox(height: AppSpacing.s2),
            _GpsMiniMap(points: _gpsPoints),
            const SizedBox(height: AppSpacing.s6),
          ],

          // 편집 이력
          if (_editHistory.isNotEmpty) _EditHistorySection(
            history: _editHistory,
            onRollback: _onRollback,
          ),
        ],
      ),
    );
  }

  // ── 편집 패널 (하단 슬라이드) ────────────────────────────────────────────────

  Widget _buildEditPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppSpacing.bottomSheetRadius,
          boxShadow: AppSpacing.floatingShadow,
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s6,
          AppSpacing.s4,
          AppSpacing.s6,
          AppSpacing.s6 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: AppSpacing.pillRadius,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),

            Text('편집 설정',
                style: AppTypography.titleMd
                    .copyWith(color: AppColors.primary)),
            const SizedBox(height: AppSpacing.s4),

            // 재생 속도
            _DataLabel('재생 속도  ×${_speed.toStringAsFixed(1)}'),
            Slider(
              value: _speed,
              min: 0.5,
              max: 3.0,
              divisions: 5,
              activeColor: AppColors.secondary,
              inactiveColor: AppColors.surfaceContainer,
              onChanged: (v) => setState(() => _speed = v),
            ),
            const SizedBox(height: AppSpacing.s4),

            // 적용 버튼
            PrimaryCtaButton(
              label: '편집 저장',
              icon: Icons.check,
              onPressed: _onApplyEdit,
            ),
          ],
        ),
      ),
    );
  }

  // ── 액션 ────────────────────────────────────────────────────────────────────

  Future<void> _onApplyEdit() async {
    setState(() => _showEditPanel = false);

    final config = VideoEditConfig(speed: _speed);
    await widget.controller.applyEdit(
      archiveId: widget.archive.id,
      config: config,
    );

    if (mounted && widget.controller.state is ArchiveStateDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('편집이 저장됐어요.',
              style: AppTypography.bodyMd.copyWith(color: Colors.white)),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
        ),
      );
      await _loadData();
    }
  }

  Future<void> _onRollback(VideoEditHistoryData history) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        title: Text('v${history.version}으로 롤백할까요?',
            style: AppTypography.titleMd.copyWith(color: AppColors.primary)),
        content: Text(
          '현재 편집 버전이 v${history.version}으로 교체돼요.',
          style: AppTypography.bodyMd
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('롤백',
                  style: TextStyle(color: AppColors.tertiary))),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.controller.rollback(
          widget.archive.id, history.version);
      await _loadData();
    }
  }
}

// ── 메타 섹션 ─────────────────────────────────────────────────────────────────

class _MetaSection extends StatelessWidget {
  final VideoArchive archive;
  const _MetaSection({required this.archive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s4, 0, AppSpacing.s4, AppSpacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.s2),
          const _DataLabel('Created'),
          Text(
            DateFormat('yyyy.MM.dd HH:mm').format(archive.createdAt),
            style: AppTypography.bodyMd
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              _Chip(
                  icon: Icons.location_on_outlined,
                  label: '${archive.gpsPointCount}곳'),
              const SizedBox(width: AppSpacing.s2),
              _Chip(
                  icon: Icons.timer_outlined,
                  label: '${archive.durationSeconds}초'),
              if (archive.editCount > 0) ...[
                const SizedBox(width: AppSpacing.s2),
                _Chip(
                    icon: Icons.edit_outlined,
                    label: '편집 ${archive.editCount}회',
                    highlight: true),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── GPS 미니맵 ─────────────────────────────────────────────────────────────────

class _GpsMiniMap extends StatelessWidget {
  final List<VideoGpsPoint> points;
  const _GpsMiniMap({required this.points});

  @override
  Widget build(BuildContext context) {
    final latLngs =
        points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final bounds = LatLngBounds.fromPoints(latLngs);

    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppSpacing.cardShadow,
      ),
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(32),
          ),
          interactionOptions:
              const InteractionOptions(flags: InteractiveFlag.none),
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                'com.mora.daily.travel_map_archiver',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: latLngs,
                strokeWidth: 2.5,
                color: AppColors.secondary,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              // 시작점
              _marker(latLngs.first, AppColors.secondary),
              // 종료점
              if (latLngs.length > 1)
                _marker(latLngs.last, AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Marker _marker(LatLng point, Color color) => Marker(
        point: point,
        width: 12,
        height: 12,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
      );
}

// ── 편집 이력 섹션 ─────────────────────────────────────────────────────────────

class _EditHistorySection extends StatelessWidget {
  final List<VideoEditHistoryData> history;
  final void Function(VideoEditHistoryData) onRollback;

  const _EditHistorySection(
      {required this.history, required this.onRollback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s4, 0, AppSpacing.s4, AppSpacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DataLabel('편집 이력'),
          const SizedBox(height: AppSpacing.s3),
          ...history.map(
            (h) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppSpacing.s2),
              child: _HistoryRow(item: h, onRollback: () => onRollback(h)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final VideoEditHistoryData item;
  final VoidCallback onRollback;
  const _HistoryRow({required this.item, required this.onRollback});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> cfg = {};
    try {
      cfg = jsonDecode(item.editConfigJson) as Map<String, dynamic>;
    } catch (_) {}

    final speed = cfg['speed'];
    final desc = speed != null ? '×$speed 속도' : '편집';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('v${item.version}',
                  style: AppTypography.dataLabel.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc,
                    style: AppTypography.labelLg
                        .copyWith(color: AppColors.onSurface)),
                Text(
                  DateFormat('MM.dd HH:mm').format(item.editedAt),
                  style: AppTypography.dataLabel
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRollback,
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s3)),
            child: Text('롤백',
                style: AppTypography.labelMd
                    .copyWith(color: AppColors.tertiary)),
          ),
        ],
      ),
    );
  }
}

// ── 공통 서브위젯 ──────────────────────────────────────────────────────────────

class _DataLabel extends StatelessWidget {
  final String text;
  const _DataLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppTypography.dataLabel.copyWith(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 9,
          letterSpacing: 1.2,
        ),
      );
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;
  const _Chip(
      {required this.icon, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color =
        highlight ? AppColors.secondary : AppColors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3, vertical: AppSpacing.s1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.dataLabel.copyWith(
                  color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
