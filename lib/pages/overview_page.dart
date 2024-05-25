import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/pages/chats/chat_overview_page.dart';
import 'package:tech_knowl_edge_connect/pages/home/home_page.dart';
import 'package:tech_knowl_edge_connect/pages/ideas/ideas_page.dart';
import 'package:tech_knowl_edge_connect/pages/profile/profile_page.dart';
import 'package:tech_knowl_edge_connect/pages/search/search_page.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  int _currentIndex = 0;
  final user = FirebaseAuth.instance.currentUser!;
  final List<Widget> _tabs = const <Widget>[
    HomePage(),
    SearchPage(),
    IdeasPage(),
    ChatOverviewPage(),
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
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.inversePrimary,
        child: BottomNavigationBar(
          elevation: 0,
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
                label: 'Ideen', icon: Icon(Icons.movie_filter)),
            BottomNavigationBarItem(label: 'Chats', icon: Icon(Icons.chat)),
            BottomNavigationBarItem(label: 'Profil', icon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
}
