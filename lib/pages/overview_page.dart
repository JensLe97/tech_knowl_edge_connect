import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/pages/chats/chat_overview_page.dart';
import 'package:tech_knowl_edge_connect/pages/home/home_page.dart';
import 'package:tech_knowl_edge_connect/pages/feed/learning_feed.dart';
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
    LearningFeedPage(),
    ChatOverviewPage(),
    ProfilePage(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildNavItem(BuildContext context,
      {required int index,
      required IconData icon,
      required IconData activeIcon,
      required String label}) {
    final isSelected = _currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withAlpha(188)
              : colorScheme.primaryContainer.withAlpha(0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onTap(index),
              borderRadius: BorderRadius.circular(16),
              hoverColor: colorScheme.primaryContainer.withAlpha(40),
              splashColor: colorScheme.primaryContainer.withAlpha(0),
              highlightColor: colorScheme.primaryContainer.withAlpha(60),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? activeIcon : icon,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color:
                  Theme.of(context).colorScheme.outlineVariant.withAlpha(128),
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context,
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Home'),
                  _buildNavItem(context,
                      index: 1,
                      icon: Icons.search_outlined,
                      activeIcon: Icons.search,
                      label: 'Suche'),
                  _buildNavItem(context,
                      index: 2,
                      icon: Icons.dynamic_feed_outlined,
                      activeIcon: Icons.dynamic_feed,
                      label: 'Feed'),
                  _buildNavItem(context,
                      index: 3,
                      icon: Icons.chat_bubble_outline,
                      activeIcon: Icons.chat,
                      label: 'Chats'),
                  _buildNavItem(context,
                      index: 4,
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profil'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
