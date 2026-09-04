import '../providers/search_provider.dart';
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/song.dart";
import "../providers/playlist_provider.dart";
import "../services/api_service.dart";
import "../providers/auth_provider.dart";

void showAddToPlaylistDialog(BuildContext context, WidgetRef ref, Song song) {
  final auth = ref.read(authProvider);
  if (!auth.isAuthenticated) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login to add to playlist")));
    return;
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Add to Playlist", style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Consumer(builder: (context, ref, child) {
            final playlistsAsync = ref.watch(playlistsProvider);
            return playlistsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
              data: (playlists) {
                if (playlists.isEmpty) return const Center(child: Text("No playlists available", style: TextStyle(color: Colors.white70)));
                return ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final pl = playlists[index];
                    return ListTile(
                      title: Text(pl.name, style: const TextStyle(color: Colors.white)),
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await ref.read(apiServiceProvider).addTrackToPlaylist(pl.id, {
                            "id": song.id,
                            "title": song.title,
                            "artist": song.artist,
                            "thumbnail": song.thumbnail,
                            "duration": song.duration,
                          });
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added to ${pl.name}")));
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                        }
                      },
                    );
                  },
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}


