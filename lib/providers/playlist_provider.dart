import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/playlist.dart";
import "search_provider.dart";
import "auth_provider.dart";

final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return [];
  
  final rawData = await ref.read(apiServiceProvider).getPlaylists();
  return (rawData as List).map((json) => Playlist.fromJson(json)).toList();
});

final playlistTracksProvider = FutureProvider.family<List<PlaylistTrack>, String>((ref, playlistId) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return [];
  
  final rawData = await ref.read(apiServiceProvider).getPlaylistTracks(playlistId);
  return (rawData as List).map((json) => PlaylistTrack.fromJson(json)).toList();
});

