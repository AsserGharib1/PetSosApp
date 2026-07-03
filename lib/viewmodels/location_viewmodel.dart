import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petsos/models/data/services/location_service.dart';

/// ViewModel for managing location state and permissions
class LocationViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  // State variables
  Position? _currentLocation;
  bool _isLoadingLocation = false;
  bool _hasLocationPermission = false;
  String? _locationError;

  // Getters
  Position? get currentLocation => _currentLocation;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get hasLocationPermission => _hasLocationPermission;
  String? get locationError => _locationError;

  double? get latitude => _currentLocation?.latitude;
  double? get longitude => _currentLocation?.longitude;

  /// Initialize location services and check permission
  Future<void> initialize() async {
    await checkLocationPermission();
    if (_hasLocationPermission) {
      await getCurrentLocation();
    }
  }

  /// Check if location permission is granted
  Future<bool> checkLocationPermission() async {
    try {
      final permission = await _locationService.checkPermission();
      _hasLocationPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (!_hasLocationPermission) {
        debugPrint('Location permission status: $permission');
      }

      notifyListeners();
      return _hasLocationPermission;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  /// Request location permission from user
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await _locationService.requestLocationPermission();

      _hasLocationPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (permission == LocationPermission.denied) {
        _locationError = 'Location permission denied';
      } else if (permission == LocationPermission.deniedForever) {
        _locationError =
            'Location permission permanently denied. Please enable it in settings.';
      }

      notifyListeners();

      // If permission granted, get current location
      if (_hasLocationPermission) {
        await getCurrentLocation();
      }

      return _hasLocationPermission;
    } catch (e) {
      _locationError = 'Failed to request permission: $e';
      notifyListeners();
      return false;
    }
  }

  // This function uses the 'geolocator' package to access the device's GPS hardware.
  // It handles permissions and retrieves high-accuracy coordinates.
  Future<Position?> getCurrentLocation() async {
    _isLoadingLocation = true;
    _locationError = null;
    notifyListeners();

    debugPrint('📍 LocationViewModel: Getting current location...');

    try {
      // 1. Check Service Status
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('📍 LocationViewModel: Location services are DISABLED');
        _locationError = 'Location services are disabled on device';
        _isLoadingLocation = false;
        notifyListeners();
        return null;
      }

      // 2. Check Permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint(
            '📍 LocationViewModel: Permission initially denied, requesting...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('📍 LocationViewModel: Permission denied by user');
          _locationError = 'Location permissions are denied';
          _isLoadingLocation = false;
          notifyListeners();
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('📍 LocationViewModel: Permission denied forever');
        _locationError = 'Location permissions are permanently denied';
        _isLoadingLocation = false;
        notifyListeners();
        return null;
      }

      // 3. Get Position (with timeout)
      debugPrint('📍 LocationViewModel: Permission OK, fetching position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentLocation = position;
      _hasLocationPermission = true;
      debugPrint(
          '📍 LocationViewModel: Location acquired: ${position.latitude}, ${position.longitude}');

      _isLoadingLocation = false;
      notifyListeners();
      return position;
    } catch (e) {
      debugPrint('📍 LocationViewModel: Error getting location: $e');
      _locationError = 'Error: $e';
      _isLoadingLocation = false;
      notifyListeners();
      return null;
    }
  }

  /// Start listening to location updates
  Stream<Position>? startLocationUpdates() {
    if (!_hasLocationPermission) {
      debugPrint(
          'Location permission not granted. Cannot start location updates.');
      return null;
    }

    return _locationService.getLocationStream();
  }

  /// Update current location ( from stream)
  void updateLocation(Position position) {
    _currentLocation = position;
    notifyListeners();
  }

  /// Calculate distance from current location to a point
  double? calculateDistance(double targetLat, double targetLng) {
    if (_currentLocation == null) {
      return null;
    }

    return _locationService.calculateDistance(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      targetLat,
      targetLng,
    );
  }

  /// Clear location error
  void clearError() {
    _locationError = null;
    notifyListeners();
  }

  /// Refresh current location
  Future<void> refreshLocation() async {
    await getCurrentLocation();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
