// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MMAScoreCard';

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
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsDataSection => 'Data';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsProfileSection => 'Profile';

  @override
  String get settingsSecuritySection => 'Security';

  @override
  String get changeEmail => 'Change email';

  @override
  String get newEmail => 'New email';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get emailUpdateSuccess =>
      'Email update requested. Check both inboxes if confirmation is required.';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordSubtitle => 'Choose a new password for this account';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm new password';

  @override
  String get passwordTooShort => 'Use at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordUpdateSuccess => 'Password updated';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get biometricUnlockTitle => 'Face ID / biometric unlock';

  @override
  String get biometricUnlockSubtitle =>
      'Require biometric authentication when returning to the app';

  @override
  String get biometricUnavailable =>
      'Biometric authentication is unavailable or not enrolled on this device.';

  @override
  String get biometricEnableReason =>
      'Confirm biometric unlock for MMA Scorecard';

  @override
  String get biometricResumeReason => 'Unlock MMA Scorecard';

  @override
  String get biometricLockTitle => 'App locked';

  @override
  String get biometricLockBody => 'Authenticate to continue to MMA Scorecard.';

  @override
  String get biometricUnlockButton => 'Unlock';

  @override
  String get themeMenuTitle => 'Theme';

  @override
  String get languageMenuTitle => 'Language';

  @override
  String get aboutMenuTitle => 'About';

  @override
  String get termsMenuTitle => 'Terms & Conditions';

  @override
  String get privacyMenuTitle => 'Privacy Policy';

  @override
  String get cachedRecordsMenuTitle => 'Cached records';

  @override
  String get cachedRecordsMenuSubtitle =>
      'Event data requests stored on this device';

  @override
  String get cachedRecordsTitle => 'Cached records';

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
  String get chooseThemeTitle => 'Choose theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get chooseLanguageTitle => 'Choose language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get aboutTitle => 'About';

  @override
  String get appTagline => 'UFC event listings and results.';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutFeaturesHeading => 'What you can do';

  @override
  String get aboutBulletEvents => 'Browse upcoming and past UFC events';

  @override
  String get aboutBulletFightCards =>
      'View full fight cards, results, and methods of victory';

  @override
  String get aboutBulletFighters =>
      'Look up fighter profiles, records, and fight history';

  @override
  String get aboutDataHeading => 'About your data';

  @override
  String get aboutDataBody =>
      'An account is optional. Event data is fetched from a third-party source and cached on this device to reduce network use.';

  @override
  String get contactLabel => 'Developer';

  @override
  String get developerName => 'Danny Vaca';

  @override
  String get developerEmail => 'danny270793@icloud.com';

  @override
  String get developerGithub => 'GitHub';

  @override
  String get developerWebsite => 'Website';

  @override
  String get developerYoutube => 'YouTube';

  @override
  String get developerLinkedin => 'LinkedIn';

  @override
  String get termsTitle => 'Terms & Conditions';

  @override
  String get termsTagline => 'Please read before using the app.';

  @override
  String get termsAcceptanceTitle => 'Acceptance of terms';

  @override
  String get termsAcceptanceBody =>
      'MMAScoreCard is provided as-is, for personal, non-commercial use. Continued use of the app constitutes acceptance of these terms; if you disagree with them, please stop using the app.';

  @override
  String get termsAccountTitle => 'Optional account';

  @override
  String get termsAccountBody =>
      'You can use the app without signing in. If you create an account, sign-in is handled by Supabase. Today we do not upload app-generated content such as favorites. Later versions may store that kind of data in Supabase when you are signed in so it can sync across your devices.';

  @override
  String get termsDisclaimerTitle => 'Not affiliated with the UFC';

  @override
  String get termsDisclaimerBody =>
      'This app is not affiliated with, endorsed by, or sponsored by the UFC, or any fighter or promotion mentioned.';

  @override
  String get termsLiabilityTitle => 'No warranty';

  @override
  String get termsLiabilityBody =>
      'Use of the app is at your own risk, and it is offered without warranties of any kind.';

  @override
  String get termsResponsibilitiesTitle => 'Data accuracy';

  @override
  String get termsResponsibilitiesBody =>
      'Event data (dates, matchups, venues) is sourced from a third-party public event listing service that we do not control or operate; we cannot guarantee its accuracy, availability, or completeness, and event details may change or be removed by that source at any time.';

  @override
  String get termsNoticeTitle => 'Changes to these terms';

  @override
  String get termsNoticeBody =>
      'These terms may be updated as the app changes. Continued use of the app after changes means you accept the updated terms.';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyTagline =>
      'Sign-in is optional. Event cache stays on this device.';

  @override
  String get privacyDataTitle => 'Account (optional)';

  @override
  String get privacyDataBody =>
      'You can use MMAScoreCard without an account. If you sign in, authentication is provided by Supabase. Your email and credentials are processed by Supabase; this app does not store your password.';

  @override
  String get privacyInfraTitle => 'What we store today — and later';

  @override
  String get privacyInfraBody =>
      'Public event listings are fetched from a third-party source over HTTPS and cached only on this device so the app does not re-download them every time. Theme and language stay on the device. We do not currently upload app-generated data such as favorites. In the future, if you are signed in, we may store that kind of information in Supabase so it can sync across your devices. You can clear the local event cache by clearing the app\'s storage.';

  @override
  String get privacySharingTitle => 'Third-party requests';

  @override
  String get privacySharingBody =>
      'Because event data is requested directly from that source, your device\'s network request (e.g. IP address) is visible to it per its own privacy practices, which this app does not control.';

  @override
  String get privacyNoticeTitle => 'Changes to this policy';

  @override
  String get privacyNoticeBody =>
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
