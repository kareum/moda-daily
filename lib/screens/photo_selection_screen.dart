import 'package:flutter/material.dart';

import '../controllers/extraction_controller.dart';
import '../controllers/photo_selection_controller.dart';
import '../core/di/app_dependencies.dart';
import '../interfaces/i_extraction_view_model.dart';
import '../interfaces/i_photo_selection_view_model.dart';
import '../widgets/album_selector_sheet.dart';
import '../widgets/date_filter_bar.dart';
import '../widgets/extraction_progress_dialog.dart';
import '../widgets/photo_grid.dart';
import '../widgets/selection_bottom_bar.dart';
import 'metadata_result_screen.dart';

/// 사진 선택 화면.
/// Controller를 구독하며 레이아웃과 라우팅만 담당한다.
/// 직접 PhotoService를 호출하지 않는다.
class PhotoSelectionScreen extends StatefulWidget {
  const PhotoSelectionScreen({super.key});

  @override
  State<PhotoSelectionScreen> createState() => _PhotoSelectionScreenState();
}

class _PhotoSelectionScreenState extends State<PhotoSelectionScreen> {
  late final IPhotoSelectionViewModel _selectionCtrl;
  late final IExtractionViewModel _extractionCtrl;

  @override
  void initState() {
    super.initState();
    _selectionCtrl = AppDependencies.instance.createPhotoSelectionController()
      ..initialize();
    _extractionCtrl = AppDependencies.instance.createExtractionController();
  }

  @override
  void dispose() {
    (_selectionCtrl as PhotoSelectionController).dispose();
    (_extractionCtrl as ExtractionController).dispose();
    super.dispose();
  }

  // ─── 추출 플로우 ──────────────────────────────────────────────────────────

  Future<void> _onExtractTapped() async {
    final assets = _selectionCtrl.selectedAssets;
    if (assets.isEmpty) return;

    // 진행 다이얼로그 표시 (Controller를 ListenableBuilder로 구독)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ListenableBuilder(
        listenable: _extractionCtrl,
        builder: (_, __) => ExtractionProgressDialog(
          progress: _extractionCtrl.progress,
          total: _extractionCtrl.total,
          progressRatio: _extractionCtrl.progressRatio,
        ),
      ),
    );

    await _extractionCtrl.extract(assets);

    if (!mounted) return;
    Navigator.pop(context); // 다이얼로그 닫기

    final result = _extractionCtrl.result;
    if (result == null) {
      _showError(_extractionCtrl.errorMessage ?? '알 수 없는 오류');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MetadataResultScreen(
          result: result,
          // 썸네일 표시용: assetId → AssetEntity 맵
          assetMap: {for (final a in assets) a.id: a},
        ),
      ),
    ).then((_) => _extractionCtrl.reset());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ─── 빌드 ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _selectionCtrl,
      builder: (context, _) {
        // 권한 거부 상태
        if (_selectionCtrl.permissionStatus == PermissionStatus.denied) {
          return _PermissionDeniedScreen(
            onOpenSettings: _selectionCtrl.openAppSettings,
          );
        }

        return Scaffold(
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // 날짜 필터 바
              DateFilterBar(
                current: _selectionCtrl.dateFilter,
                onChange: _selectionCtrl.applyDateFilter,
              ),
              const Divider(height: 1),

              // 사진 그리드
              Expanded(
                child: _selectionCtrl.isLoadingAlbums
                    ? const Center(child: CircularProgressIndicator())
                    : PhotoGrid(
                        assets: _selectionCtrl.assets,
                        selectedIds: _selectionCtrl.selectedIds,
                        isLoading: _selectionCtrl.isLoadingPhotos,
                        hasMore: _selectionCtrl.hasMorePhotos,
                        onToggle: _selectionCtrl.toggleSelection,
                        onLoadMore: _selectionCtrl.loadMore,
                      ),
              ),
            ],
          ),
          bottomNavigationBar: SelectionBottomBar(
            selectedCount: _selectionCtrl.selectedCount,
            onExtract: _selectionCtrl.selectedCount > 0
                ? _onExtractTapped
                : null,
            onClear: _selectionCtrl.clearSelection,
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('사진 선택', style: TextStyle(fontSize: 17)),
          if (_selectionCtrl.currentAlbum != null)
            Text(
              _selectionCtrl.currentAlbum!.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
        ],
      ),
      actions: [
        // 전체 선택
        if (_selectionCtrl.assets.isNotEmpty)
          TextButton(
            onPressed: _selectionCtrl.selectedCount == _selectionCtrl.assets.length
                ? _selectionCtrl.clearSelection
                : _selectionCtrl.selectAll,
            child: Text(
              _selectionCtrl.selectedCount == _selectionCtrl.assets.length
                  ? '전체 해제'
                  : '전체 선택',
            ),
          ),

        // 앨범 선택
        IconButton(
          icon: const Icon(Icons.photo_album_outlined),
          onPressed: _selectionCtrl.albums.isNotEmpty
              ? () => AlbumSelectorSheet.show(
                    context,
                    albums: _selectionCtrl.albums,
                    currentAlbum: _selectionCtrl.currentAlbum,
                    onSelect: _selectionCtrl.selectAlbum,
                  )
              : null,
        ),
      ],
    );
  }
}

// ─── 권한 거부 화면 ────────────────────────────────────────────────────────────

class _PermissionDeniedScreen extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const _PermissionDeniedScreen({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사진 접근 권한')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.black26),
              const SizedBox(height: 16),
              const Text(
                '사진첩 접근 권한이 필요합니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'GPS 정보가 포함된 여행 사진을 분석하려면\n사진첩 전체 접근 권한을 허용해 주세요.',
                style: TextStyle(color: Colors.black54, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onOpenSettings,
                child: const Text('설정에서 권한 허용하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
