import 'song.dart';

class UniversalSearchData {
  final List<Song> tracks;
  final List<Song> artists;
  final List<Song> albums;

  UniversalSearchData({
    required this.tracks,
    required this.artists,
    required this.albums,
  });

  factory UniversalSearchData.fromJson(Map<String, dynamic> json) {
    var tList = json['tracks'] as List? ?? [];
    var aList = json['artists'] as List? ?? [];
    var alList = json['albums'] as List? ?? [];

    return UniversalSearchData(
      tracks: tList.map((x) => Song.fromJson(x)).toList(),
      artists: aList.map((x) => Song.fromJson(x)).toList(),
      albums: alList.map((x) => Song.fromJson(x)).toList(),
    );
  }
}

