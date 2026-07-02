import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/pet.dart';
import 'package:app/views/theme/app_colors.dart';
import 'package:app/views/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/map_viewmodel.dart';
import '../../../viewmodels/navigation_viewmodel.dart';
import '../../../viewmodels/pets_viewmodel.dart';
import 'package:app/models/data/repositories/user_repository.dart';
import '../chat/chat_screen.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: pet.imageUrl != null
                  ? Image.network(pet.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.pets,
                        size: 80,
                        color: Colors.grey.shade500,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          pet.name.toLowerCase().contains('unknown') &&
                                  pet.petType != null
                              ? pet.petType!
                              : pet.name,
                          style: AppTextStyles.h3(isDark: isDark)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.getBadgeColor(pet.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pet.status == 'Lost'
                              ? 'filter_lost'.tr()
                              : 'filter_found'.tr(),
                          style: AppTextStyles.badge(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pet.location,
                        style: AppTextStyles.bodyMedium(isDark: isDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info Grid
                  Row(
                    children: [
                      if (pet.petType != null)
                        _buildInfoItem(
                            context,
                            'type'.tr(),
                            pet.petType == 'Dog'
                                ? 'dog'.tr()
                                : (pet.petType == 'Cat'
                                    ? 'cat'.tr()
                                    : 'other'.tr())),
                      if (pet.breed != null &&
                          pet.breed!.isNotEmpty &&
                          !pet.breed!.toLowerCase().contains('unknown'))
                        _buildInfoItem(context, 'breed'.tr(), pet.breed!),
                      if (pet.gender != null &&
                          pet.gender!.isNotEmpty &&
                          !pet.gender!.toLowerCase().contains('unknown'))
                        _buildInfoItem(
                          context,
                          'gender'.tr(),
                          pet.gender!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('description'.tr(),
                      style: AppTextStyles.h5(isDark: isDark)),
                  const SizedBox(height: 8),
                  Text(
                    pet.description,
                    style: AppTextStyles.bodyMedium(isDark: isDark),
                  ),
                  const SizedBox(height: 24),

                  // Map Preview
                  Text(
                    'last_seen_location'.tr(),
                    style: AppTextStyles.h5(isDark: isDark),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(pet.latitude, pet.longitude),
                          initialZoom: 15.0,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ), // Static map
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.abandonedpets.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(pet.latitude, pet.longitude),
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.location_on,
                                  color: AppColors.getBadgeColor(pet.status),
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Button
                  Consumer<AuthViewModel>(
                    builder: (context, authVM, child) {
                      final isOwner = authVM.user?.uid == pet.ownerId;
                      return PrimaryButton(
                        text: isOwner ? 'your_post'.tr() : 'contact_owner'.tr(),
                        icon: Icons.chat,
                        backgroundColor:
                            isOwner ? Colors.grey : AppColors.primaryBase,
                        onPressed: isOwner
                            ? () {}
                            : () async {
                                if (!authVM.isLoggedIn) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please login to contact owner',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // Fetch owner details
                                String ownerName = 'Pet Owner';
                                if (pet.ownerId != null) {
                                  try {
                                    final userRepo = UserRepository();
                                    final owner = await userRepo.getUserById(
                                      pet.ownerId!,
                                    );
                                    if (owner?.displayName != null) {
                                      ownerName = owner!.displayName!;
                                    }
                                  } catch (e) {
                                    debugPrint(
                                      'Error fetching owner details: $e',
                                    );
                                  }
                                }

                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        otherUserId: pet.ownerId ?? 'unknown',
                                        otherUserName: ownerName,
                                      ),
                                    ),
                                  );
                                }
                              },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: 'navigate'.tr(),
                    icon: Icons.map, // Changed icon to map
                    backgroundColor: AppColors.secondaryBase,
                    onPressed: () {
                      // 1. Select pet in MapViewModel
                      final mapVM = Provider.of<MapViewModel>(
                        context,
                        listen: false,
                      );
                      mapVM.selectPet(pet);

                      // 2. Switch to Map Tab
                      final navVM = Provider.of<NavigationViewModel>(
                        context,
                        listen: false,
                      );
                      navVM.setIndex(0);

                      // 3. Pop until we are back at the main shell
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (Provider.of<AuthViewModel>(context, listen: false)
                          .user
                          ?.uid ==
                      pet.ownerId)
                    PrimaryButton(
                      text: 'delete_post'.tr(),
                      icon: Icons.delete,
                      backgroundColor: AppColors.error,
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('delete'.tr()),
                            content: Text('delete_confirm'.tr()),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('cancel'.tr())),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('delete'.tr(),
                                      style:
                                          const TextStyle(color: Colors.red))),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          final petsVM = Provider.of<PetsViewModel>(context,
                              listen: false);
                          final success = await petsVM.deletePet(pet.id!);
                          if (success && context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.labelSmall(isDark: isDark)),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.bodyMediumBold(isDark: isDark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
