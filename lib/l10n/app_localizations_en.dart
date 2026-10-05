// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MMA ScoreCard';

  @override
  String get eventsPageTitle => 'UFC Events';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get tabPast => 'Past';

  @override
  String get tabSearch => 'Search';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInSubtitle =>
      'Sign in to manage your account, or keep using the app without one.';

  @override
  String get continueWithoutAccount => 'Continue without account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fieldRequired => 'Required';

  @override
  String get unexpectedError => 'Something went wrong. Please try again.';

  @override
  String get signOut => 'Sign out';

  @override
  String get searchHint => 'Search events';

  @override
  String get searchEmptyPrompt => 'Search by event, fighter, or location.';

  @override
  String get searchNoResults => 'No matching events.';

  @override
  String get upcomingLoadError => 'Could not load upcoming events.';

  @override
  String get pastLoadError => 'Could not load past events.';

  @override
  String get retryButton => 'Retry';

  @override
  String get noUpcomingEvents => 'No upcoming events.';

  @override
  String get noPastEvents => 'No past events.';

  @override
  String get todayLabel => 'Today';

  @override
  String inDaysLabel(int days) {
    return 'In ${days}d';
  }

  @override
  String get settings => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDataSection => 'Data';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsProfileSection => 'Profile';

  @override
  String get settingsSecuritySection => 'Security';

  @override
  String get settingsChangeEmail => 'Change email';

  @override
  String get settingsChangeEmailDialogTitle => 'Change email';

  @override
  String get settingsNewEmailLabel => 'New email';

  @override
  String get settingsChangeEmailInvalid => 'Enter a valid email address';

  @override
  String get settingsChangeEmailSuccess =>
      'Email update requested. Check both inboxes if confirmation is required.';

  @override
  String get settingsChangeEmailSubmit => 'Update';

  @override
  String get settingsChangeEmailSameAsCurrent => 'That is already your email.';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsChangePasswordSubtitle =>
      'Choose a new password for this account';

  @override
  String get settingsChangePasswordDialogTitle => 'Change password';

  @override
  String get settingsNewPasswordLabel => 'New password';

  @override
  String get settingsConfirmNewPasswordLabel => 'Confirm new password';

  @override
  String get settingsPasswordTooShort => 'Use at least 6 characters';

  @override
  String get settingsPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get settingsChangePasswordSuccess => 'Password updated';

  @override
  String get settingsChangePasswordSubmit => 'Update password';

  @override
  String get settingsBiometricUnlockTitle => 'Face ID / biometric unlock';

  @override
  String get settingsBiometricUnlockSubtitle =>
      'Require biometric authentication when returning to the app';

  @override
  String get settingsBiometricUnavailable =>
      'Biometric authentication is unavailable or not enrolled on this device.';

  @override
  String get settingsBiometricAuthReason =>
      'Confirm biometric unlock for MMA ScoreCard';

  @override
  String get settingsBiometricResumeReason => 'Unlock MMA ScoreCard';

  @override
  String get biometricLockTitle => 'App locked';

  @override
  String get biometricLockBody => 'Authenticate to continue to MMA ScoreCard.';

  @override
  String get biometricLockUnlockButton => 'Unlock';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAboutApp => 'About';

  @override
  String get settingsRateApp => 'Rate on Google Play';

  @override
  String get settingsTermsOfUse => 'Terms & Conditions';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsOfflineCache => 'Cached records';

  @override
  String get settingsOfflineCacheSubtitle =>
      'Event data requests stored on this device';

  @override
  String get cachedRecordsEmpty => 'Nothing cached yet.';

  @override
  String get cachedUpcomingLabel => 'Upcoming events';

  @override
  String cachedPastPageLabel(int page) {
    return 'Past events - page $page';
  }

  @override
  String get cachedFightCardLabel => 'Fight card';

  @override
  String get cachedFighterProfileLabel => 'Fighter profile';

  @override
  String cachedAtLabel(String date) {
    return 'Cached $date';
  }

  @override
  String cachedRefreshedAtLabel(String date) {
    return 'Refreshed $date';
  }

  @override
  String cachedReadCountLabel(int count) {
    return 'Read $count times';
  }

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsAboutTagline => 'UFC event listings and results.';

  @override
  String get settingsAboutVersionLabel => 'Version';

  @override
  String get settingsAboutFeaturesHeading => 'What you can do';

  @override
  String get settingsAboutBulletEvents => 'Browse upcoming and past UFC events';

  @override
  String get settingsAboutBulletFightCards =>
      'View full fight cards, results, and methods of victory';

  @override
  String get settingsAboutBulletFighters =>
      'Look up fighter profiles, records, and fight history';

  @override
  String get settingsAboutDataHeading => 'About your data';

  @override
  String get settingsAboutDataBody =>
      'An account is optional. Event data is fetched from a third-party source and cached on this device to reduce network use.';

  @override
  String get settingsAboutDeveloperHeading => 'Developer';

  @override
  String get settingsAboutDeveloperGithub => 'GitHub';

  @override
  String get settingsAboutDeveloperWebsite => 'Website';

  @override
  String get settingsAboutDeveloperYoutube => 'YouTube';

  @override
  String get settingsAboutDeveloperLinkedin => 'LinkedIn';

  @override
  String get settingsTermsTagline => 'Please read before using the app.';

  @override
  String get settingsTermsAcceptanceTitle => 'Acceptance of terms';

  @override
  String get settingsTermsAcceptanceBody =>
      'MMA ScoreCard is provided as-is, for personal, non-commercial use. Continued use of the app constitutes acceptance of these terms; if you disagree with them, please stop using the app.';

  @override
  String get settingsTermsAccountTitle => 'Optional account';

  @override
  String get settingsTermsAccountBody =>
      'You can use the app without signing in. If you create an account, sign-in is handled by Supabase. Today we do not upload app-generated content such as favorites. Later versions may store that kind of data in Supabase when you are signed in so it can sync across your devices.';

  @override
  String get settingsTermsDisclaimerTitle => 'Not affiliated with the UFC';

  @override
  String get settingsTermsDisclaimerBody =>
      'This app is not affiliated with, endorsed by, or sponsored by the UFC, or any fighter or promotion mentioned.';

  @override
  String get settingsTermsLiabilityTitle => 'No warranty';

  @override
  String get settingsTermsLiabilityBody =>
      'Use of the app is at your own risk, and it is offered without warranties of any kind.';

  @override
  String get settingsTermsResponsibilitiesTitle => 'Data accuracy';

  @override
  String get settingsTermsResponsibilitiesBody =>
      'Event data (dates, matchups, venues) is sourced from a third-party public event listing service that we do not control or operate; we cannot guarantee its accuracy, availability, or completeness, and event details may change or be removed by that source at any time.';

  @override
  String get settingsTermsNoticeTitle => 'Changes to these terms';

  @override
  String get settingsTermsNoticeBody =>
      'These terms may be updated as the app changes. Continued use of the app after changes means you accept the updated terms.';

  @override
  String get settingsPrivacyTagline =>
      'Sign-in is optional. Event cache stays on this device.';

  @override
  String get settingsPrivacyDataTitle => 'Account (optional)';

  @override
  String get settingsPrivacyDataBody =>
      'You can use MMA ScoreCard without an account. If you sign in, authentication is provided by Supabase. Your email and credentials are processed by Supabase; this app does not store your password.';

  @override
  String get settingsPrivacyInfraTitle => 'What we store today — and later';

  @override
  String get settingsPrivacyInfraBody =>
      'Public event listings are fetched from a third-party source over HTTPS and cached only on this device so the app does not re-download them every time. Theme and language stay on the device. We do not currently upload app-generated data such as favorites. In the future, if you are signed in, we may store that kind of information in Supabase so it can sync across your devices. You can clear the local event cache by clearing the app\'s storage.';

  @override
  String get settingsPrivacySharingTitle => 'Third-party requests';

  @override
  String get settingsPrivacySharingBody =>
      'Because event data is requested directly from that source, your device\'s network request (e.g. IP address) is visible to it per its own privacy practices, which this app does not control.';

  @override
  String get settingsPrivacyNoticeTitle => 'Changes to this policy';

  @override
  String get settingsPrivacyNoticeBody =>
      'This policy may be updated as the app changes. Continued use of the app after changes means you accept the updated policy.';

  @override
  String get eventDetailLocationLabel => 'Location';

  @override
  String get eventDetailDateLabel => 'Date';

  @override
  String get eventDetailFightCardLabel => 'Fight Card';

  @override
  String get eventDetailTitleFightLabel => 'Title Fight';

  @override
  String get eventDetailLoadError => 'Could not load the fight card.';

  @override
  String get eventDetailEmpty => 'No fight card available yet.';

  @override
  String get eventDetailStatisticsLabel => 'Statistics';

  @override
  String get statKoTko => 'KO/TKO';

  @override
  String get statSubmissions => 'Submissions';

  @override
  String get statDecisions => 'Decisions';

  @override
  String get fightDetailEventInfoLabel => 'Event Information';

  @override
  String get fightDetailEventLabel => 'Event';

  @override
  String get fightDetailDivisionLabel => 'Division';

  @override
  String get fightDetailResultLabel => 'Result';

  @override
  String get fightDetailMethodOfVictoryLabel => 'Method of Victory';

  @override
  String get fightDetailTimeLabel => 'Time';

  @override
  String get fightDetailRoundLabel => 'Round';

  @override
  String get fightDetailRefereeLabel => 'Referee';

  @override
  String get fightDetailFightersLabel => 'Fighters';

  @override
  String get fightDetailNotYetContested => 'This fight hasn\'t happened yet.';

  @override
  String get fightOutcomeWin => 'Win';

  @override
  String get fightOutcomeLoss => 'Loss';

  @override
  String get fightOutcomeDraw => 'Draw';

  @override
  String get fightOutcomeNoContest => 'NC';

  @override
  String get fighterDetailAgeLabel => 'Age';

  @override
  String get fighterDetailHeightLabel => 'Height';

  @override
  String get fighterDetailWeightLabel => 'Weight';

  @override
  String get fighterDetailAssociationLabel => 'Association';

  @override
  String get fighterDetailClassLabel => 'Class';

  @override
  String get fighterDetailNationalityLabel => 'Nationality';

  @override
  String get fighterDetailHometownLabel => 'Hometown';

  @override
  String get fighterDetailRecordLabel => 'Record';

  @override
  String get fighterDetailWinsLabel => 'Wins';

  @override
  String get fighterDetailLossesLabel => 'Losses';

  @override
  String get fighterDetailFightHistoryLabel => 'Fight History';

  @override
  String get fighterDetailLoadError =>
      'Could not load this fighter\'s profile.';

  @override
  String get fighterDetailEmpty => 'No fight history available yet.';

  @override
  String get fighterDetailAmateurLabel => 'Amateur';

  @override
  String get fighterDetailStreaksLabel => 'Streaks';

  @override
  String get fighterDetailCurrentStreakLabel => 'Current';

  @override
  String get fighterDetailBestStreakLabel => 'Best';

  @override
  String get fighterDetailWorstStreakLabel => 'Worst';

  @override
  String get fighterDetailOctagonTimeLabel => 'Time in octagon';

  @override
  String streakWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wins',
      one: '1 win',
    );
    return '$_temp0';
  }

  @override
  String streakLosses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count losses',
      one: '1 loss',
    );
    return '$_temp0';
  }

  @override
  String streakDraws(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count draws',
      one: '1 draw',
    );
    return '$_temp0';
  }

  @override
  String streakNoContests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count no contests',
      one: '1 no contest',
    );
    return '$_temp0';
  }

  @override
  String get streakNone => 'None';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String get fightDetailOctagonTimeLabel => 'Octagon time';
}
