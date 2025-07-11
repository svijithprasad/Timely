import 'package:flutter/material.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Browse",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: .8),
          ),
        ),
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
            icon: const Icon(Icons.settings, color: Colors.redAccent, size: 27),
          ),
        ],
        actionsPadding: const EdgeInsets.only(right: 4),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.checklist_rounded, color: Colors.green),
              title: const Text("Completed Tasks"),
              subtitle: const Text("View your completed task history"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/completedtasks');
              },
            ),
            const Divider(thickness: 1),
          ],
        ),
      ),
    );
  }
}
