import "song.dart";

class AlbumProfileData {
  final String id;
  final String title;
  final String subtitle;
  final String thumbnail;
  final List<Song> tracks;

  AlbumProfileData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.thumbnail,
    required this.tracks,
  });

  factory AlbumProfileData.fromJson(Map<String, dynamic> json) {
    return AlbumProfileData(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      subtitle: json["subtitle"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      tracks: (json["tracks"] as List?)?.map((item) => Song.fromJson(item)).toList() ?? [],
    );
  }
}

