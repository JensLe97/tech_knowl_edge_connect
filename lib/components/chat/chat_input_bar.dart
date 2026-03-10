import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/forms/message_textfield.dart';

/// A unified bottom input bar used in all chat/AI/search pages.
///
/// Parameters:
/// - [controller]       – text field controller
/// - [hintText]         – placeholder text
/// - [onSend]           – called when the send button is pressed or the user
///                        submits from the keyboard
/// - [onAttachmentTap]  – if provided, shows the leading `+` icon button and
///                        calls this callback when tapped
/// - [pickedFiles]      – list of currently picked files shown as chips above
///                        the text field
/// - [onRemoveFile]     – called with the file to remove when the user taps
///                        the × on a chip
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSend;
  final VoidCallback? onAttachmentTap;
  final List<PlatformFile> pickedFiles;
  final void Function(PlatformFile)? onRemoveFile;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Nachricht schreiben...',
    this.onAttachmentTap,
    this.pickedFiles = const [],
    this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.bottomCenter,
          child: pickedFiles.isEmpty
              ? const SizedBox(width: double.infinity, height: 0)
              : SizedBox(
                  height: 46,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 2),
                    itemCount: pickedFiles.length,
                    itemBuilder: (context, index) {
                      final file = pickedFiles[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InputChip(
                          label: Text(
                            file.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: onRemoveFile != null
                              ? () => onRemoveFile!(file)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
        ),
        Row(
          children: [
            if (onAttachmentTap != null)
              IconButton(
                onPressed: onAttachmentTap,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 40),
                color: Theme.of(context).colorScheme.secondary,
              ),
            Flexible(
              child: MessageTextField(
                controller: controller,
                hintText: hintText,
                obscureText: false,
                onSubmitted: (_) => onSend(),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final canSend = value.text.isNotEmpty || pickedFiles.isNotEmpty;
                return IconButton(
                  icon: Icon(
                    Icons.send,
                    size: 40,
                    color: canSend
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.inversePrimary,
                  ),
                  onPressed: canSend ? onSend : null,
                  tooltip: 'Nachricht senden',
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
