import '../widgets/playlist_dialog.dart';
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../providers/album_provider.dart";
import "../providers/player_provider.dart";
import "../models/song.dart";

class AlbumScreen extends ConsumerWidget {
  final String albumId;

  const AlbumScreen({Key? key, required this.albumId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumAsync = ref.watch(albumProvider(albumId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Album"),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: albumAsync.when(
        data: (album) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100), // padding for appbar
                // Header
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      album.thumbnail,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  album.title,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  album.subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Play Button
                ElevatedButton.icon(
                  onPressed: () {
                    if (album.tracks.isNotEmpty) {
                      ref.read(playerProvider.notifier).play(album.tracks.first);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Playing first track. Full queue support coming soon!")));
                    }
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.black),
                  label: const Text("Play First Track", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),

                // Track List
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: album.tracks.length,
                  itemBuilder: (context, index) {
                    final track = album.tracks[index];
                    return ListTile(
                      leading: Text("${index + 1}", style: const TextStyle(color: Colors.white54, fontSize: 16)),
                      title: Text(track.title, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(track.artist, style: const TextStyle(color: Colors.white54)),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white54),
                        onPressed: () {
                          showAddToPlaylistDialog(context, ref, track);
                        },
                      ),
                      onTap: () {
                        ref.read(playerProvider.notifier).playQueue(album.tracks, initialIndex: index);
                      },
                    );
                  },
                ),
                const SizedBox(height: 100), // padding for player dock
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(child: Text("Error: ${err}", style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }
}



