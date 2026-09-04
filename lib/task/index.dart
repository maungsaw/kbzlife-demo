import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';
import '../providers/router_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/pill_tabs.dart';

enum CalendarViewMode { day, week, month }

class ModernTaskCalendarScreen extends ConsumerStatefulWidget {
  const ModernTaskCalendarScreen({super.key});

  @override
  ConsumerState<ModernTaskCalendarScreen> createState() =>
      _ModernTaskCalendarScreenState();
}

class _ModernTaskCalendarScreenState
    extends ConsumerState<ModernTaskCalendarScreen> {
  int _selectedDay = 24;

  final Map<int, List<Map<String, dynamic>>> _tasksByDay = {
    24: [
      {
        'time': '08:00 AM',
        'title': 'Overdue: Policy Follow-up',
        'subtitle': 'Policy • HIGH Priority',
        'color': Colors.red,
        'assignees': ['Alex Morgan', 'Sarah Chen'],
      },
      {
        'time': '09:00 AM',
        'title': 'Meeting Appointment',
        'subtitle': 'Meeting • HIGH Priority',
        'color': kAppColors.primaryColor,
        'assignees': ['David Miller'],
      },
      {
        'time': '11:00 AM',
        'title': 'Customer Follow-up',
        'subtitle': 'Follow-up • MEDIUM Priority',
        'color': kAppColors.warn,
        'assignees': ['Emma Watson', 'James Wilson'],
      },
    ],
    25: [
      {
        'time': '10:00 AM',
        'title': 'Sprint Planning',
        'subtitle': 'Meeting • MEDIUM Priority',
        'color': kAppColors.primaryColor,
        'assignees': ['Alex Morgan', 'Emma Watson'],
      },
    ],
    27: [
      {
        'time': '09:30 AM',
        'title': 'Code Review Session',
        'subtitle': 'Meeting • LOW Priority',
        'color': kAppColors.emeraldAccent,
        'assignees': ['David Miller', 'James Wilson'],
      },
      {
        'time': '02:00 PM',
        'title': 'Client Demo',
        'subtitle': 'Demo • HIGH Priority',
        'color': kAppColors.infoText,
        'assignees': ['Sarah Chen'],
      },
    ],
    30: [
      {
        'time': '11:00 AM',
        'title': 'Monthly Review',
        'subtitle': 'Meeting • HIGH Priority',
        'color': kAppColors.primaryColor,
        'assignees': ['Alex Morgan', 'Sarah Chen', 'David Miller'],
      },
    ],
  };

  String _getDayName(int day) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final date = DateTime(2026, 8, day);
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskListProvider);
    final viewMode = taskState.viewMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.accentNavy),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tasks',
          style: TextStyle(
            color: context.colors.accentNavy,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: context.colors.accentNavy),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: Tooltip(
        message: 'Create Task',
        child: FloatingActionButton(
          onPressed: () {
            context.push(RoutePaths.taskCreate);
          },
          backgroundColor: context.colors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add, color: Colors.white, size: context.icon4xl),
        ),
      ),
      body: Column(
        children: [
          _buildDateHeaderNavigator(viewMode),
          const SizedBox(height: 8),
          _buildSegmentedViewSelector(viewMode),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMetricsSummaryCard(),
                const SizedBox(height: 12),
                if (viewMode == 'month') _buildMonthCalendarCard(),
                if (viewMode == 'week') _buildWeekHeaderStrip(),
                const SizedBox(height: 12),
                if (viewMode == 'month' || viewMode == 'week')
                  _buildTaskListHeader(),
                const SizedBox(height: 8),
                if (viewMode == 'month' || viewMode == 'week')
                  ..._buildTaskItems()
                else
                  ..._buildTimeSlotTaskList(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Date Navigator Header ---
  Widget _buildDateHeaderNavigator(String viewMode) {
    String headerText = 'August 2026';
    if (viewMode == 'day') {
      headerText = 'Tue, 24 Aug 2026';
    } else if (viewMode == 'week') {
      headerText = '24 – 30 Aug 2026';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: context.colors.muted),
            onPressed: () {},
          ),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: context.iconLg,
                color: context.colors.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                headerText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primaryColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_right, color: context.colors.muted),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.tune_rounded, color: context.colors.muted),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Day / Week / Month Switcher ---
  Widget _buildSegmentedViewSelector(String viewMode) {
    final idx = CalendarViewMode.values
        .indexWhere((m) => m.name == viewMode)
        .clamp(0, CalendarViewMode.values.length - 1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        child: PillTabs(
          initialIndex: idx,
          tabs: const [
            PillTab(label: 'Day'),
            PillTab(label: 'Week'),
            PillTab(label: 'Month'),
          ],
          onPageChanged: (i) => ref
              .read(taskListProvider.notifier)
              .setViewMode(CalendarViewMode.values[i].name),
        ),
      ),
    );
  }

  // --- Metrics Summary Card ---
  Widget _buildMetricsSummaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricColumn(
              '6',
              'Total Tasks',
              context.colors.accentNavy,
            ),
          ),
          Expanded(
            child: _buildMetricColumn('2', 'Open', context.colors.primaryColor),
          ),
          Expanded(
            child: _buildMetricColumn('1', 'In Progress', context.colors.warn),
          ),
          Expanded(
            child: _buildMetricColumn(
              '1',
              'Completed',
              context.colors.emeraldAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.colors.muted),
        ),
      ],
    );
  }

  // --- Month Calendar Card ---
  Widget _buildMonthCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map(
                  (day) => Text(
                    day,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: context.colors.muted,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = (constraints.maxWidth - 48) / 7;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 31,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final dayNumber = index + 1;
                  final isSelected = dayNumber == _selectedDay;
                  final hasDots = [25, 27, 30].contains(dayNumber);

                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = dayNumber;
                        });
                      },
                      child: SizedBox(
                        width: cellSize.clamp(24.0, 40.0),
                        height: cellSize.clamp(24.0, 40.0),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: cellSize.clamp(24.0, 40.0),
                              height: cellSize.clamp(24.0, 40.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.colors.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : context.colors.accentNavy,
                                  ),
                                ),
                              ),
                            ),
                            if (hasDots)
                              Positioned(
                                bottom: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 3,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: context.colors.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Container(
                                      width: 3,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: context.colors.warn,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Week Header Strip ---
  Widget _buildWeekHeaderStrip() {
    final days = [
      {'day': 'MON', 'date': 24},
      {'day': 'TUE', 'date': 25},
      {'day': 'WED', 'date': 26},
      {'day': 'THU', 'date': 27},
      {'day': 'FRI', 'date': 28},
      {'day': 'SAT', 'date': 29},
      {'day': 'SUN', 'date': 30},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((d) {
          final dayNum = d['date'] as int;
          final isActive = dayNum == _selectedDay;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = dayNum;
              });
            },
            child: Column(
              children: [
                Text(
                  d['day'].toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: context.colors.muted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive
                        ? context.colors.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      dayNum.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? Colors.white
                            : context.colors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Task List View Header ---
  Widget _buildTaskListHeader() {
    final dayName = _getDayName(_selectedDay);
    final tasks = _tasksByDay[_selectedDay] ?? [];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$dayName, $_selectedDay August 2026',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: context.colors.primaryColor,
          ),
        ),
        Text(
          '${tasks.length} Tasks',
          style: TextStyle(fontSize: 12, color: context.colors.muted),
        ),
      ],
    );
  }

  List<Widget> _buildTaskItems() {
    final tasks = _tasksByDay[_selectedDay] ?? [];
    if (tasks.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'No tasks for this day',
              style: TextStyle(fontSize: 13, color: context.colors.muted),
            ),
          ),
        ),
      ];
    }
    return tasks.map((task) {
      return _buildSimpleTaskTile(
        task['time'] as String,
        task['title'] as String,
        task['subtitle'] as String,
        task['color'] as Color,
        task['assignees'] as List<String>,
      );
    }).toList();
  }

  Widget _buildSimpleTaskTile(
    String time,
    String title,
    String subtitle,
    Color dotColor,
    List<String> assignees,
  ) {
    return InkWell(
      onTap: () {
        context.push(RoutePaths.taskDetail.replaceFirst(':id', ''));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: dotColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            _buildStackedAssignees(assignees),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: context.iconLg,
              color: context.colors.border,
            ),
          ],
        ),
      ),
    );
  }

  // --- Day / Week Time-slot List View ---
  List<Widget> _buildTimeSlotTaskList() {
    return [
      _buildTimeSlotRow(
        '08:00 AM',
        _buildColoredTaskCard(
          'Overdue: Policy Follow-up',
          'All Day',
          'OVERDUE',
          context.colors.roseLight,
          context.colors.roseAccent,
          Colors.red,
          ['Alex Morgan', 'Sarah Chen'],
        ),
      ),
      _buildTimeSlotRow(
        '09:00 AM',
        _buildColoredTaskCard(
          'Meeting Appointment',
          '09:00 - 10:00',
          'OPEN',
          context.colors.infoLight,
          context.colors.infoBorder,
          context.colors.infoText,
          ['David Miller'],
        ),
      ),
      _buildTimeSlotRow('10:00 AM', null),
      _buildTimeSlotRow(
        '11:00 AM',
        _buildColoredTaskCard(
          'Customer Follow-up',
          '11:00 - 12:00',
          'INPROGRESS',
          context.colors.warningLight,
          context.colors.warn,
          context.colors.statusLead,
          ['Emma Watson', 'James Wilson'],
        ),
      ),
      _buildTimeSlotRow('12:00 PM', null),
      _buildTimeSlotRow('13:00 PM', null),
      _buildTimeSlotRow(
        '14:00 PM',
        _buildColoredTaskCard(
          'Policy Review',
          'All Day',
          'OVERDUE',
          context.colors.roseLight,
          context.colors.roseAccent,
          Colors.red,
          ['Sarah Chen'],
        ),
      ),
      _buildTimeSlotRow(
        '15:00 PM',
        _buildColoredTaskCard(
          'Submit Policy Document',
          '15:00 - 16:00',
          'COMPLETED',
          context.colors.successAccentLight,
          context.colors.successAccent,
          context.colors.successAccent,
          ['Alex Morgan'],
        ),
      ),
      _buildTimeSlotRow('16:00 PM', null),
    ];
  }

  Widget _buildTimeSlotRow(String time, Widget? card) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 65,
            child: Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: context.colors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child:
                card ??
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: context.colors.surfaceBg),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildColoredTaskCard(
    String title,
    String timeRange,
    String badgeText,
    Color bgColor,
    Color badgeBgColor,
    Color textColor,
    List<String> assignees,
  ) {
    return InkWell(
      onTap: () {
        context.push(RoutePaths.taskDetail.replaceFirst(':id', ''));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeRange,
                  style: TextStyle(fontSize: 11, color: context.colors.muted),
                ),
              ],
            ),
            Row(
              children: [
                _buildStackedAssignees(assignees),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Stacked Assignee Avatars Widget
  Widget _buildStackedAssignees(List<String> assignees) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < assignees.length && i < 3; i++)
            Align(
              widthFactor: 0.65,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: context.colors.primaryColor,
                  child: Text(
                    assignees[i][0],
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (assignees.length > 3)
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text(
                '+${assignees.length - 3}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: context.colors.muted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
