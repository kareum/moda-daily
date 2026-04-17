import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../controllers/archive_controller.dart';

/// 영상 생성/편집 진행률을 보여주는 바텀시트.
///
/// [ArchiveController.state]를 외부에서 주입받아 표시만 한다.
/// 로직은 없고 순수 UI.
///
/// 사용 예:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isDismissible: false,
///   builder: (_) => VideoProgressSheet(
///     state: controller.state,
///     onCancel: controller.resetState,
///   ),
/// );
/// ```
class VideoProgressSheet extends StatelessWidget {
  final ArchiveState state;
  final VoidCallback? onDone;
  final VoidCallback? onCancel;
  final VoidCallback? onGoToArchives;

  const VideoProgressSheet({
    super.key,
    required this.state,
    this.onDone,
    this.onCancel,
    this.onGoToArchives,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppSpacing.bottomSheetRadius,
        boxShadow: AppSpacing.floatingShadow,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s6,
        AppSpacing.s6,
        AppSpacing.s6,
        AppSpacing.s6 + MediaQuery.of(context).padding.bottom,
      ),
      child: switch (state) {
        final ArchiveStateCreating s => _ProgressBody(
            label: '영상 생성 중…',
            progress: s.progress,
            icon: Icons.movie_creation_outlined,
            onCancel: onCancel,
          ),
        final ArchiveStateEditing s => _ProgressBody(
            label: '편집 적용 중…',
            progress: s.progress,
            icon: Icons.edit_outlined,
            onCancel: onCancel,
          ),
        ArchiveStateDone _ => _DoneBody(
            onDone: onDone,
            onGoToArchives: onGoToArchives,
          ),
        final ArchiveStateError e =>
          _ErrorBody(message: e.message, onClose: onCancel),
        ArchiveStateIdle _ => const SizedBox.shrink(),
      },
    );
  }
}

// ── 진행 중 ────────────────────────────────────────────────────────────────────

class _ProgressBody extends StatelessWidget {
  final String label;
  final double progress;
  final IconData icon;
  final VoidCallback? onCancel;

  const _ProgressBody({
    required this.label,
    required this.progress,
    required this.icon,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 핸들
        _SheetHandle(),
        const SizedBox(height: AppSpacing.s6),

        // 아이콘 + 레이블
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTypography.titleSm
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Text('$pct%',
                      style: AppTypography.dataLabel
                          .copyWith(color: AppColors.secondary)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),

        // 프로그레스 바
        ClipRRect(
          borderRadius: AppSpacing.pillRadius,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.surfaceContainer,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
        const SizedBox(height: AppSpacing.s6),

        // 취소 버튼
        if (onCancel != null)
          TextButton(
            onPressed: onCancel,
            child: Text('취소',
                style: AppTypography.labelLg
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ),
      ],
    );
  }
}

// ── 완료 ──────────────────────────────────────────────────────────────────────

class _DoneBody extends StatelessWidget {
  final VoidCallback? onDone;
  final VoidCallback? onGoToArchives;
  const _DoneBody({this.onDone, this.onGoToArchives});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHandle(),
        const SizedBox(height: AppSpacing.s8),
        GestureDetector(
          onTap: onGoToArchives,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                color: AppColors.secondary, size: 28),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text('영상이 저장됐어요!',
            style:
                AppTypography.titleMd.copyWith(color: AppColors.onSurface)),
        const SizedBox(height: AppSpacing.s2),
        Text('아이콘을 탭하면 보관함으로 이동해요.',
            style: AppTypography.bodyMd
                .copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.s8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.pillRadius),
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.s4),
                ),
                onPressed: onDone,
                child: Text('닫기',
                    style: AppTypography.titleSm
                        .copyWith(color: AppColors.onSurfaceVariant)),
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.pillRadius),
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.s4),
                ),
                onPressed: onGoToArchives,
                child: Text('보관함 보기',
                    style: AppTypography.titleSm
                        .copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── 에러 ──────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;
  const _ErrorBody({required this.message, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHandle(),
        const SizedBox(height: AppSpacing.s8),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.tertiary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline,
              color: AppColors.tertiary, size: 28),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text('영상 생성에 실패했어요',
            style: AppTypography.titleMd
                .copyWith(color: AppColors.onSurface)),
        const SizedBox(height: AppSpacing.s2),
        Text(message,
            style: AppTypography.bodySm
                .copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: AppSpacing.s8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.pillRadius),
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.s4),
            ),
            onPressed: onClose,
            child: Text('닫기',
                style: AppTypography.titleSm
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ),
        ),
      ],
    );
  }
}

// ── 공통 핸들 ──────────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          borderRadius: AppSpacing.pillRadius,
        ),
      ),
    );
  }
}
