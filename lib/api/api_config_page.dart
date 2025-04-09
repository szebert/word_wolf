import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../app_ui/app_spacing.dart";
import "../app_ui/widgets/app_button.dart";
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

  // OpenAI models
  final List<String> _openAIModels = [
    "gpt-4.5-preview", // 75 / 150
    "gpt-o1", // 15 / 60
    "gpt-o3-mini", // 1.1 / 4.4
    "gpt-4o", // 2.5 / 10
    "gpt-4o-mini", // 0.15 / 0.6
  ];

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _apiUrlController = TextEditingController();

    // Initialize values from bloc state
    final state = context.read<APIConfigBloc>().state;
    _openAIConfig = state.openAIConfig;

    // Set up OpenAI controllers if needed
    if (state.openAIConfig.apiKey != null) {
      _apiKeyController.text = state.openAIConfig.apiKey!;
    }
    if (state.openAIConfig.apiUrl != null) {
      _apiUrlController.text = state.openAIConfig.apiUrl!;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _apiUrlController.dispose();
    super.dispose();
  }

  void _saveOpenAISettings() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create updated config
      final updatedConfig = _openAIConfig.copyWith(
        enabled: _openAIConfig.enabled,
        apiKey: _apiKeyController.text,
        apiUrl: _apiUrlController.text.trim().isNotEmpty
            ? _apiUrlController.text.trim()
            : null,
        model: _openAIConfig.model,
      );

      // Update configuration
      context.read<APIConfigBloc>().add(
            OpenAIConfigUpdated(config: updatedConfig),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText("Configuration saved")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          "AI Customization",
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
          if (state.status == APIConfigStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: AppText(state.error ?? "Unknown error")),
            );
          } else if (state.status == APIConfigStatus.loaded) {
            // Update local state when bloc state changes
            setState(() {
              _openAIConfig = state.openAIConfig;

              if (state.openAIConfig.apiKey != null &&
                  _apiKeyController.text != state.openAIConfig.apiKey) {
                _apiKeyController.text = state.openAIConfig.apiKey!;
              }

              if (state.openAIConfig.apiUrl != null &&
                  _apiUrlController.text != state.openAIConfig.apiUrl) {
                _apiUrlController.text = state.openAIConfig.apiUrl!;
              }
            });
          }
        },
        builder: (context, state) {
          if (state.status == APIConfigStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

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
                            "OpenAI API Connection",
                            variant: AppTextVariant.titleMedium,
                            weight: AppTextWeight.bold,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Enable/disable OpenAI toggle
                          AppListTile(
                            onTap: null,
                            dense: true,
                            trailing: AppSwitch(
                              onText: "On",
                              offText: "Off",
                              value: _openAIConfig.enabled,
                              onChanged: (value) {
                                setState(() {
                                  _openAIConfig =
                                      _openAIConfig.copyWith(enabled: value);
                                });
                              },
                            ),
                            visualDensity: const VisualDensity(
                              vertical: VisualDensity.minimumDensity,
                            ),
                            horizontalTitleGap: 0,
                            minLeadingWidth: 0,
                            title: const AppText("Enable OpenAI"),
                            subtitle: const AppText(
                              "Use OpenAI to generate word pairs",
                              variant: AppTextVariant.bodySmall,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // API Key field
                          AppText(
                            "OpenAI API Key",
                            variant: AppTextVariant.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _apiKeyController,
                            enabled: _openAIConfig.enabled,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Enter your OpenAI API key",
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (_openAIConfig.enabled &&
                                  (value == null || value.isEmpty)) {
                                return "API key is required when OpenAI is enabled";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // API URL field
                          AppText(
                            "OpenAI API URL (Optional)",
                            variant: AppTextVariant.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _apiUrlController,
                            enabled: _openAIConfig.enabled,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText:
                                  "Custom API URL (leave empty for default)",
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Model selection dropdown
                          AppText(
                            "OpenAI Model",
                            variant: AppTextVariant.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          DropdownButtonFormField<String>(
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
                            onChanged: _openAIConfig.enabled
                                ? (value) {
                                    if (value != null) {
                                      setState(() {
                                        _openAIConfig = _openAIConfig.copyWith(
                                            model: value);
                                      });
                                    }
                                  }
                                : null,
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
                                    "Using OpenAI can help generate better customized word pairs and improve the game experience. Your credentials are stored only locally on your device.",
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

              // Save button - outside of ScrollView
              Container(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                ),
                width: double.infinity,
                child: SafeArea(
                  child: AppButton(
                    onPressed: _saveOpenAISettings,
                    minWidth: double.infinity,
                    variant: AppButtonVariant.elevated,
                    child: AppText(
                      "Save Settings",
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
