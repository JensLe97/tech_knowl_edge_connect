import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tech_knowl_edge_connect/pages/chats/chat_page.dart';

class ChatOverviewPage extends StatefulWidget {
  const ChatOverviewPage({super.key});

  @override
  State<ChatOverviewPage> createState() => _ChatOverviewPageState();
}

class _ChatOverviewPageState extends State<ChatOverviewPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Chats'),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surface, // bottomsheet color
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      enableDrag: true,
                      useSafeArea: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (BuildContext context) => Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text("Neuer Chat",
                              style: TextStyle(fontSize: 20)),
                          const SizedBox(height: 20),
                          _buildUserList(),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle)),
            ]),
        body: _buildChatList());
  }

  Widget _buildChatList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("chat_rooms")
            .orderBy("lastTimestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
          } else if (snapshot.hasData) {
            List<Widget> chats = snapshot.data!.docs
                .map<Widget>((docs) => _buildChatListItem(docs))
                .toList();
            if (chats.every((element) => element is SizedBox)) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Du hast noch keine Chats.",
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center),
                    SizedBox(height: 2),
                    Text(
                      "Starte eine neue Unterhaltung ",
                      style: TextStyle(fontSize: 20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "über das ",
                          style: TextStyle(fontSize: 20),
                        ),
                        Icon(Icons.add_circle),
                        Text(
                          "-Symbol oben rechts.",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return ListView(
                children: ListTile.divideTiles(context: context, tiles: chats)
                    .toList(),
              );
            }
          } else {
            return const Text("Keine Chats vorhanden.");
          }
        });
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
          } else if (snapshot.hasData) {
            return Flexible(
              child: ListView(
                shrinkWrap: true,
                children: ListTile.divideTiles(
                        context: context,
                        tiles: snapshot.data!.docs
                            .map<Widget>((docs) => _buildUserListItem(docs))
                            .toList())
                    .toList(),
              ),
            );
          } else {
            return const Text("Keine Chats vorhanden.");
          }
        });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails(
      String otherUserId) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(otherUserId)
        .get();
  }

  Widget _buildChatListItem(DocumentSnapshot document) {
    if (document.id.contains(currentUser!.uid) &&
        !document.id.contains("aitech")) {
      Map<String, dynamic>? docData = document.data() as Map<String, dynamic>?;
      String otherUserId = document.id
          .split("_")
          .firstWhere((element) => element != currentUser!.uid);
      return FutureBuilder(
          future: getUserDetails(otherUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
            } else if (snapshot.hasData) {
              Map<String, dynamic>? otherUser = snapshot.data!.data();
              DateTime lastDateTime =
                  (document['lastTimestamp'] as Timestamp).toDate();
              DateFormat format =
                  DateTime.now().difference(lastDateTime).inDays >= 1
                      ? DateFormat('dd.MM.yyyy')
                      : DateFormat('HH:mm');
              String lastTime = format.format(lastDateTime);
              int unread = (document.id.split("_").first == currentUser!.uid)
                  ? docData!['unreadFrom'] ?? 0
                  : docData!['unreadTo'] ?? 0;
              return ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.person,
                    size: 26,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lastTime,
                    ),
                    unread > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 8.0),
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              color: Colors.blue,
                            ),
                            child: Text(
                              unread.toString(),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
                minVerticalPadding: 15,
                title: Text(otherUser!['username']),
                subtitle: document['type'] == "text"
                    ? document['isBlocked'] &&
                            document['lastSenderId'] == otherUserId
                        ? Text(
                            document['lastUnblockedMessage'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            document['lastMessage'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                    : const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.image),
                        ],
                      ),
                onTap: () {
                  if (document.id.split("_").first == currentUser!.uid) {
                    FirebaseFirestore.instance
                        .collection("chat_rooms")
                        .doc(document.id)
                        .update({'unreadFrom': 0});
                  } else {
                    FirebaseFirestore.instance
                        .collection("chat_rooms")
                        .doc(document.id)
                        .update({'unreadTo': 0});
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverUsername: otherUser['username'],
                        receiverUid: otherUserId,
                      ),
                    ),
                  ).then((value) {
                    if (document.id.split("_").first == currentUser!.uid) {
                      FirebaseFirestore.instance
                          .collection("chat_rooms")
                          .doc(document.id)
                          .update({'unreadFrom': 0});
                    } else {
                      FirebaseFirestore.instance
                          .collection("chat_rooms")
                          .doc(document.id)
                          .update({'unreadTo': 0});
                    }
                    setState(() {});
                  });
                },
              );
            } else {
              return const Text("Keine Daten für diesen Benutzer vorhanden.");
            }
          });
    } else {
      return const SizedBox();
    }
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    if (currentUser!.uid != document.id && document.id != "aitech") {
      String otherUserId = document.id;
      return ListTile(
        leading: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.all(10),
          child: const Icon(
            Icons.person,
            size: 26,
          ),
        ),
        title: Text(document['username']),
        subtitle: Text(document['email']),
        onTap: () {
          Navigator.pop(context);
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUsername: document['username'],
                receiverUid: otherUserId,
              ),
            ),
          )
              .then((value) {
            setState(() {});
          });
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
