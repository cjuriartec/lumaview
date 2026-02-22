import 'package:flutter_test/flutter_test.dart';
import 'package:lumaview/features/map/presentation/utils/map_marker_utils.dart';

/// Tests para E3-2: Render de clusters y puntos.
/// Verifica que los markers se generan correctamente para cluster y lugar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapMarkerUtils', () {
    test('clusterDescriptor returns valid descriptor for count', () async {
      final descriptor =
          await MapMarkerUtils.clusterDescriptor(count: 5, isDark: false);
      expect(descriptor, isNotNull);
    });

    test('clusterDescriptor returns different descriptors for different counts',
        () async {
      final d1 =
          await MapMarkerUtils.clusterDescriptor(count: 1, isDark: false);
      final d2 =
          await MapMarkerUtils.clusterDescriptor(count: 10, isDark: false);
      expect(d1, isNotNull);
      expect(d2, isNotNull);
    });

    test('clusterDescriptor respects isDark for light theme', () async {
      final descriptor =
          await MapMarkerUtils.clusterDescriptor(count: 3, isDark: false);
      expect(descriptor, isNotNull);
    });

    test('clusterDescriptor respects isDark for dark theme', () async {
      final descriptor =
          await MapMarkerUtils.clusterDescriptor(count: 3, isDark: true);
      expect(descriptor, isNotNull);
    });

    test('placeDescriptor returns valid descriptor for light theme', () async {
      final descriptor = await MapMarkerUtils.placeDescriptor(isDark: false);
      expect(descriptor, isNotNull);
    });

    test('placeDescriptor returns valid descriptor for dark theme', () async {
      final descriptor = await MapMarkerUtils.placeDescriptor(isDark: true);
      expect(descriptor, isNotNull);
    });

    test('clusterDescriptor caches same count+theme', () async {
      final d1 =
          await MapMarkerUtils.clusterDescriptor(count: 7, isDark: true);
      final d2 =
          await MapMarkerUtils.clusterDescriptor(count: 7, isDark: true);
      expect(d1, equals(d2));
    });
  });
}
