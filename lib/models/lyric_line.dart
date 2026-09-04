class LyricLine {
  final Duration time;
  final String text;
  final String? transliteration;

  LyricLine({
    required this.time,
    required this.text,
    this.transliteration,
  });
}

