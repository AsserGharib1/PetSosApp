import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/pets_viewmodel.dart';
import 'package:app/views/theme/app_colors.dart';
import 'package:app/views/theme/app_text_styles.dart';
import '../../widgets/cards/pet_card.dart';
import '../../widgets/inputs/custom_text_field.dart';
import '../../widgets/buttons/secondary_button.dart';
import '../pet_detail/pet_detail_screen.dart'; // Will create this next
import '../../../viewmodels/location_viewmodel.dart';

class AbandonedScreen extends StatefulWidget {
  const AbandonedScreen({super.key});

  @override
  State<AbandonedScreen> createState() => _AbandonedScreenState();
}

class _AbandonedScreenState extends State<AbandonedScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final petsVM = Provider.of<PetsViewModel>(context, listen: false);
      if (petsVM.pets.isEmpty) {
        petsVM.loadPets();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final petsViewModel = Provider.of<PetsViewModel>(context);
    final locationViewModel = Provider.of<LocationViewModel>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title:
            Text('nav_abandoned'.tr(), style: AppTextStyles.h5(isDark: isDark)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter dialog/sheet
              _showFilterSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: _searchController,
              hint: 'search_hint'.tr(),
              prefixIcon: Icons.search,
              onChanged: (value) {
                // Implement search filtering
                setState(() {}); // Simple rebuild to trigger filter
              },
            ),
          ),

          // Pets List
          Expanded(
            child: petsViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : petsViewModel.pets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets,
                                size: 64,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.textTertiary),
                            const SizedBox(height: 16),
                            Text(
                              'no_abandoned_pets'.tr(),
                              style: AppTextStyles.bodyMedium(isDark: isDark),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: petsViewModel
                            .pets.length, // Should filter based on search
                        itemBuilder: (context, index) {
                          final pet = petsViewModel.pets[index];

                          // Basic search filter
                          if (_searchController.text.isNotEmpty) {
                            if (!pet.name.toLowerCase().contains(
                                    _searchController.text.toLowerCase()) &&
                                !(pet.breed?.toLowerCase().contains(
                                        _searchController.text.toLowerCase()) ??
                                    false)) {
                              return const SizedBox.shrink();
                            }
                          }

                          return PetCard(
                            pet: pet,
                            showDistance: true,
                            distance: locationViewModel.calculateDistance(
                                pet.latitude, pet.longitude),
                            onTap: () {
                              // Navigate to detail
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PetDetailScreen(pet: pet),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('filter_pets'.tr(),
                style: AppTextStyles.h5(
                    isDark: Theme.of(context).brightness == Brightness.dark)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['All', 'Lost', 'Found'].map((status) {
                return ChoiceChip(
                  label: Text(status == 'All'
                      ? 'filter_all'.tr()
                      : (status == 'Lost'
                          ? 'filter_lost'.tr()
                          : 'filter_found'.tr())),
                  selected: _filter == status,
                  onSelected: (selected) {
                    setState(() {
                      _filter = status;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              text: 'close'.tr(),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }
}
