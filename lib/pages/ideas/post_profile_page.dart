import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/blocked_field.dart';
import 'package:tech_knowl_edge_connect/components/user_bottom_sheet.dart';
import 'package:tech_knowl_edge_connect/data/index.dart';
import 'package:tech_knowl_edge_connect/services/user_service.dart';

class PostProfilePage extends StatefulWidget {
  final String username;
  final String uid;

  const PostProfilePage({super.key, required this.username, required this.uid});

  @override
  State<PostProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<PostProfilePage> {
  final UserService _userService = UserService();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.uid)
        .get();
  }

  void toggleBlockUser() {
    if (blockedUsers.contains(widget.uid)) {
      _userService.unblockUser(widget.uid);
      setState(() {
        blockedUsers.remove(widget.uid);
      });
    } else {
      _userService.blockUser(widget.uid);
      setState(() {
        blockedUsers.add(widget.uid);
      });
    }
  }

  void reportUser() {
    _userService.reportUser(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          title: Center(
            child: Text(widget.username),
          ),
          actions: [
            IconButton(
                onPressed: () {
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
                      child: UserBottomSheet(
                          toggleBlockUser: toggleBlockUser,
                          report: reportUser,
                          isBlocked: blockedUsers.contains(widget.uid)),
                    ),
                  );
                },
                icon: const Icon(Icons.more_vert)),
          ]),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
            } else if (snapshot.hasData) {
              Map<String, dynamic>? user = snapshot.data!.data();
              return SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.all(25),
                        child: const Icon(
                          Icons.person,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        user!['username'],
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(user['email'],
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 25),
                      blockedUsers.contains(widget.uid)
                          ? BlockedField(
                              toggleBlockUser: toggleBlockUser,
                              isBlocked: true,
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              );
            } else {
              return const Text("Keine Daten für diesen Benutzer vorhanden.");
            }
          }),
    );
  }
}
