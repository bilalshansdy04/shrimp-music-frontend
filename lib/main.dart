import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/layout_builder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize MediaKit for Audio/Video
  MediaKit.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('recent_searches');
  
  runApp(
    const ProviderScope(
      child: ShrimpMusicApp(),
    ),
  );
}

class ShrimpMusicApp extends StatelessWidget {
  const ShrimpMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrimp Music Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ResponsiveLayoutBuilder(),
    );
  }
}
