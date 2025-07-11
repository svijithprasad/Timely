import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timely/model/project_model.dart';
import 'package:timely/model/todo_model.dart';
import 'package:timely/pages/completed_tasks.dart';
import 'package:timely/pages/settings_page.dart';
import 'package:timely/utils/navigation_dart.dart';
import 'package:timely/utils/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TodoAdapter());
    Hive.registerAdapter(ProjectAdapter());
  }

  await Hive.openBox<Todo>('timelyBox');
  await Hive.openBox<Project>('projectsBox');

  await initializeNotifications();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NavigationDart(),
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/completedtasks': (context) => const CompletedTasks(),
      },
    );
  }
}
