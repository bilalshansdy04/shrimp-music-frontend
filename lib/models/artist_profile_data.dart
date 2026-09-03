import "song.dart";

class ArtistProfileData {
  final String id;
  final String name;
  final String description;
  final String thumbnail;
  final List<Song> topSongs;
  final List<Song> albums;
  final List<Song> singles;

  ArtistProfileData({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnail,
    required this.topSongs,
    required this.albums,
    required this.singles,
  });

  factory ArtistProfileData.fromJson(Map<String, dynamic> json) {
    return ArtistProfileData(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      topSongs: (json["topSongs"] as List?)?.map((item) => Song.fromJson(item)).toList() ?? [],
      albums: (json["albums"] as List?)?.map((item) => Song.fromJson(item)).toList() ?? [],
      singles: (json["singles"] as List?)?.map((item) => Song.fromJson(item)).toList() ?? [],
    );
  }
}

