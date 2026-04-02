import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// 사진 그리드의 단일 셀.
/// 외부 상태에 전혀 의존하지 않고 constructor로만 데이터를 받는다.
class PhotoGridItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 썸네일 (비동기 로드)
          FutureBuilder<Uint8List?>(
            future: asset.thumbnailDataWithSize(const ThumbnailSize.square(200)),
            builder: (_, snapshot) {
              final data = snapshot.data;
              if (data == null) {
                return const ColoredBox(
                  color: Color(0xFFEEEEEE),
                  child: Center(
                    child: Icon(Icons.image_outlined,
                        color: Colors.black26, size: 28),
                  ),
                );
              }
              return Image.memory(data, fit: BoxFit.cover);
            },
          ),

          // 선택 오버레이
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withAlpha(77)
                : Colors.transparent,
          ),

          // 체크 뱃지
          Positioned(
            top: 6,
            right: 6,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: isSelected
                  ? const _CheckBadge(key: ValueKey(true))
                  : const _UncheckBadge(key: ValueKey(false)),
            ),
          ),
        ],
      ),
    );
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
