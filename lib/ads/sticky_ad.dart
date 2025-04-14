import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../app/app_bloc.dart";
import "../app_ui/app_spacing.dart";
import "../app_ui/widgets/app_scroll_text.dart";
import "../app_ui/widgets/app_text.dart";
import "../l10n/l10n.dart";
import "ad_constants.dart";
import "banner_ad_content.dart";

/// {@template sticky_ad}
/// A bottom-anchored, adaptive ad widget with app-specific UI styling.
/// https://developers.google.com/admob/flutter/banner/anchored-adaptive
/// {@endtemplate}
class StickyAd extends StatefulWidget {
  /// {@macro sticky_ad}
  const StickyAd({
    this.showProgressIndicator = true,
    super.key,
  });

  /// Whether to show a progress indicator when the ad is loading.
  final bool showProgressIndicator;

  @override
  State<StickyAd> createState() => _StickyAdState();
}

class _StickyAdState extends State<StickyAd> {
  bool _adsRemoved = false;

  bool _adLoaded = false;
  bool _adFailedToLoad = false;
  double _adWidth = 0;
  double _adHeight = 0;

  @override
  Widget build(final BuildContext context) {
    final bool removeAds = context.select(
      (final AppBloc bloc) => bloc.state.hasPaidForAdRemoval,
    );
    setState(() => _adsRemoved = removeAds);

    if (_adsRemoved) {
      return const SizedBox();
    }

    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDarkMode = theme.brightness == Brightness.dark;

    String adUnitId;
    if (kDebugMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        adUnitId = AdConstants.androidTestUnitId;
      } else {
        adUnitId = AdConstants.iosTestUnitAd;
      }
    } else {
      if (defaultTargetPlatform == TargetPlatform.android) {
        adUnitId = AdConstants.androidUnitId;
      } else {
        adUnitId = AdConstants.iosUnitId;
      }
    }

    return SizedBox(
      width: _adWidth > 0 ? _adWidth : null,
      height: _adHeight > 0 ? _adHeight : null,
      child: Stack(
        children: [
          // The actual ad widget that will load and inform us of state changes
          Offstage(
            offstage: !_adLoaded,
            child: BannerAdContent(
              size: BannerAdSize.anchoredAdaptive,
              onAdLoaded: () => setState(() => _adLoaded = true),
              onAdFailedToLoad: (error) =>
                  setState(() => _adFailedToLoad = true),
              onAdSizeChanged: (width, height) => setState(() {
                _adWidth = width;
                _adHeight = height;
              }),
              adUnitId: adUnitId,
            ),
          ),

          // Dark mode overlay only when ad is loaded
          if (_adLoaded && isDarkMode)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black26,
                ),
              ),
            ),

          // Error UI
          if (_adFailedToLoad)
            Container(
              width: _adWidth,
              height: _adHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    l10n.adFailedToLoadTitle,
                    colorOption: AppTextColor.onSurface,
                    textAlign: TextAlign.center,
                    weight: AppTextWeight.bold,
                  ),
                  AutoScrollText(
                    l10n.adFailedToLoadSubtitle,
                    colorOption: AppTextColor.onSurface,
                  ),
                ],
              ),
            ),

          // Loading indicator
          if (!_adLoaded && !_adFailedToLoad && widget.showProgressIndicator)
            Center(
              child: _adWidth > 0 && _adHeight > 0
                  ? const CircularProgressIndicator()
                  : const SizedBox(),
            ),
        ],
      ),
    );
  }
}
