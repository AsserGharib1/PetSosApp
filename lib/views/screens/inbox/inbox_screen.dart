import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/views/theme/app_colors.dart';
import 'package:app/views/theme/app_text_styles.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/chat_viewmodel.dart';
import '../chat/chat_screen.dart';

class InboxScreen extends StatelessWidget {
  final String? forcedUserId;

  const InboxScreen({super.key, this.forcedUserId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authVM = Provider.of<AuthViewModel>(context);
    final chatVM = Provider.of<ChatViewModel>(context);
    final currentUser = authVM.user;
    final targetUserId = forcedUserId ?? currentUser?.uid;

    if (targetUserId == null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(title: Text('nav_inbox'.tr())),
        body: Center(
          child: Text(
            'login_required_message'.tr(),
            style: AppTextStyles.bodyMedium(isDark: isDark),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text('nav_inbox'.tr(), style: AppTextStyles.h5(isDark: isDark)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatVM.getUserChats(targetUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'no_messages'.tr(),
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                  ),
                ],
              ),
            );
          }

          // Client-side sorting to avoid Firestore Index requirement
          final docs = snapshot.data!.docs.toList();
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['lastTimestamp'] as Timestamp?;
            final bTime = bData['lastTimestamp'] as Timestamp?;

            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1; // Nulls last
            if (bTime == null) return -1;

            return bTime.compareTo(aTime); // Descending
          });

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // Identify the "other" user
              final List<dynamic> users = data['users'];
              final String otherUserId = users.firstWhere(
                (id) => id != targetUserId,
                orElse: () => 'Unknown',
              );
              final Map<String, dynamic> userNames = data['userNames'] ?? {};
              String otherUserName = userNames[otherUserId] ?? 'User';
              // Fix: Check for 'Admin' variants or the hardcoded Arabic string
              if (otherUserName.toLowerCase() == 'admin' ||
                  otherUserName == 'دعم المشرف' ||
                  otherUserName == 'Admin Support') {
                otherUserName = 'admin_support'.tr();
              }
              final String lastMessage = data['lastMessage'] ?? '';
              final Timestamp? timestamp = data['lastTimestamp'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBase,
                  child: Text(
                    otherUserName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  otherUserName,
                  style: AppTextStyles.bodyMediumBold(isDark: isDark),
                ),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall(isDark: isDark),
                ),
                trailing: timestamp != null
                    ? Text(
                        _formatDate(timestamp.toDate(), context),
                        style: AppTextStyles.label(
                          isDark: isDark,
                          color: Colors.grey,
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        otherUserId: otherUserId,
                        otherUserName: otherUserName,
                        currentUserId: forcedUserId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat.jm(context.locale.toString()).format(date);
    } else if (difference.inDays < 7) {
      return DateFormat.E(context.locale.toString())
          .format(date); // Day name (e.g., Mon)
    } else {
      return DateFormat.yMMMd(context.locale.toString())
          .format(date); // Date (e.g., Oct 12)
    }
  }
}
