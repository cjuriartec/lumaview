import 'package:lumaview/features/map/data/models/map_item_dto.dart';
import 'package:lumaview/features/map/domain/entities/map_bounds.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapRemoteDataSource {
  const MapRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<MapItemDto>> getItems({
    required MapBounds bounds,
    List<String>? placeTypeSlugs,
    List<String>? tagSlugs,
  }) async {
    final response = await _client.rpc(
      'get_places_clusters',
      params: {
        'ne_lat': bounds.neLat,
        'ne_lng': bounds.neLng,
        'sw_lat': bounds.swLat,
        'sw_lng': bounds.swLng,
        'zoom': bounds.zoom.toInt(),
        'place_type_slugs': placeTypeSlugs,
        'tag_slugs': tagSlugs,
      },
    );

    final list = (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(MapItemDto.fromJson)
        .toList();

    return list;
  }
}

