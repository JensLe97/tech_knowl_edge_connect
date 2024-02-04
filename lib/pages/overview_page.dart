import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:safe_area_insets/safe_area_insets.dart';
import 'package:tech_knowl_edge_connect/components/bottom_navigation_bar.dart';
import 'package:tech_knowl_edge_connect/pages/home/home_page.dart';
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
      bottomNavigationBar: kIsWeb
          ? WebSafeAreaInsets(
              child: BottomNavBar(onTap: _onTap, currentIndex: _currentIndex),
            )
          : BottomNavBar(onTap: _onTap, currentIndex: _currentIndex),
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
}
