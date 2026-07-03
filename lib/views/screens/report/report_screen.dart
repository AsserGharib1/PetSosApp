import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:petsos/views/theme/app_colors.dart';
import 'package:petsos/views/theme/app_text_styles.dart';
import '../../../models/pet.dart';
import '../../../viewmodels/pets_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'package:petsos/views/screens/report/location_picker_screen.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/custom_text_field.dart';

/// Modern report screen for lost/found pets with auto-location
class ReportScreen extends StatefulWidget {
  final LatLng? userLocation;

  const ReportScreen({super.key, this.userLocation});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _breedController = TextEditingController();
  final _contactController = TextEditingController();
  // Image URL controller removed

  String _status = 'Lost';
  String? _petType = 'Dog';
  final String _size = 'Medium';
  String? _gender;
  String? _color;
  File? _selectedImage;
  bool _isSubmitting = false;
  LatLng? _selectedCoordinates;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() {
    if (widget.userLocation != null) {
      _selectedCoordinates = widget.userLocation;
      _updateLocationText();
    }
  }

  void _updateLocationText() {
    if (_selectedCoordinates != null) {
      _locationController.text =
          '${_selectedCoordinates!.latitude.toStringAsFixed(4)}, ${_selectedCoordinates!.longitude.toStringAsFixed(4)}';
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedCoordinates = LatLng(position.latitude, position.longitude);
        _updateLocationText();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('current_location'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
    }
  }

  Future<void> _pickLocationOnMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: _selectedCoordinates ?? widget.userLocation,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCoordinates = result;
        _updateLocationText();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _breedController.dispose();
    _contactController.dispose();
    _contactController.dispose();
    // _imageUrlController.dispose();
    super.dispose();
  }

  // This method uses the 'image_picker' package to access the device's
  // camera and photo gallery, allowing users to upload pet photos.
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('select_image_source'.tr(), style: AppTextStyles.h5()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('camera'.tr()),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('gallery'.tr()),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final petsViewModel = Provider.of<PetsViewModel>(context, listen: false);
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      final user = authViewModel.user;
      final ownerId = user?.uid ?? (authViewModel.isLoggedIn ? 'guest' : null);

      // Use exact user location
      final double lat = _selectedCoordinates?.latitude ?? 30.0444;
      final double lng = _selectedCoordinates?.longitude ?? 31.2357;

      final newPet = Pet(
        name: _status == 'Lost'
            ? _nameController.text.trim()
            : 'unknown_pet'.tr(),
        status: _status,
        location: _locationController.text.trim(),
        date: DateTime.now().toString().split(' ')[0],
        description: _descriptionController.text.trim(),
        latitude: lat,
        longitude: lng,
        imageUrl: null, // Will be set in ViewModel after upload
        ownerId: ownerId,
        breed: _breedController.text.isNotEmpty ? _breedController.text : null,
        petType: _petType,
        color: _color,
        size: _size,
        gender: _gender,
        contactInfo:
            _contactController.text.isNotEmpty ? _contactController.text : null,
      );

      // Pass the selected image file to ViewModel
      final success =
          await petsViewModel.addPet(newPet, imageFile: _selectedImage);

      if (!success) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(petsViewModel.errorMessage ?? 'Unknown error'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text('OK')),
            ],
          ),
        );
        return;
      }

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success),
              ),
              const SizedBox(width: 12),
              Text('success'.tr(), style: AppTextStyles.h5()),
            ],
          ),
          content: Text(
            'report_success_message'.tr(),
            style: AppTextStyles.bodyMedium(),
          ),
          actions: [
            PrimaryButton(
              text: 'ok'.tr(),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to map
              },
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting report: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'report_lost_found'.tr(),
          style: AppTextStyles.h5(isDark: isDark),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Image picker section
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 48,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'tap_to_add_photo'.tr(),
                            style: AppTextStyles.bodyMedium(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Status dropdown
            Text('status'.tr(), style: AppTextStyles.label(isDark: isDark)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _status,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                        value: 'Lost', child: Text('filter_lost'.tr())),
                    DropdownMenuItem(
                        value: 'Found', child: Text('filter_found'.tr())),
                  ],
                  onChanged: (value) =>
                      setState(() => _status = value ?? 'Lost'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Pet name (Only for Lost pets)
            if (_status == 'Lost') ...[
              CustomTextField(
                controller: _nameController,
                label: 'pet_name'.tr(),
                hint: 'pet_name_hint'.tr(),
                prefixIcon: Icons.pets,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'pet_name_error'.tr()
                    : null,
              ),
              const SizedBox(height: 16),
            ],

            // Pet type
            Text('pet_type'.tr(), style: AppTextStyles.label(isDark: isDark)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _petType,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 'Dog', child: Text('dog'.tr())),
                    DropdownMenuItem(value: 'Cat', child: Text('cat'.tr())),
                    DropdownMenuItem(value: 'Other', child: Text('other'.tr())),
                  ],
                  onChanged: (value) => setState(() => _petType = value),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Breed
            CustomTextField(
              controller: _breedController,
              label: 'breed'.tr(),
              hint: 'breed_hint'.tr(),
              prefixIcon: Icons.category,
            ),
            const SizedBox(height: 16),

            // Location
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('location'.tr(),
                    style: AppTextStyles.label(isDark: isDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _useCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: Text('current_location'.tr()),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickLocationOnMap,
                        icon: const Icon(Icons.map),
                        label: Text('pick_on_map'.tr()),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _locationController,
                  label: '',
                  hint: 'location_hint'.tr(),
                  prefixIcon: Icons.location_on,
                  readOnly: true,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'location_error'.tr()
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            CustomTextField(
              controller: _descriptionController,
              label: 'description'.tr(),
              hint: 'description_hint'.tr(),
              prefixIcon: Icons.description,
              maxLines: 4,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'description_error'.tr()
                  : null,
            ),
            const SizedBox(height: 16),

            // Contact info
            CustomTextField(
              controller: _contactController,
              label: 'contact_info'.tr(),
              hint: 'contact_hint'.tr(),
              prefixIcon: Icons.contact_phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 32),

            // Submit button
            PrimaryButton(
              text: 'submit_report'.tr(),
              onPressed: _submitReport,
              isLoading: _isSubmitting,
              icon: Icons.send,
              height: 56,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
