import 'package:lumaview/features/place/data/models/place_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlaceRemoteDataSource {
  const PlaceRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<PlaceDto?> getPlaceById(String id) async {
    final placeRow = await _client
        .from('places')
        .select(
          'id, name, description, best_season, place_type_id, latitude, longitude',
        )
        .eq('id', id)
        .maybeSingle();

    if (placeRow == null) {
      return null;
    }

    String? placeTypeName;
    String? placeTypeSlug;

    final placeTypeId = placeRow['place_type_id'] as String?;
    if (placeTypeId != null) {
      final placeTypeRow = await _client
          .from('place_types')
          .select('slug, name')
          .eq('id', placeTypeId)
          .maybeSingle();

      if (placeTypeRow != null) {
        placeTypeName = placeTypeRow['name'] as String?;
        placeTypeSlug = placeTypeRow['slug'] as String?;
      }
    }

    final imagesResponse = await _client
        .from('place_images')
        .select('image_url')
        .eq('place_id', id)
        .order('order', ascending: true);

    final imagesList = (imagesResponse as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => row['image_url'] as String)
        .toList();

    final placeTagsResponse = await _client
        .from('place_tags')
        .select('tag_id')
        .eq('place_id', id);

    final tagIds = (placeTagsResponse as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => row['tag_id'] as String)
        .toList();

    final tagNames = <String>[];
    for (final tagId in tagIds) {
      final tagRow = await _client
          .from('tags')
          .select('name')
          .eq('id', tagId)
          .maybeSingle();
      if (tagRow != null && tagRow['name'] is String) {
        tagNames.add(tagRow['name'] as String);
      }
    }

    return PlaceDto.fromJson(
      Map<String, dynamic>.from(placeRow),
      imageUrls: imagesList,
      placeTypeName: placeTypeName,
      placeTypeSlug: placeTypeSlug,
      tagNames: tagNames,
    );
  }
}
