class Song {
  final String id;
  final String title;
  final String artist;
  final String thumbnail;
  final int duration;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnail,
    required this.duration,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Title',
      artist: json['artist'] as String? ?? 'Unknown Artist',
      thumbnail: json['thumbnail'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
    );
  }
}
