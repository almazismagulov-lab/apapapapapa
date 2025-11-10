import 'package:astana_explorer/data/mock_data.dart';
import 'package:astana_explorer/providers/game_provider.dart';
import 'package:astana_explorer/utils/location_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:astana_explorer/models/landmark.dart'; 
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  static const LatLng _astanaCenter = LatLng(51.13, 71.43); // Центр Астаны
  
  // Радиус "зрения" в реальном времени (Dota 2 style)
  static const double visibilityRadius = 300; 
  // Радиус *обнаружения* (200м) будет браться из GameProvider

  void _showLandmarkDetails(BuildContext context, Landmark landmark) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(landmark.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(landmark.description),
            const SizedBox(height: 16),
            Text("Категория: ${landmark.category}"),
            Text("Очки: ${landmark.points}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Используем Consumer для автоматической перерисовки при изменениях
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        
        // --- ГИБРИДНАЯ ЛОГИКА ТУМАНА ---
        
        // 1. Получаем текущую позицию пользователя
        final userPosition = gameProvider.currentPosition;
        final userLatLng = userPosition != null
            ? LatLng(userPosition.latitude, userPosition.longitude)
            : null;

        // 2. Получаем центры УЖЕ ОТКРЫТЫХ зон (Civilization style)
        final List<LatLng> discoveredCenters = gameProvider.discoveredHoleCenters;

        // 3. Создаем ОБЩИЙ список "дыр"
        final List<List<LatLng>> allHoles = [];

        // 4. Добавляем в список все НАВСЕГДА открытые зоны
        for (final center in discoveredCenters) {
          // Используем detectionRadius (200м), чтобы открытая зона
          // соответствовала зоне, в которой мы ее открыли
          allHoles.add(createCircleHole(center, GameProvider.detectionRadius));
        }

        // 5. Добавляем в список "дыру" вокруг игрока (Dota 2 style)
        if (userLatLng != null) {
          allHoles.add(createCircleHole(userLatLng, visibilityRadius));
        }
        // --- КОНЕЦ ГИБРИДНОЙ ЛОГИКИ ---


        return Scaffold(
          appBar: AppBar(
            title: const Text('Карта Астаны'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Обновить позицию',
                onPressed: () {
                  gameProvider.manuallyRefreshPosition();
                },
              ),
              IconButton(
                icon: const Icon(Icons.my_location),
                tooltip: 'Найти меня',
                onPressed: () {
                  if (userLatLng != null) {
                    _mapController.move(userLatLng, 15.0);
                  }
                },
              )
            ],
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _astanaCenter,
                  initialZoom: 13.0,
                ),
                children: [
                  // 1. Слой карты (OSM)
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.astana_explorer',
                  ),

                  // 2. СЛОЙ ТУМАНА ВОЙНЫ
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        // Большой прямоугольник, покрывающий Астану
                        points: [
                          LatLng(51.3, 71.2),
                          LatLng(51.3, 71.7),
                          LatLng(51.0, 71.7),
                          LatLng(51.0, 71.2),
                        ],
                        
                        // Полупрозрачность
                        color: Colors.black.withOpacity(0.6), 

                        isFilled: true,
                        borderColor: Colors.transparent,
                        
                        // Передаем наш ОБЪЕДИНЕННЫЙ список "дыр"
                        holePointsList: allHoles,
                      ),
                    ],
                  ),

                  // 3. Слой маркеров (Достопримечательности)
                  MarkerLayer(
                    markers: allLandmarks.map((landmark) {
                      final isDiscovered = gameProvider.isLandmarkDiscovered(landmark.id);
                      return Marker(
                        point: landmark.coordinates,
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _showLandmarkDetails(context, landmark),
                          child: Icon(
                            isDiscovered ? Icons.location_on : Icons.lock,
                            color: isDiscovered ? Colors.greenAccent : Colors.red,
                            size: 40.0,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // 4. Слой маркера (Игрок)
                  if (userLatLng != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: userLatLng,
                          width: 20,
                          height: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // 5. UI поверх карты (Уровень и очки)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Уровень: ${gameProvider.level} | Очки: ${gameProvider.points}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // 6. Индикатор загрузки
              if (gameProvider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}