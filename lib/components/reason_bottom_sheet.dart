import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/report_reason.dart';

class ReportReasonBottomSheet extends StatelessWidget {
  final void Function(ReportReason) report;
  final bool isContent;

  const ReportReasonBottomSheet({
    Key? key,
    required this.report,
    this.isContent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            'Grund der Meldung',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Text(
            "Wir informieren das Konto nicht darüber, wer es gemeldet hat.",
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ),
        ListTile(
          title: const Text('Gefällt mir nicht'),
          onTap: () => reportReason(context, ReportReason.dislike),
        ),
        ListTile(
          title: const Text('Spam'),
          onTap: () => reportReason(context, ReportReason.spam),
        ),
        ListTile(
          title: const Text('Nacktheit oder sexuelle Inhalte'),
          onTap: () => reportReason(context, ReportReason.nudity),
        ),
        ListTile(
          title: const Text('Gewalt oder gefährliche Organisationen'),
          onTap: () => reportReason(context, ReportReason.violence),
        ),
        ListTile(
          title: const Text('Mobbing oder Belästigung'),
          onTap: () => reportReason(context, ReportReason.hate),
        ),
        ListTile(
          title: const Text('Falsche Informationen'),
          onTap: () => reportReason(context, ReportReason.misinformation),
        ),
        ListTile(
          title: const Text('Urheberrechtsverletzung'),
          onTap: () => reportReason(context, ReportReason.copyright),
        ),
        ListTile(
          title: const Text('Sonstiges'),
          onTap: () => reportReason(context, ReportReason.other),
        ),
      ],
    );
  }

  void reportReason(BuildContext context, ReportReason reason) {
    Navigator.pop(context);
    report(reason);
    final snackBar = SnackBar(
      content: isContent
          ? const Text('Inhalt wurde gemeldet')
          : const Text('Benutzer wurde gemeldet'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
