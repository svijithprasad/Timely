import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final granted =
        await plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        false;

    setState(() => _notificationsEnabled = granted);
  }

  Future<void> _toggleNotifications(bool enabled) async {
    final plugin = FlutterLocalNotificationsPlugin();
    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (enabled) {
      final notificationGranted =
          await androidPlugin?.requestNotificationsPermission() ?? false;

      if (!notificationGranted) {
        setState(() => _notificationsEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification permission denied.")),
        );
        return;
      }

      final alarmGranted =
          await androidPlugin?.requestExactAlarmsPermission() ?? false;

      if (!alarmGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Exact alarm permission denied. Some reminders may be delayed.",
            ),
          ),
        );
      }

      setState(() => _notificationsEnabled = true);
    } else {
      setState(() => _notificationsEnabled = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "To fully disable, turn off notifications in system settings.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: .8),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          
          SwitchListTile(
            activeColor: Colors.red,
            activeTrackColor: Colors.red[100],
            secondary: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.redAccent,
            ),
            title: const Text("Enable Notifications"),
            subtitle: const Text("Receive reminders for your tasks"),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          const Divider(thickness: 1),
        ],
      ),
    );
  }
}
