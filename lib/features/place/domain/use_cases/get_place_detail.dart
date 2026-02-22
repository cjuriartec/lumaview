import 'package:lumaview/features/place/domain/entities/place.dart';
import 'package:lumaview/features/place/domain/repository_contracts/place_repository.dart';

class GetPlaceDetail {
  const GetPlaceDetail(this._repository);

  final PlaceRepository _repository;

  Future<Place> call(String id) {
    return _repository.getPlaceById(id);
  }
}

