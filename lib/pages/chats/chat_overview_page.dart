import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/pages/chats/chat_page.dart';

class ChatOverviewPage extends StatefulWidget {
  const ChatOverviewPage({super.key});

  @override
  State<ChatOverviewPage> createState() => _ChatOverviewPageState();
}

class _ChatOverviewPageState extends State<ChatOverviewPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  void _showNewChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      enableDrag: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (BuildContext context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("Neuer Chat",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildUserList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showNewChatSheet,
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Meine Chats',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  )),
              const SizedBox(height: 14),
              _buildChatList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
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
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
          } else if (snapshot.hasData) {
            List<Widget> chats = snapshot.data!.docs
                .map<Widget>((docs) => _buildChatListItem(docs))
                .toList();

            if (chats.every((element) => element is SizedBox)) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Du hast noch keine Chats.",
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Nutze das ",
                              style: TextStyle(fontSize: 16)),
                          Icon(Icons.add,
                              color: Theme.of(context).colorScheme.primary),
                          const Text("-Symbol oben rechts.",
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: chats,
              );
            }
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
    if (document.id.contains(currentUser!.uid)) {
      Map<String, dynamic>? docData = document.data() as Map<String, dynamic>?;
      String otherUserId = document.id
          .split("_")
          .firstWhere((element) => element != currentUser!.uid);

      return FutureBuilder(
        future: getUserDetails(otherUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 70);
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox();
          }

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

          final cs = Theme.of(context).colorScheme;
          String username = otherUser!['username'];
          final parts = username.trim().split(RegExp(r'\s+'));
          String initials = parts.isEmpty || parts[0].isEmpty
              ? '?'
              : parts.length > 1
                  ? (parts[0][0] + parts.last[0]).toUpperCase()
                  : parts[0].length > 1
                      ? parts[0].substring(0, 2).toUpperCase()
                      : parts[0].toUpperCase();

          Widget subtitleWidget;
          if (document['type'] == "text") {
            bool blocked = document['isBlocked'] ?? false;
            if (blocked && document['lastSenderId'] == otherUserId) {
              subtitleWidget = Text(
                document['lastUnblockedMessage'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSurfaceVariant.withAlpha(200)),
              );
            } else {
              subtitleWidget = Text(
                document['lastMessage'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSurfaceVariant.withAlpha(200)),
              );
            }
          } else {
            subtitleWidget = FaIcon(
              LearningMaterialType.getIconForMessageType(
                  document['type'] as String? ?? ''),
              size: 16,
              color: cs.onSurfaceVariant.withAlpha(200),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Material(
              color: cs.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: cs.outlineVariant.withAlpha(40)),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  // Mark as read immediately before navigation
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
                    // Mark as read after navigation returns
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: TextStyle(
                                  color: cs.onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                          if (unread > 0)
                            Positioned(
                              bottom: -4,
                              right: -4,
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 22),
                                height: 22,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(
                                      color: cs.surfaceContainer, width: 2.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  unread > 99 ? '99+' : unread.toString(),
                                  style: TextStyle(
                                    color: cs.onPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: cs.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  lastTime,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: unread > 0
                                        ? FontWeight.w900
                                        : FontWeight.bold,
                                    color: unread > 0
                                        ? cs.primary
                                        : cs.onSurface.withAlpha(150),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            subtitleWidget,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
          } else if (snapshot.hasData) {
            var users = snapshot.data!.docs.toList();
            users.sort((a, b) => (a['username'] as String)
                .toLowerCase()
                .compareTo((b['username'] as String).toLowerCase()));

            return Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return _buildUserListItem(users[index]);
                },
              ),
            );
          } else {
            return const Text("Keine Benutzer vorhanden.");
          }
        });
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    if (currentUser!.uid != document.id) {
      String otherUserId = document.id;
      String username = document['username'];
      String email = (document.data() as Map<String, dynamic>?)?['email'] ?? '';

      final parts = username.trim().split(RegExp(r'\s+'));
      String initials = parts.isEmpty || parts[0].isEmpty
          ? '?'
          : parts.length > 1
              ? (parts[0][0] + parts.last[0]).toUpperCase()
              : parts[0].length > 1
                  ? parts[0].substring(0, 2).toUpperCase()
                  : parts[0].toUpperCase();

      final cs = Theme.of(context).colorScheme;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Material(
          color: cs.surfaceContainerHigh.withAlpha(150),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.pop(context); // close sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverUsername: username,
                    receiverUid: otherUserId,
                  ),
                ),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: TextStyle(
                          color: cs.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withAlpha(150),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
