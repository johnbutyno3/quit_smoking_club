import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../usecases/storage/storage_facade_usecase.dart';

/// 戒菸排程頁面 - 甘特圖風格，顯示每日計畫 vs 實際抽菸數
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _viewMode = 0; // 0=本週, 1=月視圖
  int _initialCount = 10;
  int _durationDays = 90;
  DateTime _startDate = DateTime.now();
  int _todayActual = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final count = await StorageFacadeUseCase.getDailyCount();
    final days = await StorageFacadeUseCase.getPlanDurationDays();
    final startStr = await StorageFacadeUseCase.getPlanStartDate();
    final today = DateTime.now();
    final todayKey = _fmt(today);
    final actual = await StorageFacadeUseCase.getDayActual(todayKey);
    final records = await StorageFacadeUseCase.getSmokeRecordsForToday();

    setState(() {
      _initialCount = count;
      _durationDays = days;
      _startDate = startStr.isEmpty
          ? today
          : DateTime.tryParse(startStr) ?? today;
      _todayActual = actual >= 0 ? actual : records.length;
    });
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 計算第 N 天的計畫支數（線性遞減到 0）
  int _planned(int dayIndex) {
    if (dayIndex >= _durationDays) return 0;
    return max(0, (_initialCount * (1 - dayIndex / _durationDays)).round());
  }

  int get _currentDayIndex {
    final diff = DateTime.now().difference(_startDate).inDays;
    return diff.clamp(0, _durationDays - 1);
  }

  List<_DayRow> get _rows {
    int start, end;
    if (_viewMode == 0) {
      // 本週：以當天為中心，顯示 ±3 天 (共7天)
      start = max(0, _currentDayIndex - 2);
      end = min(_durationDays - 1, start + 6);
    } else {
      // 月視圖：顯示當月所有天
      start = max(0, _currentDayIndex - 14);
      end = min(_durationDays - 1, start + 29);
    }

    return List.generate(end - start + 1, (i) {
      final idx = start + i;
      final date = _startDate.add(Duration(days: idx));
      final planned = _planned(idx);
      int actual = -1;
      if (idx < _currentDayIndex) {
        actual = 0; // 歷史無記錄，顯示 —
      } else if (idx == _currentDayIndex) {
        actual = _todayActual;
      }
      final isCurrent = idx == _currentDayIndex;
      return _DayRow(
        dayNum: idx + 1,
        date: date,
        planned: planned,
        actual: actual,
        isCurrent: isCurrent,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = _rows;
    final today = DateTime.now();
    final elapsed = today.difference(_startDate).inDays + 1;
    final remaining = max(0, _durationDays - elapsed + 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.scheduleTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              l10n.scheduleDayRemaining(elapsed, remaining),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 視圖切換
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  _ViewBtn(
                    label: l10n.scheduleWeeklyView,
                    selected: _viewMode == 0,
                    onTap: () => setState(() => _viewMode = 0),
                  ),
                  _ViewBtn(
                    label: l10n.scheduleMonthlyView,
                    selected: _viewMode == 1,
                    onTap: () => setState(() => _viewMode = 1),
                  ),
                ],
              ),
            ),
          ),

          // 表頭
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(l10n.scheduleHeaderDay, style: _headerStyle),
                ),
                SizedBox(
                  width: 52,
                  child: Text(l10n.scheduleHeaderDate, style: _headerStyle),
                ),
                Expanded(
                  child: Text(l10n.scheduleHeaderPlanned, style: _headerStyle),
                ),
                Expanded(
                  child: Text(l10n.scheduleHeaderActual, style: _headerStyle),
                ),
              ],
            ),
          ),
          const Divider(height: 8),

          // 日程列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: rows.length,
              itemBuilder: (_, i) =>
                  _DayRowWidget(row: rows[i], maxCount: _initialCount),
            ),
          ),

          // 底部摘要
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(
                  color: const Color(0xFF4CAF50),
                  label: l10n.scheduleLegendOnTarget,
                ),
                const SizedBox(width: 16),
                _Legend(
                  color: Colors.redAccent,
                  label: l10n.scheduleLegendOverTarget,
                ),
                const SizedBox(width: 16),
                _Legend(
                  color: Colors.grey.shade300,
                  label: l10n.scheduleLegendFutureOrEmpty,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 11,
    color: Colors.grey,
    fontWeight: FontWeight.bold,
  );
}

class _DayRow {
  final int dayNum;
  final DateTime date;
  final int planned;
  final int actual; // -1 = future, >=0 = recorded
  final bool isCurrent;
  const _DayRow({
    required this.dayNum,
    required this.date,
    required this.planned,
    required this.actual,
    required this.isCurrent,
  });
}

class _DayRowWidget extends StatelessWidget {
  final _DayRow row;
  final int maxCount;
  const _DayRowWidget({required this.row, required this.maxCount});

  @override
  Widget build(BuildContext context) {
    final months = [
      '',
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月',
    ];
    final dateStr = '${months[row.date.month]}${row.date.day}日';
    final isFuture = row.actual < 0;
    final isOver = !isFuture && row.actual > row.planned;
    final barColor = isFuture
        ? Colors.grey.shade200
        : (isOver ? Colors.redAccent : const Color(0xFF4CAF50));
    final actualBarColor = isFuture ? Colors.transparent : barColor;
    final planFrac = maxCount == 0 ? 0.0 : row.planned / maxCount;
    final actualFrac = isFuture ? 0.0 : (row.actual / maxCount).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: row.isCurrent ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: row.isCurrent
            ? Border.all(color: const Color(0xFF4CAF50), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              'Day ${row.dayNum}${row.isCurrent ? ' ◄' : ''}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: row.isCurrent ? FontWeight.bold : FontWeight.normal,
                color: row.isCurrent ? const Color(0xFF1B5E20) : Colors.black87,
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              dateStr,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          // 計畫甘特條
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GanttBar(
                  fraction: planFrac,
                  color: Colors.grey.shade300,
                  label: '${row.planned}',
                ),
                const SizedBox(height: 3),
                _GanttBar(
                  fraction: actualFrac,
                  color: actualBarColor,
                  label: isFuture ? '—' : '${row.actual}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GanttBar extends StatelessWidget {
  final double fraction;
  final Color color;
  final String label;
  const _GanttBar({
    required this.fraction,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 20,
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class _ViewBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ViewBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1B5E20) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
