import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  final Brightness brightness;
  final Color primarySeedColor;
  final Color secondarySeedColor;
  final Color tertiarySeedColor;

  const AppTheme({
    this.brightness = Brightness.light,
    this.primarySeedColor = const Color(0xFFFDD276),
    this.secondarySeedColor = const Color(0xFF012233),
    this.tertiarySeedColor = const Color(0xFFD0FCFD),
  });

  ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: SeedColorScheme.fromSeeds(
        primaryKey: primarySeedColor,
        secondaryKey: secondarySeedColor,
        tertiaryKey: tertiarySeedColor,
        brightness: brightness,
      ),
    );
  }

  static ThemeData get lightTheme => const AppTheme().theme;
  static ThemeData get darkTheme => const AppDarkTheme().theme;
}

class AppDarkTheme extends AppTheme {
  const AppDarkTheme()
      : super(
          brightness: Brightness.dark,
        );
}
