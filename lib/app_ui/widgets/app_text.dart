import "package:flutter/material.dart";

/// The variant of the AppText.
enum AppTextVariant {
  /// Display Large - Largest display text
  displayLarge,

  /// Display Medium - Medium display text
  displayMedium,

  /// Display Small - Small display text
  displaySmall,

  /// Headline Large - Largest headline text
  headlineLarge,

  /// Headline Medium - Medium headline text
  headlineMedium,

  /// Headline Small - Small headline text
  headlineSmall,

  /// Title Large - Largest title text
  titleLarge,

  /// Title Medium - Medium title text
  titleMedium,

  /// Title Small - Small title text
  titleSmall,

  /// Body Large - Large body text
  bodyLarge,

  /// Body Medium - Default body text
  bodyMedium,

  /// Body Small - Small body text
  bodySmall,

  /// Label Large - Large label text
  labelLarge,

  /// Label Medium - Medium label text
  labelMedium,

  /// Label Small - Small label text
  labelSmall,
}

/// The weight of the AppText.
enum AppTextWeight {
  /// Thin weight (100)
  thin,

  /// Extra light weight (200)
  extraLight,

  /// Light weight (300)
  light,

  /// Regular weight (400)
  regular,

  /// Medium weight (500)
  medium,

  /// Semi-bold weight (600)
  semiBold,

  /// Bold weight (700)
  bold,

  /// Extra-bold weight (800)
  extraBold,

  /// Black weight (900)
  black,
}

/// Theme-based color options for text.
enum AppTextColor {
  /// Default color based on the text variant's default
  unspecified,

  /// Primary color from the theme
  primary,

  /// On Primary color from the theme (text on primary background)
  onPrimary,

  /// Primary Container color from the theme
  primaryContainer,

  /// On Primary Container color from the theme
  onPrimaryContainer,

  /// Secondary color from the theme
  secondary,

  /// On Secondary color from the theme
  onSecondary,

  /// Secondary Container color from the theme
  secondaryContainer,

  /// On Secondary Container color from the theme
  onSecondaryContainer,

  /// Tertiary color from the theme
  tertiary,

  /// On Tertiary color from the theme
  onTertiary,

  /// Tertiary Container color from the theme
  tertiaryContainer,

  /// On Tertiary Container color from the theme
  onTertiaryContainer,

  /// Error color from the theme
  error,

  /// On Error color from the theme
  onError,

  /// Surface color from the theme
  surface,

  /// On Surface color from the theme (default text color)
  onSurface,

  /// Surface Container Highest color from the theme
  surfaceContainerHighest,

  /// On Surface Variant color from the theme
  onSurfaceVariant,
}

/// A text widget with standardized styling across the app.
///
/// This is a wrapper around the standard text widget that
/// applies consistent styling based on the variant.
class AppText extends StatelessWidget {
  /// Creates a text widget with standardized styling.
  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.bodyMedium,
    this.weight = AppTextWeight.regular,
    this.colorOption = AppTextColor.unspecified,
    this.customColor,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  /// The text to display.
  final String text;

  /// The variant of the text.
  ///
  /// Defaults to [AppTextVariant.bodyMedium].
  final AppTextVariant variant;

  /// The weight of the text.
  ///
  /// Defaults to [AppTextWeight.regular].
  final AppTextWeight weight;

  /// The theme-based color of the text.
  ///
  /// Defaults to [AppTextColor.unspecified], which uses the
  /// appropriate color from the theme based on the text variant.
  final AppTextColor colorOption;

  /// Optional custom color to use instead of theme colors.
  ///
  /// If provided, this overrides [colorOption].
  final Color? customColor;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// An optional maximum number of lines for the text to span.
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// Optional custom style to apply.
  ///
  /// If provided, this will be merged with the style determined
  /// by the variant, size, and weight.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = DefaultTextStyle.of(context).style;

    // Get base style from variant (without color)
    final TextStyle baseStyle = _getVariantStyle(theme).copyWith(color: null);

    // Apply weight modifier
    final TextStyle weightedStyle = _applyWeightModifier(baseStyle);

    // Get effective color from theme or parameter
    final Color? effectiveColor = _getEffectiveColor(theme);

    // Apply color: priority is customColor, then colorOption, then DefaultTextStyle
    final TextStyle coloredStyle = weightedStyle.copyWith(
      color: effectiveColor ?? defaultTextStyle.color,
    );

    // Merge with custom style if provided
    final TextStyle effectiveStyle =
        style != null ? coloredStyle.merge(style) : coloredStyle;

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Get the effective color based on theme and color options
  Color? _getEffectiveColor(ThemeData theme) {
    // If custom color is provided, it takes precedence
    if (customColor != null) {
      return customColor;
    }

    // If unspecified, return null to use DefaultTextStyle color
    if (colorOption == AppTextColor.unspecified) {
      return null;
    }

    // Otherwise, apply the theme-based color
    final colorScheme = theme.colorScheme;

    return switch (colorOption) {
      AppTextColor.unspecified => null, // Use DefaultTextStyle color
      AppTextColor.primary => colorScheme.primary,
      AppTextColor.onPrimary => colorScheme.onPrimary,
      AppTextColor.primaryContainer => colorScheme.primaryContainer,
      AppTextColor.onPrimaryContainer => colorScheme.onPrimaryContainer,
      AppTextColor.secondary => colorScheme.secondary,
      AppTextColor.onSecondary => colorScheme.onSecondary,
      AppTextColor.secondaryContainer => colorScheme.secondaryContainer,
      AppTextColor.onSecondaryContainer => colorScheme.onSecondaryContainer,
      AppTextColor.tertiary => colorScheme.tertiary,
      AppTextColor.onTertiary => colorScheme.onTertiary,
      AppTextColor.tertiaryContainer => colorScheme.tertiaryContainer,
      AppTextColor.onTertiaryContainer => colorScheme.onTertiaryContainer,
      AppTextColor.error => colorScheme.error,
      AppTextColor.onError => colorScheme.onError,
      AppTextColor.surface => colorScheme.surface,
      AppTextColor.onSurface => colorScheme.onSurface,
      AppTextColor.surfaceContainerHighest =>
        colorScheme.surfaceContainerHighest,
      AppTextColor.onSurfaceVariant => colorScheme.onSurfaceVariant,
    };
  }

  /// Get the base style based on the variant
  TextStyle _getVariantStyle(ThemeData theme) {
    final textTheme = theme.textTheme;

    return switch (variant) {
      AppTextVariant.displayLarge => textTheme.displayLarge!,
      AppTextVariant.displayMedium => textTheme.displayMedium!,
      AppTextVariant.displaySmall => textTheme.displaySmall!,
      AppTextVariant.headlineLarge => textTheme.headlineLarge!,
      AppTextVariant.headlineMedium => textTheme.headlineMedium!,
      AppTextVariant.headlineSmall => textTheme.headlineSmall!,
      AppTextVariant.titleLarge => textTheme.titleLarge!,
      AppTextVariant.titleMedium => textTheme.titleMedium!,
      AppTextVariant.titleSmall => textTheme.titleSmall!,
      AppTextVariant.bodyLarge => textTheme.bodyLarge!,
      AppTextVariant.bodyMedium => textTheme.bodyMedium!,
      AppTextVariant.bodySmall => textTheme.bodySmall!,
      AppTextVariant.labelLarge => textTheme.labelLarge!,
      AppTextVariant.labelMedium => textTheme.labelMedium!,
      AppTextVariant.labelSmall => textTheme.labelSmall!,
    };
  }

  /// Apply weight modifier to the text style
  TextStyle _applyWeightModifier(TextStyle style) {
    final FontWeight fontWeight = switch (weight) {
      AppTextWeight.thin => FontWeight.w100,
      AppTextWeight.extraLight => FontWeight.w200,
      AppTextWeight.light => FontWeight.w300,
      AppTextWeight.regular => FontWeight.w400,
      AppTextWeight.medium => FontWeight.w500,
      AppTextWeight.semiBold => FontWeight.w600,
      AppTextWeight.bold => FontWeight.w700,
      AppTextWeight.extraBold => FontWeight.w800,
      AppTextWeight.black => FontWeight.w900,
    };

    return style.copyWith(fontWeight: fontWeight);
  }
}
