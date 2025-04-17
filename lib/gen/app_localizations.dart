import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// The title of the app
  ///
  /// In en, this message translates to:
  /// **'Word Wolf'**
  String get appTitle;

  /// The tagline of the app
  ///
  /// In en, this message translates to:
  /// **'Where even the Wolf doesn\'t know they\'re the Wolf!'**
  String get appTagline;

  /// The text of the start game button
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// The text of the how to play button
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// The text for the remove ads button
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get removeAds;

  /// The text of the ad failed to load title
  ///
  /// In en, this message translates to:
  /// **'Support Word Wolf'**
  String get adFailedToLoadTitle;

  /// The text of the ad failed to load subtitle
  ///
  /// In en, this message translates to:
  /// **'If you\'re enjoying the game, consider our ad-free version to support development and play uninterrupted!'**
  String get adFailedToLoadSubtitle;

  /// The text of the back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// The text of the not found page title
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get notFound;

  /// The text of the not found title
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get notFoundTitle;

  /// The text of the not found route
  ///
  /// In en, this message translates to:
  /// **'Route \"{routeName}\" does not exist'**
  String notFoundRoute(String routeName);

  /// The text of the go back button
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// The text of the on button
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// The text of the off button
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// The text of the settings title and button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// The text of the sound title
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// The text of the haptic title
  ///
  /// In en, this message translates to:
  /// **'Haptic'**
  String get haptic;

  /// The title of the color mode section
  ///
  /// In en, this message translates to:
  /// **'Color Mode'**
  String get colorModeTitle;

  /// The text of the light color mode button
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get colorModeLight;

  /// The text of the system color mode button
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get colorModeSystem;

  /// The text of the dark color mode button
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get colorModeDark;

  /// The title of the font size section
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSizeTitle;

  /// The text of the smaller font size button
  ///
  /// In en, this message translates to:
  /// **'Smaller'**
  String get fontSizeSmaller;

  /// The text of the regular font size button
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get fontSizeRegular;

  /// The text of the larger font size button
  ///
  /// In en, this message translates to:
  /// **'Larger'**
  String get fontSizeLarger;

  /// The text of the largest (huge) font size button
  ///
  /// In en, this message translates to:
  /// **'Huge'**
  String get fontSizeLargest;

  /// The title of the game in the how to play page
  ///
  /// In en, this message translates to:
  /// **'Word Wolf'**
  String get howToPlayGameTitle;

  /// Introduction text in the how to play page
  ///
  /// In en, this message translates to:
  /// **'The game proceeds in this order:'**
  String get howToPlayIntro;

  /// The flow of the game in the how to play page
  ///
  /// In en, this message translates to:
  /// **'\"Word Assignment\" → \"Discussion\" → \"Voting\"'**
  String get howToPlayGameFlow;

  /// Word Assignment section title in how to play page
  ///
  /// In en, this message translates to:
  /// **'Word Assignment'**
  String get howToPlayWordAssignment;

  /// Rule about receiving words in how to play page
  ///
  /// In en, this message translates to:
  /// **'Each player secretly receives a word.'**
  String get howToPlayReceiveWord;

  /// Rule about keeping words secret in how to play page
  ///
  /// In en, this message translates to:
  /// **'Do not show your word to anyone.'**
  String get howToPlayKeepSecret;

  /// Rule about the two words in play in how to play page
  ///
  /// In en, this message translates to:
  /// **'There are only two words in play: One that belongs to the majority (Citizens), and one that belongs to the minority (Wolves).'**
  String get howToPlayTwoWords;

  /// Rule about not knowing your role in how to play page
  ///
  /// In en, this message translates to:
  /// **'You won\'t know if you\'re a Citizen or a Wolf.'**
  String get howToPlayUnknownRole;

  /// Discussion section title in how to play page
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get howToPlayDiscussion;

  /// Rule about finding the wolf in how to play page
  ///
  /// In en, this message translates to:
  /// **'Players talk and try to figure out \"Who is the Wolf?\"'**
  String get howToPlayFindWolf;

  /// Rule about speaking as if sharing the same word in how to play page
  ///
  /// In en, this message translates to:
  /// **'Everyone should speak as if they share the same word, even if unsure.'**
  String get howToPlaySameWord;

  /// Rule about misleading in how to play page
  ///
  /// In en, this message translates to:
  /// **'You can subtly mislead or be vague to protect yourself and your team, but be careful!'**
  String get howToPlaySubtleMisleading;

  /// Voting section title in how to play page
  ///
  /// In en, this message translates to:
  /// **'Voting'**
  String get howToPlayVoting;

  /// Rule about pointing in how to play page
  ///
  /// In en, this message translates to:
  /// **'After discussion, players simultaneously point to who they think is a Wolf, saying \"Ready, go!\"'**
  String get howToPlayPoint;

  /// Rule about elimination in how to play page
  ///
  /// In en, this message translates to:
  /// **'The player with the most votes is eliminated.'**
  String get howToPlayElimination;

  /// Rule about ties in how to play page
  ///
  /// In en, this message translates to:
  /// **'If there\'s a tie, play a Sudden Death round:'**
  String get howToPlayTie;

  /// Rule about sudden death in how to play page
  ///
  /// In en, this message translates to:
  /// **'You have 1 additional minute to discuss, then vote again.'**
  String get howToPlaySuddenDeath;

  /// Rule about repeating votes in how to play page
  ///
  /// In en, this message translates to:
  /// **'Repeat until someone is eliminated.'**
  String get howToPlayRepeat;

  /// How to Win section title in how to play page
  ///
  /// In en, this message translates to:
  /// **'How to Win:'**
  String get howToPlayHowToWin;

  /// Rule about Citizens winning in how to play page
  ///
  /// In en, this message translates to:
  /// **'Citizens win if they vote out a Wolf.'**
  String get howToPlayCitizensWin;

  /// Rule about Wolves winning in how to play page
  ///
  /// In en, this message translates to:
  /// **'Wolves win if a Citizen is voted out.'**
  String get howToPlayWolvesWin;

  /// Rule about Wolf's Revenge in how to play page
  ///
  /// In en, this message translates to:
  /// **'Wolf\'s Revenge: If a Wolf is voted out but correctly guesses the Citizens\' word, the Wolves steal the win!'**
  String get howToPlayWolfRevenge;

  /// Spice Up Your Game section title in how to play page
  ///
  /// In en, this message translates to:
  /// **'Spice Up Your Game!'**
  String get howToPlaySpiceUp;

  /// Introduction to game variation ideas in how to play page
  ///
  /// In en, this message translates to:
  /// **'Try these ideas:'**
  String get howToPlayTryIdeas;

  /// Game variation idea about taking turns in how to play page
  ///
  /// In en, this message translates to:
  /// **'Take turns describing your word.'**
  String get howToPlayTakeTurns;

  /// Game variation idea about no lying in how to play page
  ///
  /// In en, this message translates to:
  /// **'No lying allowed!'**
  String get howToPlayNoLying;

  /// Encouragement to make own rules in how to play page
  ///
  /// In en, this message translates to:
  /// **'You can even make your own rules and play in new ways.'**
  String get howToPlayMakeRules;

  /// Closing message in how to play page
  ///
  /// In en, this message translates to:
  /// **'We hope everyone enjoys the game!'**
  String get howToPlayEnjoy;

  /// The text of the player setup page title
  ///
  /// In en, this message translates to:
  /// **'Player Setup'**
  String get playerSetup;

  /// The text for players label
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// The text for player added button
  ///
  /// In en, this message translates to:
  /// **'Add Player'**
  String get playerAdded;

  /// The text for player removed button
  ///
  /// In en, this message translates to:
  /// **'Remove Player'**
  String get playerRemoved;

  /// The text for player edit button
  ///
  /// In en, this message translates to:
  /// **'Edit Player'**
  String get playerEdit;

  /// The text for player save button
  ///
  /// In en, this message translates to:
  /// **'Save Player'**
  String get playerSave;

  /// The text for player clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get playerClear;

  /// The text for player delete button
  ///
  /// In en, this message translates to:
  /// **'Delete Player'**
  String get playerDelete;

  /// The text of the next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// The default name format for players
  ///
  /// In en, this message translates to:
  /// **'Player {number}'**
  String playerDefaultName(int number);

  /// The text of the category label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// The title of the game settings page
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get gameSettings;

  /// The title of the player composition section
  ///
  /// In en, this message translates to:
  /// **'Player Composition'**
  String get playerComposition;

  /// The text for auto-assign wolves toggle
  ///
  /// In en, this message translates to:
  /// **'Auto-assign based on player count'**
  String get autoAssign;

  /// The text showing recommended number of wolves
  ///
  /// In en, this message translates to:
  /// **'Recommends {wolfCount} wolves for {playerCount} players'**
  String autoAssignSubtitle(int wolfCount, int playerCount);

  /// The text for randomize wolf count toggle
  ///
  /// In en, this message translates to:
  /// **'Randomize wolf count'**
  String get randomize;

  /// The subtitle for explaining the randomize wolf scenario
  ///
  /// In en, this message translates to:
  /// **'Hides the exact number of wolves from all players'**
  String get randomizeSubtitle;

  /// The text for the hidden number of citizens or wolves
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get hiddenNumber;

  /// The text for citizens label
  ///
  /// In en, this message translates to:
  /// **'Citizens'**
  String get citizens;

  /// The text for wolves label
  ///
  /// In en, this message translates to:
  /// **'Wolves'**
  String get wolves;

  /// Tooltip for decreasing wolf count
  ///
  /// In en, this message translates to:
  /// **'More Citizens'**
  String get moreCitizens;

  /// Tooltip for increasing wolf count
  ///
  /// In en, this message translates to:
  /// **'More Wolves'**
  String get moreWolves;

  /// The title of the discussion duration section
  ///
  /// In en, this message translates to:
  /// **'Discussion Duration'**
  String get discussionDuration;

  /// Tooltip for decreasing discussion duration
  ///
  /// In en, this message translates to:
  /// **'Decrease Duration'**
  String get decreaseDuration;

  /// Tooltip for increasing discussion duration
  ///
  /// In en, this message translates to:
  /// **'Increase Duration'**
  String get increaseDuration;

  /// The text for minutes label
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// The title of the word pair similarity section
  ///
  /// In en, this message translates to:
  /// **'Word Pair Similarity'**
  String get wordPairSimilarity;

  /// Description of the word pair similarity feature
  ///
  /// In en, this message translates to:
  /// **'Choose how similar or different you want the word pair to be'**
  String get wordPairSimilaritySubtitle;

  /// The text for similar label on slider
  ///
  /// In en, this message translates to:
  /// **'Similar'**
  String get similar;

  /// The text for different label on slider
  ///
  /// In en, this message translates to:
  /// **'Different'**
  String get different;

  /// Description for lowest similarity range, extremely similar words
  ///
  /// In en, this message translates to:
  /// **'Extremely Similar'**
  String get extremelySimilar;

  /// Description for low similarity range, very similar words
  ///
  /// In en, this message translates to:
  /// **'Very Similar'**
  String get verySimilar;

  /// Description for medium-low similarity range, similar words
  ///
  /// In en, this message translates to:
  /// **'Similar'**
  String get similarRange;

  /// Description for medium-high similarity range, different words
  ///
  /// In en, this message translates to:
  /// **'Different'**
  String get differentRange;

  /// Description for high similarity range, very different words
  ///
  /// In en, this message translates to:
  /// **'Very Different'**
  String get veryDifferent;

  /// Description for highest similarity range, extremely different words
  ///
  /// In en, this message translates to:
  /// **'Extremely Different'**
  String get extremelyDifferent;

  /// Example word pair for extremely similar words
  ///
  /// In en, this message translates to:
  /// **'Example: \"Sofa\" and \"Couch\"'**
  String get exampleExtremelySimilar;

  /// Example word pair for very similar words
  ///
  /// In en, this message translates to:
  /// **'Example: \"Cookie\" and \"Biscuit\"'**
  String get exampleVerySimilar;

  /// Example word pair for similar words
  ///
  /// In en, this message translates to:
  /// **'Example: \"Car\" and \"Truck\"'**
  String get exampleSimilar;

  /// Example word pair for different words
  ///
  /// In en, this message translates to:
  /// **'Example: \"Soccer\" and \"Basketball\"'**
  String get exampleDifferent;

  /// Example word pair for very different words
  ///
  /// In en, this message translates to:
  /// **'Example: \"Dog\" and \"Computer\"'**
  String get exampleVeryDifferent;

  /// Example word pair for extremely different words
  ///
  /// In en, this message translates to:
  /// **'Example: \"Sunshine\" and \"Algebra\"'**
  String get exampleExtremelyDifferent;

  /// Text for the wolf's revenge section in game settings
  ///
  /// In en, this message translates to:
  /// **'Wolf\'s Revenge'**
  String get wolfRevenge;

  /// Text for the enable wolf's revenge toggle in game settings
  ///
  /// In en, this message translates to:
  /// **'Enable Wolf\'s Revenge'**
  String get enableWolfRevenge;

  /// Description text for the wolf's revenge feature in game settings
  ///
  /// In en, this message translates to:
  /// **'If a Wolf is voted out but correctly guesses the Citizens\' word, the Wolves steal the win!'**
  String get wolfRevengeSubtitle;

  /// Text for the loading state in the category selection page
  ///
  /// In en, this message translates to:
  /// **'Loading categories...'**
  String get categoriesLoading;

  /// The title of the category selection page
  ///
  /// In en, this message translates to:
  /// **'Word Choice'**
  String get categoriesTitle;

  /// The title of the category section
  ///
  /// In en, this message translates to:
  /// **'Category Selection'**
  String get categorySelection;

  /// The description text for the category selection
  ///
  /// In en, this message translates to:
  /// **'Optionally choose a category to define the theme for your word pair. A good category helps create balanced yet distinct words.'**
  String get categoryDescription;

  /// Hint text for the category search field
  ///
  /// In en, this message translates to:
  /// **'Search or add a new category'**
  String get categorySearchHint;

  /// Tooltip for the category clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get categoryClear;

  /// Tooltip for the button to use the entered category
  ///
  /// In en, this message translates to:
  /// **'Use this category'**
  String get useCategory;

  /// Text shown when no categories match the search
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// Text shown when a category is being added
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get addingCategory;

  /// Text showing when something was last used
  ///
  /// In en, this message translates to:
  /// **'Last used: {time}'**
  String lastUsed(String time);

  /// Tooltip for the button to remove a saved category
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeCategory;

  /// Text showing when something was done, just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeNow;

  /// Text showing when something was done, yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeYesterday;

  /// Text showing when something was done, minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String timeMinutesAgo(int minutes);

  /// Text showing when something was done, hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String timeHoursAgo(int hours);

  /// Text showing when something was done, days ago
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String timeDaysAgo(int days);

  /// Text showing when something was done, weeks ago
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ago'**
  String timeWeeksAgo(int weeks);

  /// Title and tooltip for the exit game dialog
  ///
  /// In en, this message translates to:
  /// **'Exit Game'**
  String get exitGame;

  /// Content text for the exit game dialog
  ///
  /// In en, this message translates to:
  /// **'If you exit to the main menu, game progress and the words chosen will be lost. Is that okay?'**
  String get exitGameContent;

  /// Text for the cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Text for the OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Title for the word distribution page
  ///
  /// In en, this message translates to:
  /// **'Word Distribution'**
  String get wordDistribution;

  /// Text for the loading state in the word distribution page
  ///
  /// In en, this message translates to:
  /// **'Loading word pair...'**
  String get wordDistributionLoading;

  /// Text for the word generation error state in the word distribution page
  ///
  /// In en, this message translates to:
  /// **'Word Generation Error'**
  String get wordGenerationErrorTitle;

  /// Text for the word generation error content in the word distribution page
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t properly connect to the online service to generate your word pair. You can still continue playing using our built-in word collection!'**
  String get wordGenerationErrorContent;

  /// Text for the word generation error category note in the word distribution page
  ///
  /// In en, this message translates to:
  /// **'Note: The offline words used will typically have a different category than the one you selected.'**
  String get wordGenerationErrorCategoryNote;

  /// Text for the word generation error continue while offline button in the word distribution page
  ///
  /// In en, this message translates to:
  /// **'Continue While Offline'**
  String get wordGenerationErrorContinue;

  /// Text for the all players finished state in the word distribution page
  ///
  /// In en, this message translates to:
  /// **'All players have seen their words!'**
  String get allPlayersFinished;

  /// Text for the start discussion button
  ///
  /// In en, this message translates to:
  /// **'Start Discussion'**
  String get startDiscussion;

  /// Text for the first phase of the display word screen
  ///
  /// In en, this message translates to:
  /// **'Please make sure nobody else can see this screen.'**
  String get displayWordPhase1;

  /// Text for the second phase of the display word screen
  ///
  /// In en, this message translates to:
  /// **'We will display your word. Are you ready?'**
  String get displayWordPhase2;

  /// Text for the third phase of the display word screen
  ///
  /// In en, this message translates to:
  /// **'Your Word'**
  String get displayWordPhase3;

  /// Text for the show button
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// Text for the display word confirmation button
  ///
  /// In en, this message translates to:
  /// **'I\'ve memorized my word!'**
  String get displayWordConfirmation;

  /// Text for the discussion page title
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get discussion;

  /// Text for the no category selected state
  ///
  /// In en, this message translates to:
  /// **'No category selected'**
  String get noCategorySelected;

  /// Text showing remaining time for the display timer
  ///
  /// In en, this message translates to:
  /// **'{minutes}:{seconds}'**
  String timerValue(String minutes, String seconds);

  /// Text for the pause button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Text for the resume button
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Text for the end discussion button
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endDiscussion;

  /// Text for the icebreakers section
  ///
  /// In en, this message translates to:
  /// **'Icebreakers'**
  String get icebreakers;

  /// Text for the icebreakers subtitle
  ///
  /// In en, this message translates to:
  /// **'Optional conversation starters to help players discuss their words'**
  String get icebreakersSubtitle;

  /// Text for the icebreaker label when unrevealed
  ///
  /// In en, this message translates to:
  /// **'???'**
  String get icebreakerUnrevealed;

  /// Title for the voting page
  ///
  /// In en, this message translates to:
  /// **'Voting'**
  String get voting;

  /// Title for the voting section, pluralized based on wolf count
  ///
  /// In en, this message translates to:
  /// **'{wolfCount, plural, =1{Who is the Wolf?} other{Who is a Wolf?}}'**
  String votingTitle(int wolfCount);

  /// Subtitle for the voting section, pluralized based on wolf count
  ///
  /// In en, this message translates to:
  /// **'{wolfCount, plural, =1{Everyone point to the person you think is the Wolf at the same time. Select the individual with the most votes.} other{Everyone point to a person you think is a Wolf at the same time. Select the individual with the most votes.}}'**
  String votingSubtitle(int wolfCount);

  /// Text for the confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Text for the sudden death button
  ///
  /// In en, this message translates to:
  /// **'Sudden Death'**
  String get suddenDeath;

  /// Subtitle for the sudden death button explaining when to use it
  ///
  /// In en, this message translates to:
  /// **'(when there\'s still a tie)'**
  String get suddenDeathSubtitle;

  /// Text for the results page title
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// Text shown when citizens win the game
  ///
  /// In en, this message translates to:
  /// **'The Citizens Win!'**
  String get citizensWin;

  /// Text shown when wolves win the game
  ///
  /// In en, this message translates to:
  /// **'{wolvesCount, plural, =1{The Wolf Wins!} other{The Wolves Win!}}'**
  String wolvesWin(int wolvesCount);

  /// Label for the eliminated player
  ///
  /// In en, this message translates to:
  /// **'Eliminated'**
  String get eliminated;

  /// Label for the revenged player
  ///
  /// In en, this message translates to:
  /// **'Revenged'**
  String get revenged;

  /// Text for the button to exit to main menu
  ///
  /// In en, this message translates to:
  /// **'Exit to Menu'**
  String get exitToMenu;

  /// Title for the Wolf's Revenge page
  ///
  /// In en, this message translates to:
  /// **'Wolf\'s Revenge'**
  String get revengePageTitle;

  /// Message shown to the eliminated wolf player
  ///
  /// In en, this message translates to:
  /// **'{playerName}, you\'ve been eliminated!'**
  String revengeEliminated(String playerName);

  /// Explanation of the Wolf's Revenge mechanic
  ///
  /// In en, this message translates to:
  /// **'But you can still win the game for the wolves! If you can correctly guess the citizens\' word, you\'ll steal the victory.'**
  String get revengeExplanation;

  /// Prompt for the wolf to guess the citizens' word
  ///
  /// In en, this message translates to:
  /// **'What do you think the citizens\' word was?'**
  String get revengePrompt;

  /// Hint text for the word guess input field
  ///
  /// In en, this message translates to:
  /// **'Enter your guess'**
  String get revengeGuessHint;

  /// Text for the submit guess button
  ///
  /// In en, this message translates to:
  /// **'Submit Guess'**
  String get revengeSubmit;

  /// Error message when no word is entered into the guess input field
  ///
  /// In en, this message translates to:
  /// **'Please enter a word'**
  String get revengeEmptyError;

  /// Text for the verbal guess button
  ///
  /// In en, this message translates to:
  /// **'Guess Verbally'**
  String get revengeVerbal;

  /// Text for the give up button
  ///
  /// In en, this message translates to:
  /// **'Give Up'**
  String get revengeGiveUp;

  /// Title for the verbal guess confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Was your verbal guess correct?'**
  String get revengeVerbalTitle;

  /// Content for the verbal guess confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Did the citizens confirm your guess was correct?'**
  String get revengeVerbalContent;

  /// Button text for incorrect verbal guess
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get revengeVerbalNo;

  /// Button text for correct verbal guess
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get revengeVerbalYes;

  /// Text for time remaining label
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get revengeTimeRemaining;

  /// Tooltip text for decrease time button
  ///
  /// In en, this message translates to:
  /// **'Decrease Time'**
  String get revengeDecreaseTime;

  /// Tooltip text for increase time button
  ///
  /// In en, this message translates to:
  /// **'Increase Time'**
  String get revengeIncreaseTime;

  /// Title for the AI customization page
  ///
  /// In en, this message translates to:
  /// **'AI Customization'**
  String get aiCustomizationTitle;

  /// Title for the OpenAI connection page
  ///
  /// In en, this message translates to:
  /// **'OpenAI Connection'**
  String get openaiConnectionTitle;

  /// Text for the enable OpenAI button
  ///
  /// In en, this message translates to:
  /// **'Enable OpenAI'**
  String get enableOpenai;

  /// Subtitle for the enable OpenAI button
  ///
  /// In en, this message translates to:
  /// **'Use OpenAI to generate word pairs'**
  String get enableOpenaiSubtitle;

  /// Title for the OpenAI API key input field
  ///
  /// In en, this message translates to:
  /// **'OpenAI API Key'**
  String get openaiApiKey;

  /// Hint text for the OpenAI API key input field
  ///
  /// In en, this message translates to:
  /// **'Enter your OpenAI API key'**
  String get openaiApiKeyHint;

  /// Error message when no OpenAI API key is entered
  ///
  /// In en, this message translates to:
  /// **'API key is required when OpenAI is enabled'**
  String get openaiApiKeyRequired;

  /// Title for the OpenAI API URL input field
  ///
  /// In en, this message translates to:
  /// **'OpenAI API URL (Optional)'**
  String get openaiApiUrl;

  /// Title for the OpenAI model input field
  ///
  /// In en, this message translates to:
  /// **'OpenAI Model'**
  String get openaiModel;

  /// Informational text for the OpenAI connection page
  ///
  /// In en, this message translates to:
  /// **'Using OpenAI can help generate better customized word pairs and improve the game experience. Your credentials are stored only locally on your device.'**
  String get openaiInformational;

  /// Text for the save settings button
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// Text for the save settings success message
  ///
  /// In en, this message translates to:
  /// **'Configuration saved'**
  String get saveSettingsSuccess;

  /// Text for the unknown error message
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// Text for the OpenAI offline error message
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to OpenAI. Please check your internet connection.'**
  String get openaiOfflineError;

  /// Text for the OpenAI invalid key error message
  ///
  /// In en, this message translates to:
  /// **'The API key appears to be invalid. Please check your API key.'**
  String get openaiInvalidKeyError;

  /// Text for the OpenAI insufficient permissions error message
  ///
  /// In en, this message translates to:
  /// **'Your API key doesn\'t have sufficient permissions. Missing scope: model.request.'**
  String get openaiInsufficientPermissionsError;

  /// Text for the OpenAI invalid model error message
  ///
  /// In en, this message translates to:
  /// **'The selected model does not exist or you do not have access to it.'**
  String get openaiInvalidModelError;

  /// Text for the OpenAI model not supported error message
  ///
  /// In en, this message translates to:
  /// **'The selected model doesn\'t support JSON schema response format. Please choose a different model.'**
  String get openaiModelNotSupportedError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
