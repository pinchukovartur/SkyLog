import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repository.dart';
import 'screens/shell_screen.dart';
import 'state/progress.dart';
import 'state/progress_scope.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final systemLang = PlatformDispatcher.instance.locale.languageCode;
  final lang = Progress.resolveLang(prefs, systemLang);
  final repo = await Repository.load(rootBundle, lang: lang);
  runApp(
    SkyLogApp(
      progress: Progress(
        prefs,
        repo,
        lang: lang,
        systemLang: systemLang,
        loadRepository: (lang) => Repository.load(rootBundle, lang: lang),
      ),
    ),
  );
}

class SkyLogApp extends StatelessWidget {
  const SkyLogApp({super.key, required this.progress});

  final Progress progress;

  @override
  Widget build(BuildContext context) {
    return ProgressScope(
      progress: progress,
      child: MaterialApp(
        title: 'SkyLog',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const ShellScreen(),
      ),
    );
  }
}
