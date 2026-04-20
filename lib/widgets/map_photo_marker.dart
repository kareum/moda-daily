import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../interfaces/i_travel_map_view_model.dart';
import '../models/marker_style.dart';
import '../models/photo_metadata.dart';

/// 단독 사진 마커 위젯.
/// 썸네일을 비동기로 로드하며, Controller 레벨 캐시를 통해
/// 지도 이동/zoom 시 재요청을 방지한다.
class MapPhotoMarker extends StatefulWidget {
  final PhotoMetadata metadata;
  final AssetEntity? asset;
  final bool isSelected;
  final ITravelMapViewModel controller;
  final VoidCallback onTap;
  final MarkerStyle style;

  const MapPhotoMarker({
    super.key,
    required this.metadata,
    required this.asset,
    required this.isSelected,
    required this.controller,
    required this.onTap,
    this.style = MarkerStyle.thumbnail,
  });

  @override
  State<MapPhotoMarker> createState() => _MapPhotoMarkerState();
}

class _MapPhotoMarkerState extends State<MapPhotoMarker> {
  Uint8List? _thumb;

  @override
  void initState() {
    super.initState();
    _loadThumb();
  }

  Future<void> _loadThumb() async {
    // 캐시 우선 조회
    final cached = widget.controller.getCachedThumb(widget.metadata.assetId);
    if (cached != null) {
      if (mounted) setState(() => _thumb = cached);
      return;
    }

    final data = await widget.asset
        ?.thumbnailDataWithSize(const ThumbnailSize.square(120));
    if (data != null) {
      widget.controller.cacheThumb(widget.metadata.assetId, data);
      if (mounted) setState(() => _thumb = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isSelected ? Colors.orange : Colors.white;
    final borderWidth = widget.isSelected ? 3.0 : 2.0;
    final size = widget.isSelected ? 52.0 : 44.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: borderWidth),
              borderRadius: BorderRadius.circular(
                widget.style.type == MarkerStyleType.icon ? size / 2 : 8,
              ),
              color: widget.style.type == MarkerStyleType.icon
                  ? widget.style.backgroundColor
                  : Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.style.type == MarkerStyleType.icon
                ? _IconMarkerBody(style: widget.style, size: size)
                : _ThumbnailMarkerBody(
                    thumb: _thumb,
                    isVideo: widget.metadata.isVideo,
                  ),
          ),
          CustomPaint(
            size: const Size(12, 8),
            painter: _PinPainter(color: borderColor),
          ),
        ],
      ),
    );
  }
}

// ─── 마커 내부 바디 위젯 ───────────────────────────────────────────────────

class _ThumbnailMarkerBody extends StatelessWidget {
  final Uint8List? thumb;
  final bool isVideo;
  const _ThumbnailMarkerBody({required this.thumb, required this.isVideo});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: thumb != null
              ? Image.memory(thumb!, fit: BoxFit.cover)
              : Icon(
                  isVideo ? Icons.videocam_outlined : Icons.photo_camera,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
        ),
        if (isVideo)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 10),
            ),
          ),
      ],
    );
  }
}

class _IconMarkerBody extends StatelessWidget {
  final MarkerStyle style;
  final double size;
  const _IconMarkerBody({required this.style, required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        style.icon,
        color: style.iconColor,
        size: size * 0.5,
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  final Color color;
  const _PinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PinPainter old) => old.color != color;
}

// ─── 클러스터 마커 ─────────────────────────────────────────────────────────

/// 여러 사진이 묶인 클러스터 마커.
/// 탭 시 지도가 해당 영역으로 zoom-in된다.
class MapClusterMarker extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const MapClusterMarker({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    // 개수에 따라 크기 점진적 확대
    final size = count >= 10 ? 44.0 : (count >= 5 ? 38.0 : 32.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(100),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
