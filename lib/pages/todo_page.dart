import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:timely/components/todaypage_placeholder.dart';
import 'package:timely/model/project_model.dart';
import 'package:timely/model/todo_model.dart';
import 'package:timely/utils/addtodo_form.dart';
import 'package:timely/utils/todo_item.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:device_info_plus/device_info_plus.dart';
// 👈 Import this

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final box = Hive.box<Todo>('timelyBox');

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notificationStatus = await Permission.notification.status;
      final alarmStatus = await Permission.scheduleExactAlarm.status;

      if (!notificationStatus.isGranted || !alarmStatus.isGranted) {
        final notificationResult = await Permission.notification.request();
        final alarmResult = await Permission.scheduleExactAlarm.request();

        debugPrint("🔔 Notification permission result: $notificationResult");
        debugPrint("⏰ Exact alarm permission result: $alarmResult");

        if (!alarmResult.isGranted) {
          await openExactAlarmSettingsIfDenied(); // Guide user to settings
        }
      } else {
        debugPrint(
          "✅ Both notification and alarm permissions already granted.",
        );
      }
    });
  }

  Future<void> openExactAlarmSettingsIfDenied() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt >= 31) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          "Today",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: .8),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            sheetAnimationStyle: AnimationStyle(
              curve: Curves.decelerate,
              duration: Duration(milliseconds: 400),
            ),
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            context: context,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: const AddtodoForm(),
            ),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Todo>('timelyBox').listenable(),
          builder: (context, Box<Todo> box, _) {
            final today = DateTime.now();
            final todayDate = DateTime(today.year, today.month, today.day);

            final allTodos = box.values.toList();
            final incompleteTodos = allTodos.where((todo) {
              if (todo.isCompleted) return false;

              if (todo.dueDate == null) return true; // no due date = today

              final dueDate = DateTime(
                todo.dueDate!.year,
                todo.dueDate!.month,
                todo.dueDate!.day,
              );

              return dueDate.isBefore(todayDate) || dueDate == todayDate;
            }).toList();

            final overdueTodos = incompleteTodos.where((todo) {
              if (todo.dueDate == null) return false;

              final dueDate = DateTime(
                todo.dueDate!.year,
                todo.dueDate!.month,
                todo.dueDate!.day,
              );

              return dueDate.isBefore(todayDate);
            }).toList();

            final todayTodos = incompleteTodos.where((todo) {
              if (todo.dueDate == null) return true;

              final dueDate = DateTime(
                todo.dueDate!.year,
                todo.dueDate!.month,
                todo.dueDate!.day,
              );

              return dueDate == todayDate;
            }).toList();
            final todayLabel = DateFormat(
              'dd MMM yy',
            ).format(todayDate); // "07 Jul 25"

            final combinedList = [
              if (overdueTodos.isNotEmpty) {'header': 'Overdue'},
              ...overdueTodos,
              if (todayTodos.isNotEmpty) {'header': todayLabel},
              ...todayTodos,
            ];

            if (overdueTodos.isEmpty && todayTodos.isEmpty) {
              return TodaypagePlaceholder();
            }

            final projectBox = Hive.box<Project>('projectsBox');

            return ListView.builder(
              itemCount: combinedList.length,
              itemBuilder: (context, index) {
                final item = combinedList[index];

                if (item is Map && item.containsKey('header')) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      item['header'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                final todo = item as Todo;
                final key = box.keyAt(box.values.toList().indexOf(todo));
                final project = todo.projectId != null
                    ? projectBox.get(todo.projectId)
                    : null;

                return TodoItem(
                  todo: todo,
                  reminderTime: todo.reminderTime,
                  todoKey: key,
                  projectName: project?.name ?? 'Inbox',
                  projectColor: project?.color != null
                      ? Color(project!.color!)
                      : Colors.black54,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
