class Place {
  const Place({
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
}
