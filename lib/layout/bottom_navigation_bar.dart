import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.storage), // Ensure home icon is set here
          label: 'Storage',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note),
          label: 'Live Music',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.design_services),
        //   label: 'Service',
        // ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.settings),
        //   label: 'Settings',
        // ),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    );
  }
}
