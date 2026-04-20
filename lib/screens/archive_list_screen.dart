import 'package:flutter/material.dart';

import '../controllers/archive_controller.dart';
import '../core/database/app_database.dart';
import '../core/di/app_dependencies.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../interfaces/i_archive_view_model.dart';
import '../widgets/components/index.dart';
import 'video_detail_screen.dart';

/// 저장된 영상 아카이브 목록 화면.
///
/// [ArchiveController.archives] 스트림을 구독하며
/// 레이아웃·라우팅만 담당한다.
class ArchiveListScreen extends StatefulWidget {
  const ArchiveListScreen({super.key});

  @override
  State<ArchiveListScreen> createState() => _ArchiveListScreenState();
}

class _ArchiveListScreenState extends State<ArchiveListScreen> {
  late final IArchiveViewModel _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AppDependencies.instance.createArchiveController();
  }

  @override
  void dispose() {
    (_ctrl as ArchiveController).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        onBack: () => Navigator.maybePop(context),
      ),
      body: ListenableBuilder(
        listenable: _ctrl,
        builder: (context, _) {
          final archives = _ctrl.archives;

          if (archives.isEmpty) {
            return const _EmptyBody();
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: EditorialHeader(
                  sessionLabel: 'My Archives',
                  title: '저장된 영상',
                  subtitle: '${archives.length}개의 아카이브',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s4),
                sliver: SliverList.separated(
                  itemCount: archives.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.s4),
                  itemBuilder: (_, i) => ArchiveCard(
                    archive: archives[i],
                    onTap: () => _goToDetail(archives[i]),
                    onEdit: () => _goToDetail(archives[i], editMode: true),
                    onDelete: () => _confirmDelete(archives[i]),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  void _goToDetail(VideoArchive archive, {bool editMode = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoDetailScreen(
          archive: archive,
          viewModel: _ctrl,
          initialEditMode: editMode,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(VideoArchive archive) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        title: Text('삭제하시겠어요?',
            style: AppTypography.titleMd.copyWith(color: AppColors.primary)),
        content: Text(
          '"${archive.title}"을(를) 삭제하면 복구할 수 없어요.',
          style: AppTypography.bodyMd
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('취소',
                style: AppTypography.labelLg
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('삭제',
                style: AppTypography.labelLg
                    .copyWith(color: AppColors.tertiary)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _ctrl.delete(archive.id);
    }
  }
}

// ── 빈 상태 ───────────────────────────────────────────────────────────────────

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.movie_outlined,
                  color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text('아직 저장된 영상이 없어요',
                style: AppTypography.titleMd
                    .copyWith(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.s2),
            Text(
              '지도 화면에서 사진을 선택한 뒤\n영상을 만들어 보세요.',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
