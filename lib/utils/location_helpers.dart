import 'package:latlong2/latlong.dart';

// Генерирует список точек (LatLng) для создания круга
List<LatLng> createCircleHole(LatLng center, double radiusInMeters) {
  final distance = const Distance();
  final List<LatLng> points = [];
  // 36 точек для достаточно гладкого круга
  for (int i = 0; i <= 360; i += 10) {
    points.add(distance.offset(center, radiusInMeters, i.toDouble()));
  }
  return points;
}