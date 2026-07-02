import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app/views/theme/app_colors.dart';
import 'package:app/views/theme/app_text_styles.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final MapController _mapController;
  late LatLng _selectedLocation;

  // Default to Cairo if no location provided
  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation ?? _defaultLocation;
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    setState(() {
      _selectedLocation = camera.center;
    });
  }

  void _confirmLocation() {
    Navigator.of(context).pop(_selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('pick_location'.tr(), style: AppTextStyles.h6(isDark: isDark)),
        actions: [
          TextButton(
            onPressed: _confirmLocation,
            child: Text(
              'confirm'.tr(),
              style: AppTextStyles.buttonSmall(
                color: isDark ? AppColors.primaryStart : AppColors.primaryBase,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onPositionChanged: _onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                // Dark mode tiles could be used here if available,
                // for now standard OSM tiles
              ),
            ],
          ),

          // Center Marker (Fixed)
          const Center(
            child: Icon(
              Icons.location_on,
              size: 48,
              color: AppColors.primaryBase,
            ),
          ),

          // User guidance text
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'move_map_hint'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(isDark: isDark),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reset to initial or user location if we had access to it here
          // For now just recenter on initial
          _mapController.move(widget.initialLocation ?? _defaultLocation, 15.0);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
