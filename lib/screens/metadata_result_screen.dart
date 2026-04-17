import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/extraction_result.dart';
import '../widgets/components/index.dart';
import 'archive_list_screen.dart';
import 'travel_map_screen.dart';

/// 추출된 메타데이터 결과 화면 — Editorial Cartography 디자인 적용.
class MetadataResultScreen extends StatefulWidget {
  final ExtractionResult result;
  final Map<String, AssetEntity> assetMap;

  const MetadataResultScreen({
    super.key,
    required this.result,
    required this.assetMap,
  });

  @override
  State<MetadataResultScreen> createState() => _MetadataResultScreenState();
}

class _MetadataResultScreenState extends State<MetadataResultScreen> {
  NavTab _currentTab = NavTab.metadata;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // AppColors.surface
      appBar: AppTopBar(
        onBack: () => Navigator.maybePop(context),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: _currentTab,
        onTabSelected: _onTabSelected,
      ),
      body: widget.result.hasData
          ? _ResultBody(
              result: widget.result,
              assetMap: widget.assetMap,
              onGenerateMap: _goToMap,
            )
          : const _NoGpsBody(),
    );
  }

  void _onTabSelected(NavTab tab) {
    setState(() => _currentTab = tab);
    if (tab == NavTab.export) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ArchiveListScreen()),
      ).then((_) => setState(() => _currentTab = NavTab.metadata));
    }
  }

  void _goToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TravelMapScreen(
          result: widget.result,
          assetMap: widget.assetMap,
        ),
      ),
    );
  }
}

// ─── GPS 있는 결과 본문 ────────────────────────────────────────────────────────

class _ResultBody extends StatelessWidget {
  final ExtractionResult result;
  final Map<String, AssetEntity> assetMap;
  final VoidCallback onGenerateMap;

  const _ResultBody({
    required this.result,
    required this.assetMap,
    required this.onGenerateMap,
  });

  String get _tripLabel {
    if (result.metadata.isEmpty) return '';
    final first = result.metadata.first.capturedAt;
    final last = result.metadata.last.capturedAt;
    final fmt = DateFormat('MMM d, yyyy');
    return first.day == last.day &&
            first.month == last.month &&
            first.year == last.year
        ? fmt.format(first)
        : '${fmt.format(first)} — ${fmt.format(last)}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Scrollable content ────────────────────────────────────
        CustomScrollView(
          slivers: [
            // Editorial Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: EditorialHeader(
                  sessionLabel: 'Archive Session',
                  title: 'Metadata Logs',
                  subtitle:
                      '${result.successCount} items captured · $_tripLabel',
                ),
              ),
            ),

            // Card list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.separated(
                itemCount: result.metadata.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final meta = result.metadata[index];
                  return MetadataCard(
                    metadata: meta,
                    asset: assetMap[meta.assetId],
                  );
                },
              ),
            ),

            // Bottom padding for FAB + nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),

        // ── Floating CTA ──────────────────────────────────────────
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: PrimaryCtaButton(
            label: 'Generate Map Archive',
            icon: Icons.map,
            onPressed: onGenerateMap,
          ),
        ),
      ],
    );
  }
}

// ─── GPS 없음 안내 ────────────────────────────────────────────────────────────

class _NoGpsBody extends StatelessWidget {
  const _NoGpsBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: const Color(0xFF44474E).withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'GPS 정보가 있는 사진이 없습니다',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1C1C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '카메라 앱의 위치 정보 기록을 활성화한 후\n찍은 사진을 선택해 주세요.',
              style: TextStyle(color: Color(0xFF44474E), height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
