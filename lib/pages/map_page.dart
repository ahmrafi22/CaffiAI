import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/brand_colors.dart';
import '../models/cafe_model.dart';
import '../services/cafe_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  LatLng _getInitialCenter(List<Cafe> cafes) {
    if (cafes.isNotEmpty) {
      return LatLng(cafes.first.latitude, cafes.first.longitude);
    }
    return LatLng(23.7808875, 90.2792371);
  }

  void _showCafeSheet(Cafe cafe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: BrandColors.latteFoam,
                        borderRadius: BorderRadius.circular(12),
                        image: cafe.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(cafe.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: cafe.imageUrl == null
                          ? const Center(
                              child: Icon(
                                Icons.local_cafe_rounded,
                                size: 32,
                                color: BrandColors.caramel,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cafe.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: BrandColors.deepEspresso,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cafe.location,
                            style: const TextStyle(
                              color: BrandColors.mediumRoast,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: BrandColors.caramel,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cafe.avgRating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Text(
                      'From ${cafe.startingPrice} TK',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: BrandColors.deepEspresso,
                      ),
                    ),
                  ],
                ),
                if (cafe.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: cafe.tags
                        .map(
                          (t) => Chip(
                            label: Text(
                              t,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Lat: ${cafe.latitude.toStringAsFixed(6)}  Lon: ${cafe.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mapController.move(
                        LatLng(cafe.latitude, cafe.longitude),
                        16,
                      );
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('Center on map'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Cafe>>(
        stream: cafeService.cafesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: BrandColors.caramel),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cafes found'));
          }

          final cafes = snapshot.data!;

          final markers = cafes.map((c) {
            return Marker(
              width: 48,
              height: 48,
              point: LatLng(c.latitude, c.longitude),
              child: GestureDetector(
                onTap: () => _showCafeSheet(c),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 40,
                  color: BrandColors.caramel,
                ),
              ),
            );
          }).toList();

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _getInitialCenter(cafes),
              initialZoom: 13.0,
              maxZoom: 18,
              minZoom: 3,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.caffiai',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }
}
