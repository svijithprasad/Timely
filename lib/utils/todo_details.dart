import 'package:flutter/material.dart';
import 'package:timely/model/todo_model.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class TodoDetails extends StatefulWidget {
  final Todo todo;

  const TodoDetails({super.key, required this.todo});

  @override
  State<TodoDetails> createState() => _TodoDetailsState();
}

class _TodoDetailsState extends State<TodoDetails> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  late bool isCompleted;
  late Todo todo;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.todo.isCompleted;
    todo = widget.todo;
    titleController = TextEditingController(text: widget.todo.title);
    descriptionController = TextEditingController(
      text: widget.todo.description,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.all_inbox_rounded, color: Colors.red[500]),
                    const SizedBox(width: 6),
                    Row(
                      children: [
                        Text(
                          "Inbox",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(Icons.more_vert_rounded, color: Colors.black54),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundCheckBox(
                  isChecked: todo.isCompleted,
                  onTap: (selected) {
                    setState(() {
                      isCompleted = selected ?? false;
                    });
                  },
                  size: 25,
                  
                  uncheckedColor: Colors.white,
                  checkedColor: getPriorityColor(todo.priority),
                  checkedWidget: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                  ),
                  border: Border.all(
                    width: 1,
                    color: getPriorityColor(todo.priority),
                  ),
                  animationDuration: const Duration(milliseconds: 100),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: titleController,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Task Title',
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_note_rounded, size: 35),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: descriptionController,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Description',
                    ),
                    maxLines: null,
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
