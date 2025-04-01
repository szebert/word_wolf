import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  static const String _logoWhite = 'assets/images/logo_white.webp';
  static const String _logoBlack = 'assets/images/logo_black.webp';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Image.asset(
      brightness == Brightness.dark ? _logoWhite : _logoBlack,
      width: 120,
      height: 120,
    );
  }
}
