import "package:flutter/material.dart";

import "../app_config.dart";

/// {@template app_dropdown_button_form_field}
/// A DropdownButtonFormField with app-specific feedback settings.
/// {@endtemplate}
class AppDropdownButtonFormField<T> extends DropdownButtonFormField<T> {
  /// {@macro app_dropdown_button_form_field}
  AppDropdownButtonFormField({
    required Function(T?)? onChanged,
    bool disabled = false,
    super.key,
    super.decoration,
    super.value,
    super.items,
  }) : super(
          onChanged: disabled
              ? null
              : onChanged == null
                  ? null
                  : (T? newValue) {
                      AppConfig.playFeedback();
                      onChanged(newValue);
                    },
          enableFeedback: false,
        );
}
