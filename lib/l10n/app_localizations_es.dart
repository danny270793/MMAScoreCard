// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MMA ScoreCard';

  @override
  String get eventsPageTitle => 'Eventos de UFC';

  @override
  String get tabUpcoming => 'Próximos';

  @override
  String get tabPast => 'Pasados';

  @override
  String get tabSearch => 'Buscar';

  @override
  String get searchHint => 'Buscar eventos';

  @override
  String get searchEmptyPrompt => 'Busca por evento, luchador o lugar.';

  @override
  String get searchNoResults => 'No hay eventos que coincidan.';

  @override
  String get upcomingLoadError => 'No se pudieron cargar los próximos eventos.';

  @override
  String get pastLoadError => 'No se pudieron cargar los eventos pasados.';

  @override
  String get retryButton => 'Reintentar';

  @override
  String get noUpcomingEvents => 'No hay próximos eventos.';

  @override
  String get noPastEvents => 'No hay eventos pasados.';

  @override
  String get todayLabel => 'Hoy';

  @override
  String inDaysLabel(int days) {
    return 'En ${days}d';
  }

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsDataSection => 'Datos';

  @override
  String get settingsAboutSection => 'Acerca de';

  @override
  String get settingsSecuritySection => 'Seguridad';

  @override
  String get settingsBiometricUnlockTitle =>
      'Desbloqueo con Face ID / biometría';

  @override
  String get settingsBiometricUnlockSubtitle =>
      'Requerir autenticación biométrica al volver a la app';

  @override
  String get settingsBiometricUnavailable =>
      'La autenticación biométrica no está disponible o configurada en este dispositivo.';

  @override
  String get settingsBiometricAuthReason =>
      'Confirma el desbloqueo biométrico para MMA ScoreCard';

  @override
  String get settingsBiometricResumeReason => 'Desbloquea MMA ScoreCard';

  @override
  String get biometricLockTitle => 'App bloqueada';

  @override
  String get biometricLockBody => 'Autentícate para continuar a MMA ScoreCard.';

  @override
  String get biometricLockUnlockButton => 'Desbloquear';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsAboutApp => 'Acerca de';

  @override
  String get settingsRateApp => 'Calificar en Google Play';

  @override
  String get settingsTermsOfUse => 'Términos y condiciones';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsOfflineCache => 'Registros en caché';

  @override
  String get settingsOfflineCacheSubtitle =>
      'Solicitudes de datos de eventos guardadas en este dispositivo';

  @override
  String get cachedRecordsEmpty => 'Todavía no hay nada en caché.';

  @override
  String get cachedUpcomingLabel => 'Próximos eventos';

  @override
  String cachedPastPageLabel(int page) {
    return 'Eventos pasados - página $page';
  }

  @override
  String get cachedFightCardLabel => 'Cartelera de peleas';

  @override
  String get cachedFighterProfileLabel => 'Perfil del peleador';

  @override
  String cachedAtLabel(String date) {
    return 'Guardado en caché $date';
  }

  @override
  String cachedRefreshedAtLabel(String date) {
    return 'Actualizado $date';
  }

  @override
  String cachedReadCountLabel(int count) {
    return 'Leído $count veces';
  }

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsAboutTagline => 'Eventos de UFC y resultados.';

  @override
  String get settingsAboutVersionLabel => 'Versión';

  @override
  String get settingsAboutFeaturesHeading => 'Qué puedes hacer';

  @override
  String get settingsAboutBulletEvents =>
      'Explorar eventos de UFC próximos y pasados';

  @override
  String get settingsAboutBulletFightCards =>
      'Ver carteleras completas, resultados y métodos de victoria';

  @override
  String get settingsAboutBulletFighters =>
      'Consultar perfiles, récords e historial de combates de los peleadores';

  @override
  String get settingsAboutDataHeading => 'Sobre tus datos';

  @override
  String get settingsAboutDataBody =>
      'No necesitas una cuenta. Los datos de los eventos se obtienen de una fuente externa y se guardan en caché en este dispositivo para reducir el uso de red.';

  @override
  String get settingsAboutDeveloperHeading => 'Desarrollador';

  @override
  String get settingsAboutDeveloperGithub => 'GitHub';

  @override
  String get settingsAboutDeveloperWebsite => 'Sitio web';

  @override
  String get settingsAboutDeveloperYoutube => 'YouTube';

  @override
  String get settingsAboutDeveloperLinkedin => 'LinkedIn';

  @override
  String get settingsTermsTagline => 'Léelos antes de usar la app.';

  @override
  String get settingsTermsAcceptanceTitle => 'Aceptación de los términos';

  @override
  String get settingsTermsAcceptanceBody =>
      'MMA ScoreCard se ofrece tal cual, para uso personal y no comercial. El uso continuado de la app implica la aceptación de estos términos; si no estás de acuerdo, deja de usar la app.';

  @override
  String get settingsTermsNoAccountTitle => 'Sin cuenta';

  @override
  String get settingsTermsNoAccountBody =>
      'MMA ScoreCard no tiene cuentas ni inicio de sesión. Tus preferencias y la caché de eventos se guardan solo en este dispositivo, y no subimos ningún contenido generado por la app.';

  @override
  String get settingsTermsDisclaimerTitle => 'Sin afiliación con la UFC';

  @override
  String get settingsTermsDisclaimerBody =>
      'Esta app no está afiliada, respaldada ni patrocinada por la UFC, ni ningún luchador o promotora mencionados.';

  @override
  String get settingsTermsLiabilityTitle => 'Sin garantía';

  @override
  String get settingsTermsLiabilityBody =>
      'El uso de la app es bajo tu propio riesgo y se ofrece sin garantías de ningún tipo.';

  @override
  String get settingsTermsResponsibilitiesTitle => 'Exactitud de los datos';

  @override
  String get settingsTermsResponsibilitiesBody =>
      'Los datos de los eventos (fechas, combates, sedes) provienen de un servicio externo de listados de eventos que no controlamos ni operamos; no podemos garantizar su exactitud, disponibilidad ni integridad, y los detalles pueden cambiar o eliminarse en cualquier momento.';

  @override
  String get settingsTermsNoticeTitle => 'Cambios en estos términos';

  @override
  String get settingsTermsNoticeBody =>
      'Estos términos pueden actualizarse a medida que la app cambie. El uso continuado de la app después de esos cambios implica la aceptación de los términos actualizados.';

  @override
  String get settingsPrivacyTagline =>
      'Sin cuenta ni inicio de sesión. Todo se queda en este dispositivo.';

  @override
  String get settingsPrivacyDataTitle => 'Sin cuenta';

  @override
  String get settingsPrivacyDataBody =>
      'Usas MMA ScoreCard sin cuenta. La app no te pide nombre, correo ni contraseña, y no envía datos personales a ningún servidor que operemos.';

  @override
  String get settingsPrivacyInfraTitle => 'Qué guardamos';

  @override
  String get settingsPrivacyInfraBody =>
      'Los listados públicos de eventos se obtienen de una fuente externa por HTTPS y se guardan en caché solo en este dispositivo para no volver a descargarlos cada vez. El tema, el idioma y el ajuste de desbloqueo biométrico se quedan en el dispositivo. Puedes borrar la caché local de eventos al borrar el almacenamiento de la app.';

  @override
  String get settingsPrivacySharingTitle => 'Solicitudes a terceros';

  @override
  String get settingsPrivacySharingBody =>
      'Como los datos se solicitan directamente a esa fuente, tu solicitud de red (por ejemplo, tu dirección IP) es visible para ella según sus propias prácticas de privacidad, que esta app no controla.';

  @override
  String get settingsPrivacyNoticeTitle => 'Cambios en esta política';

  @override
  String get settingsPrivacyNoticeBody =>
      'Esta política puede actualizarse a medida que la app cambie. El uso continuado de la app después de esos cambios implica la aceptación de la política actualizada.';

  @override
  String get eventDetailLocationLabel => 'Ubicación';

  @override
  String get eventDetailDateLabel => 'Fecha';

  @override
  String get eventDetailFightCardLabel => 'Cartelera';

  @override
  String get eventDetailTitleFightLabel => 'Combate por el título';

  @override
  String get eventDetailLoadError => 'No se pudo cargar la cartelera.';

  @override
  String get eventDetailEmpty => 'Todavía no hay cartelera disponible.';

  @override
  String get eventDetailStatisticsLabel => 'Estadísticas';

  @override
  String get statKoTko => 'KO/TKO';

  @override
  String get statSubmissions => 'Sumisiones';

  @override
  String get statDecisions => 'Decisiones';

  @override
  String get fightDetailEventInfoLabel => 'Información del evento';

  @override
  String get fightDetailEventLabel => 'Evento';

  @override
  String get fightDetailDivisionLabel => 'División';

  @override
  String get fightDetailResultLabel => 'Resultado';

  @override
  String get fightDetailMethodOfVictoryLabel => 'Método de victoria';

  @override
  String get fightDetailTimeLabel => 'Tiempo';

  @override
  String get fightDetailRoundLabel => 'Ronda';

  @override
  String get fightDetailRefereeLabel => 'Árbitro';

  @override
  String get fightDetailFightersLabel => 'Peleadores';

  @override
  String get fightDetailNotYetContested =>
      'Este combate todavía no se ha disputado.';

  @override
  String get fightOutcomeWin => 'Gana';

  @override
  String get fightOutcomeLoss => 'Pierde';

  @override
  String get fightOutcomeDraw => 'Empate';

  @override
  String get fightOutcomeNoContest => 'SD';

  @override
  String get fighterDetailAgeLabel => 'Edad';

  @override
  String get fighterDetailHeightLabel => 'Estatura';

  @override
  String get fighterDetailWeightLabel => 'Peso';

  @override
  String get fighterDetailAssociationLabel => 'Asociación';

  @override
  String get fighterDetailClassLabel => 'Categoría';

  @override
  String get fighterDetailNationalityLabel => 'Nacionalidad';

  @override
  String get fighterDetailHometownLabel => 'Ciudad de origen';

  @override
  String get fighterDetailRecordLabel => 'Récord';

  @override
  String get fighterDetailWinsLabel => 'Victorias';

  @override
  String get fighterDetailLossesLabel => 'Derrotas';

  @override
  String get fighterDetailFightHistoryLabel => 'Historial de combates';

  @override
  String get fighterDetailLoadError =>
      'No se pudo cargar el perfil del peleador.';

  @override
  String get fighterDetailEmpty => 'Todavía no hay historial de combates.';

  @override
  String get fighterDetailAmateurLabel => 'Amateur';

  @override
  String get fighterDetailStreaksLabel => 'Rachas';

  @override
  String get fighterDetailCurrentStreakLabel => 'Actual';

  @override
  String get fighterDetailBestStreakLabel => 'Mejor';

  @override
  String get fighterDetailWorstStreakLabel => 'Peor';

  @override
  String get fighterDetailOctagonTimeLabel => 'Tiempo en el octágono';

  @override
  String streakWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count victorias',
      one: '1 victoria',
    );
    return '$_temp0';
  }

  @override
  String streakLosses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count derrotas',
      one: '1 derrota',
    );
    return '$_temp0';
  }

  @override
  String streakDraws(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count empates',
      one: '1 empate',
    );
    return '$_temp0';
  }

  @override
  String streakNoContests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sin decisión',
      one: '1 sin decisión',
    );
    return '$_temp0';
  }

  @override
  String get streakNone => 'Ninguna';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String get fightDetailOctagonTimeLabel => 'Tiempo en el octágono';
}
