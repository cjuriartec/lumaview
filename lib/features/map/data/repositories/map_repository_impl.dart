import 'package:lumaview/features/map/data/data_sources/map_remote_data_source.dart';
import 'package:lumaview/features/map/domain/entities/map_bounds.dart';
import 'package:lumaview/features/map/domain/entities/map_item.dart';
import 'package:lumaview/features/map/domain/repository_contracts/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  const MapRepositoryImpl(this._remoteDataSource);

  final MapRemoteDataSource _remoteDataSource;

  @override
  Future<List<MapItem>> getItems({
    required MapBounds bounds,
    List<String>? placeTypeSlugs,
    List<String>? tagSlugs,
  }) async {
    final dtos = await _remoteDataSource.getItems(
      bounds: bounds,
      placeTypeSlugs: placeTypeSlugs,
      tagSlugs: tagSlugs,
    );

    return dtos
        .map(
          (dto) => MapItem(
            type: dto.type == 'cluster'
                ? MapItemType.cluster
                : MapItemType.place,
            id: dto.id,
            lat: dto.lat,
            lng: dto.lng,
            count: dto.count,
            bboxNeLat: dto.bboxNeLat,
            bboxNeLng: dto.bboxNeLng,
            bboxSwLat: dto.bboxSwLat,
            bboxSwLng: dto.bboxSwLng,
            name: dto.name,
            placeType: dto.placeType,
            tags: dto.tags,
            primaryImageUrl: dto.imageUrl,
          ),
        )
        .toList();
  }
}
