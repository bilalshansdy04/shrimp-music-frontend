import 'search_provider.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../services/api_service.dart";
import "../models/artist_profile_data.dart";

final artistProvider = FutureProvider.family<ArtistProfileData, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  return api.getArtist(id);
});

