import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/photo_metadata.dart';

/// 마커 탭 시 나타나는 하단 정보 패널.
/// [metadata]와 [asset]을 constructor로 받는 순수 위젯.
/// null이면 빈 영역 렌더링 (AnimatedPositioned가 제어).
class PhotoInfoPanel extends StatelessWidget {
  final PhotoMetadata? metadata;
  final AssetEntity? asset;
  final VoidCallback onClose;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PhotoInfoPanel({
    super.key,
    required this.metadata,
    required this.asset,
    required this.onClose,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final m = metadata;
    if (m == null) return const SizedBox.shrink();

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final dx = details.primaryVelocity ?? 0;
        if (dx < -300) onNext?.call();   // 왼쪽 스와이프 → 다음
        if (dx > 300) onPrevious?.call(); // 오른쪽 스와이프 → 이전
      },
      child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 썸네일
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: asset != null
                          ? _ThumbImage(asset: asset!)
                          : const ColoredBox(
                              color: Color(0xFFEEEEEE),
                              child: Icon(Icons.image_outlined,
                                  color: Colors.black26),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 메타데이터
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 파일명
                        Text(
                          m.fileName ?? m.assetId,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        _InfoRow(
                          icon: Icons.access_time_outlined,
                          text: DateFormat('yyyy.MM.dd  HH:mm:ss')
                              .format(m.capturedAt),
                        ),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          text: m.coordinateText,
                          color: Colors.green.shade700,
                        ),
                        if (m.altitude != null)
                          _InfoRow(
                            icon: Icons.terrain_outlined,
                            text: m.altitudeText,
                          ),
                        if (m.isVideo && m.videoDurationSeconds != null)
                          _InfoRow(
                            icon: Icons.videocam_outlined,
                            text: _formatDuration(m.videoDurationSeconds!),
                            color: Colors.blue.shade700,
                          ),
                        if (!m.isVideo && (m.cameraModel != null || m.cameraMake != null))
                          _InfoRow(
                            icon: Icons.camera_alt_outlined,
                            text: m.cameraInfo,
                          ),
                      ],
                    ),
                  ),

                  // 닫기 버튼
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),  // Container
    );  // GestureDetector
  }
}

// ─── 내부 헬퍼 위젯 ────────────────────────────────────────────────────────

class _ThumbImage extends StatefulWidget {
  final AssetEntity asset;
  const _ThumbImage({required this.asset});

  @override
  State<_ThumbImage> createState() => _ThumbImageState();
}

class _ThumbImageState extends State<_ThumbImage> {
  Uint8List? _data;

  @override
  void initState() {
    super.initState();
    widget.asset
        .thumbnailDataWithSize(const ThumbnailSize.square(160))
        .then((d) {
      if (mounted && d != null) setState(() => _data = d);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _data != null
        ? Image.memory(_data!, fit: BoxFit.cover)
        : const ColoredBox(
            color: Color(0xFFEEEEEE),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
  }
}

String _formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (m > 0) return '$m분 $s초';
  return '$s초';
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.black54;
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: c),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
