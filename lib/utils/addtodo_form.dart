import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:timely/model/project_model.dart';
import 'package:timely/model/todo_model.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:timely/utils/notification_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AddtodoForm extends StatefulWidget {
  final Todo? existingTodo;
  final int? index;
  final dynamic todoKey;

  const AddtodoForm({super.key, this.existingTodo, this.index, this.todoKey});

  @override
  State<AddtodoForm> createState() => _AddtodoFormState();
}

class _AddtodoFormState extends State<AddtodoForm> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  int projectColor = Colors.black.toARGB32();
  bool isButtonEnabled = false;
  String selectedProject = "Inbox";
  DateTime? selectedDate;
  int selectedPriority = 2;
  DateTime? selectedReminderTime;
  int? selectedProjectId;

  bool get isEdit => widget.existingTodo != null;

  late CleanCalendarController calendarController;

  void _showAddProjectBottomSheet(
    BuildContext context,
    void Function(void Function()) setModalState,
  ) {
    final controller = TextEditingController();
    int selectedColor = const Color.fromARGB(
      255,
      33,
      150,
      243,
    ).toARGB32(); // default color

    final colorOptions = [
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.pink,
      Colors.grey,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setSheetState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "New Project",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Project name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Select a color",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: colorOptions
                      .map(
                        (color) => GestureDetector(
                          onTap: () => setSheetState(() {
                            selectedColor = color.toARGB32();
                          }),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color.toARGB32()
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add Project"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      final name = controller.text.trim();
                      if (name.isNotEmpty) {
                        final box = Hive.box<Project>('projectsBox');
                        await box.add(
                          Project(name: name, color: selectedColor),
                        );
                        setModalState(() {}); // Refresh parent modal if needed
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Project name is required"),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProjectSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final box = Hive.box<Project>('projectsBox');
        final List<Project> projects = box.values.toList();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text(
                    "Select Project",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () =>
                        _showAddProjectBottomSheet(context, setModalState),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text("Inbox"),
                  leading: const Icon(
                    Icons.inbox,
                    size: 20,
                    color: Colors.black54,
                  ),
                  onTap: () {
                    setState(() {
                      selectedProject = "Inbox";
                      selectedProjectId = null;
                      projectColor = Colors.black.toARGB32();
                    });
                    Navigator.pop(context);
                  },
                ),
                ...projects.map(
                  (project) => ListTile(
                    title: Text(project.name),
                    leading: Icon(
                      Icons.list_alt_rounded,
                      size: 16,
                      color: Color(project.color ?? 0xFF000000),
                    ),
                    onTap: () {
                      setState(() {
                        selectedProject = project.name;
                        selectedProjectId = project.key as int;
                        projectColor = project.color ?? Colors.black.toARGB32();
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final todo = widget.existingTodo!;
      titleController.text = todo.title;
      descriptionController.text = todo.description;
      selectedDate = todo.dueDate;
      selectedPriority = todo.priority ?? 2;
      selectedReminderTime = todo.reminderTime;
      selectedProjectId = todo.projectId;

      if (selectedProjectId != null) {
        final box = Hive.box<Project>('projectsBox');
        final project = box.get(selectedProjectId);
        if (project != null) {
          selectedProject = project.name;
          projectColor = project.color ?? Colors.black.toARGB32();
        }
      }
    }

    calendarController = CleanCalendarController(
      minDate: DateTime.now(),
      maxDate: DateTime.now().add(const Duration(days: 365)),
      initialDateSelected: selectedDate ?? DateTime.now(),
      rangeMode: false,
      onDayTapped: (date) {
        setState(() {
          selectedDate = date;
        });
      },
    );

    titleController.addListener(() {
      setState(() {
        isButtonEnabled = titleController.text.trim().isNotEmpty;
      });
    });
  }

  String getSmartDateLabel(DateTime? date) {
    if (date == null) return "Today";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    final diff = selected.difference(today).inDays;

    if (diff == 0) return "Today";
    if (diff == 1) return "Tomorrow";

    // Format like "29 Jun"
    return DateFormat('d MMM').format(selected);
  }

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

  // void addOrUpdateTask() async {
  //   final box = Hive.box<Todo>('timelyBox');

  //   final newTodo = Todo(
  //     title: titleController.text.trim(),
  //     description: descriptionController.text.trim(),
  //     dueDate: selectedDate ?? DateTime.now(),
  //     priority: selectedPriority,
  //     reminderTime: selectedReminderTime,
  //     projectId: selectedProjectId,
  //   );

  //   if (isEdit && widget.todoKey != null) {
  //     await box.put(widget.todoKey, newTodo);
  //   } else {
  //     await box.add(newTodo);
  //   }

  //   Navigator.pop(context, true); // Return true to refresh
  // }

  void addOrUpdateTask() async {
    final box = Hive.box<Todo>('timelyBox');

    final newTodo = Todo(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      dueDate: selectedDate ?? DateTime.now(),
      priority: selectedPriority,
      reminderTime: selectedReminderTime,
      projectId: selectedProjectId,
    );

    int todoId;

    if (isEdit && widget.todoKey != null) {
      todoId = widget.todoKey as int;

      // Cancel old notification if any
      await cancelNotification(todoId);

      await box.put(todoId, newTodo);
    } else {
      todoId = await box.add(newTodo); // returns the new key
    }

    // Schedule new notification if reminder is set
    if (selectedReminderTime != null) {
      await scheduleNotification(
        id: todoId,
        title: newTodo.title,
        body: newTodo.description.isNotEmpty
            ? newTodo.description
            : "You have a task reminder",
        scheduledTime: selectedReminderTime!,
      );
    }

    Navigator.pop(context, true); // Return true to refresh
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              cursorColor: Colors.red,
              decoration: const InputDecoration(
                hintText: "Task name",
                hintStyle: TextStyle(color: Colors.black45),
                border: InputBorder.none,
              ),
            ),
            TextField(
              controller: descriptionController,
              style: const TextStyle(fontSize: 16),
              maxLines: null,
              cursorColor: Colors.red,
              decoration: const InputDecoration(
                hintText: "Description",
                hintStyle: TextStyle(color: Colors.black45),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 10),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FormButton(
                    icon: Icons.date_range_rounded,
                    label: getSmartDateLabel(selectedDate),
                    color: Colors.deepPurple,
                    onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.white,
                        context: context,
                        builder: (context) => Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ScrollableCleanCalendar(
                              calendarMainAxisSpacing: 6,
                              calendarCrossAxisSpacing: 6,
                              dayTextStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                              ),
                              dayDisableBackgroundColor: Colors.black38,
                              daySelectedBackgroundColor: Colors.red,
                              dayBackgroundColor: Colors.white,
                              calendarController: calendarController,
                              layout: Layout.BEAUTY,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 25,
                                bottom: 30,
                              ),
                              child: FloatingActionButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                backgroundColor: Colors.red,
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  _FormButton(
                    icon: Icons.outlined_flag_rounded,
                    label: "Priority",
                    color: getPriorityColor(selectedPriority),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: const Text(
                              "Select Priority",
                              style: TextStyle(),
                            ),
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.flag,
                                  color: Colors.red,
                                ),
                                title: const Text(
                                  "High",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedPriority = 1;
                                  });
                                  Navigator.pop(context);
                                },
                              ),

                              ListTile(
                                leading: const Icon(
                                  Icons.flag,
                                  color: Colors.orange,
                                ),
                                title: const Text(
                                  "Medium",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedPriority = 2;
                                  });
                                  Navigator.pop(context);
                                },
                              ),

                              ListTile(
                                leading: const Icon(
                                  Icons.flag,
                                  color: Colors.green,
                                ),
                                title: const Text(
                                  "Low",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedPriority = 3;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  _FormButton(
                    icon: Icons.alarm,
                    label: selectedReminderTime != null
                        ? DateFormat(
                            'd MMM • h:mm a',
                          ).format(selectedReminderTime!)
                        : "Reminders",
                    color: const Color(0xff272757),
                    onPressed: () async {
                      final plugin = FlutterLocalNotificationsPlugin();
                      final androidPlugin = plugin
                          .resolvePlatformSpecificImplementation<
                            AndroidFlutterLocalNotificationsPlugin
                          >();

                      final hasNotificationPerms =
                          await androidPlugin?.areNotificationsEnabled() ??
                          false;

                      if (!hasNotificationPerms) {
                        final notificationGranted =
                            await androidPlugin
                                ?.requestNotificationsPermission() ??
                            false;

                        if (!notificationGranted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Notification permission denied."),
                            ),
                          );

                          return;
                        }
                      }

                      final alarmGranted =
                          await androidPlugin?.requestExactAlarmsPermission() ??
                          false;

                      if (!alarmGranted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Exact alarm permission denied. Cannot schedule reminders.",
                            ),
                          ),
                        );
                        return;
                      }

                      // Now show date and time pickers
                      DateTime now = DateTime.now();

                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedReminderTime ?? now,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 365)),
                      );

                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            selectedReminderTime ?? now,
                          ),
                        );

                        if (pickedTime != null) {
                          setState(() {
                            selectedReminderTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),

                  // _FormButton(
                  //   icon: Icons.more_horiz_rounded,
                  //   label: "",
                  //   color: Colors.red,
                  //   onPressed: () {},
                  // ),
                ],
              ),
            ),
            const Divider(color: Colors.black12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _showProjectSelector(context),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 20,
                        color: Color(projectColor),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedProject,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(projectColor),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.black54),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: isButtonEnabled ? addOrUpdateTask : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isButtonEnabled
                          ? Colors.red
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _FormButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: color),
        label: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          side: const BorderSide(color: Colors.black12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
