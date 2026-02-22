import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumaview/features/map/data/data_sources/map_remote_data_source.dart';
import 'package:lumaview/features/map/data/repositories/map_repository_impl.dart';
import 'package:lumaview/features/map/domain/entities/map_bounds.dart';
import 'package:lumaview/features/map/domain/entities/map_item.dart';
import 'package:lumaview/features/map/domain/repository_contracts/map_repository.dart';
import 'package:lumaview/features/map/domain/use_cases/get_clusters_for_bounds.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final mapRemoteDataSourceProvider = Provider<MapRemoteDataSource>(
  (ref) => MapRemoteDataSource(ref.read(supabaseClientProvider)),
);

final mapRepositoryProvider = Provider<MapRepository>(
  (ref) => MapRepositoryImpl(ref.read(mapRemoteDataSourceProvider)),
);

final getClustersForBoundsProvider = Provider<GetClustersForBounds>(
  (ref) => GetClustersForBounds(ref.read(mapRepositoryProvider)),
);

final mapItemsProvider =
    StateNotifierProvider<MapItemsNotifier, AsyncValue<List<MapItem>>>(
      (ref) => MapItemsNotifier(ref),
    );

class MapItemsNotifier extends StateNotifier<AsyncValue<List<MapItem>>> {
  MapItemsNotifier(this._ref) : super(const AsyncValue.data([]));

  final Ref _ref;

  Future<void> loadForBounds(MapBounds bounds) async {
    state = const AsyncValue.loading();
    try {
      final useCase = _ref.read(getClustersForBoundsProvider);
      final items = await useCase(bounds);
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
