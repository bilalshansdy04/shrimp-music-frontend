import "package:dio/dio.dart";
import "package:kuroshiro/kuroshiro.dart";
import "package:korean_romanization_converter/korean_romanization_converter.dart";
import "../models/lyric_line.dart";

class LyricService {
  final Dio _dio = Dio();
  Kuroshiro? _kuroshiro;
  final _krConverter = KoreanRomanizationConverter();

  Future<void> _initKuroshiro() async {
    if (_kuroshiro == null) {
      _kuroshiro = Kuroshiro();
      await _kuroshiro!.init();
    }
  }

  Future<List<LyricLine>> fetchLyrics(String trackName, String artistName) async {
    try {
      final response = await _dio.get(
        "https://lrclib.net/api/get",
        queryParameters: {
          "track_name": trackName,
          "artist_name": artistName,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final syncedLyrics = response.data["syncedLyrics"];
        if (syncedLyrics != null && syncedLyrics.toString().isNotEmpty) {
          return await _parseLrc(syncedLyrics.toString());
        }
      }
    } catch (e) {
      print("Failed to fetch lyrics from lrclib: $e");
    }
    return [];
  }

  Future<List<LyricLine>> _parseLrc(String lrcContent) async {
    await _initKuroshiro();
    final lines = lrcContent.split("\n");
    final List<LyricLine> parsedLines = [];

    final timeRegex = RegExp(r"\[(\d{2}):(\d{2})\.(\d{2,3})\]");

    for (var line in lines) {
      final match = timeRegex.firstMatch(line);
      if (match != null) {
        final min = int.parse(match.group(1)!);
        final sec = int.parse(match.group(2)!);
        String msStr = match.group(3)!;
        final ms = msStr.length == 2 ? int.parse(msStr) * 10 : int.parse(msStr);
        
        final text = line.substring(match.end).trim();
        if (text.isEmpty) continue;

        String? transliteration;
        
        // Check for Japanese (Hiragana, Katakana, Kanji)
        bool hasJapanese = RegExp(r"[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]").hasMatch(text);
        // Check for Korean (Hangul)
        bool hasKorean = RegExp(r"[\uAC00-\uD7A3]").hasMatch(text);

        try {
          if (hasJapanese && _kuroshiro != null) {
            transliteration = await _kuroshiro!.convert(text, to: ConvertTo.romaji);
          } else if (hasKorean) {
            transliteration = _krConverter.romanize(text);
          }
        } catch (e) {
          print("Transliteration error: $e");
        }

        parsedLines.add(LyricLine(
          time: Duration(minutes: min, seconds: sec, milliseconds: ms),
          text: text,
          transliteration: transliteration,
        ));
      }
    }

    return parsedLines;
  }
}


