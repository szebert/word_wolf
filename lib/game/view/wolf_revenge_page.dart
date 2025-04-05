import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../app_ui/app_spacing.dart";
import "../../app_ui/widgets/app_button.dart";
import "../../app_ui/widgets/app_exit_scope.dart";
import "../../app_ui/widgets/app_text.dart";
import "../../l10n/l10n.dart";
import "../bloc/game_bloc.dart";
import "../models/player.dart";
import "results_page.dart";

class WolfRevengePage extends StatelessWidget {
  const WolfRevengePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const WolfRevengePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const WolfRevengeView();
  }
}

class WolfRevengeView extends StatefulWidget {
  const WolfRevengeView({super.key});

  @override
  State<WolfRevengeView> createState() => _WolfRevengeViewState();
}

class _WolfRevengeViewState extends State<WolfRevengeView> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  void _submitGuess() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final guess = _wordController.text.trim();
      // Add the wolf revenge guess event
      context.read<GameBloc>().add(WolfRevengeGuess(guess: guess));
    }
  }

  Future<void> _submitVerbalGuess() async {
    // Show dialog to confirm if verbal guess was correct
    final wasCorrect = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          title: AppText(
            l10n.wolfRevengeVerbalTitle,
            variant: AppTextVariant.titleMedium,
          ),
          content: AppText(
            l10n.wolfRevengeVerbalContent,
            variant: AppTextVariant.bodyMedium,
          ),
          actions: [
            AppButton(
              variant: AppButtonVariant.outlined,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: AppText(
                l10n.wolfRevengeVerbalNo,
                variant: AppTextVariant.titleMedium,
              ),
            ),
            AppButton(
              variant: AppButtonVariant.filled,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: AppText(
                l10n.wolfRevengeVerbalYes,
                variant: AppTextVariant.titleMedium,
              ),
            ),
          ],
        );
      },
    );

    // Check if the widget is still mounted and if we got a result
    if (!mounted || wasCorrect == null) return;

    // Process the result
    if (wasCorrect) {
      // Successful verbal guess
      context.read<GameBloc>().add(const WolfRevengeVerbalGuess(correct: true));
    } else {
      // Failed verbal guess
      context
          .read<GameBloc>()
          .add(const WolfRevengeVerbalGuess(correct: false));
    }
  }

  void _skipRevenge() {
    // Skip the revenge attempt
    context.read<GameBloc>().add(const WolfRevengeSkipped());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppExitScope(
      child: BlocConsumer<GameBloc, GameState>(
        listenWhen: (previous, current) =>
            previous.game.wolfRevengeAttempted !=
            current.game.wolfRevengeAttempted,
        listener: (context, state) {
          // Check if Wolf's Revenge attempt has already been handled
          if (state.game.wolfRevengeAttempted) {
            // If revenge has been attempted, go directly to results
            Navigator.of(context).push(ResultsPage.route());
          }
        },
        builder: (context, state) {
          final game = state.game;

          // Get the selected (eliminated) player
          final selectedPlayer = game.selectedPlayerId != null
              ? game.players.firstWhere(
                  (player) => player.id == game.selectedPlayerId,
                  orElse: () => Player.empty(),
                )
              : Player.empty();

          return Scaffold(
            appBar: AppBar(
              title: AppText(
                l10n.wolfRevengePageTitle,
                variant: AppTextVariant.titleLarge,
              ),
            ),
            // Use resizeToAvoidBottomInset: false to prevent the screen from resizing when keyboard appears
            resizeToAvoidBottomInset: false,
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Scrollable content area
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Player name and explanation
                          AppText(
                            l10n.wolfRevengeEliminated(selectedPlayer.name),
                            variant: AppTextVariant.headlineSmall,
                            weight: AppTextWeight.bold,
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          AppText(
                            l10n.wolfRevengeExplanation,
                            variant: AppTextVariant.bodyLarge,
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Input form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                AppText(
                                  l10n.wolfRevengePrompt,
                                  variant: AppTextVariant.labelLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextFormField(
                                  controller: _wordController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: l10n.wolfRevengeGuessHint,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return l10n.wolfRevengeEmptyError;
                                    }
                                    return null;
                                  },
                                  textCapitalization: TextCapitalization.words,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Fixed button area at the bottom
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Submit button
                      AppButton(
                        variant: AppButtonVariant.filled,
                        isLoading: _isSubmitting,
                        onPressed: _submitGuess,
                        child: AppText(
                          l10n.wolfRevengeSubmit,
                          variant: AppTextVariant.titleMedium,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Verbal guess button
                      AppButton(
                        variant: AppButtonVariant.outlined,
                        disabled: _isSubmitting,
                        onPressed: _submitVerbalGuess,
                        child: AppText(
                          l10n.wolfRevengeVerbal,
                          variant: AppTextVariant.titleMedium,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Give up button
                      AppButton(
                        variant: AppButtonVariant.outlined,
                        disabled: _isSubmitting,
                        onPressed: _skipRevenge,
                        child: AppText(
                          l10n.wolfRevengeGiveUp,
                          variant: AppTextVariant.titleMedium,
                          colorOption: AppTextColor.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
