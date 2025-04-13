import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../app_ui/app_spacing.dart";
import "../app_ui/widgets/app_button.dart";
import "../app_ui/widgets/app_dropdown_button_form_field.dart";
import "../app_ui/widgets/app_icon_button.dart";
import "../app_ui/widgets/app_list_tile.dart";
import "../app_ui/widgets/app_switch.dart";
import "../app_ui/widgets/app_text.dart";
import "../l10n/l10n.dart";
import "bloc/api_config_bloc.dart";
import "models/ai_provider.dart";

class APIConfigPage extends StatelessWidget {
  const APIConfigPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const APIConfigPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const APIConfigView();
  }
}

class APIConfigView extends StatefulWidget {
  const APIConfigView({super.key});

  @override
  State<APIConfigView> createState() => _APIConfigViewState();
}

class _APIConfigViewState extends State<APIConfigView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apiKeyController;
  late TextEditingController _apiUrlController;
  late OpenAIConfig _openAIConfig;
  final FocusNode _apiKeyFocusNode = FocusNode();

  // Track original values for comparison
  String? _originalApiKey;
  String? _originalApiUrl;
  bool _keyModified = false;
  bool _urlModified = false;

  // OpenAI models
  final List<String> _openAIModels = [
    // "model", // (input $/1M tokens) / (output $/1M tokens)
    "o1-pro", // 150 / 600
    "gpt-4.5-preview", // 75 / 150
    "o1", // 15 / 60
    "gpt-4o", // 2.5 / 10
    "o3-mini", // 1.1 / 4.4
    "gpt-4o-mini", // 0.15 / 0.6
  ];

  final apiKeyPlaceholder = "••••••••••••••••••••••";

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _apiUrlController = TextEditingController();

    // Initialize values from bloc state
    final state = context.read<APIConfigBloc>().state;
    _openAIConfig = state.openAIConfig;

    // Store original values to track modifications
    _originalApiKey = state.openAIConfig.apiKey;
    _originalApiUrl = state.openAIConfig.apiUrl;

    // Set up URL controller if needed
    if (state.openAIConfig.apiUrl != null) {
      _apiUrlController.text = state.openAIConfig.apiUrl!;
    }

    // Don't set actual API key for security - just show a placeholder if it exists
    if (state.openAIConfig.apiKey != null &&
        state.openAIConfig.apiKey!.isNotEmpty) {
      _apiKeyController.text = apiKeyPlaceholder;
    }

    // Add listeners to track modifications
    _apiKeyController.addListener(_onApiKeyChanged);
    _apiUrlController.addListener(_onApiUrlChanged);

    // Add focus listeners to handle placeholder
    _apiKeyFocusNode.addListener(_handleApiKeyFocus);
  }

  @override
  void dispose() {
    _apiKeyController.removeListener(_onApiKeyChanged);
    _apiUrlController.removeListener(_onApiUrlChanged);
    _apiKeyFocusNode.removeListener(_handleApiKeyFocus);
    _apiKeyController.dispose();
    _apiUrlController.dispose();
    _apiKeyFocusNode.dispose();
    super.dispose();
  }

  void _onApiKeyChanged() {
    final keyText = _apiKeyController.text;

    // Consider it modified if:
    // 1. It's not the placeholder bullets AND
    // 2. It's not the original key AND
    // 3. It's not empty (empty is handled by the focus listener)
    if (keyText != apiKeyPlaceholder &&
        keyText != _originalApiKey &&
        keyText.isNotEmpty) {
      setState(() {
        _keyModified = true;
      });
    }
  }

  void _onApiUrlChanged() {
    setState(() {
      _urlModified = _apiUrlController.text != _originalApiUrl;
    });
  }

  // Auto-save when the toggle or model changes
  void _autoSaveOpenAISettings(AppLocalizations l10n) {
    // Don't save if we're enabling but no key is provided
    if (_openAIConfig.enabled && _apiKeyController.text.isEmpty) {
      return;
    }

    _saveOpenAISettings(l10n);
  }

  void _saveOpenAISettings(AppLocalizations l10n) {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    // Determine the API key to save
    final apiKey = _getApiKeyToSave();

    // Determine the API URL to save
    final apiUrl = _apiUrlController.text.trim().isNotEmpty
        ? _apiUrlController.text.trim()
        : null;

    // Create updated config with explicit null handling
    final updatedConfig = _openAIConfig.copyWithExplicitNulls(
      enabled: _openAIConfig.enabled,
      apiKey: apiKey,
      apiUrl: apiUrl,
      model: _openAIConfig.model,
    );

    // Update configuration
    context.read<APIConfigBloc>().add(
          OpenAIConfigUpdated(
            config: updatedConfig,
            l10n: l10n,
          ),
        );

    // Reset modification flags after saving
    setState(() {
      _keyModified = false;
      _urlModified = false;
      _originalApiKey = updatedConfig.apiKey;
      _originalApiUrl = updatedConfig.apiUrl;
    });
  }

  // Logic to determine what API key to save
  String? _getApiKeyToSave() {
    final keyText = _apiKeyController.text;

    // If API key was modified and is not the placeholder
    if (_keyModified) {
      // If field is empty, the user might be trying to clear the key
      if (keyText.isEmpty) {
        return null;
      }
      // Don't save the placeholder as the actual key
      if (keyText != apiKeyPlaceholder) {
        return keyText;
      }
    }

    // If not modified or is the placeholder, keep original
    return _originalApiKey;
  }

  // Handle focus changes on the API key field
  void _handleApiKeyFocus() {
    // When focused, clear the placeholder to allow typing
    if (_apiKeyFocusNode.hasFocus) {
      if (_apiKeyController.text == apiKeyPlaceholder) {
        // Remove the placeholder when focused
        _apiKeyController.clear();
      }
    } else {
      // When unfocused, restore placeholder if field is empty and we have an original key
      if (_apiKeyController.text.isEmpty &&
          _originalApiKey != null &&
          _originalApiKey!.isNotEmpty) {
        _apiKeyController.text = apiKeyPlaceholder;
        // Reset modification flag since we're reverting to the placeholder
        setState(() {
          _keyModified = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          l10n.aiCustomizationTitle,
          variant: AppTextVariant.titleLarge,
        ),
        leading: AppIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: l10n.back,
        ),
      ),
      body: BlocConsumer<APIConfigBloc, APIConfigState>(
        listener: (context, state) {
          switch (state.status) {
            case APIConfigStatus.error:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: AppText(state.error ?? l10n.unknownError),
                  showCloseIcon: true,
                ),
              );
              break;
            case APIConfigStatus.loaded:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: AppText(l10n.saveSettingsSuccess),
                  showCloseIcon: true,
                ),
              );
              // Update local state when bloc state changes
              setState(() {
                _openAIConfig = state.openAIConfig;
                _originalApiKey = state.openAIConfig.apiKey;
                _originalApiUrl = state.openAIConfig.apiUrl;
                _keyModified = false;
                _urlModified = false;

                // Reset URL controller if needed
                if (state.openAIConfig.apiUrl != null &&
                    _apiUrlController.text != state.openAIConfig.apiUrl) {
                  _apiUrlController.text = state.openAIConfig.apiUrl!;
                }

                // Reset key field to placeholder if key exists
                if (state.openAIConfig.apiKey != null &&
                    state.openAIConfig.apiKey!.isNotEmpty) {
                  _apiKeyController.text = apiKeyPlaceholder;
                }
              });
              break;
            default:
          }
        },
        builder: (context, state) {
          final isLoading = state.status == APIConfigStatus.loading;

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // OpenAI Title
                          AppText(
                            l10n.openaiConnectionTitle,
                            variant: AppTextVariant.titleMedium,
                            weight: AppTextWeight.bold,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Enable/disable OpenAI toggle
                          AppListTile(
                            onTap: null,
                            dense: true,
                            trailing: AppSwitch(
                              loading: isLoading,
                              onText: l10n.on,
                              offText: l10n.off,
                              value: _openAIConfig.enabled,
                              onChanged: (value) {
                                setState(() {
                                  _openAIConfig =
                                      _openAIConfig.copyWith(enabled: value);
                                });
                                if (value == null) return;
                                // Auto-save when toggle changes
                                // Only if disabling or if key exists
                                if (!value) {
                                  // Always auto-save when disabling
                                  _autoSaveOpenAISettings(l10n);
                                } else if (_originalApiKey != null) {
                                  // Only auto-save when enabling if key exists
                                  if (_originalApiKey!.isNotEmpty) {
                                    _autoSaveOpenAISettings(l10n);
                                  }
                                }
                              },
                            ),
                            visualDensity: const VisualDensity(
                              vertical: VisualDensity.minimumDensity,
                            ),
                            horizontalTitleGap: 0,
                            minLeadingWidth: 0,
                            title: AppText(l10n.enableOpenai),
                            subtitle: AppText(
                              l10n.enableOpenaiSubtitle,
                              variant: AppTextVariant.bodySmall,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // API Key field
                          AppText(
                            l10n.openaiApiKey,
                            variant: AppTextVariant.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _apiKeyController,
                            focusNode: _apiKeyFocusNode,
                            enabled: _openAIConfig.enabled && !isLoading,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: l10n.openaiApiKeyHint,
                              // Show clear button if key exists
                              suffixIcon: _apiKeyController.text.isNotEmpty &&
                                      _openAIConfig.enabled &&
                                      _apiKeyController.text !=
                                          apiKeyPlaceholder
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        // Clear the field and mark as modified
                                        _apiKeyController.clear();
                                        setState(() {
                                          _keyModified = true;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (_openAIConfig.enabled &&
                                  (value == null || value.isEmpty)) {
                                // If field is empty but we have an original key, consider it valid
                                if (_originalApiKey != null &&
                                    _originalApiKey!.isNotEmpty &&
                                    !_keyModified) {
                                  return null;
                                }
                                return l10n.openaiApiKeyRequired;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // API URL field
                          AppText(
                            l10n.openaiApiUrl,
                            variant: AppTextVariant.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _apiUrlController,
                            enabled: _openAIConfig.enabled && !isLoading,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText:
                                  "https://api.openai.com/v1/chat/completions",
                              // Show clear button if URL exists
                              suffixIcon: _apiUrlController.text.isNotEmpty &&
                                      _openAIConfig.enabled
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        // Clear to reset to default URL
                                        _apiUrlController.clear();
                                        setState(() {
                                          _urlModified = true;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Model selection dropdown
                          AppText(
                            l10n.openaiModel,
                            variant: AppTextVariant.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppDropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            value: _openAIConfig.model,
                            items: _openAIModels.map((model) {
                              return DropdownMenuItem<String>(
                                value: model,
                                child: AppText(model),
                              );
                            }).toList(),
                            disabled: !_openAIConfig.enabled || isLoading,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _openAIConfig =
                                    _openAIConfig.copyWith(model: value);
                              });
                              // Auto-save when model changes
                              // Only if we have an API key already
                              if (_originalApiKey != null &&
                                  _originalApiKey!.isNotEmpty) {
                                _autoSaveOpenAISettings(l10n);
                              }
                            },
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Info text
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainer,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.sm),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: AppText(
                                    l10n.openaiInformational,
                                    variant: AppTextVariant.bodySmall,
                                    colorOption: AppTextColor.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Save button - only show when API key or URL is modified
              if (_keyModified || _urlModified)
                Container(
                  padding: EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                  ),
                  width: double.infinity,
                  child: SafeArea(
                    child: AppButton(
                      onPressed: () => _saveOpenAISettings(l10n),
                      minWidth: double.infinity,
                      variant: AppButtonVariant.elevated,
                      child: AppText(
                        l10n.saveSettings,
                        variant: AppTextVariant.titleMedium,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
