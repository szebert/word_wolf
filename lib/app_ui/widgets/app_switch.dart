import "package:flutter/material.dart";

import "../app_config.dart";
import "../app_spacing.dart";
import "app_text.dart";

/// {@template app_switch}
/// Switch with optional leading text displayed in the application.
/// {@endtemplate}
class AppSwitch extends StatelessWidget {
  /// {@macro app_switch}
  const AppSwitch({
    required this.value,
    required this.onChanged,
    this.onText = "",
    this.offText = "",
    this.enabled = true,
    this.loading = false,
    super.key,
  });

  /// Text displayed when this switch is set to true.
  ///
  /// Defaults to an empty string.
  final String onText;

  /// Text displayed when this switch is set to false.
  ///
  /// Defaults to an empty string.
  final String offText;

  /// Whether this checkbox is checked.
  final bool value;

  /// Called when the value of the checkbox should change.
  final ValueChanged<bool?> onChanged;

  /// Whether this switch is enabled.
  final bool enabled;

  /// Whether this switch is loading.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          value ? onText : offText,
        ),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: loading ? 0.5 : 1.0,
                child: Switch(
                  value: value,
                  onChanged: (loading || !enabled)
                      ? null
                      : (bool newValue) {
                          AppConfig.playFeedback();
                          onChanged(newValue);
                        },
                ),
              ),
              if (loading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
