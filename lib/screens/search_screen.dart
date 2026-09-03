import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import '../providers/player_provider.dart';
import 'artist_screen.dart';
import 'album_screen.dart';
import '../theme/glassmorphism.dart';
import '../models/song.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  Widget _buildItem(Song item, String type) {
    final bool isArtist = type == 'Artist';
    final bool isTrack = type == 'Song';
    final bool isAlbum = type == 'Album' || type == 'album';
    
    // Format subtitle properly
    String formattedSubtitle = isArtist ? 'Artist' : "$type â€¢ $item.artist";
    formattedSubtitle = formattedSubtitle.replaceAll("$item.artist", item.artist);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(isArtist ? 28.0 : 4.0),
            child: Image.network(
              item.thumbnail,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: Colors.white10,
                child: const Icon(Icons.music_note, color: Colors.white54),
              ),
            ),
          ),
          if (!isArtist)
            Container(
              width: 56,
              height: 56,
              color: Colors.black26,
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
            ),
        ],
      ),
      title: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(formattedSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      trailing: isArtist ? const Icon(Icons.verified, color: Colors.greenAccent, size: 18) : const Icon(Icons.more_vert, color: Colors.white54),
      onTap: () {
        if (isTrack) {
          ref.read(playerProvider.notifier).play(item);
        } else if (isArtist) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ArtistScreen(artistId: item.id)));
        } else if (isAlbum) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AlbumScreen(albumId: item.id)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Page not implemented yet for ${item.title}")));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: GlassContainer(
          borderRadius: BorderRadius.circular(8.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search songs, artists, albums...',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.white54),
            ),
          ),
        ),
      ),
      body: searchResults.when(
        data: (data) {
          if (data.tracks.isEmpty && data.artists.isEmpty && data.albums.isEmpty && _controller.text.isEmpty) {
            return const Center(
              child: Text("Type something to search", style: TextStyle(color: Colors.white54)),
            );
          }
          
          if (data.tracks.isEmpty && data.artists.isEmpty && data.albums.isEmpty) {
            return const Center(
              child: Text("No results found.", style: TextStyle(color: Colors.white54)),
            );
          }

          // Combine them in a logical order
          List<Map<String, dynamic>> combinedList = [];
          
          if (data.artists.isNotEmpty) {
            combinedList.add({'item': data.artists.first, 'type': 'Artist'});
          }
          
          for (var track in data.tracks) {
            combinedList.add({'item': track, 'type': 'Song'});
          }
          
          for (var album in data.albums) {
            combinedList.add({'item': album, 'type': 'Album'});
          }
          
          if (data.artists.length > 1) {
            for (var i = 1; i < data.artists.length; i++) {
              combinedList.add({'item': data.artists[i], 'type': 'Artist'});
            }
          }

          return ListView.builder(
            itemCount: combinedList.length,
            itemBuilder: (context, index) {
              final entry = combinedList[index];
              return _buildItem(entry['item'] as Song, entry['type'] as String);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }
}
