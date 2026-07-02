import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/pet.dart';
import '../models/data/services/routing_service.dart';

/// ViewModel for managing map state and interactions
class MapViewModel extends ChangeNotifier {
  // Map state
  LatLng? _mapCenter;
  double _zoomLevel = 13.0;
  Pet? _selectedPet;
  String _filterStatus = 'All'; // 'All', 'Lost', 'Found'
  bool _isFollowingUserLocation = false;

  // Routing
  final RoutingService _routingService = RoutingService();
  List<LatLng> _routePoints = [];
  bool _isRouting = false;

  // Getters
  LatLng? get mapCenter => _mapCenter;
  double get zoomLevel => _zoomLevel;
  Pet? get selectedPet => _selectedPet;
  String get filterStatus => _filterStatus;
  bool get isFollowingUserLocation => _isFollowingUserLocation;
  List<LatLng> get routePoints => _routePoints;
  bool get isRouting => _isRouting;

  /// Set map center position
  void setMapCenter(LatLng center) {
    _mapCenter = center;
    notifyListeners();
  }

  /// Set zoom level
  void setZoomLevel(double zoom) {
    _zoomLevel = zoom;
    notifyListeners();
  }

  /// Center map on user's current location
  void centerOnUserLocation(double latitude, double longitude) {
    _mapCenter = LatLng(latitude, longitude);
    _isFollowingUserLocation = true;
    notifyListeners();
  }

  /// Select a pet marker
  void selectPet(Pet? pet) {
    _selectedPet = pet;
    if (pet != null) {
      _mapCenter = LatLng(pet.latitude, pet.longitude);
    }
    notifyListeners();
  }

  /// Clear selected pet and route
  void clearSelectedPet() {
    _selectedPet = null;
    _routePoints = [];
    _isRouting = false;
    notifyListeners();
  }

  /// Fetch route from user location to selected pet
  Future<void> startNavigation(LatLng userLocation) async {
    if (_selectedPet == null) return;

    _isRouting = true;
    notifyListeners();

    final end = LatLng(_selectedPet!.latitude, _selectedPet!.longitude);
    try {
      _routePoints = await _routingService.getRoute(userLocation, end);
    } catch (e) {
      debugPrint('Error fetching route: $e');
      _routePoints = [];
    } finally {
      _isRouting = false;
      notifyListeners();
    }
  }

  /// Set filter status (All, Lost, Found)
  void setFilterStatus(String status) {
    if (['All', 'Lost', 'Found'].contains(status)) {
      _filterStatus = status;
      notifyListeners();
    }
  }

  /// Toggle following user location
  void toggleFollowUserLocation(bool follow) {
    _isFollowingUserLocation = follow;
    notifyListeners();
  }

  /// Zoom in
  void zoomIn() {
    if (_zoomLevel < 18.0) {
      _zoomLevel += 1.0;
      notifyListeners();
    }
  }

  /// Zoom out
  void zoomOut() {
    if (_zoomLevel > 1.0) {
      _zoomLevel -= 1.0;
      notifyListeners();
    }
  }

  /// Filter pets by current filter status
  List<Pet> filterPets(List<Pet> allPets) {
    if (_filterStatus == 'All') {
      return allPets;
    }
    return allPets.where((pet) => pet.status == _filterStatus).toList();
  }

  /// Reset map to default state
  void reset() {
    _selectedPet = null;
    _filterStatus = 'All';
    _isFollowingUserLocation = false;
    _zoomLevel = 13.0;
    _routePoints = [];
    _isRouting = false;
    notifyListeners();
  }
}
