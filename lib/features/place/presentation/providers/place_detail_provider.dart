import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumaview/features/place/data/data_sources/place_remote_data_source.dart';
import 'package:lumaview/features/place/data/repositories/place_repository_impl.dart';
import 'package:lumaview/features/place/domain/entities/place.dart';
import 'package:lumaview/features/place/domain/repository_contracts/place_repository.dart';
import 'package:lumaview/features/place/domain/use_cases/get_place_detail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final placeSupabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final placeRemoteDataSourceProvider = Provider<PlaceRemoteDataSource>(
  (ref) => PlaceRemoteDataSource(ref.read(placeSupabaseClientProvider)),
);

final placeRepositoryProvider = Provider<PlaceRepository>(
  (ref) => PlaceRepositoryImpl(ref.read(placeRemoteDataSourceProvider)),
);

final getPlaceDetailProvider = Provider<GetPlaceDetail>(
  (ref) => GetPlaceDetail(ref.read(placeRepositoryProvider)),
);

final placeDetailProvider = FutureProvider.family<Place, String>((
  ref,
  placeId,
) async {
  final useCase = ref.read(getPlaceDetailProvider);
  return useCase(placeId);
});

final isUserAuthenticatedProvider = Provider<bool>(
  (ref) => Supabase.instance.client.auth.currentUser != null,
);
