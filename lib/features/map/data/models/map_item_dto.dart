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
    this.imageUrl,
  });

  factory MapItemDto.fromJson(Map<String, dynamic> json) {
    return MapItemDto(
      type: _string(json['type']) ?? 'place',
      id: _string(json['id']) ?? '',
      lat: _numToDouble(json['lat']) ?? 0.0,
      lng: _numToDouble(json['lng']) ?? 0.0,
      count: _numToInt(json['count']) ?? 1,
      bboxNeLat: _numToDouble(json['bbox_ne_lat']),
      bboxNeLng: _numToDouble(json['bbox_ne_lng']),
      bboxSwLat: _numToDouble(json['bbox_sw_lat']),
      bboxSwLng: _numToDouble(json['bbox_sw_lng']),
      name: _string(json['name']),
      placeType: _string(json['place_type']),
      tags: _stringList(json['tags']),
      imageUrl: _string(json['image_url']),
    );
  }

  static String? _string(dynamic v) =>
      v == null ? null : (v is String ? v : v.toString());

  static double? _numToDouble(dynamic v) =>
      v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));

  static int? _numToInt(dynamic v) =>
      v == null ? null : (v is num ? v.toInt() : int.tryParse('$v'));

  static List<String> _stringList(dynamic v) {
    if (v == null || v is! List) return const [];
    return v.map((e) => '$e').toList();
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
  final String? imageUrl;
}
