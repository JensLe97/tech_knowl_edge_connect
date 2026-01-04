import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tech_knowl_edge_connect/components/blocked_field.dart';
import 'package:tech_knowl_edge_connect/components/chat_bubble.dart';
import 'package:tech_knowl_edge_connect/components/message_textfield.dart';
import 'package:tech_knowl_edge_connect/components/user_bottom_sheet.dart';
import 'package:tech_knowl_edge_connect/data/index.dart';
import 'package:tech_knowl_edge_connect/env/env.dart';
import 'package:tech_knowl_edge_connect/models/report_reason.dart';
import 'package:tech_knowl_edge_connect/pages/chats/upload_image_page.dart';
import 'package:tech_knowl_edge_connect/services/chat_service.dart';
import 'package:tech_knowl_edge_connect/services/user_service.dart';
import 'package:uuid/uuid.dart';

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
  final UserService _userService = UserService();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  var allMessages = [
    OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "You are a helpful assistant.",
        ),
      ],
      role: OpenAIChatMessageRole.system,
    )
  ];

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String prompt = _messageController.text;
      await _chatService.sendMessage(
          widget.receiverUid, _messageController.text);
      _messageController.clear();
      if (widget.receiverUid == "aitech") {
        String response = await askOpenAi(allMessages, prompt);
        await _chatService.sendMessage(_firebaseAuth.currentUser!.uid, response,
            fromAI: true);
      }
    }
  }

  void sendImage(ImageSource imageSource) async {
    final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

    ImagePicker imagePicker = ImagePicker();
    // await Permission.photos.request();

    // var permissionStatus = await Permission.photos.status;

    if (true) {
      XFile? image = await imagePicker.pickImage(source: imageSource);

      if (image != null) {
        String extension = image.name.split(".").last;
        String fileName = const Uuid().v4();

        Reference upload =
            firebaseStorage.ref().child('images').child("$fileName.$extension");
        extension = extension == "jpg" ? "jpeg" : extension;
        TaskSnapshot taskSnapshot = await upload.putData(
          await image.readAsBytes(),
          SettableMetadata(contentType: 'image/$extension'),
        );

        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        await _chatService.sendMessage(widget.receiverUid, imageUrl,
            type: "image");
      }
    }
  }

  void toggleBlockUser() {
    if (blockedUsers.contains(widget.receiverUid)) {
      _userService.unblockUser(widget.receiverUid);
      setState(() {
        blockedUsers.remove(widget.receiverUid);
      });
    } else {
      _userService.blockUser(widget.receiverUid);
      setState(() {
        blockedUsers.add(widget.receiverUid);
      });
    }
  }

  void reportUser(ReportReason reason) {
    _userService.reportUser(widget.receiverUid, reason);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
            title: Text(widget.receiverUsername),
            centerTitle: true,
            actions: [
              widget.receiverUid == "aitech"
                  ? const SizedBox()
                  : IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
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
                                isBlocked:
                                    blockedUsers.contains(widget.receiverUid)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.more_horiz)),
            ]),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(child: _buildMessageList()),
              const SizedBox(height: 2),
              blockedUsers.contains(widget.receiverUid)
                  ? BlockedField(
                      toggleBlockUser: toggleBlockUser,
                      isBlocked: true,
                    )
                  : _buildMessageInput(),
              const SizedBox(height: 8),
            ],
          ),
        ));
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Heute';
    } else if (messageDate == yesterday) {
      return 'Gestern';
    } else {
      // Format: "Mo. 7. Dez. 25"
      return DateFormat('E d. MMM yy', 'de').format(date);
    }
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDateHeader(date),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          _firebaseAuth.currentUser!.uid, widget.receiverUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text("Ein Fehler ist aufgetreten: \\${snapshot.error}");
        } else if (snapshot.hasData) {
          final docs = snapshot.data!.docs.toList(); // oldest first
          List<Widget> messageWidgets = [];
          DateTime? lastDate;

          for (var document in docs) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            Timestamp timestamp = data['timestamp'];
            DateTime messageDate = timestamp.toDate();
            DateTime messageDayOnly =
                DateTime(messageDate.year, messageDate.month, messageDate.day);

            if (lastDate == null || lastDate != messageDayOnly) {
              messageWidgets.add(_buildDateSeparator(messageDate));
              lastDate = messageDayOnly;
            }

            messageWidgets.add(_buildMessageItem(document));
          }

          ListView messageList = ListView(
              reverse: true, children: messageWidgets.reversed.toList());
          return TextFieldTapRegion(child: messageList);
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
        child: ChatBubble(
          uid: data['senderId'],
          message: data['message'],
          type: data['type'],
          isMe: data['senderId'] == _firebaseAuth.currentUser!.uid,
          time: data['timestamp'],
          userService: _userService,
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          widget.receiverUid == "aitech"
              ? const SizedBox()
              : IconButton(
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
                              child: UploadImagePage(
                                sendImage: sendImage,
                              ),
                            ));
                  },
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 40,
                  ),
                  color: Theme.of(context).colorScheme.secondary),
          Flexible(
            child: MessageTextField(
              controller: _messageController,
              hintText: 'Nachricht schreiben...',
              obscureText: false,
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (context, value, child) {
              final isEmpty = value.text.isEmpty;
              final color = isEmpty
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Theme.of(context).colorScheme.secondary;
              return IconButton(
                onPressed: isEmpty ? null : sendMessage,
                icon: Icon(
                  Icons.send,
                  size: 40,
                  color: color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<String> askOpenAi(
    List<OpenAIChatCompletionChoiceMessageModel> thisMessages,
    String prompt,
  ) async {
    OpenAI.apiKey = Env.openaiApiKey;
    List<OpenAIChatCompletionChoiceMessageModel> newMessages = [];
    for (var messageElement in thisMessages) {
      newMessages.add(messageElement);
    }

    newMessages.add(OpenAIChatCompletionChoiceMessageModel(
      content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)],
      role: OpenAIChatMessageRole.user,
    ));

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: newMessages,
      n: 1,
      maxTokens: 2000,
      temperature: 0.7,
    );
    String response = chatCompletion.choices.first.message.content!.first.text!;
    newMessages.add(
      OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(response)
        ],
        role: OpenAIChatMessageRole.assistant,
      ),
    );
    allMessages = newMessages;

    return response;
  }
}
