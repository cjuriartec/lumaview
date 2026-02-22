import 'package:lumaview/features/place/data/data_sources/place_remote_data_source.dart';
import 'package:lumaview/features/place/domain/entities/place.dart';
import 'package:lumaview/features/place/domain/repository_contracts/place_repository.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  const PlaceRepositoryImpl(this._remoteDataSource);

  final PlaceRemoteDataSource _remoteDataSource;

  @override
  Future<Place> getPlaceById(String id) async {
    final dto = await _remoteDataSource.getPlaceById(id);
    if (dto == null) {
      throw Exception('Place not found');
    }

    return Place(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      latitude: dto.latitude,
      longitude: dto.longitude,
      bestSeason: dto.bestSeason,
      imageUrls: dto.imageUrls,
      placeTypeName: dto.placeTypeName,
      placeTypeSlug: dto.placeTypeSlug,
      tagNames: dto.tagNames,
    );
  }
}
