import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/universal_search_data.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<UniversalSearchData>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) {
    return UniversalSearchData(tracks: [], artists: [], albums: []);
  }
  
  final api = ref.read(apiServiceProvider);
  return await api.searchSongs(query);
});
