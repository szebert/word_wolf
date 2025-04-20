// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Word Wolf';

  @override
  String get appTagline => 'Where even the Wolf doesn\'t know they\'re the Wolf!';

  @override
  String get startGame => 'Start Game';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get removeAds => 'Remove Ads';

  @override
  String get adFailedToLoadTitle => 'Support Word Wolf';

  @override
  String get adFailedToLoadSubtitle => 'If you\'re enjoying the game, consider our ad-free version to support development and play uninterrupted!';

  @override
  String get back => 'Back';

  @override
  String get notFound => 'Not Found';

  @override
  String get notFoundTitle => 'Page Not Found';

  @override
  String notFoundRoute(String routeName) {
    return 'Route \"$routeName\" does not exist';
  }

  @override
  String get goBack => 'Go Back';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get settings => 'Settings';

  @override
  String get sound => 'Sound';

  @override
  String get haptic => 'Haptic';

  @override
  String get colorModeTitle => 'Color Mode';

  @override
  String get colorModeLight => 'Light';

  @override
  String get colorModeSystem => 'System';

  @override
  String get colorModeDark => 'Dark';

  @override
  String get fontSizeTitle => 'Font Size';

  @override
  String get fontSizeSmaller => 'Smaller';

  @override
  String get fontSizeRegular => 'Regular';

  @override
  String get fontSizeLarger => 'Larger';

  @override
  String get fontSizeLargest => 'Huge';

  @override
  String get howToPlayGameTitle => 'Word Wolf';

  @override
  String get howToPlayIntro => 'The game proceeds in this order:';

  @override
  String get howToPlayGameFlow => '\"Word Assignment\" → \"Discussion\" → \"Voting\"';

  @override
  String get howToPlayWordAssignment => 'Word Assignment';

  @override
  String get howToPlayReceiveWord => 'Each player secretly receives a word.';

  @override
  String get howToPlayKeepSecret => 'Do not show your word to anyone.';

  @override
  String get howToPlayTwoWords => 'There are only two words in play: One that belongs to the majority (Citizens), and one that belongs to the minority (Wolves).';

  @override
  String get howToPlayUnknownRole => 'You won\'t know if you\'re a Citizen or a Wolf.';

  @override
  String get howToPlayDiscussion => 'Discussion';

  @override
  String get howToPlayFindWolf => 'Players talk and try to figure out \"Who is the Wolf?\"';

  @override
  String get howToPlaySameWord => 'Everyone should speak as if they share the same word, even if unsure.';

  @override
  String get howToPlaySubtleMisleading => 'You can subtly mislead or be vague to protect yourself and your team, but be careful!';

  @override
  String get howToPlayVoting => 'Voting';

  @override
  String get howToPlayPoint => 'After discussion, players simultaneously point to who they think is a Wolf, saying \"Ready, go!\"';

  @override
  String get howToPlayElimination => 'The player with the most votes is eliminated.';

  @override
  String get howToPlayTie => 'If there\'s a tie, play a Sudden Death round:';

  @override
  String get howToPlaySuddenDeath => 'You have 1 additional minute to discuss, then vote again.';

  @override
  String get howToPlayRepeat => 'Repeat until someone is eliminated.';

  @override
  String get howToPlayHowToWin => 'How to Win:';

  @override
  String get howToPlayCitizensWin => 'Citizens win if they vote out a Wolf.';

  @override
  String get howToPlayWolvesWin => 'Wolves win if a Citizen is voted out.';

  @override
  String get howToPlayWolfRevenge => 'Wolf\'s Revenge: If a Wolf is voted out but correctly guesses the Citizens\' word, the Wolves steal the win!';

  @override
  String get howToPlaySpiceUp => 'Spice Up Your Game!';

  @override
  String get howToPlayTryIdeas => 'Try these ideas:';

  @override
  String get howToPlayTakeTurns => 'Take turns describing your word.';

  @override
  String get howToPlayNoLying => 'No lying allowed!';

  @override
  String get howToPlayMakeRules => 'You can even make your own rules and play in new ways.';

  @override
  String get howToPlayEnjoy => 'We hope everyone enjoys the game!';

  @override
  String get playerSetup => 'Player Setup';

  @override
  String get players => 'Players';

  @override
  String get playerAdded => 'Add Player';

  @override
  String get playerRemoved => 'Remove Player';

  @override
  String get playerEdit => 'Edit Player';

  @override
  String get playerSave => 'Save Player';

  @override
  String get playerClear => 'Clear';

  @override
  String get playerDelete => 'Delete Player';

  @override
  String get next => 'Next';

  @override
  String playerDefaultName(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Player $numberString';
  }

  @override
  String get category => 'Category';

  @override
  String get gameSettings => 'Game Settings';

  @override
  String get playerComposition => 'Player Composition';

  @override
  String get autoAssign => 'Auto-assign based on player count';

  @override
  String autoAssignSubtitle(int wolfCount, int playerCount) {
    final intl.NumberFormat wolfCountNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String wolfCountString = wolfCountNumberFormat.format(wolfCount);
    final intl.NumberFormat playerCountNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String playerCountString = playerCountNumberFormat.format(playerCount);

    return 'Recommends $wolfCountString wolves for $playerCountString players';
  }

  @override
  String get randomize => 'Randomize wolf count';

  @override
  String get randomizeSubtitle => 'Hides the exact number of wolves from all players';

  @override
  String get hiddenNumber => '?';

  @override
  String get citizens => 'Citizens';

  @override
  String get wolves => 'Wolves';

  @override
  String get moreCitizens => 'More Citizens';

  @override
  String get moreWolves => 'More Wolves';

  @override
  String get discussionDuration => 'Discussion Duration';

  @override
  String get decreaseDuration => 'Decrease Duration';

  @override
  String get increaseDuration => 'Increase Duration';

  @override
  String get minutes => 'Minutes';

  @override
  String get wordPairSimilarity => 'Word Pair Similarity';

  @override
  String get wordPairSimilaritySubtitle => 'Choose how similar or different you want the word pair to be';

  @override
  String get similar => 'Similar';

  @override
  String get different => 'Different';

  @override
  String get extremelySimilar => 'Extremely Similar';

  @override
  String get verySimilar => 'Very Similar';

  @override
  String get similarRange => 'Similar';

  @override
  String get differentRange => 'Different';

  @override
  String get veryDifferent => 'Very Different';

  @override
  String get extremelyDifferent => 'Extremely Different';

  @override
  String get exampleExtremelySimilar => 'Example: \"Sofa\" and \"Couch\"';

  @override
  String get exampleVerySimilar => 'Example: \"Cookie\" and \"Biscuit\"';

  @override
  String get exampleSimilar => 'Example: \"Car\" and \"Truck\"';

  @override
  String get exampleDifferent => 'Example: \"Soccer\" and \"Basketball\"';

  @override
  String get exampleVeryDifferent => 'Example: \"Dog\" and \"Computer\"';

  @override
  String get exampleExtremelyDifferent => 'Example: \"Sunshine\" and \"Algebra\"';

  @override
  String get wolfRevenge => 'Wolf\'s Revenge';

  @override
  String get enableWolfRevenge => 'Enable Wolf\'s Revenge';

  @override
  String get wolfRevengeSubtitle => 'If a Wolf is voted out but correctly guesses the Citizens\' word, the Wolves steal the win!';

  @override
  String get categoriesLoading => 'Loading categories...';

  @override
  String get categoriesTitle => 'Word Choice';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get categoryDescription => 'Optionally choose a category to define the theme for your word pair. A good category helps create balanced yet distinct words.';

  @override
  String get categorySearchHint => 'Search or add a new category';

  @override
  String get categoryClear => 'Clear';

  @override
  String get useCategory => 'Use this category';

  @override
  String get noCategoriesFound => 'No categories found';

  @override
  String get addingCategory => 'Adding...';

  @override
  String lastUsed(String time) {
    return 'Last used: $time';
  }

  @override
  String get removeCategory => 'Remove from saved';

  @override
  String get timeNow => 'Just now';

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String timeMinutesAgo(int minutes) {
    final intl.NumberFormat minutesNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString minutes ago';
  }

  @override
  String timeHoursAgo(int hours) {
    final intl.NumberFormat hoursNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return '$hoursString hours ago';
  }

  @override
  String timeDaysAgo(int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString days ago';
  }

  @override
  String timeWeeksAgo(int weeks) {
    final intl.NumberFormat weeksNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String weeksString = weeksNumberFormat.format(weeks);

    return '$weeksString weeks ago';
  }

  @override
  String get exitGame => 'Exit Game';

  @override
  String get exitGameContent => 'If you exit to the main menu, game progress and the words chosen will be lost. Is that okay?';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get wordDistribution => 'Word Distribution';

  @override
  String get wordDistributionLoading => 'Loading word pair...';

  @override
  String get wordGenerationErrorTitle => 'Word Generation Error';

  @override
  String get wordGenerationErrorContent => 'We couldn\'t properly connect to the online service to generate your word pair. You can still continue playing using our built-in word collection!';

  @override
  String get wordGenerationErrorCategoryNote => 'Note: The offline words used will typically have a different category than the one you selected.';

  @override
  String get wordGenerationErrorContinue => 'Continue While Offline';

  @override
  String get allPlayersFinished => 'All players have seen their words!';

  @override
  String get startDiscussion => 'Start Discussion';

  @override
  String get displayWordPhase1 => 'Please make sure nobody else can see this screen.';

  @override
  String get displayWordPhase2 => 'We will display your word. Are you ready?';

  @override
  String get displayWordPhase3 => 'Your Word';

  @override
  String get show => 'Show';

  @override
  String get displayWordConfirmation => 'I\'ve memorized my word!';

  @override
  String get discussion => 'Discussion';

  @override
  String get noCategorySelected => 'No category selected';

  @override
  String timerValue(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get endDiscussion => 'End';

  @override
  String get icebreakers => 'Icebreakers';

  @override
  String get icebreakersSubtitle => 'Optional conversation starters to help players discuss their words';

  @override
  String get icebreakerUnrevealed => '???';

  @override
  String get voting => 'Voting';

  @override
  String votingTitle(int wolfCount) {
    final intl.NumberFormat wolfCountNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String wolfCountString = wolfCountNumberFormat.format(wolfCount);

    String _temp0 = intl.Intl.pluralLogic(
      wolfCount,
      locale: localeName,
      other: 'Who is a Wolf?',
      one: 'Who is the Wolf?',
    );
    return '$_temp0';
  }

  @override
  String votingSubtitle(int wolfCount) {
    final intl.NumberFormat wolfCountNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String wolfCountString = wolfCountNumberFormat.format(wolfCount);

    String _temp0 = intl.Intl.pluralLogic(
      wolfCount,
      locale: localeName,
      other: 'Everyone point to a person you think is a Wolf at the same time. Select the individual with the most votes.',
      one: 'Everyone point to the person you think is the Wolf at the same time. Select the individual with the most votes.',
    );
    return '$_temp0';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get suddenDeath => 'Sudden Death';

  @override
  String get suddenDeathSubtitle => '(when there\'s still a tie)';

  @override
  String get results => 'Results';

  @override
  String get citizensWin => 'The Citizens Win!';

  @override
  String wolvesWin(int wolvesCount) {
    final intl.NumberFormat wolvesCountNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String wolvesCountString = wolvesCountNumberFormat.format(wolvesCount);

    String _temp0 = intl.Intl.pluralLogic(
      wolvesCount,
      locale: localeName,
      other: 'The Wolves Win!',
      one: 'The Wolf Wins!',
    );
    return '$_temp0';
  }

  @override
  String get eliminated => 'Eliminated';

  @override
  String get revenged => 'Revenged';

  @override
  String get exitToMenu => 'Exit to Menu';

  @override
  String get revengePageTitle => 'Wolf\'s Revenge';

  @override
  String revengeEliminated(String playerName) {
    return '$playerName, you\'ve been eliminated!';
  }

  @override
  String get revengeExplanation => 'But you can still win the game for the wolves! If you can correctly guess the citizens\' word, you\'ll steal the victory.';

  @override
  String get revengePrompt => 'What do you think the citizens\' word was?';

  @override
  String get revengeGuessHint => 'Enter your guess';

  @override
  String get revengeSubmit => 'Submit Guess';

  @override
  String get revengeEmptyError => 'Please enter a word';

  @override
  String get revengeVerbal => 'Guess Verbally';

  @override
  String get revengeGiveUp => 'Give Up';

  @override
  String get revengeVerbalTitle => 'Was your verbal guess correct?';

  @override
  String get revengeVerbalContent => 'Did the citizens confirm your guess was correct?';

  @override
  String get revengeVerbalNo => 'No';

  @override
  String get revengeVerbalYes => 'Yes';

  @override
  String get revengeTimeRemaining => 'Time Remaining';

  @override
  String get revengeDecreaseTime => 'Decrease Time';

  @override
  String get revengeIncreaseTime => 'Increase Time';

  @override
  String get aiCustomizationTitle => 'AI Customization';

  @override
  String get openaiConnectionTitle => 'OpenAI Connection';

  @override
  String get enableOpenai => 'Enable OpenAI';

  @override
  String get enableOpenaiSubtitle => 'Use OpenAI to generate word pairs';

  @override
  String get openaiApiKey => 'OpenAI API Key';

  @override
  String get openaiApiKeyHint => 'Enter your OpenAI API key';

  @override
  String get openaiApiKeyRequired => 'API key is required when OpenAI is enabled';

  @override
  String get openaiApiUrl => 'OpenAI API URL (Optional)';

  @override
  String get openaiModel => 'OpenAI Model';

  @override
  String get openaiInformational => 'Using OpenAI can help generate better customized word pairs and improve the game experience. Your credentials are stored only locally on your device.';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get saveSettingsSuccess => 'Configuration saved';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get openaiOfflineError => 'Unable to connect to OpenAI. Please check your internet connection.';

  @override
  String get openaiInvalidKeyError => 'The API key appears to be invalid. Please check your API key.';

  @override
  String get openaiInsufficientPermissionsError => 'Your API key doesn\'t have sufficient permissions. Missing scope: model.request.';

  @override
  String get openaiInvalidModelError => 'The selected model does not exist or you do not have access to it.';

  @override
  String get openaiModelNotSupportedError => 'The selected model doesn\'t support JSON schema response format. Please choose a different model.';
}
