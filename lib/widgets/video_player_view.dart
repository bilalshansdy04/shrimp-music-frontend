import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../providers/player_provider.dart';

class VideoPlayerView extends ConsumerWidget {
  const VideoPlayerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final videoController = ref.watch(videoControllerProvider);

    if (playerState.currentSong == null) {
      return const Center(
        child: Icon(Icons.music_note, size: 64, color: Colors.white24),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Video(
        controller: videoController,
        controls: NoVideoControls, // We use our custom UI controls instead
        fit: BoxFit.cover,
      ),
    );
  }
}
