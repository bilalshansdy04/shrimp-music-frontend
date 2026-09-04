import "song.dart";

class Playlist {
  final String id;
  final String name;
  final String description;
  final String createdAt;

  Playlist({
    required this.id,
    required this.name,
    this.description = "",
    required this.createdAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      createdAt: json["created_at"] ?? "",
    );
  }
}

class PlaylistTrack {
  final int id;
  final String playlistId;
  final Song track;
  final int positionOrder;
  final String addedAt;

  PlaylistTrack({
    required this.id,
    required this.playlistId,
    required this.track,
    required this.positionOrder,
    required this.addedAt,
  });

  factory PlaylistTrack.fromJson(Map<String, dynamic> json) {
    final trackJson = json["track"] ?? {};
    final song = Song(
      id: trackJson["id"] ?? "",
      title: trackJson["title"] ?? "",
      artist: trackJson["artist"] ?? "",
      thumbnail: trackJson["thumbnail"] ?? "",
      duration: trackJson["duration_seconds"] ?? 0,
    );

    return PlaylistTrack(
      id: json["id"] ?? 0,
      playlistId: json["playlist_id"] ?? "",
      track: song,
      positionOrder: json["position_order"] ?? 0,
      addedAt: json["added_at"] ?? "",
    );
  }
}

