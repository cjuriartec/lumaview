enum MapItemType {
  cluster,
  place,
}

class MapItem {
  const MapItem({
    required this.type,
    required this.id,
    required this.lat,
    required this.lng,
    required this.count,
    this.bboxNeLat,
    this.bboxNeLng,
    this.bboxSwLat,
    this.bboxSwLng,
    this.name,
    this.placeType,
    this.tags = const [],
    this.primaryImageUrl,
  });

  final MapItemType type;
  final String id;
  final double lat;
  final double lng;
  final int count;
  final double? bboxNeLat;
  final double? bboxNeLng;
  final double? bboxSwLat;
  final double? bboxSwLng;
  final String? name;
  final String? placeType;
  final List<String> tags;
  final String? primaryImageUrl;
}
