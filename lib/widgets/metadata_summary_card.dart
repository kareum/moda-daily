import 'package:flutter/material.dart';

/// 추출 결과 요약 카드.
/// 숫자 세 가지를 constructor로 받는 단순 표시 위젯.
class MetadataSummaryCard extends StatelessWidget {
  final int totalSelected;
  final int withGps;
  final int skipped;

  const MetadataSummaryCard({
    super.key,
    required this.totalSelected,
    required this.withGps,
    required this.skipped,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            _StatCell(
              label: '선택한 사진',
              value: '$totalSelected장',
              icon: Icons.photo_library_outlined,
              color: color.primary,
            ),
            _Divider(),
            _StatCell(
              label: 'GPS 있음',
              value: '$withGps장',
              icon: Icons.location_on_outlined,
              color: Colors.green,
            ),
            _Divider(),
            _StatCell(
              label: 'GPS 없어 제외',
              value: '$skipped장',
              icon: Icons.location_off_outlined,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: Colors.black12);
  }
}
