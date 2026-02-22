import 'package:lumaview/features/place/domain/entities/place.dart';

abstract class PlaceRepository {
  Future<Place> getPlaceById(String id);
}

