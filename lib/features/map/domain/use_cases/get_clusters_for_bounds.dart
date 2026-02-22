import 'package:lumaview/features/map/domain/entities/map_bounds.dart';
import 'package:lumaview/features/map/domain/entities/map_item.dart';
import 'package:lumaview/features/map/domain/repository_contracts/map_repository.dart';

class GetClustersForBounds {
  const GetClustersForBounds(this._repository);

  final MapRepository _repository;

  Future<List<MapItem>> call(MapBounds bounds) {
    return _repository.getItems(bounds: bounds);
  }
}

