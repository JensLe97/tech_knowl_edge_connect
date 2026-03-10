import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/pages/admin/content_admin_page.dart';
import 'package:tech_knowl_edge_connect/pages/profile/settings.dart';

class MenuItems extends StatelessWidget {
  final bool isAdmin;

  const MenuItems({Key? key, this.isAdmin = false}) : super(key: key);

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
        if (isAdmin)
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ContentAdminPage(),
                ),
              );
            },
          ),
        // ListTile(
        //   leading: const Icon(Icons.subject),
        //   title: const Text('Fächer'),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
        // ListTile(
        //   leading: const Icon(Icons.language),
        //   title: const Text('Sprache'),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
        // ListTile(
        //   leading: const Icon(Icons.people),
        //   title: const Text('Nutzerart'),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
        // ListTile(
        //   leading: const Icon(Icons.school),
        //   title: const Text('Schulform'),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
        // ListTile(
        //   leading: const Icon(Icons.grade),
        //   title: const Text('Klassenstufe'),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ],
    );
  }
}
