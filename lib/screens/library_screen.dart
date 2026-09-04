import '../providers/search_provider.dart';
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../providers/playlist_provider.dart";
import "../providers/auth_provider.dart";
import "../services/api_service.dart";
import "playlist_screen.dart";

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  void _createPlaylist(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("New Playlist", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Playlist Name",
            hintStyle: TextStyle(color: Colors.white54),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Create", style: TextStyle(color: Colors.greenAccent)),
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(context); // close dialog
              try {
                await ref.read(apiServiceProvider).createPlaylist(nameController.text.trim(), "");
                ref.invalidate(playlistsProvider); // refresh list
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
          ),
        ],
      ),
    );
  }

  void _deletePlaylist(String id) async {
    try {
      await ref.read(apiServiceProvider).deletePlaylist(id);
      ref.invalidate(playlistsProvider);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    
    if (!auth.isAuthenticated) {
      return const Center(
        child: Text("Please login to view your library", style: TextStyle(color: Colors.white70, fontSize: 18)),
      );
    }

    final playlistsAsync = ref.watch(playlistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Library", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createPlaylist(context),
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: playlistsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
        data: (playlists) {
          if (playlists.isEmpty) {
            return const Center(child: Text("No playlists yet. Create one!", style: TextStyle(color: Colors.white70)));
          }
          return ListView.builder(
            itemCount: playlists.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final pl = playlists[index];
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.white10,
                  child: const Icon(Icons.music_note, color: Colors.white54),
                ),
                title: Text(pl.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("Playlist", style: const TextStyle(color: Colors.white54)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white24),
                  onPressed: () => _deletePlaylist(pl.id),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlaylistScreen(playlist: pl)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


