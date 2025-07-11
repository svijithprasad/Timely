// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavBar extends StatelessWidget {
  void Function(int)? onTabChange;
  NavBar({super.key, required this.onTabChange});

  @override
  Widget build(context) {
    return Container(
      color: Colors.black,
      child: GNav(
        backgroundColor: Colors.white,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        gap: 0,
        color: Color(0xff969696),
        activeColor: Color(0xffE44332),
        tabBorderRadius: 10,
        onTabChange: (value) => onTabChange!(value),

        tabs: [
          GButton(
            icon: Icons.inbox_rounded, // required dummy icon
            duration: Duration(microseconds: 100),
            iconSize: 23,
            
            text: "Today",
            backgroundColor: const Color(0xFFE44332).withValues(alpha: .1),
            gap: 8,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
          ),

          GButton(
            duration: Duration(microseconds: 100),
            iconSize: 23,
            icon: Icons.upcoming_rounded,
            text: "Upcoming",
            backgroundColor: Color(0xFFE44332).withValues(alpha: .1),
            gap: 8,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
          ),
          GButton(
            duration: Duration(microseconds: 100),
            iconSize: 23,
            icon: Icons.search_rounded,
            text: "Search",
            backgroundColor: Color(0xFFE44332).withValues(alpha: .1),
            gap: 8,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
          ),
          GButton(
            duration: Duration(microseconds: 100),
            iconSize: 23,
            icon: Icons.list_alt_rounded,
            text: "Browse",
            backgroundColor: Color(0xFFE44332).withValues(alpha: .1),
            gap: 8,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }
}
