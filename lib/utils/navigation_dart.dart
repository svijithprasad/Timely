import 'package:flutter/material.dart';
import 'package:timely/pages/browse_page.dart';
import 'package:timely/pages/search_page.dart';
import 'package:timely/pages/todo_page.dart';
import 'package:timely/pages/upcoming_page.dart';

class NavigationDart extends StatefulWidget {
  const NavigationDart({super.key});

  @override
  State<NavigationDart> createState() => _FirstPageState();
}

class _FirstPageState extends State<NavigationDart> {
  final List _pages = [TodoPage(), UpcomingPage(), SearchPage(), BrowsePage()];

  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
            states,
          ) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Colors.red, // Selected label color
                fontWeight: FontWeight.w600,
                fontSize: 13
              );
            }
            return const TextStyle(
              color: Colors.black54, // Unselected label color
              fontWeight: FontWeight.w400,
              fontSize: 13
            );
          }),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: NavigationBar(
            indicatorColor: const Color.fromARGB(255, 255, 227, 231),
            backgroundColor: Colors.white,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _navigateBottomBar,
            destinations: const [
              NavigationDestination(
                selectedIcon: Icon(Icons.inbox_rounded, color: Colors.red),
                icon: Icon(Icons.inbox_outlined),
                label: "Today",
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.upcoming_rounded, color: Colors.red),
                icon: Icon(Icons.upcoming_outlined),
                label: "Upcoming",
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.search_rounded, color: Colors.red),
                icon: Icon(Icons.search_rounded),
                label: "Search",
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.menu_open_rounded, color: Colors.red),
                icon: Icon(Icons.menu_open_rounded),
                label: "Browse",
              ),
            ],
          ),
          body: Center(child: _pages[_selectedIndex]),
        ),
      ),
    );
  }
}
