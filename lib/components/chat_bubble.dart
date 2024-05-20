import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final Timestamp time;

  const ChatBubble(
      {super.key,
      required this.message,
      required this.isMe,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 50 : 0,
        right: isMe ? 0 : 50,
        top: 0,
        bottom: 0,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isMe ? Colors.blue : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                  bottomLeft: Radius.circular(isMe ? 15 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  message,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : Theme.of(context).textTheme.displayLarge!.color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time.toDate().toString().substring(11, 16),
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : Theme.of(context).textTheme.displayLarge!.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
