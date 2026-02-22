class MapItemDto {
  const MapItemDto({
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
  });

  factory MapItemDto.fromJson(Map<String, dynamic> json) {
    return MapItemDto(
      type: json['type'] as String,
      id: json['id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
      bboxNeLat: (json['bbox_ne_lat'] as num?)?.toDouble(),
      bboxNeLng: (json['bbox_ne_lng'] as num?)?.toDouble(),
      bboxSwLat: (json['bbox_sw_lat'] as num?)?.toDouble(),
      bboxSwLng: (json['bbox_sw_lng'] as num?)?.toDouble(),
      name: json['name'] as String?,
      placeType: json['place_type'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  final String type;
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
}

