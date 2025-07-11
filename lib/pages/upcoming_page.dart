import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timely/components/empty_placeholder.dart';
import 'package:timely/model/project_model.dart';
import 'package:timely/model/todo_model.dart';
import 'package:timely/utils/todo_item.dart';

class UpcomingPage extends StatefulWidget {
  const UpcomingPage({super.key});

  @override
  State<UpcomingPage> createState() => _UpcomingPageState();
}

class _UpcomingPageState extends State<UpcomingPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isExpanded = false;

  late final Box<Todo> todoBox;

  @override
  void initState() {
    super.initState();
    todoBox = Hive.box<Todo>('timelyBox');
    _selectedDay = _focusedDay;
  }

  List<Todo> _getTasksForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    return todoBox.values
        .where(
          (todo) =>
              !todo.isCompleted &&
              todo.dueDate != null &&
              DateTime(
                    todo.dueDate!.year,
                    todo.dueDate!.month,
                    todo.dueDate!.day,
                  ) ==
                  dateOnly,
        )
        .toList();
  }

  Map<DateTime, List<Todo>> _getTaskEvents() {
    Map<DateTime, List<Todo>> events = {};
    for (var todo in todoBox.values) {
      if (todo.dueDate != null && !todo.isCompleted) {
        final dateOnly = DateTime(
          todo.dueDate!.year,
          todo.dueDate!.month,
          todo.dueDate!.day,
        );
        events.putIfAbsent(dateOnly, () => []).add(todo);
      }
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final taskEvents = _getTaskEvents();
    final tasksToday = _getTasksForDay(_selectedDay!);
    debugPrint(tasksToday.toString());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Upcoming",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: .8),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar<Todo>(
            focusedDay: _focusedDay,
            pageAnimationEnabled: true,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _isExpanded
                ? CalendarFormat.month
                : CalendarFormat.week,
            eventLoader: (day) =>
                taskEvents[DateTime(day.year, day.month, day.day)] ?? [],
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _isExpanded = format == CalendarFormat.month;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              formatButtonDecoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.red),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.red),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.red.withValues(alpha: .9),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),
              defaultTextStyle: const TextStyle(color: Colors.black87),
              weekendTextStyle: const TextStyle(color: Colors.red),
              todayTextStyle: const TextStyle(color: Colors.redAccent),
              outsideDaysVisible: false,
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              weekendStyle: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Todo>('timelyBox').listenable(),
              builder: (context, Box<Todo> box, _) {
                final projectBox = Hive.box<Project>('projectsBox');
                final selectedDate = DateTime(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                );

                final tasksForSelectedDay = box.values.where((todo) {
                  if (todo.isCompleted || todo.dueDate == null) return false;

                  final dueDate = DateTime(
                    todo.dueDate!.year,
                    todo.dueDate!.month,
                    todo.dueDate!.day,
                  );

                  return dueDate == selectedDate;
                }).toList();

                if (tasksForSelectedDay.isEmpty) {
                  return const EmptyPlaceholder();
                }

                return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: ListView.builder(
                    itemCount: tasksForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final todo = tasksForSelectedDay[index];
                      final key = box.keyAt(box.values.toList().indexOf(todo));

                      final project = todo.projectId != null
                          ? projectBox.get(todo.projectId)
                          : null;

                      return TodoItem(
                        todo: todo,
                        todoKey: key,
                        reminderTime: todo.reminderTime,
                        projectName: project?.name ?? 'Inbox',
                        projectColor: project?.color != null
                            ? Color(project!.color!)
                            : Colors.black54,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
