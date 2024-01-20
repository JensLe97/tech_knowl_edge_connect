import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/pages/profile/profile_page.dart';
import 'package:tech_knowl_edge_connect/pages/search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  final user = FirebaseAuth.instance.currentUser!;
  final List<Widget> _tabs = const <Widget>[
    Center(child: Text('Home')),
    SearchPage(),
    Center(child: Text('Bibliothek')),
    ProfilePage(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: IndexedStack(children: [
        _tabs.elementAt(_currentIndex),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).textTheme.displayLarge!.color,
        unselectedItemColor: Theme.of(context).textTheme.bodyLarge!.color,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(label: 'Suche', icon: Icon(Icons.search)),
          BottomNavigationBarItem(
              label: 'Bibliothek', icon: Icon(Icons.library_books)),
          BottomNavigationBarItem(label: 'Profil', icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
}
