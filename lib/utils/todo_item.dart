import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:timely/model/todo_model.dart';
import 'package:timely/utils/addtodo_form.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:hive/hive.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timely/utils/notification_helper.dart';
import 'package:intl/intl.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final String? projectName;
  final DateTime? reminderTime;
  final Color? projectColor;
  final dynamic todoKey;

  const TodoItem({
    super.key,
    required this.todo,
    this.projectColor,
    this.projectName,
    this.reminderTime,
    required this.todoKey,
  });

  Color getPriorityColor(int? priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void checkTodo(BuildContext context) async {
    final box = Hive.box<Todo>('timelyBox');
    final isNowCompleted = !todo.isCompleted;

    final updated = Todo(
      title: todo.title,
      description: todo.description,
      dueDate: todo.dueDate,
      priority: todo.priority,
      reminderTime: todo.reminderTime,
      isCompleted: isNowCompleted,
      projectId: todo.projectId,
    );

    await box.put(todoKey, updated);

    // Cancel or schedule notifications based on state
    if (todo.reminderTime != null) {
      if (isNowCompleted) {
        await cancelNotification(todoKey.hashCode);
      } else {
        await scheduleNotification(
          id: todoKey.hashCode,
          title: todo.title,
          body: todo.description,
          scheduledTime: todo.reminderTime!,
        );
      }
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowCompleted
              ? "Task marked as completed"
              : "Task marked as incomplete",
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () async {
            final restored = updated..isCompleted = !isNowCompleted;
            await box.put(todoKey, restored);

            if (todo.reminderTime != null) {
              if (isNowCompleted) {
                // Undoing a complete: reschedule
                await scheduleNotification(
                  id: todoKey.hashCode,
                  title: todo.title,
                  body: todo.description,
                  scheduledTime: todo.reminderTime!,
                );
              } else {
                // Undoing an incomplete: cancel
                await cancelNotification(todoKey.hashCode);
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> openCalendar(BuildContext context) async {
    DateTime? selectedDate;
    final calendarController = CleanCalendarController(
      minDate: DateTime.now().subtract(const Duration(days: 1)),
      maxDate: DateTime.now().add(const Duration(days: 365)),
      initialDateSelected: todo.dueDate ?? DateTime.now(),
      rangeMode: false,
      onDayTapped: (date) {
        selectedDate = date;
      },
    );

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => Stack(
        alignment: Alignment.bottomRight,
        children: [
          ScrollableCleanCalendar(
            calendarMainAxisSpacing: 6,
            calendarCrossAxisSpacing: 6,
            dayTextStyle: const TextStyle(fontWeight: FontWeight.w400),
            dayDisableBackgroundColor: Colors.black38,
            daySelectedBackgroundColor: Colors.red,
            dayBackgroundColor: Colors.white,
            calendarController: calendarController,
            layout: Layout.BEAUTY,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 25, bottom: 30),
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context, selectedDate),
              backgroundColor: Colors.red,
              child: const Icon(Icons.check_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (picked != null) {
      final box = Hive.box<Todo>('timelyBox');
      final updated = Todo(
        title: todo.title,
        description: todo.description,
        dueDate: picked,
        priority: todo.priority,
        reminderTime: todo.reminderTime,
        isCompleted: todo.isCompleted,
        projectId: todo.projectId,
      );
      await box.put(todoKey, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = getPriorityColor(todo.priority);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.8),
        ),
      ),

      child: Slidable(
        key: ValueKey(todoKey),
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.2,
          children: [
            CustomSlidableAction(
              onPressed: (_) => openCalendar(context),
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              child: Container(
                height: 48,
                width: 48,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade500,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 6,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.2,
          children: [
            CustomSlidableAction(
              onPressed: (_) async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text("Delete Task?"),
                    content: const Text(
                      "Are you sure you want to delete this task?",
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true) {
                  final box = Hive.box<Todo>('timelyBox');
                  await box.delete(todoKey);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Task deleted")));
                }
              },
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              child: Container(
                height: 48,
                width: 48,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade100,
                      blurRadius: 6,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.white,
              context: context,
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: AddtodoForm(
                  existingTodo: todo,
                  index: null,
                  todoKey: todoKey,
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoundCheckBox(
                      isChecked: todo.isCompleted,
                      onTap: (selected) async {
                        await Future.delayed(const Duration(milliseconds: 200));
                        checkTodo(context);
                      },
                      size: 25,
                      uncheckedColor: priorityColor.withValues(alpha: .1),
                      checkedColor: priorityColor,
                      checkedWidget: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      border: Border.all(width: 2, color: priorityColor),
                      animationDuration: const Duration(milliseconds: 100),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (todo.description.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              todo.description,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Reminder
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.alarm,
                                      size: 14,
                                      color: Color.fromARGB(255, 34, 34, 175),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      reminderTime != null
                                          ? DateFormat(
                                              'd MMM · h:mm a',
                                            ).format(reminderTime!)
                                          : '-- -- --',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color.fromARGB(255, 34, 34, 175),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                // Project
                                Row(
                                  children: [
                                    Icon(
                                      projectName == 'Inbox'
                                          ? Icons.all_inbox
                                          : Icons.list_alt_rounded,
                                      size: 14,
                                      color: projectColor ?? Colors.black38,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      projectName ?? 'Inbox',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: projectColor ?? Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
