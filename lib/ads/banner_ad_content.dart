import "dart:async";

import "package:flutter/material.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";

import "ads_retry_policy.dart";

/// The size of a [BannerAd].
enum BannerAdSize {
  /// The normal size of a banner ad.
  normal,

  /// The large size of a banner ad.
  large,

  /// The extra large size of a banner ad.
  extraLarge,

  /// The anchored adaptive size of a banner ad.
  anchoredAdaptive
}

/// {@template banner_ad_failed_to_load_exception}
/// An exception thrown when loading a banner ad fails.
/// {@endtemplate}
class BannerAdFailedToLoadException implements Exception {
  /// {@macro banner_ad_failed_to_load_exception}
  BannerAdFailedToLoadException(this.error);

  /// The error which was caught.
  final Object error;
}

/// {@template banner_ad_failed_to_get_size_exception}
/// An exception thrown when getting a banner ad size fails.
/// {@endtemplate}
class BannerAdFailedToGetSizeException implements Exception {
  /// {@macro banner_ad_failed_to_get_size_exception}
  BannerAdFailedToGetSizeException();
}

/// Signature for [BannerAd] builder.
typedef BannerAdBuilder = BannerAd Function({
  required AdSize size,
  required String adUnitId,
  required BannerAdListener listener,
  required AdRequest request,
});

/// Signature for [AnchoredAdaptiveBannerAdSize] provider.
typedef AnchoredAdaptiveAdSizeProvider = Future<AnchoredAdaptiveBannerAdSize?>
    Function(
  Orientation orientation,
  int width,
);

/// {@template banner_ad_content}
/// A reusable content of a banner ad.
///
/// This widget handles the core functionality of loading and displaying a banner ad
/// without any app-specific UI styling. It exposes the ad widget and states
/// through callbacks that parent widgets can use for UI customization.
/// {@endtemplate}
class BannerAdContent extends StatefulWidget {
  /// {@macro banner_ad_content}
  const BannerAdContent({
    required this.size,
    required this.adUnitId,
    this.adsRetryPolicy = const AdsRetryPolicy(),
    this.anchoredAdaptiveWidth,
    this.adBuilder = BannerAd.new,
    this.anchoredAdaptiveAdSizeProvider =
        AdSize.getAnchoredAdaptiveBannerAdSize,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdSizeChanged,
    super.key,
  });

  /// The size of this banner ad.
  final BannerAdSize size;

  /// The retry policy for loading ads.
  final AdsRetryPolicy adsRetryPolicy;

  /// The width of this banner ad for [BannerAdSize.anchoredAdaptive].
  ///
  /// Defaults to the width of the device.
  final int? anchoredAdaptiveWidth;

  /// The unit id of this banner ad.
  ///
  /// Defaults to [androidTestUnitId] on Android
  /// and [iosTestUnitAd] on iOS.
  final String adUnitId;

  /// The builder of this banner ad.
  final BannerAdBuilder adBuilder;

  /// The provider for this banner ad for [BannerAdSize.anchoredAdaptive].
  final AnchoredAdaptiveAdSizeProvider anchoredAdaptiveAdSizeProvider;

  /// Called once when this banner ad loads.
  final VoidCallback? onAdLoaded;

  /// Called when the ad fails to load with the error.
  final Function(Object error)? onAdFailedToLoad;

  /// Called when the ad size changes.
  final Function(double width, double height)? onAdSizeChanged;

  /// The size values of this banner ad.
  ///
  /// The width of [BannerAdSize.anchoredAdaptive] depends on
  /// [anchoredAdaptiveWidth] and is defined in
  /// [_BannerAdContentState._getAnchoredAdaptiveAdSize].
  /// The height of such an ad is determined by Google.
  static const _sizeValues = <BannerAdSize, AdSize>{
    BannerAdSize.normal: AdSize.banner,
    BannerAdSize.large: AdSize.largeBanner,
    BannerAdSize.extraLarge: AdSize.mediumRectangle,
  };

  @override
  State<BannerAdContent> createState() => _BannerAdContentState();
}

class _BannerAdContentState extends State<BannerAdContent>
    with AutomaticKeepAliveClientMixin {
  BannerAd? _ad;
  AdSize? _adSize;
  bool _adLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_loadAd());
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_adLoaded && _ad != null) {
      return AdWidget(ad: _ad!);
    }

    return const SizedBox();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadAd() async {
    AdSize? adSize;
    if (widget.size == BannerAdSize.anchoredAdaptive) {
      adSize = await _getAnchoredAdaptiveAdSize();
    } else {
      adSize = BannerAdContent._sizeValues[widget.size];
    }

    if (!mounted) return;

    if (adSize != _adSize) {
      setState(() => _adSize = adSize);
      if (adSize != null) {
        widget.onAdSizeChanged
            ?.call(adSize.width.toDouble(), adSize.height.toDouble());
      }
    }

    if (_adSize == null) {
      final error = BannerAdFailedToGetSizeException();
      _reportError(error, StackTrace.current);
      widget.onAdFailedToLoad?.call(error);
      return;
    }

    await _loadAdInstance();
  }

  Future<void> _loadAdInstance({int retry = 0}) async {
    if (!mounted) return;

    try {
      final adCompleter = Completer<Ad>();

      setState(
        () => _ad = widget.adBuilder(
          adUnitId: widget.adUnitId,
          request: const AdRequest(),
          size: _adSize!,
          listener: BannerAdListener(
            onAdLoaded: adCompleter.complete,
            onAdFailedToLoad: (_, error) {
              adCompleter.completeError(error);
            },
          ),
        )..load(),
      );

      _onAdLoaded(await adCompleter.future);
    } catch (error, stackTrace) {
      _reportError(BannerAdFailedToLoadException(error), stackTrace);

      if (retry < widget.adsRetryPolicy.maxRetryCount) {
        final nextRetry = retry + 1;
        await Future<void>.delayed(
          widget.adsRetryPolicy.getIntervalForRetry(nextRetry),
        );
        return _loadAdInstance(retry: nextRetry);
      } else {
        widget.onAdFailedToLoad?.call(error);
      }
    }
  }

  void _onAdLoaded(Ad ad) {
    if (mounted) {
      setState(() {
        _ad = ad as BannerAd;
        _adLoaded = true;
      });
      widget.onAdLoaded?.call();
    }
  }

  /// Returns an ad size for [BannerAdSize.anchoredAdaptive].
  ///
  /// Only supports the portrait mode.
  Future<AnchoredAdaptiveBannerAdSize?> _getAnchoredAdaptiveAdSize() async {
    final adWidth = widget.anchoredAdaptiveWidth ??
        MediaQuery.of(context).size.width.truncate();
    return widget.anchoredAdaptiveAdSizeProvider(
      Orientation.portrait,
      adWidth,
    );
  }

  void _reportError(Object exception, StackTrace stackTrace) =>
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: exception,
          stack: stackTrace,
        ),
      );
}
