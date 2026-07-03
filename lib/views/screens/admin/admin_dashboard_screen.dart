import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petsos/views/theme/app_colors.dart';
import 'package:petsos/views/theme/app_text_styles.dart';

import '../../../../viewmodels/pets_viewmodel.dart';
import '../../../../models/pet.dart';
import '../../../../models/user.dart';
import 'package:petsos/models/data/repositories/user_repository.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          title:
              Text('Admin Dashboard', style: AppTextStyles.h5(isDark: isDark)),
          centerTitle: true,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Manage Pets'),
              Tab(text: 'Manage Users'),
            ],
            labelStyle: AppTextStyles.bodyMediumBold(),
            unselectedLabelStyle: AppTextStyles.bodyMedium(),
          ),
        ),
        body: const TabBarView(
          children: [
            _PetsManagementTab(),
            _UsersManagementTab(),
          ],
        ),
      ),
    );
  }
}

class _PetsManagementTab extends StatelessWidget {
  const _PetsManagementTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final petsVM = Provider.of<PetsViewModel>(context);

    // Filter out deleted pets if ViewModel doesn't do it?
    // Assume ViewModel returns all active pets.
    final pets = petsVM.pets;

    if (pets.isEmpty) {
      return Center(
          child: Text('No pets found',
              style: AppTextStyles.bodyMedium(isDark: isDark)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        return Card(
          elevation: 2,
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  pet.imageUrl != null ? NetworkImage(pet.imageUrl!) : null,
              child: pet.imageUrl == null ? const Icon(Icons.pets) : null,
            ),
            title: Text(pet.name, style: AppTextStyles.h6(isDark: isDark)),
            subtitle: Text('${pet.status} • ${pet.breed ?? "Unknown"}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _confirmDeletePet(context, pet, petsVM),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeletePet(BuildContext context, Pet pet, PetsViewModel petsVM) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${pet.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (pet.id != null) {
                petsVM.deletePet(pet.id!);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _UsersManagementTab extends StatelessWidget {
  const _UsersManagementTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // We instantiate UserRepository directly here or use Provider if available.
    // Assuming we need a stream.
    final userRepo = UserRepository();

    return StreamBuilder<List<User>>(
      stream: userRepo.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isBanned = user.role == 'banned';
            final isAdmin = user.role == 'admin';

            return Card(
              elevation: 2,
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child:
                      user.photoUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(user.displayName ?? 'Unknown',
                    style: AppTextStyles.h6(isDark: isDark)),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.primaryBase,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('ADMIN',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      )
                    else
                      IconButton(
                        icon: Icon(isBanned ? Icons.check_circle : Icons.block,
                            color: isBanned ? Colors.green : Colors.red),
                        tooltip: isBanned ? 'Unban User' : 'Ban User',
                        onPressed: () async {
                          if (isBanned) {
                            await userRepo.unbanUser(user.uid);
                          } else {
                            _confirmBanUser(context, user, userRepo);
                          }
                        },
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

  void _confirmBanUser(BuildContext context, User user, UserRepository repo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ban User'),
        content: Text('Are you sure you want to ban ${user.displayName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await repo.banUser(user.uid);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Ban', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
