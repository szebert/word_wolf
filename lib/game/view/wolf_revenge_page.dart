import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../app_ui/app_spacing.dart";
import "../../app_ui/widgets/app_button.dart";
import "../../app_ui/widgets/app_exit_scope.dart";
import "../../app_ui/widgets/app_icon_button.dart";
import "../../app_ui/widgets/app_text.dart";
import "../../l10n/l10n.dart";
import "../bloc/game_bloc.dart";
import "../models/player.dart";
import "../services/timer_feedback_manager.dart";
import "results_page.dart";

// Timer manager to ensure only one timer exists globally
class _TimerManager {
  static Timer? _timer;
  static final Stopwatch _stopwatch = Stopwatch();
  static int _targetDuration = 0;

  static void reset(int initialDuration) {
    cancelTimer();
    _targetDuration = initialDuration;
    _stopwatch.reset();
  }

  static void cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _stopwatch.stop();
  }

  static int getRemainingSeconds() {
    if (!_stopwatch.isRunning) return _targetDuration;

    final elapsed = _stopwatch.elapsed.inSeconds;
    final remaining = _targetDuration - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  static void adjustTime(int seconds) {
    final elapsed = _stopwatch.elapsed.inSeconds;
    final remaining = _targetDuration - elapsed;
    if (remaining <= 0) return;

    _targetDuration += seconds;
  }

  static void startTimer() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    }
  }
}

class WolfRevengePage extends StatelessWidget {
  const WolfRevengePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const WolfRevengePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Timer will be reset when the view initializes
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

  // Local state for display
  static const _initialTimerDuration = 30;
  int _displaySeconds = _initialTimerDuration;
  Timer? _displayUpdateTimer;

  // Timer feedback manager for audio and haptic feedback
  final _feedbackManager = TimerFeedbackManager();

  @override
  void initState() {
    super.initState();

    // Initialize audio/haptic feedback
    _feedbackManager.initialize();

    // Reset timer with our initial duration
    _TimerManager.reset(_initialTimerDuration);

    // Start the global timer
    _TimerManager.startTimer();

    // Start the UI update timer
    _startDisplayUpdates();
  }

  @override
  void dispose() {
    _wordController.dispose();
    if (_displayUpdateTimer != null) {
      _displayUpdateTimer!.cancel();
      _displayUpdateTimer = null;
    }

    // Dispose of audio/haptic feedback
    _feedbackManager.dispose();

    super.dispose();
  }

  void _startDisplayUpdates() {
    // Cancel any existing UI update timer
    if (_displayUpdateTimer != null) {
      _displayUpdateTimer!.cancel();
    }

    // Create a timer just for UI updates
    _displayUpdateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        final remaining = _TimerManager.getRemainingSeconds();

        // Only update if changed
        if (remaining != _displaySeconds) {
          setState(() {
            _displaySeconds = remaining;
          });

          // Play tick-tock sounds for last 10 seconds
          if (remaining > 0 && remaining <= 10) {
            _feedbackManager.playTickTock(remaining);
          }

          // Check for expiration
          if (remaining <= 0) {
            _displayUpdateTimer?.cancel();
            _displayUpdateTimer = null;
            _timeExpired();
          }
        }
      },
    );
  }

  void _timeExpired() {
    // Wolf's time is up - they lose
    if (!mounted) return;

    _TimerManager.cancelTimer();
    _feedbackManager.stopFeedback();
    context.read<GameBloc>().add(const WolfRevengeSkipped());

    // Navigate to results page
    Navigator.of(context).pushReplacement(ResultsPage.route());
  }

  void _adjustTime(int seconds) {
    if (!mounted) return;

    final remaining = _TimerManager.getRemainingSeconds();

    final newTarget = remaining + seconds;

    // Validate time bounds (min 1 second, max 5 minutes)
    if (newTarget < 1 || newTarget > 5 * 60) return;

    // Adjust time in global timer
    _TimerManager.adjustTime(seconds);

    // Update display immediately
    setState(() {
      _displaySeconds = _TimerManager.getRemainingSeconds();
    });

    // Reset tick tracking if we adjust above 10 seconds
    if (newTarget > 10) {
      _feedbackManager.resetTickTracking();
    }
  }

  void _submitGuess() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Stop feedback when submitting
      _feedbackManager.stopFeedback();

      final guess = _wordController.text.trim();
      // Add the wolf revenge guess event
      context.read<GameBloc>().add(WolfRevengeGuess(guess: guess));
    }
  }

  Future<void> _submitVerbalGuess() async {
    // Stop feedback when submitting verbal guess
    _feedbackManager.stopFeedback();

    // Show dialog to confirm if verbal guess was correct
    final wasCorrect = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          title: AppText(
            l10n.revengeVerbalTitle,
            variant: AppTextVariant.titleMedium,
          ),
          content: AppText(
            l10n.revengeVerbalContent,
            variant: AppTextVariant.bodyMedium,
          ),
          actions: [
            AppButton(
              variant: AppButtonVariant.outlined,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: AppText(
                l10n.revengeVerbalNo,
                variant: AppTextVariant.titleMedium,
              ),
            ),
            AppButton(
              variant: AppButtonVariant.filled,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: AppText(
                l10n.revengeVerbalYes,
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
      context.read<GameBloc>().add(const WolfRevengeVerbalGuess(
            correct: false,
          ));
    }
  }

  void _skipRevenge() {
    // Stop feedback when skipping
    _feedbackManager.stopFeedback();

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
            // Cancel timer when a decision is made
            _TimerManager.cancelTimer();
            _feedbackManager.stopFeedback();
            // If revenge has been attempted, go directly to results
            Navigator.of(context).pushReplacement(ResultsPage.route());
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
                l10n.revengePageTitle,
                variant: AppTextVariant.titleLarge,
              ),
            ),
            // Allow screen to resize when keyboard appears
            resizeToAvoidBottomInset: true,
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Scrollable content area
                  Expanded(
                    child: SingleChildScrollView(
                      // Enable physics to ensure it's scrollable
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Player name and explanation
                          AppText(
                            l10n.revengeEliminated(selectedPlayer.name),
                            variant: AppTextVariant.headlineSmall,
                            weight: AppTextWeight.bold,
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          AppText(
                            l10n.revengeExplanation,
                            variant: AppTextVariant.bodyLarge,
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: AppSpacing.xs),

                          // Timer section
                          Column(
                            children: [
                              // Timer with minus/plus buttons on the sides
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Minus 30s button on left
                                  AppIconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 36),
                                    tooltip: l10n.revengeDecreaseTime,
                                    onPressed: () => _adjustTime(-30),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),

                                  // Timer display in center
                                  Column(
                                    children: [
                                      AppText(
                                        l10n.timerValue(
                                          (_displaySeconds ~/ 60).toString(),
                                          (_displaySeconds % 60)
                                              .toString()
                                              .padLeft(2, "0"),
                                        ),
                                        variant: AppTextVariant.displayMedium,
                                        weight: AppTextWeight.bold,
                                        colorOption: _displaySeconds <= 10
                                            ? AppTextColor.error
                                            : AppTextColor.unspecified,
                                      ),
                                      AppText(
                                        l10n.revengeTimeRemaining,
                                        variant: AppTextVariant.bodySmall,
                                        colorOption:
                                            AppTextColor.onSurfaceVariant,
                                      ),
                                    ],
                                  ),

                                  // Plus 30s button on right
                                  AppIconButton(
                                    icon: const Icon(Icons.add_circle_outline,
                                        size: 36),
                                    tooltip: l10n.revengeIncreaseTime,
                                    onPressed: () => _adjustTime(30),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Input form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                AppText(
                                  l10n.revengePrompt,
                                  variant: AppTextVariant.labelLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextFormField(
                                  controller: _wordController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: l10n.revengeGuessHint,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return l10n.revengeEmptyError;
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

                  const SizedBox(height: AppSpacing.lg),

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
                          l10n.revengeSubmit,
                          variant: AppTextVariant.titleMedium,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Verbal guess and Give up buttons in a row
                      Row(
                        children: [
                          // Verbal guess button
                          Expanded(
                            child: AppButton(
                              variant: AppButtonVariant.outlined,
                              disabled: _isSubmitting,
                              onPressed: _submitVerbalGuess,
                              child: AppText(
                                l10n.revengeVerbal,
                                variant: AppTextVariant.titleMedium,
                              ),
                            ),
                          ),

                          const SizedBox(width: AppSpacing.md),

                          // Give up button
                          Expanded(
                            child: AppButton(
                              variant: AppButtonVariant.outlined,
                              disabled: _isSubmitting,
                              onPressed: _skipRevenge,
                              child: AppText(
                                l10n.revengeGiveUp,
                                variant: AppTextVariant.titleMedium,
                                colorOption: AppTextColor.error,
                              ),
                            ),
                          ),
                        ],
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
