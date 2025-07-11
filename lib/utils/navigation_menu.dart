import 'package:flutter/material.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(destinations: [
        NavigationDestination( icon: Icon(Icons.inbox_rounded), label: "Today",),
        NavigationDestination( icon: Icon(Icons.upcoming_rounded), label: "Upcoming",),
        NavigationDestination( icon: Icon(Icons.search_rounded), label: "Search",),
        NavigationDestination( icon: Icon(Icons.menu_open_rounded), label: "Browse",),
      ],),
    );
  }
}