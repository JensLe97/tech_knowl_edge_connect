import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_knowl_edge_connect/providers/user_provider.dart';
import 'package:tech_knowl_edge_connect/services/user/learning_material_service.dart';
import 'package:tech_knowl_edge_connect/models/user/learning_material.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/pages/feed/post_profile_page.dart';
import 'package:tech_knowl_edge_connect/services/user/user_service.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/user_bottom_sheet.dart';
import 'package:tech_knowl_edge_connect/models/user/report_reason.dart';

class DetailedLearningMaterialTile extends StatelessWidget {
  final LearningMaterial material;
  final VoidCallback? onTap;

  const DetailedLearningMaterialTile({
    super.key,
    required this.material,
    required this.onTap,
  });

  String _formatTimeAgo(DateTime date) {
    timeago.setLocaleMessages('de', timeago.DeMessages());
    return timeago.format(date, locale: 'de');
  }

  void _toggleBlockUser(BuildContext context) async {
    final userService = UserService();
    final blockedUsers = UserState.of(context)?.blockedUsers ?? [];
    final userId = material.userId;
    if (blockedUsers.contains(userId)) {
      await userService.unblockUser(userId);
    } else {
      await userService.blockUser(userId);
    }
  }

  void _reportContent(ReportReason reason) {
    final userService = UserService();
    userService.reportContent(
      material.id,
      material.userId,
      material.type,
      true,
      reason,
    );
  }

  void _toggleLike(BuildContext context) async {
    final firebaseAuth = FirebaseAuth.instance;
    final learningMaterialsService = LearningMaterialService();
    final userState = UserState.of(context);
    if (userState == null) return;

    final likedLearningMaterials = userState.likedLearningMaterials;
    if (likedLearningMaterials.contains(material.id)) {
      await learningMaterialsService.unlikeLearningMaterial(
          firebaseAuth.currentUser!.uid, material.id);
    } else {
      await learningMaterialsService.likeLearningMaterial(
          firebaseAuth.currentUser!.uid, material.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userState = UserState.of(context);
    final likedLearningMaterials = userState?.likedLearningMaterials ?? [];
    final isLiked = likedLearningMaterials.contains(material.id);

    final isImage =
        LearningMaterialType.imageTypes.contains(material.type.toLowerCase());

    final parts = material.userName.trim().split(RegExp(r'\s+'));
    String initials = parts.isEmpty || parts[0].isEmpty
        ? '?'
        : parts.length > 1
            ? (parts[0][0] + parts.last[0]).toUpperCase()
            : parts[0].length > 1
                ? parts[0].substring(0, 2).toUpperCase()
                : parts[0].toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).colorScheme.surfaceContainerLowest
              : Theme.of(context).colorScheme.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PostProfilePage(
                        username: material.userName,
                        uid: material.userId,
                      ),
                    ));
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.userName,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatTimeAgo(material.createdAt.toDate()),
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer.withAlpha(77),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        material.type.toUpperCase(),
                        style: TextStyle(
                          color: cs.onTertiaryContainer,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          final blockedUsers =
                              UserState.of(context)?.blockedUsers ?? [];
                          showModalBottomSheet(
                            context: context,
                            useSafeArea: true,
                            enableDrag: true,
                            builder: (BuildContext context) => SafeArea(
                              child: UserBottomSheet(
                                toggleBlockUser: () =>
                                    _toggleBlockUser(context),
                                report: _reportContent,
                                isBlocked:
                                    blockedUsers.contains(material.userId),
                                isContent: true,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.more_horiz,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isImage
                    ? Colors.transparent
                    : cs.secondaryContainer.withAlpha(51),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.outlineVariant.withAlpha(77)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: isImage
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 3 / 2,
                            child:
                                Image.network(material.url, fit: BoxFit.cover),
                          ),
                          Container(
                            color: cs.secondaryContainer.withAlpha(51),
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 16),
                            child: Text(
                              material.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 16),
                        child: Column(
                          children: [
                            FaIcon(
                              LearningMaterialType.getIconForType(
                                  material.type),
                              size: 48,
                              color: cs.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              material.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _toggleLike(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked
                                    ? Colors.redAccent
                                    : cs.onSurfaceVariant.withAlpha(150),
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                material.numberOfLikes.toString(),
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withAlpha(25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Text(
                          'ÖFFNEN',
                          style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
