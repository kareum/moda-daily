import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/extraction_result.dart';
import '../widgets/metadata_list_item.dart';
import '../widgets/metadata_summary_card.dart';
import 'travel_map_screen.dart';

/// 추출된 메타데이터 결과 화면.
/// [result]와 [assetMap]을 생성자로 받으며, Controller 의존이 없다.
class MetadataResultScreen extends StatelessWidget {
  final ExtractionResult result;

  /// assetId → AssetEntity 맵. 썸네일 표시용.
  final Map<String, AssetEntity> assetMap;

  const MetadataResultScreen({
    super.key,
    required this.result,
    required this.assetMap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추출 결과'),
        actions: [
          // 여행 날짜 범위 표시
          if (result.hasData)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: Text(_travelDateRange(), style: const TextStyle(fontSize: 12))),
            ),
        ],
      ),
      body: result.hasData ? _ResultBody(result: result, assetMap: assetMap) : _NoGpsBody(),
      floatingActionButton: result.hasData
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TravelMapScreen(
                    result: result,
                    assetMap: assetMap,
                  ),
                ),
              ),
              icon: const Icon(Icons.map_outlined),
              label: const Text('지도에서 보기'),
            )
          : null,
    );
  }

  String _travelDateRange() {
    if (result.metadata.isEmpty) return '';
    final first = result.metadata.first.capturedAt;
    final last = result.metadata.last.capturedAt;
    final fmt = DateFormat('yy.MM.dd');
    return first.day == last.day && first.month == last.month && first.year == last.year
        ? fmt.format(first)
        : '${fmt.format(first)} ~ ${fmt.format(last)}';
  }
}

// ─── GPS 있는 결과 본문 ────────────────────────────────────────────────────────

class _ResultBody extends StatelessWidget {
  final ExtractionResult result;
  final Map<String, AssetEntity> assetMap;

  const _ResultBody({required this.result, required this.assetMap});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 요약 카드
        SliverToBoxAdapter(
          child: MetadataSummaryCard(
            totalSelected: result.totalProcessed,
            withGps: result.successCount,
            skipped: result.skippedCount,
          ),
        ),

        // 리스트 헤더
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              '시간 순 정렬 · ${result.successCount}장',
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ),
        ),

        // 메타데이터 리스트
        SliverList.builder(
          itemCount: result.metadata.length,
          itemBuilder: (_, index) {
            final meta = result.metadata[index];
            return MetadataListItem(
              metadata: meta,
              asset: assetMap[meta.assetId],
            );
          },
        ),

        // FAB 겹침 방지 여백
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

// ─── GPS 없음 안내 ────────────────────────────────────────────────────────────

class _NoGpsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined, size: 64, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              'GPS 정보가 있는 사진이 없습니다',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              '카메라 앱의 위치 정보 기록을 활성화한 후\n찍은 사진을 선택해 주세요.',
              style: TextStyle(color: Colors.black54, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
