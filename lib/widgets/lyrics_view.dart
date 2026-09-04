import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_lyric/flutter_lyric.dart";
import "../providers/lyrics_provider.dart";
import "../providers/player_provider.dart";

class LyricsView extends ConsumerStatefulWidget {
  const LyricsView({super.key});

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView> {
  final LyricController _lyricController = LyricController();
  
  @override
  void dispose() {
    _lyricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lyricsAsync = ref.watch(lyricsProvider);
    final position = ref.watch(playerProvider.select((state) => state.position));

    // Update lyric controller position
    _lyricController.setProgress(position);

    return lyricsAsync.when(
      data: (lyricData) {
        if (lyricData == null) {
          return const Center(
            child: Text(
              "Lyrics not available",
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
          );
        }

        // Load lyrics if not loaded or if lyrics changed
        _lyricController.loadLyric(
          lyricData.lrc,
          translationLyric: lyricData.translation ?? "",
        );

        return LyricView(
          controller: _lyricController,
          style: LyricStyles.default1.copyWith(
            activeHighlightColor: Colors.white,
            selectedColor: Colors.greenAccent,
            selectedTranslationColor: Colors.greenAccent.withOpacity(0.7),
          ),
          width: double.infinity,
          height: double.infinity,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
      error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.redAccent))),
    );
  }
}


