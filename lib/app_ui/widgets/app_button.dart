import "package:flutter/material.dart";

import "../app_config.dart";

/// The variant of the AppButton.
enum AppButtonVariant {
  /// Elevated button style
  elevated,

  /// Filled button style
  filled,

  /// Filled tonal button style
  filledTonal,

  /// Outlined button style
  outlined,

  /// Text button style
  text,
}

/// The size of the AppButton.
enum AppButtonSize {
  /// Small size
  small,

  /// Medium size (default)
  medium,

  /// Large size
  large,

  /// Extra large size
  xlarge,
}

/// The shape of the AppButton.
enum AppButtonShape {
  /// Default slightly rounded edges
  rounded,

  /// Very rounded edges like a pill
  pill,

  /// No rounded edges (rectangle)
  rectangle,
}

/// A button that can be styled as any of the material button types.
///
/// This is a wrapper around the different material button types that
/// allows you to switch between them by changing the [variant] parameter.
class AppButton extends StatefulWidget {
  /// Creates a button that adapts to different Material button styles.
  const AppButton({
    super.key,
    this.variant = AppButtonVariant.elevated,
    this.size = AppButtonSize.medium,
    this.shape = AppButtonShape.rounded,
    this.onPressed,
    this.style,
    this.disabled = false,
    this.isLoading = false,
    this.pulse = false,
    this.minWidth,
    this.minHeight,
    this.icon,
    this.iconAlignment = IconAlignment.start,
    required this.child,
  });

  /// The style to use for this button.
  ///
  /// By default, this will be derived from the [variant] and [size].
  final ButtonStyle? style;

  /// The variant of the button.
  ///
  /// Defaults to [AppButtonVariant.elevated].
  final AppButtonVariant variant;

  /// The size of the button.
  ///
  /// Defaults to [AppButtonSize.medium].
  final AppButtonSize size;

  /// The shape of the button.
  ///
  /// Defaults to [AppButtonShape.rounded].
  final AppButtonShape shape;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// Whether the button is disabled.
  final bool disabled;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button should have a pulsing animation effect.
  final bool pulse;

  /// Optional minimum width for the button.
  ///
  /// If provided, overrides the default minimum width for the selected size.
  final double? minWidth;

  /// Optional minimum height for the button.
  ///
  /// If provided, overrides the default minimum height for the selected size.
  final double? minHeight;

  /// Optional icon to display with the button label.
  ///
  /// If provided, uses the .icon variant of the button.
  final Widget? icon;

  /// The alignment of the icon relative to the label.
  ///
  /// Defaults to [IconAlignment.start].
  final IconAlignment iconAlignment;

  /// The button's label.
  final Widget child;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.pulse) {
      _setupAnimation();
    }
  }

  @override
  void didUpdateWidget(AppButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulse != widget.pulse) {
      if (widget.pulse) {
        _setupAnimation();
      } else {
        _disposeAnimation();
      }
    }
  }

  void _setupAnimation() {
    _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _disposeAnimation() {
    _controller?.dispose();
    _controller = null;
    _pulseAnimation = null;
  }

  @override
  void dispose() {
    _disposeAnimation();
    super.dispose();
  }

  /// Whether the button is enabled.
  bool get enabled =>
      widget.onPressed != null && !widget.isLoading && !widget.disabled;

  /// Wraps the onPressed callback to include feedback
  VoidCallback? _wrapOnPressed() {
    // If button is disabled or has no callback, return null
    if (!enabled || widget.onPressed == null) {
      return null;
    }

    // Otherwise, wrap with feedback
    return () {
      AppConfig.playFeedback();
      widget.onPressed?.call();
    };
  }

  /// Gets the base style for the button based on its size.
  ButtonStyle _getSizeStyle() {
    final buttonShape = switch (widget.shape) {
      AppButtonShape.rounded => WidgetStateProperty.all<OutlinedBorder>(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      AppButtonShape.pill => WidgetStateProperty.all<OutlinedBorder>(
          const StadiumBorder(),
        ),
      AppButtonShape.rectangle => WidgetStateProperty.all<OutlinedBorder>(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
    };

    // Get the style based on size
    ButtonStyle style;
    switch (widget.size) {
      case AppButtonSize.small:
        style = ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          minimumSize: WidgetStateProperty.all<Size>(const Size(64, 32)),
          shape: buttonShape,
          enableFeedback: false,
        );
      case AppButtonSize.medium:
        style = ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
          minimumSize: WidgetStateProperty.all<Size>(const Size(80, 40)),
          shape: buttonShape,
          enableFeedback: false,
        );
      case AppButtonSize.large:
        style = ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          minimumSize: WidgetStateProperty.all<Size>(const Size(96, 48)),
          shape: buttonShape,
          enableFeedback: false,
        );
      case AppButtonSize.xlarge:
        style = ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          minimumSize: WidgetStateProperty.all<Size>(const Size(120, 56)),
          shape: buttonShape,
          enableFeedback: false,
        );
    }

    // Get the current minimum size
    final Size currentSize = style.minimumSize?.resolve({}) ?? const Size(0, 0);

    // Apply custom minimum size if provided
    if (widget.minWidth != null || widget.minHeight != null) {
      style = style.copyWith(
        minimumSize: WidgetStateProperty.all<Size>(
          Size(
            widget.minWidth ?? currentSize.width,
            widget.minHeight ?? currentSize.height,
          ),
        ),
      );
    }

    return style;
  }

  /// Combines the size style with any custom style provided.
  ButtonStyle _getEffectiveStyle(ButtonStyle baseStyle) {
    if (widget.style == null) return baseStyle;
    return baseStyle.merge(widget.style!);
  }

  /// Gets the progress indicator size based on the button size.
  double _getProgressIndicatorSize() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 16.0;
      case AppButtonSize.medium:
        return 20.0;
      case AppButtonSize.large:
        return 24.0;
      case AppButtonSize.xlarge:
        return 24.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = _getSizeStyle();
    final effectiveStyle = _getEffectiveStyle(baseStyle);

    final button = _buildButton(effectiveStyle, colorScheme);

    // Only wrap with pulse if needed
    if (widget.pulse && _pulseAnimation != null && enabled) {
      return _wrapWithPulse(context, button);
    }

    return button;
  }

  Widget _wrapWithPulse(BuildContext context, Widget button) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation!,
          builder: (context, _) {
            return CustomPaint(
              painter: _PulsePainter(
                animationValue: _pulseAnimation!.value,
                color: _getButtonColor(colorScheme),
                shape: widget.shape,
              ),
              child: button,
            );
          },
        ),
        button,
      ],
    );
  }

  /// Gets the primary color for the button based on its variant.
  Color _getButtonColor(ColorScheme colorScheme) {
    return switch (widget.variant) {
      AppButtonVariant.elevated => colorScheme.primary,
      AppButtonVariant.filled => colorScheme.primary,
      AppButtonVariant.filledTonal => colorScheme.secondaryContainer,
      AppButtonVariant.outlined => colorScheme.outline,
      AppButtonVariant.text => colorScheme.primary,
    };
  }

  Widget _buildButton(ButtonStyle effectiveStyle, ColorScheme colorScheme) {
    // Get onPressed callback with appropriate feedback
    final onPressed = _wrapOnPressed();

    if (widget.icon != null) {
      final effectiveIcon = widget.isLoading
          ? CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            )
          : widget.icon;

      switch (widget.variant) {
        case AppButtonVariant.elevated:
          return ElevatedButton.icon(
            onPressed: onPressed,
            style: effectiveStyle,
            icon: effectiveIcon,
            label: widget.child,
            iconAlignment: widget.iconAlignment,
          );
        case AppButtonVariant.filled:
          return FilledButton.icon(
            onPressed: onPressed,
            style: effectiveStyle,
            icon: effectiveIcon,
            label: widget.child,
            iconAlignment: widget.iconAlignment,
          );
        case AppButtonVariant.filledTonal:
          return FilledButton.tonalIcon(
            onPressed: onPressed,
            style: effectiveStyle,
            icon: effectiveIcon,
            label: widget.child,
            iconAlignment: widget.iconAlignment,
          );
        case AppButtonVariant.outlined:
          return OutlinedButton.icon(
            onPressed: onPressed,
            style: effectiveStyle,
            icon: effectiveIcon,
            label: widget.child,
            iconAlignment: widget.iconAlignment,
          );
        case AppButtonVariant.text:
          return TextButton.icon(
            onPressed: onPressed,
            style: effectiveStyle,
            icon: effectiveIcon,
            label: widget.child,
            iconAlignment: widget.iconAlignment,
          );
      }
    }

    // If loading, replace child with a centered progress indicator that maintains button size
    final effectiveChild = Stack(
      alignment: Alignment.center,
      children: [
        // This invisible child maintains the button size while loading
        Visibility(
          visible: !widget.isLoading,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: widget.child,
        ),
        if (widget.isLoading)
          SizedBox.square(
            dimension: _getProgressIndicatorSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            ),
          ),
      ],
    );

    switch (widget.variant) {
      case AppButtonVariant.elevated:
        return ElevatedButton(
          onPressed: onPressed,
          style: effectiveStyle,
          child: effectiveChild,
        );
      case AppButtonVariant.filled:
        return FilledButton(
          onPressed: onPressed,
          style: effectiveStyle,
          child: effectiveChild,
        );
      case AppButtonVariant.filledTonal:
        return FilledButton.tonal(
          onPressed: onPressed,
          style: effectiveStyle,
          child: effectiveChild,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: effectiveStyle,
          child: effectiveChild,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          style: effectiveStyle,
          child: effectiveChild,
        );
    }
  }
}

/// A custom painter that draws the pulse animation around a button.
class _PulsePainter extends CustomPainter {
  _PulsePainter({
    required this.animationValue,
    required this.color,
    required this.shape,
  });

  final double animationValue;
  final Color color;
  final AppButtonShape shape;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha((255 * (1 - animationValue)).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);

    final double radius = switch (shape) {
      AppButtonShape.rounded => 8.0,
      AppButtonShape.pill => 100,
      AppButtonShape.rectangle => 0,
    };

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: size.width + (animationValue * 20),
          height: size.height + (animationValue * 20),
        ),
        Radius.circular(radius),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
