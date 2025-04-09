import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:package_info_plus/package_info_plus.dart";

import "../app_ui/app_config.dart";
import "../app_ui/app_spacing.dart";
import "../app_ui/widgets/app_icon_button.dart";
import "../app_ui/widgets/app_list_tile.dart";
import "../app_ui/widgets/app_segmented_button.dart";
import "../app_ui/widgets/app_switch.dart";
import "../app_ui/widgets/app_text.dart";
import "../l10n/l10n.dart";
import "../settings/settings_bloc.dart";
import "../theme/theme_mode_bloc.dart";

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const SettingsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SettingsView();
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with WidgetsBindingObserver {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<SettingsBloc>().add(const FetchFeedbackSettings());
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    // Fetch current notification status each time a user enters the app.
    // This may happen when a user changes permissions in app settings.
    if (state == AppLifecycleState.resumed) {
      WidgetsFlutterBinding.ensureInitialized();
      context.read<SettingsBloc>().add(const FetchFeedbackSettings());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    final bool soundEnabled = context.select(
      (final SettingsBloc bloc) => bloc.state.soundEnabled,
    );
    final bool hapticEnabled = context.select(
      (final SettingsBloc bloc) => bloc.state.hapticEnabled,
    );

    final bool isLoadingSound = context.select(
      (final SettingsBloc bloc) =>
          bloc.state.soundStatus == FeedbackStatus.loading ||
          bloc.state.fetchStatus == FeedbackStatus.loading,
    );

    final bool isLoadingHaptic = context.select(
      (final SettingsBloc bloc) =>
          bloc.state.hapticStatus == FeedbackStatus.loading ||
          bloc.state.fetchStatus == FeedbackStatus.loading,
    );

    return BlocListener<SettingsBloc, SettingsState>(
      listener: (final BuildContext context, final SettingsState state) {
        // Configure sound for UI components when sound setting changes
        if (state.soundStatus == FeedbackStatus.success) {
          AppConfig.setSoundEnabled(state.soundEnabled);
        }

        // Configure haptic for UI components when haptic setting changes
        if (state.hapticStatus == FeedbackStatus.success) {
          AppConfig.setHapticEnabled(state.hapticEnabled);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: AppText(l10n.settings),
          leading: AppIconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: l10n.back,
          ),
        ),
        body: ListView(
          children: [
            const ColorModeSection(),
            const FontSizeSection(),
            SettingItem(
              leading: Icon(
                Icons.volume_up,
              ),
              title: l10n.sound,
              trailing: AppSwitch(
                loading: isLoadingSound,
                onText: l10n.on,
                offText: l10n.off,
                value: soundEnabled,
                onChanged: (final _) =>
                    context.read<SettingsBloc>().add(const ToggleSound()),
              ),
            ),
            SettingItem(
              leading: Icon(
                Icons.vibration,
              ),
              title: l10n.haptic,
              trailing: AppSwitch(
                loading: isLoadingHaptic,
                onText: l10n.on,
                offText: l10n.off,
                value: hapticEnabled,
                onChanged: (final _) =>
                    context.read<SettingsBloc>().add(const ToggleHaptic()),
              ),
            ),
            const Divider(),
            SettingItem(
              title:
                  "Version ${_packageInfo?.version ?? "1.0.0"} Build ${_packageInfo?.buildNumber ?? "1"}",
              titleColor: theme.colorScheme.primary.withAlpha(153),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorModeSection extends StatelessWidget {
  const ColorModeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final currentThemeMode = context.watch<ThemeModeBloc>().state;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Platform.isAndroid ? Icons.tablet_android : Icons.tablet_mac,
              ),
              const SizedBox(width: 16),
              AppText(
                l10n.colorModeTitle,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppSegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: AppText(l10n.colorModeLight),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: AppText(l10n.colorModeSystem),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: AppText(l10n.colorModeDark),
                ),
              ],
              selected: {currentThemeMode},
              onSelectionChanged: (Set<ThemeMode> selection) {
                context.read<ThemeModeBloc>().add(
                      ThemeModeChanged(selection.first),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum FontSize {
  smaller,
  regular,
  larger,
}

class FontSizeSection extends StatelessWidget {
  const FontSizeSection({super.key});

  static const Map<FontSize, double> _fontSizeScales = <FontSize, double>{
    FontSize.smaller: 0.85,
    FontSize.regular: 1.0,
    FontSize.larger: 1.15,
  };

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    final double currentScale = context.select(
      (final SettingsBloc bloc) => bloc.state.textScale,
    );

    // Find the closest scale value
    final FontSize currentValue = _fontSizeScales.entries
        .reduce(
          (
            final MapEntry<FontSize, double> a,
            final MapEntry<FontSize, double> b,
          ) =>
              (a.value - currentScale).abs() < (b.value - currentScale).abs()
                  ? a
                  : b,
        )
        .key;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.format_size),
              const SizedBox(width: 16),
              AppText(
                l10n.fontSizeTitle,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppSegmentedButton<FontSize>(
              segments: <ButtonSegment<FontSize>>[
                ButtonSegment<FontSize>(
                  value: FontSize.smaller,
                  label: AppText(l10n.fontSizeSmaller),
                ),
                ButtonSegment<FontSize>(
                  value: FontSize.regular,
                  label: AppText(l10n.fontSizeRegular),
                ),
                ButtonSegment<FontSize>(
                  value: FontSize.larger,
                  label: AppText(l10n.fontSizeLarger),
                ),
              ],
              selected: <FontSize>{currentValue},
              onSelectionChanged: (final Set<FontSize> selection) {
                if (selection.isEmpty) {
                  return;
                }
                final double scale = _fontSizeScales[selection.first]!;
                context
                    .read<SettingsBloc>()
                    .add(TextScaleChanged(scale: scale));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  const SettingItem({
    required this.title,
    this.leading,
    this.trailing,
    this.onTap,
    this.titleColor,
    super.key,
  });

  static const double _leadingWidth = AppSpacing.xxxlg + AppSpacing.sm;

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasLeading = leading != null;

    return AppListTile(
      dense: true,
      leading: SizedBox(
        width: hasLeading ? _leadingWidth : 0,
        child: leading,
      ),
      trailing: trailing,
      visualDensity: const VisualDensity(
        vertical: VisualDensity.minimumDensity,
      ),
      contentPadding: EdgeInsets.fromLTRB(
        hasLeading ? 0 : AppSpacing.xlg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      horizontalTitleGap: 0,
      minLeadingWidth: hasLeading ? _leadingWidth : 0,
      onTap: onTap,
      title: AppText(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: titleColor ?? theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
