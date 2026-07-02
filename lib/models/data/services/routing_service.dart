import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

class RoutingService {
  static const String _baseUrl =
      'https://router.project-osrm.org/route/v1/driving';

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      '$_baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] == null || (data['routes'] as List).isEmpty) {
          return [];
        }

        final geometry = data['routes'][0]['geometry'];
        final coordinates = geometry['coordinates'] as List;

        return coordinates.map((coord) {
          // OSRM returns [lon, lat]
          return LatLng(
            (coord[1] as num).toDouble(),
            (coord[0] as num).toDouble(),
          );
        }).toList();
      } else {
        debugPrint('Failed to load route: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
      return [];
    }
  }
}
