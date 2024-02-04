import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final void Function(int)? onTap;
  final int currentIndex;

  const BottomNavBar({super.key, this.onTap, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).textTheme.displayLarge!.color,
      unselectedItemColor: Theme.of(context).textTheme.bodyLarge!.color,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          label: 'Home',
          icon: Icon(Icons.home),
        ),
        BottomNavigationBarItem(label: 'Suche', icon: Icon(Icons.search)),
        BottomNavigationBarItem(label: 'Profil', icon: Icon(Icons.person)),
      ],
    );
  }
}
