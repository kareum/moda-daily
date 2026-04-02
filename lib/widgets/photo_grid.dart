import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'photo_grid_item.dart';

/// 스크롤 가능한 사진 그리드.
/// - 하단 스크롤 도달 시 [onLoadMore] 호출 → Controller가 다음 페이지 로드
/// - 선택 상태는 [selectedIds] Set으로 외부에서 주입
class PhotoGrid extends StatefulWidget {
  final List<AssetEntity> assets;
  final Set<String> selectedIds;
  final bool isLoading;
  final bool hasMore;
  final void Function(String assetId) onToggle;
  final VoidCallback onLoadMore;

  const PhotoGrid({
    super.key,
    required this.assets,
    required this.selectedIds,
    required this.isLoading,
    required this.hasMore,
    required this.onToggle,
    required this.onLoadMore,
  });

  @override
  State<PhotoGrid> createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.assets.isEmpty) {
      return const _EmptyState();
    }

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      // hasMore일 때 로딩 인디케이터 슬롯 추가
      itemCount: widget.assets.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.assets.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final asset = widget.assets[index];
        return PhotoGridItem(
          asset: asset,
          isSelected: widget.selectedIds.contains(asset.id),
          onTap: () => widget.onToggle(asset.id),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined, size: 56, color: Colors.black26),
          SizedBox(height: 12),
          Text('사진이 없습니다', style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }
}
