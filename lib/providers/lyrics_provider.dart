import "package:flutter_riverpod/flutter_riverpod.dart";
import "../services/lyric_service.dart";
import "player_provider.dart";

final lyricServiceProvider = Provider((ref) => LyricService());

final lyricsProvider = FutureProvider<LyricData?>((ref) async {
  final currentSong = ref.watch(playerProvider.select((state) => state.currentSong));

  if (currentSong == null) {
    return null;
  }

  final service = ref.read(lyricServiceProvider);
  return await service.fetchLyrics(currentSong.title, currentSong.artist);
});

