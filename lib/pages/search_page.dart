import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timely/components/emptysearch_placeholder.dart';
import 'package:timely/model/project_model.dart';
import 'package:timely/model/todo_model.dart';
import 'package:timely/utils/todo_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  String query = "";

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        query = searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoBox = Hive.box<Todo>('timelyBox');
    final projectBox = Hive.box<Project>('projectsBox');

    final List<Todo> allIncompleteTasks = todoBox.values
        .where((todo) => !todo.isCompleted)
        .toList();

    final List<Todo> filteredTasks = allIncompleteTasks.where((todo) {
      return todo.title.toLowerCase().contains(query) ||
          todo.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          "Search",
          style: TextStyle(
            fontWeight: FontWeight.w600,
             color: Colors.black.withValues(alpha: .8),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search tasks...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Results
            Expanded(
              child: query.isEmpty
                  ? const EmptySearchPlaceholder()
                  : filteredTasks.isEmpty
                  ? const Center(
                      child: Text(
                        "No matching tasks found",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final todo = filteredTasks[index];
                        final key = todoBox.keyAt(
                          todoBox.values.toList().indexOf(todo),
                        );
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
            ),
          ],
        ),
      ),
    );
  }
}
