import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import '../theme/glassmorphism.dart';
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
        data: (songs) {
          if (songs.isEmpty && _controller.text.isEmpty) {
            return const Center(
              child: Text("Type something to search", style: TextStyle(color: Colors.white54)),
            );
          }
          if (songs.isEmpty) {
            return const Center(
              child: Text("No results found.", style: TextStyle(color: Colors.white54)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    song.thumbnail,
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
                title: Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(song.artist, style: const TextStyle(color: Colors.white54)),
                trailing: IconButton(
                  icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                  onPressed: () {
                    // TODO: Play song logic here
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }
}
