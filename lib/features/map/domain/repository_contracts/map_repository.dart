import 'package:lumaview/features/map/domain/entities/map_bounds.dart';
import 'package:lumaview/features/map/domain/entities/map_item.dart';

abstract class MapRepository {
  Future<List<MapItem>> getItems({
    required MapBounds bounds,
    List<String>? placeTypeSlugs,
    List<String>? tagSlugs,
  });
}

