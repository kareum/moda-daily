import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../widgets/components/bottom_nav_bar.dart';
import '../widgets/components/primary_cta_button.dart';
import 'archive_list_screen.dart';
import 'photo_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NavTab _currentTab = NavTab.photos;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        extendBody: true,
        appBar: _HomeTopBar(),
        bottomNavigationBar: AppBottomNavBar(
          currentTab: _currentTab,
          onTabSelected: _onTabSelected,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 16,
            bottom: 120 + MediaQuery.of(context).padding.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── App Identity ───────────────────────────────────
                const _AppIdentity(),
                const SizedBox(height: AppSpacing.s10),

                // ── Hero Visualization Card ────────────────────────
                const _HeroCard(),
                const SizedBox(height: AppSpacing.s10),

                // ── Feature Grid ───────────────────────────────────
                const _FeatureGrid(),
                const SizedBox(height: AppSpacing.s10),

                // ── Primary CTA ────────────────────────────────────
                PrimaryCtaButton(
                  label: '여행 사진 선택하기',
                  icon: Icons.add_photo_alternate_outlined,
                  onPressed: () => _goToPhotoSelection(context),
                ),
                const SizedBox(height: AppSpacing.s3),
                Text(
                  'GPS 정보가 포함된 사진만 분석됩니다.',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTabSelected(NavTab tab) {
    setState(() => _currentTab = tab);
    if (tab == NavTab.export) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ArchiveListScreen()),
      ).then((_) => setState(() => _currentTab = NavTab.photos));
    }
  }

  void _goToPhotoSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PhotoSelectionScreen()),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: AppSpacing.s4,
        right: AppSpacing.s4,
      ),
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      child: Row(
        children: [
          // Menu button
          _TopBarIconBtn(icon: Icons.menu, onTap: () {}),
          const SizedBox(width: AppSpacing.s3),

          // Brand title
          Expanded(
            child: Text(
              'TravelMap ArchiVer'.toUpperCase(),
              style: AppTypography.titleMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontSize: 13,
              ),
            ),
          ),

          // Account button
          _TopBarIconBtn(icon: Icons.account_circle_outlined, onTap: () {}),
        ],
      ),
    );
  }
}

class _TopBarIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopBarIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s2),
        decoration: BoxDecoration(
          borderRadius: AppSpacing.pillRadius,
          color: Colors.transparent,
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
    );
  }
}

// ── App Identity ──────────────────────────────────────────────────────────────

class _AppIdentity extends StatelessWidget {
  const _AppIdentity();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon badge
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: AppSpacing.floatingShadow,
          ),
          child: const Icon(Icons.explore, color: Colors.white, size: 44),
        ),
        const SizedBox(height: AppSpacing.s6),

        // Title
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTypography.headlineLg.copyWith(
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(
                text: 'TravelMap ',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              TextSpan(
                text: 'ArchiVer',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s4),

        // Subtitle
        Text(
          '사진첩의 GPS · 시간 데이터를 기반으로\n여행 경로를 지도 위에 시각화합니다.',
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl + 8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background — simulated map aesthetic
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1B5E), Color(0xFF1A237E), Color(0xFF0A3D4A)],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Decorative grid dots
            CustomPaint(painter: _MapGridPainter()),

            // Route lines (decorative)
            CustomPaint(painter: _RoutePainter()),

            // Gradient overlay (bottom fade)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.primaryContainer.withValues(alpha: 0.85),
                    ],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),
            ),

            // Content overlay
            Positioned(
              left: AppSpacing.s6,
              right: AppSpacing.s6,
              bottom: AppSpacing.s6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Live Archive" badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s3,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: AppSpacing.pillRadius,
                    ),
                    child: Text(
                      'LIVE ARCHIVE',
                      style: AppTypography.dataLabel.copyWith(
                        color: const Color(0xFF00201A),
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),

                  Text(
                    '당신의 여정을 기록하세요',
                    style: AppTypography.headlineSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feature Grid ──────────────────────────────────────────────────────────────

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const _items = [
    (Icons.location_on_outlined, 'GPS 자동 추출'),
    (Icons.map_outlined, '여행 경로 시각화'),
    (Icons.movie_filter_outlined, '숏폼 영상 생성'),
    (Icons.auto_awesome_outlined, 'AI 자막 생성'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.s4,
      mainAxisSpacing: AppSpacing.s4,
      childAspectRatio: 1.3,
      children: _items
          .map((item) => _FeatureCard(icon: item.$1, label: item.$2))
          .toList(),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, color: AppColors.secondary, size: 22),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(
            label,
            style: AppTypography.titleSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Decorative Painters ───────────────────────────────────────────────────────

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.7)
      ..cubicTo(
        size.width * 0.25, size.height * 0.3,
        size.width * 0.5, size.height * 0.5,
        size.width * 0.65, size.height * 0.25,
      )
      ..cubicTo(
        size.width * 0.75, size.height * 0.1,
        size.width * 0.85, size.height * 0.35,
        size.width * 0.9, size.height * 0.2,
      );

    canvas.drawPath(path, paint);

    // Marker dots
    final dotPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    for (final pt in [
      Offset(size.width * 0.1, size.height * 0.7),
      Offset(size.width * 0.65, size.height * 0.25),
      Offset(size.width * 0.9, size.height * 0.2),
    ]) {
      canvas.drawCircle(pt, 5, dotPaint);
      canvas.drawCircle(
        pt,
        9,
        Paint()
          ..color = AppColors.secondary.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
