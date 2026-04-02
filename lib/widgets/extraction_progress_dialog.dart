import 'package:flutter/material.dart';

/// 메타데이터 추출 진행 상황 다이얼로그.
/// [progress], [total], [progressRatio] 를 constructor로 받는다.
/// Screen에서 ListenableBuilder로 감싸 반응형으로 업데이트한다.
class ExtractionProgressDialog extends StatelessWidget {
  final int progress;
  final int total;
  final double progressRatio;

  const ExtractionProgressDialog({
    super.key,
    required this.progress,
    required this.total,
    required this.progressRatio,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 추출 중 뒤로가기 차단
      child: AlertDialog(
        title: const Text('메타데이터 추출 중'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: progressRatio),
            const SizedBox(height: 12),
            Text(
              '$progress / $total',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            const Text(
              'GPS · 시간 · 카메라 정보를 읽고 있습니다',
              style: TextStyle(fontSize: 12, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }
}
