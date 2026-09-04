import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../providers/player_provider.dart";

void showQueueSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Up Next", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final playerState = ref.watch(playerProvider);
                  final queue = playerState.queue;
                  if (queue.isEmpty) {
                    return const Center(child: Text("Queue is empty", style: TextStyle(color: Colors.white54)));
                  }

                  return ListView.builder(
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final song = queue[index];
                      final isPlaying = index == playerState.queueIndex;

                      return ListTile(
                        leading: song.thumbnail.isNotEmpty
                            ? Image.network(song.thumbnail, width: 48, height: 48, fit: BoxFit.cover)
                            : Container(width: 48, height: 48, color: Colors.white10, child: const Icon(Icons.music_note, color: Colors.white54)),
                        title: Text(
                          song.title,
                          style: TextStyle(color: isPlaying ? Colors.greenAccent : Colors.white, fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.artist,
                          style: TextStyle(color: isPlaying ? Colors.greenAccent.withValues(alpha: 0.7) : Colors.white54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isPlaying ? const Icon(Icons.volume_up, color: Colors.greenAccent) : null,
                        onTap: () {
                          ref.read(playerProvider.notifier).playQueue(queue, initialIndex: index);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

