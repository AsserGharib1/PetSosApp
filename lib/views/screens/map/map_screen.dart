import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:petsos/views/theme/app_colors.dart';
import 'package:petsos/views/theme/app_text_styles.dart';
import '../../../models/pet.dart';
import '../../../viewmodels/pets_viewmodel.dart';
import '../../../viewmodels/location_viewmodel.dart';
import '../../../viewmodels/map_viewmodel.dart';
import '../../widgets/dialogs/location_permission_dialog.dart';
import '../../widgets/buttons/primary_button.dart';
import '../report/report_screen.dart';
import '../chat/chat_screen.dart';
import '../../../viewmodels/auth_viewmodel.dart';

/// Modern interactive map screen with location features
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
      final response = await http
          .get(url, headers: {'User-Agent': 'PetSOS/1.0 (contact@petsos.app)'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);

          _mapController.move(LatLng(lat, lon), 13.0);
          FocusManager.instance.primaryFocus?.unfocus();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('location_not_found'.tr())),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen to map center changes (e.g. from "Navigate to Location")
    final mapVM = Provider.of<MapViewModel>(context, listen: false);
    mapVM.addListener(_onMapStateChanged);

    // Initial load of pets if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final petsVM = Provider.of<PetsViewModel>(context, listen: false);
      if (petsVM.pets.isEmpty) {
        petsVM.loadPets();
      }
    });

    _initializeLocation();
  }

  void _onMapStateChanged() {
    if (!mounted) return;
    final mapVM = Provider.of<MapViewModel>(context, listen: false);
    if (mapVM.mapCenter != null) {
      // Current camera position
      final currentCenter = _mapController.camera.center;
      final newCenter = mapVM.mapCenter!;

      // Calculate distance to avoid micro-movements or loops
      final distance = const Distance().as(
        LengthUnit.Meter,
        currentCenter,
        newCenter,
      );

      // Only move if distance > 1 meter or zoom changed significantly
      if (distance > 1 ||
          (_mapController.camera.zoom - mapVM.zoomLevel).abs() > 0.1) {
        _mapController.move(newCenter, mapVM.zoomLevel);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final mapVM = Provider.of<MapViewModel>(context, listen: false);
    mapVM.removeListener(_onMapStateChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Optimization: Removed aggressive location check on resume to prevent UI jank
    // if (state == AppLifecycleState.resumed) {
    //   final locationVM = Provider.of<LocationViewModel>(context, listen: false);
    //   locationVM.checkLocationPermission().then((hasPermission) {
    //     if (hasPermission && locationVM.currentLocation == null) {
    //       locationVM.getCurrentLocation();
    //     }
    //   });
    // }
  }

  Future<void> _initializeLocation() async {
    final locationVM = Provider.of<LocationViewModel>(context, listen: false);

    // Check if we have permission
    final hasPermission = await locationVM.checkLocationPermission();

    if (!hasPermission) {
      // Show permission dialog
      if (!mounted) return;
      final result = await LocationPermissionDialog.show(context);

      if (result == true) {
        final granted = await locationVM.requestLocationPermission();
        if (!granted && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(locationVM.locationError ?? 'Location required'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => locationVM.openAppSettings(),
              ),
            ),
          );
        }
      }
    } else {
      // Already have permission, get location
      await locationVM.getCurrentLocation();
    }

    // Center map on user location if available
    if (mounted && locationVM.currentLocation != null) {
      final mapVM = Provider.of<MapViewModel>(context, listen: false);
      mapVM.centerOnUserLocation(locationVM.latitude!, locationVM.longitude!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locationVM = Provider.of<LocationViewModel>(context);
    final mapVM = Provider.of<MapViewModel>(context);
    final petsVM = Provider.of<PetsViewModel>(context);

    // Filter pets based on selected filter
    final filteredPets = mapVM.filterPets(petsVM.pets);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // Map
          _buildMap(locationVM, filteredPets),

          // Safe area overlay with UI controls
          SafeArea(
            child: _buildPointerInterceptor(
              // Prevent clicks passing through to map
              child: Column(
                children: [
                  // Top bar with filters and search
                  _buildSearchBar(isDark),
                  _buildTopBar(isDark, mapVM),
                ],
              ),
            ),
          ),

          // Controls (Zoom & Location) - Moved to top rightish/side to avoid FAB
          Positioned(
            right: 16,
            top: 180, // Moved to top right, below the filter bar
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildControlButton(
                  icon: Icons.add,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom + 1);
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildControlButton(
                  icon: Icons.remove,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom - 1);
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildControlButton(
                  icon: Icons.my_location,
                  onPressed: () async {
                    if (locationVM.currentLocation != null) {
                      _mapController.move(
                        LatLng(locationVM.latitude!, locationVM.longitude!),
                        15.0,
                      );
                    } else {
                      await locationVM.requestLocationPermission();
                      if (locationVM.currentLocation != null) {
                        _mapController.move(
                          LatLng(locationVM.latitude!, locationVM.longitude!),
                          15.0,
                        );
                      }
                    }
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Selected pet preview card
          if (mapVM.selectedPet != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16, // Full width since FAB is hidden
              child: _buildPetPreviewCard(mapVM.selectedPet!, isDark),
            ),
        ],
      ),

      // FAB for reporting (Hidden when a pet is selected to avoid overlap)
      floatingActionButton:
          mapVM.selectedPet == null ? _buildReportFAB(locationVM) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Helper widget to intercept pointers if needed, or simple container
  // Only defined locally if not available
  Widget _buildPointerInterceptor({required Widget child}) => child;

  Widget _buildMap(LocationViewModel locationVM, List<Pet> filteredPets) {
    final mapVM = Provider.of<MapViewModel>(context);
    if (locationVM.currentLocation == null &&
        locationVM.locationError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                locationVM.locationError!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Retry Location',
              width: 200,
              onPressed: () => locationVM.getCurrentLocation(),
            ),
          ],
        ),
      );
    }

    // Default center (Cairo, Egypt)
    final center = locationVM.currentLocation != null
        ? LatLng(locationVM.latitude!, locationVM.longitude!)
        : LatLng(30.0444, 31.2357);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13.0,
        minZoom: 5.0,
        maxZoom: 18.0,
        onTap: (_, __) {
          final mapVM = Provider.of<MapViewModel>(context, listen: false);
          mapVM.clearSelectedPet();
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.petsos.app',
        ),
        if (mapVM.routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: mapVM.routePoints,
                strokeWidth: 4.0,
                color: AppColors.primaryBase,
              ),
            ],
          ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () =>
                  launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            if (locationVM.currentLocation != null)
              Marker(
                point: LatLng(locationVM.latitude!, locationVM.longitude!),
                width: 60,
                height: 60,
                child: _buildUserLocationMarker(),
              ),
            ...filteredPets.map(
              (pet) => Marker(
                point: LatLng(pet.latitude, pet.longitude),
                width: 50,
                height: 50,
                child: _buildPetMarker(pet),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserLocationMarker() {
    // Simplified marker to prevent animation-loop freezing
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.userLocationMarker.withValues(alpha: 0.3),
      ),
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.userLocationMarker,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.userLocationMarker.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetMarker(Pet pet) {
    final mapVM = Provider.of<MapViewModel>(context, listen: false);
    final markerColor =
        pet.status == 'Lost' ? AppColors.lostMarker : AppColors.foundMarker;

    return GestureDetector(
      onTap: () {
        mapVM.selectPet(pet);
        _mapController.move(LatLng(pet.latitude, pet.longitude), 15.0);
      },
      child: Icon(
        Icons.location_on,
        size: 50,
        color: markerColor,
        shadows: [
          Shadow(color: markerColor.withValues(alpha: 0.5), blurRadius: 10),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'search_location'.tr(),
          border: InputBorder.none,
          icon: Icon(Icons.search,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary),
          suffixIcon: _isSearching
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)))
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
        ),
        onSubmitted: _searchLocation,
      ),
    );
  }

  Widget _buildTopBar(bool isDark, MapViewModel mapVM) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterChip('filter_all', mapVM, isDark),
          const SizedBox(width: 8),
          _buildFilterChip('filter_lost', mapVM, isDark),
          const SizedBox(width: 8),
          _buildFilterChip('filter_found', mapVM, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String labelKey, MapViewModel mapVM, bool isDark) {
    // We use the key for checking status, but we might need to map it if the VM uses hardcoded English strings.
    // Assuming MapViewModel uses 'All', 'Lost', 'Found' internall, we need a map.
    String internalStatus;
    if (labelKey == 'filter_all') {
      internalStatus = 'All';
    } else if (labelKey == 'filter_lost') {
      internalStatus = 'Lost';
    } else {
      internalStatus = 'Found';
    }

    final isSelected = mapVM.filterStatus == internalStatus;
    final chipColor = internalStatus == 'Lost'
        ? AppColors.lostPetColor
        : internalStatus == 'Found'
            ? AppColors.foundPetColor
            : AppColors.primaryBase;

    return GestureDetector(
      onTap: () => mapVM.setFilterStatus(internalStatus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          labelKey.tr(),
          style: AppTextStyles.bodySmallBold(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            isDark: isDark,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: isDark ? AppColors.primaryStart : AppColors.primaryBase,
      ),
    );
  }

  Widget _buildPetPreviewCard(Pet pet, bool isDark) {
    final mapVM = Provider.of<MapViewModel>(context);
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Pet image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                    image: pet.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(pet.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: pet.imageUrl == null
                      ? const Icon(Icons.pets, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),

                // Pet info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              pet.name.toLowerCase().contains('unknown') &&
                                      pet.petType != null
                                  ? pet.petType!
                                  : pet.name,
                              style: AppTextStyles.h6(isDark: isDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: pet.status == 'Lost'
                                  ? AppColors.lostPetColor.withValues(
                                      alpha: 0.1,
                                    )
                                  : AppColors.foundPetColor.withValues(
                                      alpha: 0.1,
                                    ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: pet.status == 'Lost'
                                    ? AppColors.lostPetColor
                                    : AppColors.foundPetColor,
                              ),
                            ),
                            child: Text(
                              pet.status == 'Lost'
                                  ? 'filter_lost'.tr()
                                  : 'filter_found'.tr(),
                              style: AppTextStyles.bodySmallBold(
                                color: pet.status == 'Lost'
                                    ? AppColors.lostPetColor
                                    : AppColors.foundPetColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.breed ?? pet.petType ?? 'Unknown Pet',
                        style: AppTextStyles.bodyMedium(isDark: isDark),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: isDark ? Colors.grey : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pet.location,
                              style: AppTextStyles.bodySmall(isDark: isDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Close button
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    final mapVM = Provider.of<MapViewModel>(
                      context,
                      listen: false,
                    );
                    mapVM.clearSelectedPet();
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),
            // Navigation Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final locationVM = Provider.of<LocationViewModel>(context,
                          listen: false);
                      if (locationVM.currentLocation != null) {
                        mapVM.startNavigation(LatLng(
                            locationVM.latitude!, locationVM.longitude!));
                      } else {
                        // Request location if missing
                        locationVM.requestLocationPermission().then((_) {
                          if (locationVM.currentLocation != null) {
                            mapVM.startNavigation(LatLng(
                                locationVM.latitude!, locationVM.longitude!));
                          }
                        });
                      }
                    },
                    icon: mapVM.isRouting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.directions, size: 18),
                    label: Text("map_start".tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBase,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    final url =
                        'https://www.google.com/maps/dir/?api=1&destination=${pet.latitude},${pet.longitude}';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.map),
                  tooltip: 'Open in Google Maps',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
              ],
            ),

            // Contact Options
            if (pet.contactInfo != null || pet.ownerId != null) ...[
              const SizedBox(height: 8),
              if (pet.ownerId ==
                  Provider.of<AuthViewModel>(context, listen: false)
                      .user
                      ?.uid) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'your_post'.tr(),
                    style: AppTextStyles.buttonSmall(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    // Call Button
                    if (pet.contactInfo != null)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final cleanNumber = pet.contactInfo!.replaceAll(
                                RegExp(r'[^\d+]'),
                                '',
                              );
                              final Uri launchUri = Uri(
                                scheme: 'tel',
                                path: cleanNumber,
                              );
                              try {
                                await launchUrl(launchUri);
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Could not launch dialer: $e')),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.phone, size: 18),
                            label: Text('call'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),

                    if (pet.contactInfo != null && pet.ownerId != null)
                      const SizedBox(width: 8),

                    // Message Button
                    if (pet.ownerId != null)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    otherUserId: pet.ownerId!,
                                    otherUserName: pet.name,
                                  ),
                                ),
                              );
                            },
                            icon:
                                const Icon(Icons.chat_bubble_outline, size: 18),
                            label: Text('message'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryBase,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportFAB(LocationViewModel locationVM) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportScreen(
              userLocation: locationVM.currentLocation != null
                  ? LatLng(locationVM.latitude!, locationVM.longitude!)
                  : null,
            ),
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: Text('report_title'.tr()),
      backgroundColor: AppColors.secondaryBase,
    );
  }
}
