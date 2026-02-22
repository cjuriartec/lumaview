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
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      bestSeason: json['best_season'] as String?,
      imageUrls: imageUrls,
      placeTypeName: placeTypeName,
      placeTypeSlug: placeTypeSlug,
      tagNames: tagNames,
    );
  }
}
