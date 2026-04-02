import 'package:flutter/material.dart';

/// 날짜 범위 필터 칩 바.
/// 선택된 범위([current])와 변경 콜백([onChange])만 받는다.
class DateFilterBar extends StatelessWidget {
  final DateTimeRange? current;
  final void Function(DateTimeRange?) onChange;

  const DateFilterBar({
    super.key,
    required this.current,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _FilterChip(
            label: '전체',
            isSelected: current == null,
            onTap: () => onChange(null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '이번 주',
            isSelected: _isThisWeek(current),
            onTap: () => onChange(_thisWeekRange()),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '이번 달',
            isSelected: _isThisMonth(current),
            onTap: () => onChange(_thisMonthRange()),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: current != null && !_isThisWeek(current) && !_isThisMonth(current)
                ? _formatRange(current!)
                : '직접 선택',
            isSelected: current != null && !_isThisWeek(current) && !_isThisMonth(current),
            onTap: () => _pickCustomRange(context),
            icon: Icons.calendar_today_outlined,
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: current,
      locale: const Locale('ko'),
      helpText: '날짜 범위 선택',
      cancelText: '취소',
      confirmText: '확인',
    );
    if (picked != null) onChange(picked);
  }

  // ─── 비교 헬퍼 ─────────────────────────────────────────────────────────────

  DateTimeRange _thisWeekRange() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return DateTimeRange(
      start: DateTime(start.year, start.month, start.day),
      end: now,
    );
  }

  DateTimeRange _thisMonthRange() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  bool _isThisWeek(DateTimeRange? r) {
    if (r == null) return false;
    final w = _thisWeekRange();
    return r.start == w.start;
  }

  bool _isThisMonth(DateTimeRange? r) {
    if (r == null) return false;
    final m = _thisMonthRange();
    return r.start == m.start;
  }

  String _formatRange(DateTimeRange r) {
    String fmt(DateTime d) => '${d.month}/${d.day}';
    return '${fmt(r.start)} ~ ${fmt(r.end)}';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.black26),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14,
                  color: isSelected ? Colors.white : Colors.black54),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
