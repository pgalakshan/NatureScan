import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E4D2B),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
        BottomNavigationBarItem(
            icon: Icon(Icons.library_books), label: 'Library'),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onTap: (i) {
        const routes = [
          '/home',
          '/camera',
          '/library',
          '/favorites',
          '/settings',
        ];
        if (i != currentIndex) {
          Navigator.pushReplacementNamed(context, routes[i]);
        }
      },
    );
  }
}
