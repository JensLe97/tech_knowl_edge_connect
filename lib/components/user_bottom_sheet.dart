import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/reason_bottom_sheet.dart';
import 'package:tech_knowl_edge_connect/models/report_reason.dart';

class UserBottomSheet extends StatelessWidget {
  final void Function() toggleBlockUser;
  final void Function(ReportReason) report;
  final bool isBlocked;
  final bool isContent;

  const UserBottomSheet({
    Key? key,
    required this.toggleBlockUser,
    required this.report,
    this.isBlocked = false,
    this.isContent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        isContent
            ? const SizedBox()
            : ListTile(
                leading: const Icon(Icons.block),
                title: isBlocked
                    ? const Text('Blockierung aufheben')
                    : const Text('Benutzer blockieren'),
                onTap: () {
                  Navigator.pop(context);
                  toggleBlockUser();
                  final snackBar = SnackBar(
                    content: isBlocked
                        ? const Text('Benutzer ist nicht mehr blockiert')
                        : const Text('Benutzer ist blockiert'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
        ListTile(
          leading: const Icon(Icons.flag),
          title: isContent
              ? const Text('Inhalt melden')
              : const Text('Benutzer melden'),
          onTap: () {
            Navigator.pop(context);
            showModalBottomSheet(
              backgroundColor: Theme.of(context).colorScheme.surface,
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              enableDrag: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              builder: (BuildContext context) => SafeArea(
                child: ReportReasonBottomSheet(
                  report: report,
                  isContent: isContent,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
