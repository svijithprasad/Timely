import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime? dueDate;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  int? priority; // 1 = High, 2 = Medium, 3 = Low

  @HiveField(5)
  DateTime? reminderTime;

  @HiveField(6)
  int? projectId; // Foreign key: Hive key of the Project

  Todo({
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = 2,
    this.reminderTime,
    this.projectId,
  });
}
