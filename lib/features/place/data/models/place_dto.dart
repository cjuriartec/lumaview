class PlaceDto {
  const PlaceDto({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.bestSeason,
    this.imageUrls = const [],
    this.placeTypeName,
    this.placeTypeSlug,
    this.tagNames = const [],
  });

  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String? bestSeason;
  final List<String> imageUrls;
  final String? placeTypeName;
  final String? placeTypeSlug;
  final List<String> tagNames;

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  factory PlaceDto.fromJson(
    Map<String, dynamic> json, {
    List<String> imageUrls = const [],
    String? placeTypeName,
    String? placeTypeSlug,
    List<String> tagNames = const [],
  }) {
    return PlaceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      bestSeason: json['best_season'] as String?,
      imageUrls: imageUrls,
      placeTypeName: placeTypeName,
      placeTypeSlug: placeTypeSlug,
      tagNames: tagNames,
    );
  }
}
