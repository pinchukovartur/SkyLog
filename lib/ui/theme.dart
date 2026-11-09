import 'package:flutter/material.dart';

// Палитра стола зачарования и алхимии: бирюзовое свечение на тёмном камне.
const _glow = Color(0xFF7FE6CF);
const _arcane = Color(0xFF5CB8D9);
const _abyss = Color(0xFF081215);
const _text = Color(0xFFD9EEEA);

ThemeData buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: _glow,
        brightness: Brightness.dark,
      ).copyWith(
        primary: _glow,
        onPrimary: const Color(0xFF00201A),
        primaryContainer: const Color(0xFF14463F),
        onPrimaryContainer: _glow,
        secondary: _arcane,
        secondaryContainer: const Color(0xFF123A48),
        onSecondaryContainer: const Color(0xFFBDE9F7),
        surface: _abyss,
        onSurface: _text,
        onSurfaceVariant: const Color(0xFF8FB3AD),
        surfaceContainerLow: const Color(0xFF0E1C20),
        surfaceContainer: const Color(0xFF112328),
        surfaceContainerHigh: const Color(0xFF162C32),
        surfaceContainerHighest: const Color(0xFF1C363C),
        outline: const Color(0xFF2F5A57),
        outlineVariant: const Color(0xFF1F3E3E),
      );
  return ThemeData(
    colorScheme: scheme,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: _MagicPageTransitions()},
    ),
    // Фон каждой страницы рисует [_MagicPageTransitions].
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: _glow,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        shadows: [Shadow(color: Color(0xAA3FD9B8), blurRadius: 12)],
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainer.withValues(alpha: 0.82),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _glow.withValues(alpha: 0.16)),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _glow,
      linearTrackColor: _arcane.withValues(alpha: 0.14),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      dragHandleColor: _glow.withValues(alpha: 0.5),
    ),
    dialogTheme: DialogThemeData(backgroundColor: scheme.surfaceContainerHigh),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primaryContainer,
      foregroundColor: _glow,
    ),
  );
}

/// Стандартный переход Android, но каждая страница лежит на своём
/// непрозрачном [_MagicBackground], чтобы при переходе не просвечивала соседняя.
class _MagicPageTransitions extends PageTransitionsBuilder {
  const _MagicPageTransitions();

  static const _base = FadeForwardsPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => _base.buildTransitions(
    route,
    context,
    animation,
    secondaryAnimation,
    _MagicBackground(child: child),
  );
}

/// Тёмный фон с мягким бирюзовым свечением сверху, как над столом зачарования.
class _MagicBackground extends StatelessWidget {
  const _MagicBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _abyss,
        gradient: RadialGradient(
          center: Alignment(0, -1.1),
          radius: 1.3,
          colors: [Color(0xFF12403B), Color(0xFF0B2226), _abyss],
          stops: [0, 0.45, 1],
        ),
      ),
      child: child,
    );
  }
}

/// Цвета пометок, общие для всех экранов.
abstract final class Marks {
  static const missable = Color(0xFFE6A35C);
  static const secret = Color(0xFF8CC8FF);
  static const choice = Color(0xFFC0A8FF);
  static const repeatable = Color(0xFF7FC8E6);
  static const marriage = Color(0xFFE88AA8);
}

IconData categoryIcon(String key) => switch (key) {
  'dragon' => Icons.local_fire_department,
  'swords' => Icons.flag,
  'wolf' => Icons.pets,
  'magic' => Icons.auto_fix_high,
  'lock' => Icons.lock_open,
  'dagger' => Icons.dark_mode,
  'daedra' => Icons.whatshot,
  'vampire' => Icons.bloodtype,
  'book' => Icons.menu_book,
  'warning' => Icons.warning_amber,
  'star' => Icons.auto_awesome,
  _ => Icons.map,
};
