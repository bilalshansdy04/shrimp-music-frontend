import 'package:kuroshiro/kuroshiro.dart';
import 'package:korean_romanization_converter/korean_romanization_converter.dart';

void main() async {
  final kuroshiro = Kuroshiro();
  await kuroshiro.init();
  final result = await kuroshiro.convert('こんにちは', to: ConvertTo.romaji);
  print('Japanese: ' + result);

  final converter = KoreanRomanizationConverter();
  final krResult = converter.romanize('안녕하세요');
  print('Korean: ' + krResult);
}

