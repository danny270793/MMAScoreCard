import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MMAScoreCard'**
  String get appTitle;

  /// No description provided for @eventsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'UFC Events'**
  String get eventsPageTitle;

  /// No description provided for @tabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tabUpcoming;

  /// No description provided for @tabPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get tabPast;

  /// No description provided for @tabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tabSearch;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your account, or keep using the app without one.'**
  String get signInSubtitle;

  /// No description provided for @continueWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get continueWithoutAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unexpectedError;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search events'**
  String get searchHint;

  /// No description provided for @searchEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search by event, fighter, or location.'**
  String get searchEmptyPrompt;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching events.'**
  String get searchNoResults;

  /// No description provided for @upcomingLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load upcoming events.'**
  String get upcomingLoadError;

  /// No description provided for @pastLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load past events.'**
  String get pastLoadError;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events.'**
  String get noUpcomingEvents;

  /// No description provided for @noPastEvents.
  ///
  /// In en, this message translates to:
  /// **'No past events.'**
  String get noPastEvents;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @inDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'In {days}d'**
  String inDaysLabel(int days);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsDataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataSection;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @settingsProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileSection;

  /// No description provided for @settingsSecuritySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecuritySection;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get newEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @emailUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email update requested. Check both inboxes if confirmation is required.'**
  String get emailUpdateSuccess;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for this account'**
  String get changePasswordSubtitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdateSuccess;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @biometricUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Face ID / biometric unlock'**
  String get biometricUnlockTitle;

  /// No description provided for @biometricUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require biometric authentication when returning to the app'**
  String get biometricUnlockSubtitle;

  /// No description provided for @biometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is unavailable or not enrolled on this device.'**
  String get biometricUnavailable;

  /// No description provided for @biometricEnableReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm biometric unlock for MMA Scorecard'**
  String get biometricEnableReason;

  /// No description provided for @biometricResumeReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock MMA Scorecard'**
  String get biometricResumeReason;

  /// No description provided for @biometricLockTitle.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get biometricLockTitle;

  /// No description provided for @biometricLockBody.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to continue to MMA Scorecard.'**
  String get biometricLockBody;

  /// No description provided for @biometricUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get biometricUnlockButton;

  /// No description provided for @themeMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMenuTitle;

  /// No description provided for @languageMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageMenuTitle;

  /// No description provided for @aboutMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutMenuTitle;

  /// No description provided for @termsMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsMenuTitle;

  /// No description provided for @privacyMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyMenuTitle;

  /// No description provided for @cachedRecordsMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Cached records'**
  String get cachedRecordsMenuTitle;

  /// No description provided for @cachedRecordsMenuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Event data requests stored on this device'**
  String get cachedRecordsMenuSubtitle;

  /// No description provided for @cachedRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cached records'**
  String get cachedRecordsTitle;

  /// No description provided for @cachedRecordsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing cached yet.'**
  String get cachedRecordsEmpty;

  /// No description provided for @cachedUpcomingLabel.
  ///
  /// In en, this message translates to:
  /// **'Upcoming events'**
  String get cachedUpcomingLabel;

  /// No description provided for @cachedPastPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Past events - page {page}'**
  String cachedPastPageLabel(int page);

  /// No description provided for @cachedFightCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Fight card'**
  String get cachedFightCardLabel;

  /// No description provided for @cachedFighterProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Fighter profile'**
  String get cachedFighterProfileLabel;

  /// No description provided for @cachedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Cached {date}'**
  String cachedAtLabel(String date);

  /// No description provided for @cachedRefreshedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Refreshed {date}'**
  String cachedRefreshedAtLabel(String date);

  /// No description provided for @cachedReadCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Read {count} times'**
  String cachedReadCountLabel(int count);

  /// No description provided for @chooseThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose theme'**
  String get chooseThemeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @chooseLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguageTitle;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'UFC event listings and results.'**
  String get appTagline;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @aboutFeaturesHeading.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get aboutFeaturesHeading;

  /// No description provided for @aboutBulletEvents.
  ///
  /// In en, this message translates to:
  /// **'Browse upcoming and past UFC events'**
  String get aboutBulletEvents;

  /// No description provided for @aboutBulletFightCards.
  ///
  /// In en, this message translates to:
  /// **'View full fight cards, results, and methods of victory'**
  String get aboutBulletFightCards;

  /// No description provided for @aboutBulletFighters.
  ///
  /// In en, this message translates to:
  /// **'Look up fighter profiles, records, and fight history'**
  String get aboutBulletFighters;

  /// No description provided for @aboutDataHeading.
  ///
  /// In en, this message translates to:
  /// **'About your data'**
  String get aboutDataHeading;

  /// No description provided for @aboutDataBody.
  ///
  /// In en, this message translates to:
  /// **'An account is optional. Event data is fetched from a third-party source and cached on this device to reduce network use.'**
  String get aboutDataBody;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get contactLabel;

  /// No description provided for @developerName.
  ///
  /// In en, this message translates to:
  /// **'Danny Vaca'**
  String get developerName;

  /// No description provided for @developerEmail.
  ///
  /// In en, this message translates to:
  /// **'danny270793@icloud.com'**
  String get developerEmail;

  /// No description provided for @developerGithub.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get developerGithub;

  /// No description provided for @developerWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get developerWebsite;

  /// No description provided for @developerYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get developerYoutube;

  /// No description provided for @developerLinkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get developerLinkedin;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsTitle;

  /// No description provided for @termsTagline.
  ///
  /// In en, this message translates to:
  /// **'Please read before using the app.'**
  String get termsTagline;

  /// No description provided for @termsAcceptanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of terms'**
  String get termsAcceptanceTitle;

  /// No description provided for @termsAcceptanceBody.
  ///
  /// In en, this message translates to:
  /// **'MMAScoreCard is provided as-is, for personal, non-commercial use. Continued use of the app constitutes acceptance of these terms; if you disagree with them, please stop using the app.'**
  String get termsAcceptanceBody;

  /// No description provided for @termsAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional account'**
  String get termsAccountTitle;

  /// No description provided for @termsAccountBody.
  ///
  /// In en, this message translates to:
  /// **'You can use the app without signing in. If you create an account, sign-in is handled by Supabase. Today we do not upload app-generated content such as favorites. Later versions may store that kind of data in Supabase when you are signed in so it can sync across your devices.'**
  String get termsAccountBody;

  /// No description provided for @termsDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Not affiliated with the UFC'**
  String get termsDisclaimerTitle;

  /// No description provided for @termsDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'This app is not affiliated with, endorsed by, or sponsored by the UFC, or any fighter or promotion mentioned.'**
  String get termsDisclaimerBody;

  /// No description provided for @termsLiabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'No warranty'**
  String get termsLiabilityTitle;

  /// No description provided for @termsLiabilityBody.
  ///
  /// In en, this message translates to:
  /// **'Use of the app is at your own risk, and it is offered without warranties of any kind.'**
  String get termsLiabilityBody;

  /// No description provided for @termsResponsibilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Data accuracy'**
  String get termsResponsibilitiesTitle;

  /// No description provided for @termsResponsibilitiesBody.
  ///
  /// In en, this message translates to:
  /// **'Event data (dates, matchups, venues) is sourced from a third-party public event listing service that we do not control or operate; we cannot guarantee its accuracy, availability, or completeness, and event details may change or be removed by that source at any time.'**
  String get termsResponsibilitiesBody;

  /// No description provided for @termsNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes to these terms'**
  String get termsNoticeTitle;

  /// No description provided for @termsNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'These terms may be updated as the app changes. Continued use of the app after changes means you accept the updated terms.'**
  String get termsNoticeBody;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyTagline.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is optional. Event cache stays on this device.'**
  String get privacyTagline;

  /// No description provided for @privacyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Account (optional)'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In en, this message translates to:
  /// **'You can use MMAScoreCard without an account. If you sign in, authentication is provided by Supabase. Your email and credentials are processed by Supabase; this app does not store your password.'**
  String get privacyDataBody;

  /// No description provided for @privacyInfraTitle.
  ///
  /// In en, this message translates to:
  /// **'What we store today — and later'**
  String get privacyInfraTitle;

  /// No description provided for @privacyInfraBody.
  ///
  /// In en, this message translates to:
  /// **'Public event listings are fetched from a third-party source over HTTPS and cached only on this device so the app does not re-download them every time. Theme and language stay on the device. We do not currently upload app-generated data such as favorites. In the future, if you are signed in, we may store that kind of information in Supabase so it can sync across your devices. You can clear the local event cache by clearing the app\'s storage.'**
  String get privacyInfraBody;

  /// No description provided for @privacySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Third-party requests'**
  String get privacySharingTitle;

  /// No description provided for @privacySharingBody.
  ///
  /// In en, this message translates to:
  /// **'Because event data is requested directly from that source, your device\'s network request (e.g. IP address) is visible to it per its own privacy practices, which this app does not control.'**
  String get privacySharingBody;

  /// No description provided for @privacyNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes to this policy'**
  String get privacyNoticeTitle;

  /// No description provided for @privacyNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'This policy may be updated as the app changes. Continued use of the app after changes means you accept the updated policy.'**
  String get privacyNoticeBody;

  /// No description provided for @eventDetailLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get eventDetailLocationLabel;

  /// No description provided for @eventDetailDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get eventDetailDateLabel;

  /// No description provided for @eventDetailFightCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Fight Card'**
  String get eventDetailFightCardLabel;

  /// No description provided for @eventDetailTitleFightLabel.
  ///
  /// In en, this message translates to:
  /// **'Title Fight'**
  String get eventDetailTitleFightLabel;

  /// No description provided for @eventDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the fight card.'**
  String get eventDetailLoadError;

  /// No description provided for @eventDetailEmpty.
  ///
  /// In en, this message translates to:
  /// **'No fight card available yet.'**
  String get eventDetailEmpty;

  /// No description provided for @eventDetailStatisticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get eventDetailStatisticsLabel;

  /// No description provided for @statKoTko.
  ///
  /// In en, this message translates to:
  /// **'KO/TKO'**
  String get statKoTko;

  /// No description provided for @statSubmissions.
  ///
  /// In en, this message translates to:
  /// **'Submissions'**
  String get statSubmissions;

  /// No description provided for @statDecisions.
  ///
  /// In en, this message translates to:
  /// **'Decisions'**
  String get statDecisions;

  /// No description provided for @fightDetailEventInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Event Information'**
  String get fightDetailEventInfoLabel;

  /// No description provided for @fightDetailEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get fightDetailEventLabel;

  /// No description provided for @fightDetailDivisionLabel.
  ///
  /// In en, this message translates to:
  /// **'Division'**
  String get fightDetailDivisionLabel;

  /// No description provided for @fightDetailResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get fightDetailResultLabel;

  /// No description provided for @fightDetailMethodOfVictoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Method of Victory'**
  String get fightDetailMethodOfVictoryLabel;

  /// No description provided for @fightDetailTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get fightDetailTimeLabel;

  /// No description provided for @fightDetailRoundLabel.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get fightDetailRoundLabel;

  /// No description provided for @fightDetailRefereeLabel.
  ///
  /// In en, this message translates to:
  /// **'Referee'**
  String get fightDetailRefereeLabel;

  /// No description provided for @fightDetailFightersLabel.
  ///
  /// In en, this message translates to:
  /// **'Fighters'**
  String get fightDetailFightersLabel;

  /// No description provided for @fightDetailNotYetContested.
  ///
  /// In en, this message translates to:
  /// **'This fight hasn\'t happened yet.'**
  String get fightDetailNotYetContested;

  /// No description provided for @fightOutcomeWin.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get fightOutcomeWin;

  /// No description provided for @fightOutcomeLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get fightOutcomeLoss;

  /// No description provided for @fightOutcomeDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get fightOutcomeDraw;

  /// No description provided for @fightOutcomeNoContest.
  ///
  /// In en, this message translates to:
  /// **'NC'**
  String get fightOutcomeNoContest;

  /// No description provided for @fighterDetailAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get fighterDetailAgeLabel;

  /// No description provided for @fighterDetailHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get fighterDetailHeightLabel;

  /// No description provided for @fighterDetailWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get fighterDetailWeightLabel;

  /// No description provided for @fighterDetailAssociationLabel.
  ///
  /// In en, this message translates to:
  /// **'Association'**
  String get fighterDetailAssociationLabel;

  /// No description provided for @fighterDetailClassLabel.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get fighterDetailClassLabel;

  /// No description provided for @fighterDetailNationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get fighterDetailNationalityLabel;

  /// No description provided for @fighterDetailHometownLabel.
  ///
  /// In en, this message translates to:
  /// **'Hometown'**
  String get fighterDetailHometownLabel;

  /// No description provided for @fighterDetailRecordLabel.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get fighterDetailRecordLabel;

  /// No description provided for @fighterDetailWinsLabel.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get fighterDetailWinsLabel;

  /// No description provided for @fighterDetailLossesLabel.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get fighterDetailLossesLabel;

  /// No description provided for @fighterDetailFightHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Fight History'**
  String get fighterDetailFightHistoryLabel;

  /// No description provided for @fighterDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this fighter\'s profile.'**
  String get fighterDetailLoadError;

  /// No description provided for @fighterDetailEmpty.
  ///
  /// In en, this message translates to:
  /// **'No fight history available yet.'**
  String get fighterDetailEmpty;

  /// No description provided for @fighterDetailAmateurLabel.
  ///
  /// In en, this message translates to:
  /// **'Amateur'**
  String get fighterDetailAmateurLabel;

  /// No description provided for @fighterDetailStreaksLabel.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get fighterDetailStreaksLabel;

  /// No description provided for @fighterDetailCurrentStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get fighterDetailCurrentStreakLabel;

  /// No description provided for @fighterDetailBestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get fighterDetailBestStreakLabel;

  /// No description provided for @fighterDetailWorstStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Worst'**
  String get fighterDetailWorstStreakLabel;

  /// No description provided for @fighterDetailOctagonTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time in octagon'**
  String get fighterDetailOctagonTimeLabel;

  /// No description provided for @streakWins.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 win} other{{count} wins}}'**
  String streakWins(int count);

  /// No description provided for @streakLosses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 loss} other{{count} losses}}'**
  String streakLosses(int count);

  /// No description provided for @streakDraws.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 draw} other{{count} draws}}'**
  String streakDraws(int count);

  /// No description provided for @streakNoContests.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 no contest} other{{count} no contests}}'**
  String streakNoContests(int count);

  /// No description provided for @streakNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get streakNone;

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String durationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @fightDetailOctagonTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Octagon time'**
  String get fightDetailOctagonTimeLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
