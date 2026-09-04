import "package:dio/dio.dart";
import "package:kuroshiro/kuroshiro.dart";
import "package:korean_romanization_converter/korean_romanization_converter.dart";

class LyricData {
  final String lrc;
  final String? translation;

  LyricData(this.lrc, this.translation);
}

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

  Future<LyricData?> fetchLyrics(String trackName, String artistName) async {
    try {
      final response = await _dio.get(
        "http://localhost:8080/api/v1/lyrics",
        queryParameters: {
          "track": trackName,
          "artist": artistName,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final lrc = response.data["data"]["lrc"];
        if (lrc != null && lrc.toString().isNotEmpty) {
          final translated = await _generateTranslationLrc(lrc.toString());
          return LyricData(lrc.toString(), translated);
        }
      }
    } catch (e) {
      print("Failed to fetch lyrics from backend: $e");
    }
    return null;
  }

  Future<String?> _generateTranslationLrc(String lrcContent) async {
    await _initKuroshiro();
    final lines = lrcContent.split("\n");
    final List<String> translationLines = [];
    bool hasAnyTranslation = false;

    final timeRegex = RegExp(r"^(\[\d{2}:\d{2}\.\d{2,3}\])(.*)");

    for (var line in lines) {
      final match = timeRegex.firstMatch(line);
      if (match != null) {
        final timeTag = match.group(1)!;
        final text = match.group(2)!.trim();
        
        if (text.isEmpty) {
          translationLines.add(line);
          continue;
        }

        String transliteration = text;
        bool translated = false;
        
        bool hasJapanese = RegExp(r"[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]").hasMatch(text);
        bool hasKorean = RegExp(r"[\uAC00-\uD7A3]").hasMatch(text);

        try {
          if (hasJapanese && _kuroshiro != null) {
            transliteration = await _kuroshiro!.convert(text, to: ConvertTo.romaji);
            translated = true;
          } else if (hasKorean) {
            transliteration = _krConverter.romanize(text);
            translated = true;
          }
        } catch (e) {
          print("Transliteration error: $e");
        }

        if (translated) {
          hasAnyTranslation = true;
        }
        
        translationLines.add("$timeTag $transliteration");
      } else {
        translationLines.add(line);
      }
    }

    return hasAnyTranslation ? translationLines.join("\n") : null;
  }
}

