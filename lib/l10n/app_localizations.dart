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
/// import 'l10n/app_localizations.dart';
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
  /// **'MMA ScoreCard'**
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

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

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

  /// No description provided for @settingsChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get settingsChangeEmail;

  /// No description provided for @settingsChangeEmailDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get settingsChangeEmailDialogTitle;

  /// No description provided for @settingsNewEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get settingsNewEmailLabel;

  /// No description provided for @settingsChangeEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get settingsChangeEmailInvalid;

  /// No description provided for @settingsChangeEmailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email update requested. Check both inboxes if confirmation is required.'**
  String get settingsChangeEmailSuccess;

  /// No description provided for @settingsChangeEmailSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get settingsChangeEmailSubmit;

  /// No description provided for @settingsChangeEmailSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'That is already your email.'**
  String get settingsChangeEmailSameAsCurrent;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePassword;

  /// No description provided for @settingsChangePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for this account'**
  String get settingsChangePasswordSubtitle;

  /// No description provided for @settingsChangePasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePasswordDialogTitle;

  /// No description provided for @settingsNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get settingsNewPasswordLabel;

  /// No description provided for @settingsConfirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get settingsConfirmNewPasswordLabel;

  /// No description provided for @settingsPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters'**
  String get settingsPasswordTooShort;

  /// No description provided for @settingsPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get settingsPasswordsDoNotMatch;

  /// No description provided for @settingsChangePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get settingsChangePasswordSuccess;

  /// No description provided for @settingsChangePasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get settingsChangePasswordSubmit;

  /// No description provided for @settingsBiometricUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Face ID / biometric unlock'**
  String get settingsBiometricUnlockTitle;

  /// No description provided for @settingsBiometricUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require biometric authentication when returning to the app'**
  String get settingsBiometricUnlockSubtitle;

  /// No description provided for @settingsBiometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is unavailable or not enrolled on this device.'**
  String get settingsBiometricUnavailable;

  /// No description provided for @settingsBiometricAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm biometric unlock for MMA ScoreCard'**
  String get settingsBiometricAuthReason;

  /// No description provided for @settingsBiometricResumeReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock MMA ScoreCard'**
  String get settingsBiometricResumeReason;

  /// No description provided for @biometricLockTitle.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get biometricLockTitle;

  /// No description provided for @biometricLockBody.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to continue to MMA ScoreCard.'**
  String get biometricLockBody;

  /// No description provided for @biometricLockUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get biometricLockUnlockButton;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutApp;

  /// No description provided for @settingsRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate on Google Play'**
  String get settingsRateApp;

  /// No description provided for @settingsTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get settingsTermsOfUse;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsOfflineCache.
  ///
  /// In en, this message translates to:
  /// **'Cached records'**
  String get settingsOfflineCache;

  /// No description provided for @settingsOfflineCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Event data requests stored on this device'**
  String get settingsOfflineCacheSubtitle;

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

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsAboutTagline.
  ///
  /// In en, this message translates to:
  /// **'UFC event listings and results.'**
  String get settingsAboutTagline;

  /// No description provided for @settingsAboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsAboutVersionLabel;

  /// No description provided for @settingsAboutFeaturesHeading.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get settingsAboutFeaturesHeading;

  /// No description provided for @settingsAboutBulletEvents.
  ///
  /// In en, this message translates to:
  /// **'Browse upcoming and past UFC events'**
  String get settingsAboutBulletEvents;

  /// No description provided for @settingsAboutBulletFightCards.
  ///
  /// In en, this message translates to:
  /// **'View full fight cards, results, and methods of victory'**
  String get settingsAboutBulletFightCards;

  /// No description provided for @settingsAboutBulletFighters.
  ///
  /// In en, this message translates to:
  /// **'Look up fighter profiles, records, and fight history'**
  String get settingsAboutBulletFighters;

  /// No description provided for @settingsAboutDataHeading.
  ///
  /// In en, this message translates to:
  /// **'About your data'**
  String get settingsAboutDataHeading;

  /// No description provided for @settingsAboutDataBody.
  ///
  /// In en, this message translates to:
  /// **'An account is optional. Event data is fetched from a third-party source and cached on this device to reduce network use.'**
  String get settingsAboutDataBody;

  /// No description provided for @settingsAboutDeveloperHeading.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsAboutDeveloperHeading;

  /// No description provided for @settingsAboutDeveloperGithub.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get settingsAboutDeveloperGithub;

  /// No description provided for @settingsAboutDeveloperWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get settingsAboutDeveloperWebsite;

  /// No description provided for @settingsAboutDeveloperYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get settingsAboutDeveloperYoutube;

  /// No description provided for @settingsAboutDeveloperLinkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get settingsAboutDeveloperLinkedin;

  /// No description provided for @settingsTermsTagline.
  ///
  /// In en, this message translates to:
  /// **'Please read before using the app.'**
  String get settingsTermsTagline;

  /// No description provided for @settingsTermsAcceptanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of terms'**
  String get settingsTermsAcceptanceTitle;

  /// No description provided for @settingsTermsAcceptanceBody.
  ///
  /// In en, this message translates to:
  /// **'MMA ScoreCard is provided as-is, for personal, non-commercial use. Continued use of the app constitutes acceptance of these terms; if you disagree with them, please stop using the app.'**
  String get settingsTermsAcceptanceBody;

  /// No description provided for @settingsTermsAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional account'**
  String get settingsTermsAccountTitle;

  /// No description provided for @settingsTermsAccountBody.
  ///
  /// In en, this message translates to:
  /// **'You can use the app without signing in. If you create an account, sign-in is handled by Supabase. Today we do not upload app-generated content such as favorites. Later versions may store that kind of data in Supabase when you are signed in so it can sync across your devices.'**
  String get settingsTermsAccountBody;

  /// No description provided for @settingsTermsDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Not affiliated with the UFC'**
  String get settingsTermsDisclaimerTitle;

  /// No description provided for @settingsTermsDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'This app is not affiliated with, endorsed by, or sponsored by the UFC, or any fighter or promotion mentioned.'**
  String get settingsTermsDisclaimerBody;

  /// No description provided for @settingsTermsLiabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'No warranty'**
  String get settingsTermsLiabilityTitle;

  /// No description provided for @settingsTermsLiabilityBody.
  ///
  /// In en, this message translates to:
  /// **'Use of the app is at your own risk, and it is offered without warranties of any kind.'**
  String get settingsTermsLiabilityBody;

  /// No description provided for @settingsTermsResponsibilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Data accuracy'**
  String get settingsTermsResponsibilitiesTitle;

  /// No description provided for @settingsTermsResponsibilitiesBody.
  ///
  /// In en, this message translates to:
  /// **'Event data (dates, matchups, venues) is sourced from a third-party public event listing service that we do not control or operate; we cannot guarantee its accuracy, availability, or completeness, and event details may change or be removed by that source at any time.'**
  String get settingsTermsResponsibilitiesBody;

  /// No description provided for @settingsTermsNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes to these terms'**
  String get settingsTermsNoticeTitle;

  /// No description provided for @settingsTermsNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'These terms may be updated as the app changes. Continued use of the app after changes means you accept the updated terms.'**
  String get settingsTermsNoticeBody;

  /// No description provided for @settingsPrivacyTagline.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is optional. Event cache stays on this device.'**
  String get settingsPrivacyTagline;

  /// No description provided for @settingsPrivacyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Account (optional)'**
  String get settingsPrivacyDataTitle;

  /// No description provided for @settingsPrivacyDataBody.
  ///
  /// In en, this message translates to:
  /// **'You can use MMA ScoreCard without an account. If you sign in, authentication is provided by Supabase. Your email and credentials are processed by Supabase; this app does not store your password.'**
  String get settingsPrivacyDataBody;

  /// No description provided for @settingsPrivacyInfraTitle.
  ///
  /// In en, this message translates to:
  /// **'What we store today — and later'**
  String get settingsPrivacyInfraTitle;

  /// No description provided for @settingsPrivacyInfraBody.
  ///
  /// In en, this message translates to:
  /// **'Public event listings are fetched from a third-party source over HTTPS and cached only on this device so the app does not re-download them every time. Theme and language stay on the device. We do not currently upload app-generated data such as favorites. In the future, if you are signed in, we may store that kind of information in Supabase so it can sync across your devices. You can clear the local event cache by clearing the app\'s storage.'**
  String get settingsPrivacyInfraBody;

  /// No description provided for @settingsPrivacySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Third-party requests'**
  String get settingsPrivacySharingTitle;

  /// No description provided for @settingsPrivacySharingBody.
  ///
  /// In en, this message translates to:
  /// **'Because event data is requested directly from that source, your device\'s network request (e.g. IP address) is visible to it per its own privacy practices, which this app does not control.'**
  String get settingsPrivacySharingBody;

  /// No description provided for @settingsPrivacyNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes to this policy'**
  String get settingsPrivacyNoticeTitle;

  /// No description provided for @settingsPrivacyNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'This policy may be updated as the app changes. Continued use of the app after changes means you accept the updated policy.'**
  String get settingsPrivacyNoticeBody;

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
