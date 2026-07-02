import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/pets_viewmodel.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class PetsTab extends StatelessWidget {
  const PetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PetsViewModel>(
      builder: (context, petsVM, child) {
        if (petsVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final pets = petsVM.pets;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (pets.isEmpty) {
          return Center(child: Text('no_pets_found'.tr()));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: pet.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(pet.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey.shade300,
                  ),
                  child: pet.imageUrl == null ? const Icon(Icons.pets) : null,
                ),
                title: Text(
                  pet.name,
                  style: AppTextStyles.bodyMediumBold(isDark: isDark),
                ),
                subtitle: Text(
                  '${(pet.petType?.toLowerCase() ?? "unknown").tr()} - ${pet.status == 'Lost' ? 'filter_lost'.tr() : 'filter_found'.tr()}',
                  style: AppTextStyles.label(isDark: isDark),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // Confirm delete
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('delete_post_title'.tr()),
                        content: Text('delete_post_content'.tr()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('cancel'.tr()),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'delete'.tr(),
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && pet.id != null) {
                      await petsVM.deletePet(pet.id!);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
