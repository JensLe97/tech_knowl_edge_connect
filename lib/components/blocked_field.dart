import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/submit_button.dart';

class BlockedField extends StatelessWidget {
  final void Function() toggleBlockUser;
  final bool isBlocked;

  const BlockedField(
      {Key? key, required this.toggleBlockUser, this.isBlocked = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text(
          "Benutzer ist blockiert und kann keine",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        const Text(
          "Nachrichten von dir erhalten.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 5),
        SubmitButton(
            onTap: () {
              toggleBlockUser();
              final snackBar = SnackBar(
                content: isBlocked
                    ? const Text("Benutzer ist nicht mehr blockiert")
                    : const Text("Benutzer ist blockiert"),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            text: "Blockierung aufheben")
      ],
    );
  }
}
