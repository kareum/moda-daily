import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// 사진 그리드의 단일 셀.
/// 외부 상태에 전혀 의존하지 않고 constructor로만 데이터를 받는다.
class PhotoGridItem extends StatefulWidget {
  final AssetEntity asset;
  final bool isSelected;
  final VoidCallback onTap;

  const PhotoGridItem({
    super.key,
    required this.asset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<PhotoGridItem> createState() => _PhotoGridItemState();
}

class _PhotoGridItemState extends State<PhotoGridItem> {
  Uint8List? _thumb;

  @override
  void initState() {
    super.initState();
    _loadThumb();
  }

  Future<void> _loadThumb() async {
    final data = await widget.asset
        .thumbnailDataWithSize(const ThumbnailSize.square(200));
    if (mounted && data != null) setState(() => _thumb = data);
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.asset.type == AssetType.video;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 썸네일
          _thumb != null
              ? Image.memory(_thumb!, fit: BoxFit.cover)
              : const ColoredBox(
                  color: Color(0xFFEEEEEE),
                  child: Center(
                    child: Icon(Icons.image_outlined,
                        color: Colors.black26, size: 28),
                  ),
                ),

          // 선택 오버레이
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: widget.isSelected
                ? Theme.of(context).colorScheme.primary.withAlpha(77)
                : Colors.transparent,
          ),

          // 동영상 배지 (좌하단)
          if (isVideo)
            Positioned(
              left: 5,
              bottom: 5,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam,
                        color: Colors.white, size: 11),
                    const SizedBox(width: 2),
                    Text(
                      _fmtDuration(widget.asset.duration),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

          // 체크 배지 (우상단)
          Positioned(
            top: 6,
            right: 6,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: widget.isSelected
                  ? const _CheckBadge(key: ValueKey(true))
                  : const _UncheckBadge(key: ValueKey(false)),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, size: 14, color: Colors.white),
    );
  }
}

class _UncheckBadge extends StatelessWidget {
  const _UncheckBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.5),
        shape: BoxShape.circle,
        color: Colors.black26,
      ),
    );
  }
}
