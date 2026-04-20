import 'package:flutter/material.dart';

/// 사진 선택 화면 하단 고정 바.
/// 선택 개수와 액션 콜백만 받는다.
class SelectionBottomBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onExtract; // null이면 버튼 비활성
  final VoidCallback onClear;

  const SelectionBottomBar({
    super.key,
    required this.selectedCount,
    required this.onExtract,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 선택 개수 표시
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$selectedCount장 선택됨',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (selectedCount > 0)
                    GestureDetector(
                      onTap: onClear,
                      child: const Text(
                        '선택 해제',
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ),
                ],
              ),
            ),

            // 추출 버튼
            FilledButton.icon(
              onPressed: onExtract,
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text('지도에 그리기'),
            ),
          ],
        ),
      ),
    );
  }
}
