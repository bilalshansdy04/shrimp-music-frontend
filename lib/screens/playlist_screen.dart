import '../providers/search_provider.dart';
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/playlist.dart";
import "../providers/playlist_provider.dart";
import "../providers/player_provider.dart";
import "../services/api_service.dart";

class PlaylistScreen extends ConsumerStatefulWidget {
  final Playlist playlist;
  const PlaylistScreen({Key? key, required this.playlist}) : super(key: key);

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  void _removeTrack(String trackId) async {
    try {
      await ref.read(apiServiceProvider).removeTrackFromPlaylist(widget.playlist.id, trackId);
      ref.invalidate(playlistTracksProvider(widget.playlist.id));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(playlistTracksProvider(widget.playlist.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: tracksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
        data: (tracks) {
          if (tracks.isEmpty) {
            return const Center(child: Text("No tracks in this playlist", style: TextStyle(color: Colors.white70)));
          }
          return ListView.builder(
            itemCount: tracks.length,
            padding: const EdgeInsets.only(bottom: 100),
            itemBuilder: (context, index) {
              final pt = tracks[index];
              final song = pt.track;
              
              return ListTile(
                leading: song.thumbnail.isNotEmpty
                    ? Image.network(song.thumbnail, width: 50, height: 50, fit: BoxFit.cover)
                    : Container(width: 50, height: 50, color: Colors.white10, child: const Icon(Icons.music_note, color: Colors.white)),
                title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
                subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54)),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                  onPressed: () => _removeTrack(song.id),
                ),
                onTap: () {
                  ref.read(playerProvider.notifier).play(song);
                },
              );
            },
          );
        },
      ),
    );
  }
}



