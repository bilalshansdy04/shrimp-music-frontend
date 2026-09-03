import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_screen.dart';
import 'auth_screen.dart';
import '../widgets/video_player_view.dart';
import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.transparent,
          title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final auth = ref.watch(authProvider);
                return IconButton(
                  icon: Icon(
                    auth.isAuthenticated ? Icons.account_circle : Icons.login,
                    color: auth.isAuthenticated ? Colors.greenAccent : Colors.white,
                  ),
                  onPressed: () {
                    if (auth.isAuthenticated) {
                      // Show logout dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.grey[900],
                          title: Text('Logout', style: const TextStyle(color: Colors.white)),
                          content: Text('Logged in as ${auth.username}. Do you want to logout?', style: const TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                              onPressed: () {
                                ref.read(authProvider.notifier).logout();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthScreen()),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: playerState.currentSong != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Now Playing",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Video or Album Art Surface
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: playerState.hasVideo
                            ? const VideoPlayerView()
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(16.0),
                                  image: (playerState.currentSong?.thumbnail.isNotEmpty ?? false)
                                      ? DecorationImage(
                                          image: NetworkImage(playerState.currentSong!.thumbnail),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    )
                                  ],
                                ),
                                child: (playerState.currentSong?.thumbnail.isEmpty ?? true)
                                    ? const Center(child: Icon(Icons.music_note, size: 64, color: Colors.white24))
                                    : null,
                              ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Evening',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text("Search for a song to start playing", style: TextStyle(color: Colors.white54)),
                      )
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
