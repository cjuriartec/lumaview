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
    final params = <String, dynamic>{
      'ne_lat': bounds.neLat,
      'ne_lng': bounds.neLng,
      'sw_lat': bounds.swLat,
      'sw_lng': bounds.swLng,
      'zoom': bounds.zoom.round(),
    };
    if (placeTypeSlugs != null && placeTypeSlugs.isNotEmpty) {
      params['place_type_slugs'] = placeTypeSlugs;
    }
    if (tagSlugs != null && tagSlugs.isNotEmpty) {
      params['tag_slugs'] = tagSlugs;
    }

    final response = await _client.rpc(
      'get_places_clusters',
      params: params,
    );

    if (response == null) return [];
    final list = response is List ? response : [];
    return list
        .map((e) {
          if (e is! Map<String, dynamic>) return null;
          return MapItemDto.fromJson(e);
        })
        .whereType<MapItemDto>()
        .toList();
  }
}

