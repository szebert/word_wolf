import "dart:async";

import "package:flutter/material.dart";

import "../app_spacing.dart";
import "app_text.dart";

class AutoScrollText extends StatefulWidget {
  final String text;
  final AppTextVariant variant;
  final AppTextWeight weight;
  final AppTextColor colorOption;

  const AutoScrollText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.bodyMedium,
    this.weight = AppTextWeight.regular,
    this.colorOption = AppTextColor.unspecified,
  });

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  final GlobalKey _textKey = GlobalKey();
  double _textWidth = 0;
  double _containerWidth = 0;
  double _currentOffset = 0;
  // pixels per second
  final double _scrollSpeed = 15.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureText();
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _measureText() {
    final RenderBox? textBox =
        _textKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? containerBox = context.findRenderObject() as RenderBox?;

    if (textBox != null && containerBox != null) {
      _textWidth = textBox.size.width;
      _containerWidth = containerBox.size.width;

      if (_textWidth > _containerWidth) {
        _startScrollTimer();
      }
    }
  }

  void _startScrollTimer() {
    // Cancel any existing timer
    _scrollTimer?.cancel();

    // Initial position
    _currentOffset = 0;
    _scrollController.jumpTo(_currentOffset);

    // Create a timer that updates the scroll position frequently
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Calculate new position
      // 0.033 seconds per frame at 30fps
      _currentOffset += _scrollSpeed * 0.033;

      // Reset if we've scrolled past one full width of the text
      // This creates the continuous cylinder effect
      if (_currentOffset >= _textWidth) {
        _currentOffset %= _textWidth;
      }

      // Apply the scroll offset
      _scrollController.jumpTo(_currentOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20, // Fixed height to ensure visibility
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: const [0.0, 0.1, 0.9, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: LayoutBuilder(builder: (context, constraints) {
            // Create a row with multiple copies of the text to create a continuous loop
            return Row(
              children: List.generate(3, (index) {
                final isLast = index == 2;
                return Row(
                  children: [
                    AppText(
                      widget.text,
                      key: index == 0 ? _textKey : null,
                      variant: widget.variant,
                      weight: widget.weight,
                      colorOption: widget.colorOption,
                    ),
                    if (!isLast) const SizedBox(width: AppSpacing.xs),
                  ],
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
