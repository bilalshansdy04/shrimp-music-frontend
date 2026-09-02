import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import '../providers/player_provider.dart';
import '../theme/glassmorphism.dart';
import '../models/song.dart';
import 'dart:async';

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

  Widget _buildList(List<Song> items, bool isTrack) {
    if (items.isEmpty) {
      return const Center(child: Text("No results found.", style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(isTrack ? 8.0 : 25.0),
            child: Image.network(
              item.thumbnail,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: Colors.white10,
                child: const Icon(Icons.music_note, color: Colors.white54),
              ),
            ),
          ),
          title: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(item.artist, style: const TextStyle(color: Colors.white54)),
          trailing: isTrack
              ? IconButton(
                  icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                  onPressed: () {
                    ref.read(playerProvider.notifier).play(item);
                  },
                )
              : null,
          onTap: () {
            if (isTrack) {
              ref.read(playerProvider.notifier).play(item);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile page not implemented yet for ${item.title}")));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Songs"),
              Tab(text: "Artists"),
              Tab(text: "Albums"),
            ],
          ),
        ),
        body: searchResults.when(
          data: (data) {
            if (data.tracks.isEmpty && data.artists.isEmpty && data.albums.isEmpty && _controller.text.isEmpty) {
              return const Center(
                child: Text("Type something to search", style: TextStyle(color: Colors.white54)),
              );
            }
            return TabBarView(
              children: [
                _buildList(data.tracks, true),
                _buildList(data.artists, false),
                _buildList(data.albums, false),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
        ),
      ),
    );
  }
}

