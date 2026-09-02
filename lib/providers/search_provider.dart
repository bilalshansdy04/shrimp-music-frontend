import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/song.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Song>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) {
    return []; // Return empty list if query is empty
  }
  
  final api = ref.read(apiServiceProvider);
  return await api.searchSongs(query);
});
