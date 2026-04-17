import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// 로컬 MP4 파일을 인라인으로 재생하는 카드.
///
/// 재생/일시정지, 시크바 포함. 로직은 내부 [VideoPlayerController]가 담당.
/// 외부에서는 [videoPath]만 전달하면 된다.
class VideoPlayerCard extends StatefulWidget {
  final String videoPath;

  /// 카드 외부에 표시할 제목 (null이면 미표시)
  final String? title;

  const VideoPlayerCard({
    super.key,
    required this.videoPath,
    this.title,
  });

  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    _controller = VideoPlayerController.file(File(widget.videoPath));
    await _controller.initialize();
    _controller.addListener(_onVideoUpdate);
    if (mounted) setState(() => _initialized = true);
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(widget.title!,
              style:
                  AppTypography.titleSm.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.s3),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppSpacing.cardShadow,
          ),
          clipBehavior: Clip.hardEdge,
          child: AspectRatio(
            aspectRatio: _initialized
                ? _controller.value.aspectRatio
                : 9 / 16,
            child: _initialized ? _buildPlayer() : _buildLoading(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayer() {
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 영상
          VideoPlayer(_controller),

          // 글래스 컨트롤 오버레이
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _Controls(
              controller: _controller,
              onPlayPause: _togglePlay,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.secondary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// ── 글래스 컨트롤 오버레이 ─────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onPlayPause;

  const _Controls({required this.controller, required this.onPlayPause});

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final position = value.position;
    final duration = value.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 재생/일시정지 버튼 (중앙)
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppSpacing.glassFill,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: AppColors.secondary,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          // 하단 시크바 + 시간
          Container(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.s4, AppSpacing.s3, AppSpacing.s4, AppSpacing.s4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Column(
              children: [
                // 시크바
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 5),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: AppColors.secondary,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppColors.secondary,
                    overlayColor:
                        AppColors.secondary.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (v) {
                      final ms =
                          (v * duration.inMilliseconds).toInt();
                      controller
                          .seekTo(Duration(milliseconds: ms));
                    },
                  ),
                ),

                // 시간 표시
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(position),
                          style: AppTypography.dataLabel.copyWith(
                              color: Colors.white70, fontSize: 10)),
                      Text(_fmt(duration),
                          style: AppTypography.dataLabel.copyWith(
                              color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
