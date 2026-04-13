import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tech_knowl_edge_connect/components/dialogs/user_bottom_sheet.dart';
import 'package:tech_knowl_edge_connect/models/user/learning_material.dart';
import 'package:tech_knowl_edge_connect/providers/user_provider.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/pages/feed/post_profile_page.dart';
import 'package:tech_knowl_edge_connect/pages/library/learning_material_preview_page.dart';
import 'package:tech_knowl_edge_connect/services/user/learning_material_service.dart';
import 'package:video_player/video_player.dart';
import 'package:tech_knowl_edge_connect/models/user/report_reason.dart';
import 'package:tech_knowl_edge_connect/services/user/user_service.dart';

class LearningMaterialReelItem extends StatefulWidget {
  final LearningMaterial material;

  const LearningMaterialReelItem({
    super.key,
    required this.material,
  });

  @override
  State<LearningMaterialReelItem> createState() =>
      _LearningMaterialReelItemState();
}

class _LearningMaterialReelItemState extends State<LearningMaterialReelItem> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final LearningMaterialService _learningMaterialsService =
      LearningMaterialService();

  toggleLike() async {
    final likedLearningMaterials =
        UserState.of(context)!.likedLearningMaterials;
    if (likedLearningMaterials.contains(widget.material.id)) {
      await _learningMaterialsService.unlikeLearningMaterial(
          _firebaseAuth.currentUser!.uid, widget.material.id);
    } else {
      await _learningMaterialsService.likeLearningMaterial(
          _firebaseAuth.currentUser!.uid, widget.material.id);
    }
  }

  void toggleBlockUser() async {
    final blockedUsers = UserState.of(context)!.blockedUsers;
    final userId = widget.material.userId;
    if (blockedUsers.contains(userId)) {
      await _userService.unblockUser(userId);
    } else {
      await _userService.blockUser(userId);
    }
  }

  void reportContent(ReportReason reason) {
    _userService.reportContent(
      widget.material.id,
      widget.material.userId,
      widget.material.type,
      true,
      reason,
    );
  }

  String _formatTimeAgo(DateTime date) {
    timeago.setLocaleMessages('de', timeago.DeMessages());
    return timeago.format(date, locale: 'de');
  }

  @override
  Widget build(BuildContext context) {
    final userState = UserState.of(context);
    final blockedUsers = userState?.blockedUsers ?? [];
    final likedLearningMaterials = userState?.likedLearningMaterials ?? [];

    final material = widget.material;
    final cs = Theme.of(context).colorScheme;

    final parts = material.userName.trim().split(RegExp(r'\s+'));
    String initials = parts.isEmpty || parts[0].isEmpty
        ? '?'
        : parts.length > 1
            ? (parts[0][0] + parts.last[0]).toUpperCase()
            : parts[0].length > 1
                ? parts[0].substring(0, 2).toUpperCase()
                : parts[0].toUpperCase();

    final isMedia = LearningMaterialType.imageTypes
            .contains(material.type.toLowerCase()) ||
        LearningMaterialType.videoTypes.contains(material.type.toLowerCase());

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final useGlassMode = isDarkMode || isMedia;

    final textColor = useGlassMode ? Colors.white : cs.onSurface;
    final secondaryTextColor =
        useGlassMode ? Colors.white.withAlpha(220) : cs.onSecondaryContainer;
    final pillBgColor = useGlassMode
        ? Colors.black.withAlpha(80)
        : cs.secondaryContainer.withAlpha(220);
    final outlineColor = useGlassMode
        ? Colors.white.withAlpha(40)
        : cs.outlineVariant.withAlpha(100);
    final secondaryOutlineColor =
        useGlassMode ? Colors.white.withAlpha(40) : cs.outlineVariant;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Layer (Video / Image / Placeholder)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LearningMaterialPreviewPage(
                  url: material.url,
                  type: material.type,
                  name: material.name,
                ),
              ),
            );
          },
          child: LearningMaterialType.imageTypes
                  .contains(material.type.toLowerCase())
              ? Image.network(
                  material.url,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : LearningMaterialType.videoTypes
                      .contains(material.type.toLowerCase())
                  ? VideoPlayerWidget(url: material.url)
                  : Center(
                      child: FractionallySizedBox(
                        heightFactor: 0.40,
                        widthFactor: 1.0,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLowest
                                    : Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(20),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: secondaryOutlineColor.withAlpha(77)),
                          ),
                          child: Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: cs.primary.withAlpha(26),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: FaIcon(
                                LearningMaterialType.getIconForType(
                                    material.type),
                                size: 40,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
        // Bottom Details & Actions
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info Drop
                        Transform.translate(
                          offset: const Offset(-6, 0),
                          child: Material(
                            color: pillBgColor,
                            borderRadius: BorderRadius.circular(30),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PostProfilePage(
                                    username: material.userName,
                                    uid: material.userId,
                                  ),
                                ));
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: outlineColor),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: cs.primaryContainer,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: secondaryOutlineColor),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          color: cs.onSecondaryContainer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            material.userName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: secondaryTextColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            _formatTimeAgo(
                                                material.createdAt.toDate()),
                                            style: TextStyle(
                                              color: secondaryTextColor,
                                              fontSize: 11,
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
                        ),
                        const SizedBox(height: 12),
                        Text(
                          material.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildReelActionButton(
                        context: context,
                        icon: likedLearningMaterials.contains(material.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        label: material.numberOfLikes.toString(),
                        onTap: toggleLike,
                        isActive: likedLearningMaterials.contains(material.id),
                        activeColor: Colors.redAccent,
                        isMedia: isMedia,
                      ),
                      const SizedBox(height: 16),
                      _buildReelActionButton(
                        context: context,
                        icon: Icons.more_horiz,
                        label: "",
                        isMedia: isMedia,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            useSafeArea: true,
                            enableDrag: true,
                            builder: (BuildContext context) => SafeArea(
                              child: UserBottomSheet(
                                toggleBlockUser: toggleBlockUser,
                                report: reportContent,
                                isBlocked:
                                    blockedUsers.contains(material.userId),
                                isContent: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReelActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isMedia,
    bool isActive = false,
    Color? activeColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final useGlassMode = isDarkMode || isMedia;

    final textColor = useGlassMode ? Colors.white : cs.onSurface;
    final pillBgColor = useGlassMode
        ? Colors.black.withAlpha(80)
        : cs.secondaryContainer.withAlpha(220);
    final outlineColor = useGlassMode
        ? Colors.white.withAlpha(40)
        : cs.outlineVariant.withAlpha(100);

    return Column(
      children: [
        Material(
          color: pillBgColor,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: outlineColor),
              ),
              child: Icon(
                icon,
                color: isActive ? (activeColor ?? textColor) : textColor,
                size: 28,
              ),
            ),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ]
      ],
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({Key? key, required this.url}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
        _controller.setVolume(0.0);
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: IgnorePointer(child: VideoPlayer(_controller)),
              ),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
