import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/pages/profile/settings.dart';

class MenuItems extends StatelessWidget {
  const MenuItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Einstellungen'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.subject),
          title: const Text('Fächer'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Sprache'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Nutzerart'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.school),
          title: const Text('Schulform'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.grade),
          title: const Text('Klassenstufe'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
