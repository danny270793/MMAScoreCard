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
  String get settingsSecuritySection => 'Security';

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
      'No account is needed. Event data is fetched from a third-party source and cached on this device to reduce network use.';

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
  String get settingsTermsNoAccountTitle => 'No account needed';

  @override
  String get settingsTermsNoAccountBody =>
      'MMA ScoreCard does not have accounts or sign-in. Your preferences and the event cache are stored only on this device, and we do not upload any app-generated content.';

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
      'No account, no sign-in. Everything stays on this device.';

  @override
  String get settingsPrivacyDataTitle => 'No account';

  @override
  String get settingsPrivacyDataBody =>
      'You use MMA ScoreCard without an account. The app does not ask for your name, email or password, and does not send personal data to any server we operate.';

  @override
  String get settingsPrivacyInfraTitle => 'What we store';

  @override
  String get settingsPrivacyInfraBody =>
      'Public event listings are fetched from a third-party source over HTTPS and cached only on this device so the app does not re-download them every time. Theme, language and the biometric unlock setting stay on the device. You can clear the local event cache by clearing the app\'s storage.';

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
