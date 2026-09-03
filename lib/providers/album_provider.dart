import "package:flutter_riverpod/flutter_riverpod.dart";
import "search_provider.dart";
import "../models/album_profile_data.dart";

final albumProvider = FutureProvider.family<AlbumProfileData, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  return api.getAlbum(id);
});

