import 'queue_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/glassmorphism.dart';
import '../providers/player_provider.dart';

class DesktopPlayerDock extends ConsumerWidget {
  const DesktopPlayerDock({Key? key}) : super(key: key);

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.toString();
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final song = playerState.currentSong;
    
    // Calculate progress (0.0 to 1.0)
    double progress = 0.0;
    if (playerState.duration.inMilliseconds > 0) {
      progress = playerState.position.inMilliseconds / playerState.duration.inMilliseconds;
    }

    return GlassContainer(
      blur: 30.0,
      opacity: 0.05,
      border: const Border(top: BorderSide(color: Colors.white12, width: 1)),
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Now Playing Info
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: (song != null && song.thumbnail.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(song.thumbnail, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.music_note, color: Colors.white54),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          song?.title ?? "Not Playing",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song?.artist ?? "-",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    color: Colors.white54,
                    iconSize: 20,
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Center: Playback Controls & Scrubber
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shuffle),
                        color: Colors.white54,
                        iconSize: 20,
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        color: Colors.white,
                        onPressed: () => ref.read(playerProvider.notifier).playPrevious(),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: playerState.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.0),
                              )
                            : IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(playerState.isPlaying ? Icons.pause : Icons.play_arrow),
                                color: Colors.black,
                                onPressed: () {
                                  if (song != null) {
                                    ref.read(playerProvider.notifier).togglePlayPause();
                                  }
                                },
                              ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        color: Colors.white,
                        onPressed: () => ref.read(playerProvider.notifier).playNext(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.repeat),
                        color: Colors.white54,
                        iconSize: 20,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(_formatDuration(playerState.position), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onTapDown: (details) {
                                if (playerState.duration.inMilliseconds > 0) {
                                  final percent = details.localPosition.dx / constraints.maxWidth;
                                  final targetMs = (percent * playerState.duration.inMilliseconds).round();
                                  ref.read(playerProvider.notifier).seek(Duration(milliseconds: targetMs));
                                }
                              },
                              child: Container(
                                height: 16, // easy to touch
                                color: Colors.transparent,
                                child: Center(
                                  child: Container(
                                    height: 4,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: constraints.maxWidth * progress,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_formatDuration(playerState.duration), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),

            // Right: Volume & Extra Controls
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.lyrics_outlined),
                    color: Colors.white54,
                    iconSize: 20,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.queue_music),
                    color: Colors.white54,
                    iconSize: 20,
                    onPressed: () {
                      showQueueSheet(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.volume_up, color: Colors.white54, size: 20),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


