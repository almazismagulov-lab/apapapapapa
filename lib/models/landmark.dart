import 'package:latlong2/latlong.dart';

class Landmark {
  String id;
  String name;
  String description;
  String category; // architecture, culture, park, museum, etc.
  LatLng coordinates;
  String imageUrl;
  int points;
  // bool isDiscovered; // Это состояние будет храниться в GameProvider
  // DateTime? discoveredAt; // Это тоже

  Landmark({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.coordinates,
    required this.imageUrl,
    required this.points,
  });
}