import "package:flutter/material.dart";

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  // Define reusable AssetImage objects to match the precached images
  static const AssetImage logoWhiteImage =
      AssetImage("assets/images/logo_white.webp");
  static const AssetImage logoBlackImage =
      AssetImage("assets/images/logo_black.webp");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final assetImage =
        brightness == Brightness.dark ? logoWhiteImage : logoBlackImage;

    return Image(
      image: assetImage,
      width: 120,
      height: 120,
      // Add fade-in animation for smoother appearance
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          child: child,
        );
      },
    );
  }
}
