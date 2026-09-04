import '../widgets/playlist_dialog.dart';
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../providers/artist_provider.dart";
import "../providers/player_provider.dart";
import "../models/song.dart";
import "album_screen.dart";

class ArtistScreen extends ConsumerWidget {
  final String artistId;

  const ArtistScreen({Key? key, required this.artistId}) : super(key: key);

  Widget _buildHorizontalList(String title, List<Song> items, WidgetRef ref) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AlbumScreen(albumId: item.id)));
                },
                child: Container(
                width: 140,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(item.thumbnail, width: 140, height: 140, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(item.artist, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ));
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistAsync = ref.watch(artistProvider(artistId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Artist Profile"),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: artistAsync.when(
        data: (artist) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.network(
                      artist.thumbnail,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Theme.of(context).scaffoldBackgroundColor],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(artist.name, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                          if (artist.description.isNotEmpty)
                            Text(artist.description, style: const TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Top Songs
                if (artist.topSongs.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text("Top Songs", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: artist.topSongs.length,
                    itemBuilder: (context, index) {
                      final track = artist.topSongs[index];
                      return ListTile(
                        leading: Image.network(track.thumbnail, width: 48, height: 48, fit: BoxFit.cover),
                        title: Text(track.title, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(track.artist, style: const TextStyle(color: Colors.white54)),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white54),
                          onPressed: () {
                            showAddToPlaylistDialog(context, ref, track);
                          },
                        ),
                        onTap: () {
                          ref.read(playerProvider.notifier).playQueue(artist.topSongs, initialIndex: index);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Albums & Singles
                _buildHorizontalList("Albums", artist.albums, ref),
                _buildHorizontalList("Singles & EPs", artist.singles, ref),
                
                const SizedBox(height: 100), // padding for player
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






