import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:palette_generator/palette_generator.dart';
import '../models/song.dart';
import 'search_provider.dart';

class PlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final Color? dominantColor;
  final bool hasVideo;

  PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.dominantColor,
    this.hasVideo = false,
  });

  PlayerState copyWith({
    Song? currentSong,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    Color? dominantColor,
    bool? hasVideo,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      dominantColor: dominantColor ?? this.dominantColor,
      hasVideo: hasVideo ?? this.hasVideo,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final Player _player = Player();
  late final VideoController videoController = VideoController(_player);
  final Ref _ref;

  PlayerNotifier(this._ref) : super(PlayerState()) {
    _player.stream.playing.listen((playing) {
      if (mounted) state = state.copyWith(isPlaying: playing, isLoading: false);
    });
    _player.stream.position.listen((pos) {
      if (mounted) state = state.copyWith(position: pos);
    });
    _player.stream.duration.listen((dur) {
      if (mounted) state = state.copyWith(duration: dur);
    });
    _player.stream.videoParams.listen((params) {
      if (mounted) {
        state = state.copyWith(hasVideo: (params.w ?? 0) > 0);
      }
    });
    _player.stream.error.listen((error) {
      if (mounted) state = state.copyWith(isLoading: false);
      print('Player Error: $error');
    });
  }

  Future<void> play(Song song) async {
    state = state.copyWith(currentSong: song, isLoading: true);
    
    if (song.thumbnail.isNotEmpty) {
      _extractDominantColor(song.thumbnail);
    }

    try {
      final api = _ref.read(apiServiceProvider);
      // Determine if we should request video format (now false for Spotify-like behavior)
      final streamUrl = await api.resolveStreamUrl(song.id, isVideo: false); 
      await _player.open(Media(streamUrl));
      await _player.play();
    } catch (e) {
      print('Failed to play: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _extractDominantColor(String imageUrl) async {
    try {
      final palette = await PaletteGenerator.fromImageProvider(NetworkImage(imageUrl));
      if (mounted) {
        state = state.copyWith(dominantColor: palette.dominantColor?.color ?? palette.darkMutedColor?.color);
      }
    } catch (e) {
      print("Failed to extract color: $e");
    }
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier(ref);
});

final videoControllerProvider = Provider<VideoController>((ref) {
  return ref.watch(playerProvider.notifier).videoController;
});
