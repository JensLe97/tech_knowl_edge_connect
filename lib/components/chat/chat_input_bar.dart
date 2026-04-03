import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    
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
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest, // or bright surface
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(51),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (onAttachmentTap != null)
                Material(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onAttachmentTap,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.add,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final canSend = value.text.trim().isNotEmpty || pickedFiles.isNotEmpty;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: canSend ? colorScheme.primary : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: canSend ? [
                        BoxShadow(
                          color: colorScheme.primary.withAlpha(76),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ] : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: canSend ? onSend : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Icon(
                          Icons.arrow_upward,
                          color: canSend ? colorScheme.onPrimary : colorScheme.onSurfaceVariant.withAlpha(128),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
