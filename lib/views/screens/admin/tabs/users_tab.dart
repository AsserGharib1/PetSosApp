import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petsos/models/data/repositories/user_repository.dart';
import '../../../../models/user.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<User>>(
      stream: userRepository.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isBanned = user.role == 'banned';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isBanned ? Colors.grey : AppColors.primaryBase,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(
                          (user.displayName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                title: Text(
                  user.displayName ?? 'unknown'.tr(),
                  style: AppTextStyles.bodyMediumBold(isDark: isDark),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.email,
                      style: AppTextStyles.label(isDark: isDark),
                    ),
                    if (isBanned)
                      Text(
                        'BANNED',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    try {
                      if (value == 'ban') {
                        await userRepository.banUser(user.uid);
                      } else if (value == 'unban') {
                        await userRepository.unbanUser(user.uid);
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('delete_user_title'.tr()),
                            content: Text(
                              'delete_user_content'.tr(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // Note: This only deletes data, not Auth account
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .delete();
                        }
                      }

                      if (context.mounted && value != 'delete') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value == 'ban' ? 'User banned' : 'User unbanned',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isBanned)
                      PopupMenuItem(
                        value: 'ban',
                        child: Text(
                          'ban_user'.tr(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else
                      PopupMenuItem(
                        value: 'unban',
                        child: Text(
                          'unban_user'.tr(),
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'delete_data'.tr(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
