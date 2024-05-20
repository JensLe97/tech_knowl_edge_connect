import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/chat_bubble.dart';
import 'package:tech_knowl_edge_connect/components/message_textfield.dart';
import 'package:tech_knowl_edge_connect/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverUsername;
  final String receiverUid;
  const ChatPage(
      {super.key, required this.receiverUsername, required this.receiverUid});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUid, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Center(
            child: Text(widget.receiverUsername),
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildMessageList()),
              ),
              const SizedBox(height: 10),
              _buildMessageInput(),
              const SizedBox(height: 10),
            ],
          ),
        ));
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverUid, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
        } else if (snapshot.hasData) {
          ListView messageList = ListView(
              reverse: true,
              shrinkWrap: true,
              children: snapshot.data!.docs.reversed
                  .map((document) => _buildMessageItem(document))
                  .toList());
          return messageList;
        } else {
          return const Text("Noch keine Nachrichten vorhanden.");
        }
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = data['senderId'] == _firebaseAuth.currentUser!.uid
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: data['senderId'] == _firebaseAuth.currentUser!.uid
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisAlignment: data['senderId'] == _firebaseAuth.currentUser!.uid
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            ChatBubble(
                message: data['message'],
                isMe: data['senderId'] == _firebaseAuth.currentUser!.uid,
                time: data['timestamp'])
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          Expanded(
            child: MessageTextField(
              controller: _messageController,
              hintText: 'Nachricht schreiben...',
              obscureText: false,
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.send,
                size: 40,
              ),
              color: Theme.of(context).colorScheme.inversePrimary),
        ],
      ),
    );
  }
}
