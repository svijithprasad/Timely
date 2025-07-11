import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timely/model/todo_model.dart';
import 'package:timely/model/project_model.dart';
import 'package:timely/utils/todo_item.dart';

class CompletedTasks extends StatelessWidget {
  const CompletedTasks({super.key});

  @override
  Widget build(BuildContext context) {
    final todoBox = Hive.box<Todo>('timelyBox');
    final projectBox = Hive.box<Project>('projectsBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Completed Tasks",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: ValueListenableBuilder(
        valueListenable: todoBox.listenable(),
        builder: (context, Box<Todo> box, _) {
          final completedTodos = box.values
              .where((todo) => todo.isCompleted)
              .toList()
            ..sort((a, b) => b.dueDate?.compareTo(a.dueDate ?? DateTime(2000)) ?? 0);

          if (completedTodos.isEmpty) {
            return const Center(
              child: Text(
                "You haven’t completed any tasks yet!",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: completedTodos.length,
            itemBuilder: (context, index) {
              final todo = completedTodos[index];
              final key = box.keyAt(box.values.toList().indexOf(todo));
              final project = todo.projectId != null
                  ? projectBox.get(todo.projectId)
                  : null;

              return Opacity(
                opacity: 0.6,
                child: TodoItem(
                  todo: todo,
                  todoKey: key,
                  reminderTime: todo.reminderTime,
                  projectName: project?.name ?? 'Inbox',
                  projectColor: project?.color != null
                      ? Color(project!.color!)
                      : Colors.black54,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
