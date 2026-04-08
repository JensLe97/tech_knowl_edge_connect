import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/pages/profile/account_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final String helpAndSupport =
      "https://jenslemke.com/tech-knowl-edge-connect#support";
  final String privacyPolicy =
      "https://jenslemke.com/tech-knowl-edge-connect#privacy";
  final String disclosure =
      "https://jenslemke.com/tech-knowl-edge-connect#imprint";
  final String termsAndConditions =
      "https://jenslemke.com/tech-knowl-edge-connect";
  final String aboutThisApp =
      "https://jenslemke.com/tech-knowl-edge-connect#about";

  @override
  void initState() {
    super.initState();
  }

  Future<void> openUrl(String url) async {
    final toLaunch = Uri.parse(url);
    if (!await launchUrl(toLaunch)) {
      throw Exception('Could not launch $toLaunch');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Einstellungen'),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.account_circle),
            trailing: Icon(Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: const Text('Konto'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AccountPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            trailing: Icon(Icons.open_in_new,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: const Text('Hilfe & Support'),
            onTap: () => openUrl(helpAndSupport),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.paperclip),
            trailing: Icon(Icons.open_in_new,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: const Text('Impressum'),
            onTap: () => openUrl(disclosure),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.userShield),
            trailing: Icon(Icons.open_in_new,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: const Text('Datenschutz'),
            onTap: () => openUrl(privacyPolicy),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.fileShield),
            trailing: Icon(Icons.open_in_new,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: const Text('Nutzungsbedingungen'),
            onTap: () => openUrl(termsAndConditions),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            trailing: Icon(Icons.open_in_new,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            title: const Text('Über die App'),
            onTap: () => openUrl(aboutThisApp),
          ),
          ListTile(
              leading: Icon(Icons.logout,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Abmelden',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                signUserOut();
              }),
        ],
      ),
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
}
