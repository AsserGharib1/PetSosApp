import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:petsos/views/theme/app_colors.dart';
import 'package:petsos/views/theme/app_text_styles.dart';
import '../../../models/pet.dart';
import '../../../viewmodels/auth_viewmodel.dart';

/// Modern pet card component with gradient border and animations
class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final bool showDistance;
  final double? distance; // in km

  const PetCard({
    super.key,
    required this.pet,
    this.onTap,
    this.showDistance = false,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = AppColors.getBadgeColor(pet.status);
    final authVM = Provider.of<AuthViewModel>(context);
    final isOwner = authVM.user?.uid == pet.ownerId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.1),
            statusColor.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet image
                Hero(
                  tag: 'pet_${pet.id}',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.shade200,
                      image: pet.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(pet.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: pet.imageUrl == null
                        ? Icon(
                            Icons.pets,
                            size: 48,
                            color: statusColor.withValues(alpha: 0.5),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Pet details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pet.status == 'Lost'
                              ? 'filter_lost'.tr()
                              : 'filter_found'.tr(),
                          style: AppTextStyles.badge(),
                        ),
                      ),
                      if (isOwner) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBase,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'my_post'.tr(),
                            style: AppTextStyles.bodySmall(color: Colors.white),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),

                      // Pet name
                      Text(
                        pet.name.toLowerCase().contains('unknown') &&
                                pet.petType != null
                            ? pet.petType!
                            : pet.name,
                        style: AppTextStyles.h6(isDark: isDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pet.location,
                              style: AppTextStyles.bodySmall(isDark: isDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Date or distance
                      if (showDistance && distance != null)
                        Row(
                          children: [
                            Icon(
                              Icons.near_me,
                              size: 14,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${distance!.toStringAsFixed(1)} ${'km_away'.tr()}',
                              style: AppTextStyles.bodySmall(isDark: isDark),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pet.date,
                              style: AppTextStyles.bodySmall(isDark: isDark),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
