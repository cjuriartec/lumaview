import 'package:flutter_test/flutter_test.dart';
import 'package:lumaview/features/place/domain/entities/place.dart';
import 'package:lumaview/features/place/domain/repository_contracts/place_repository.dart';
import 'package:lumaview/features/place/domain/use_cases/get_place_detail.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlaceRepository extends Mock implements PlaceRepository {}

void main() {
  late GetPlaceDetail useCase;
  late _MockPlaceRepository repository;

  setUp(() {
    repository = _MockPlaceRepository();
    useCase = GetPlaceDetail(repository);
  });

  test('should return place from repository when called with id', () async {
    const place = Place(
      id: '1',
      name: 'Test place',
      description: 'Description',
      latitude: 10.0,
      longitude: 20.0,
      bestSeason: 'summer',
      imageUrls: ['https://example.com/image.jpg'],
    );

    when(() => repository.getPlaceById('1')).thenAnswer((_) async => place);

    final result = await useCase('1');

    expect(result, place);
    verify(() => repository.getPlaceById('1')).called(1);
    verifyNoMoreInteractions(repository);
  });
}
