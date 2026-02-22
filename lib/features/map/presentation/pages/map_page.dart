import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lumaview/features/map/domain/entities/map_bounds.dart';
import 'package:lumaview/features/map/domain/entities/map_item.dart';
import 'package:lumaview/features/map/presentation/providers/map_items_provider.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => MapPageState();
}

class MapPageState extends ConsumerState<MapPage> {
  final Completer<GoogleMapController> controllerCompleter = Completer();
  CameraPosition currentCamera = const CameraPosition(
    target: LatLng(40.0, -4.0),
    zoom: 5,
  );

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(mapItemsProvider);

    final markers = itemsAsync.maybeWhen(
      data: (items) => items
          .map(
            (item) => Marker(
              markerId: MarkerId(item.id),
              position: LatLng(item.lat, item.lng),
              infoWindow: InfoWindow(
                title: item.type == MapItemType.cluster
                    ? 'Cluster (${item.count})'
                    : item.name ?? 'Lugar',
              ),
            ),
          )
          .toSet(),
      orElse: () => <Marker>{},
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Lumaview Map')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: currentCamera,
            myLocationEnabled: false,
            onMapCreated: (controller) {
              if (!controllerCompleter.isCompleted) {
                controllerCompleter.complete(controller);
              }
            },
            onCameraMove: (position) {
              currentCamera = position;
            },
            onCameraIdle: () async {
              final controller = await controllerCompleter.future;
              final visibleRegion = await controller.getVisibleRegion();
              final ne = visibleRegion.northeast;
              final sw = visibleRegion.southwest;

              final bounds = MapBounds(
                neLat: ne.latitude,
                neLng: ne.longitude,
                swLat: sw.latitude,
                swLng: sw.longitude,
                zoom: currentCamera.zoom,
              );

              await ref.read(mapItemsProvider.notifier).loadForBounds(bounds);
            },
            markers: markers,
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: itemsAsync.when(
                  data: (items) => Text('Resultados: ${items.length}'),
                  loading: () => const Text('Cargando...'),
                  error: (error, stackTrace) =>
                      const Text('Error al cargar datos'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
