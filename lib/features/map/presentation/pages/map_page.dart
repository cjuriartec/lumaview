import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lumaview/core/theme/map_styles.dart';
import 'package:lumaview/core/theme/theme_utils.dart';
import 'package:lumaview/features/map/domain/entities/map_bounds.dart';
import 'package:lumaview/features/map/domain/entities/map_item.dart';
import 'package:lumaview/features/map/presentation/providers/map_items_provider.dart';
import 'package:lumaview/features/map/presentation/utils/map_marker_utils.dart';

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

  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 350);

  BitmapDescriptor? _placeIcon;
  Set<Marker> _markers = {};
  bool _iconsReady = false;
  List<MapItem>? _lastBuiltItems;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadPlaceIcon() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeIcon = await MapMarkerUtils.placeDescriptor(isDark: isDark);
    if (mounted) {
      setState(() {
        _placeIcon = placeIcon;
        _iconsReady = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = ThemeUtils.isDark(context);
    if (_lastThemeDark != isDark) {
      _lastThemeDark = isDark;
      _lastBuiltItems = null;
      _loadPlaceIcon(); // Carga inicial + cuando cambia el tema
    }
  }

  bool? _lastThemeDark;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onCameraIdle() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      if (!mounted) return;
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
    });
  }

  bool _itemsEqual(List<MapItem> a, List<MapItem>? b) {
    if (b == null) return a.isEmpty;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].count != b[i].count) return false;
    }
    return true;
  }

  Future<void> _buildMarkersAsync(List<MapItem> items) async {
    if (!_iconsReady || _placeIcon == null) return;
    final isDark = ThemeUtils.isDark(context);

    final markers = <Marker>{};
    for (final item in items) {
      final icon = item.type == MapItemType.cluster
          ? await MapMarkerUtils.clusterDescriptor(
              count: item.count,
              isDark: isDark,
            )
          : _placeIcon!;

      final isCluster = item.type == MapItemType.cluster;
      markers.add(
        Marker(
          markerId: MarkerId(item.id),
          position: LatLng(item.lat, item.lng),
          icon: icon,
          onTap: () => _onMarkerTap(item),
          anchor: isCluster ? const Offset(0.5, 0.5) : const Offset(0.5, 1.0),
          zIndexInt: isCluster ? 0 : 1,
          infoWindow: InfoWindow(
            title: item.type == MapItemType.cluster
                ? '${item.count} lugares'
                : (item.name ?? 'Lugar'),
          ),
        ),
      );
    }

    if (mounted) {
      setState(() => _markers = markers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(mapItemsProvider);

    // Mantener marcadores previos visibles durante carga para transición fluida
    final items = itemsAsync.valueOrNull ?? [];

    // Reconstruir marcadores solo cuando los items cambian (evita bucles)
    if (_iconsReady && !_itemsEqual(items, _lastBuiltItems)) {
      _lastBuiltItems = List.from(items);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _buildMarkersAsync(items);
      });
    } else if (items.isEmpty && _markers.isNotEmpty) {
      _lastBuiltItems = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _markers = {});
      });
    }

    final isDark = ThemeUtils.isDark(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: currentCamera,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              style: isDark ? darkMapStyle : null,
              onMapCreated: (controller) {
                if (!controllerCompleter.isCompleted) {
                  controllerCompleter.complete(controller);
                }
              },
              onCameraMove: (position) {
                currentCamera = position;
              },
              onCameraIdle: _onCameraIdle,
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onMarkerTap(MapItem item) async {
    if (item.type != MapItemType.cluster) return;
    final controller = await controllerCompleter.future;
    if (item.bboxNeLat != null &&
        item.bboxNeLng != null &&
        item.bboxSwLat != null &&
        item.bboxSwLng != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(item.bboxSwLat!, item.bboxSwLng!),
        northeast: LatLng(item.bboxNeLat!, item.bboxNeLng!),
      );
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 64));
    } else {
      final targetZoom = (currentCamera.zoom + 2).clamp(3.0, 20.0);
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(item.lat, item.lng), zoom: targetZoom),
        ),
      );
    }
  }
}
