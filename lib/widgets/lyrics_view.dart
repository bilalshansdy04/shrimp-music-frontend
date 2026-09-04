import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../providers/lyrics_provider.dart";
import "../providers/player_provider.dart";

class LyricsView extends ConsumerStatefulWidget {
  const LyricsView({Key? key}) : super(key: key);

  @override
  ConsumerState<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<LyricsView> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveLine() {
    if (_currentIndex >= 0 && _scrollController.hasClients) {
      // Approximate position: each item is around 60-80 pixels tall.
      // We use a fixed item height or Scrollable.ensureVisible.
      // For now, simple animation using index * estimated height.
      final offset = _currentIndex * 70.0;
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lyricsAsync = ref.watch(lyricsProvider);
    final position = ref.watch(playerProvider.select((state) => state.position));

    return lyricsAsync.when(
      data: (lines) {
        if (lines.isEmpty) {
          return const Center(
            child: Text(
              "Lyrics not available",
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
          );
        }

        // Find the active line based on current position
        int newIndex = -1;
        for (int i = 0; i < lines.length; i++) {
          if (position >= lines[i].time) {
            newIndex = i;
          } else {
            break;
          }
        }

        if (newIndex != _currentIndex) {
          _currentIndex = newIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToActiveLine();
          });
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 200, horizontal: 24),
          itemCount: lines.length,
          itemBuilder: (context, index) {
            final line = lines[index];
            final isActive = index == _currentIndex;

            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isActive ? 1.0 : 0.4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isActive ? 28 : 24,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    if (line.transliteration != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        line.transliteration!,
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: isActive ? 18 : 16,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
      error: (e, st) => Center(child: Text("Error loading lyrics: $e", style: const TextStyle(color: Colors.redAccent))),
    );
  }
}

