// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MMAScoreCard';

  @override
  String get eventsPageTitle => 'Eventos de UFC';

  @override
  String get tabUpcoming => 'Próximos';

  @override
  String get tabPast => 'Pasados';

  @override
  String get tabSearch => 'Buscar';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signInSubtitle =>
      'Inicia sesión para administrar tu cuenta o sigue usando la app sin una.';

  @override
  String get continueWithoutAccount => 'Continuar sin cuenta';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get fieldRequired => 'Obligatorio';

  @override
  String get unexpectedError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get signOut => 'Cerrar sesión';

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
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAppearanceSection => 'Apariencia';

  @override
  String get settingsDataSection => 'Datos';

  @override
  String get settingsAboutSection => 'Acerca de';

  @override
  String get settingsProfileSection => 'Perfil';

  @override
  String get settingsSecuritySection => 'Seguridad';

  @override
  String get changeEmail => 'Cambiar correo electrónico';

  @override
  String get newEmail => 'Nuevo correo electrónico';

  @override
  String get invalidEmail => 'Ingresa un correo electrónico válido';

  @override
  String get emailUpdateSuccess =>
      'Se solicitó actualizar el correo. Revisa ambas bandejas si se requiere confirmación.';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get changePasswordSubtitle =>
      'Elige una nueva contraseña para esta cuenta';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmPassword => 'Confirmar nueva contraseña';

  @override
  String get passwordTooShort => 'Usa al menos 6 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordUpdateSuccess => 'Contraseña actualizada';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get biometricUnlockTitle => 'Desbloqueo con Face ID / biometría';

  @override
  String get biometricUnlockSubtitle =>
      'Requerir autenticación biométrica al volver a la app';

  @override
  String get biometricUnavailable =>
      'La autenticación biométrica no está disponible o configurada en este dispositivo.';

  @override
  String get biometricEnableReason =>
      'Confirma el desbloqueo biométrico para MMA Scorecard';

  @override
  String get biometricResumeReason => 'Desbloquea MMA Scorecard';

  @override
  String get biometricLockTitle => 'App bloqueada';

  @override
  String get biometricLockBody => 'Autentícate para continuar a MMA Scorecard.';

  @override
  String get biometricUnlockButton => 'Desbloquear';

  @override
  String get themeMenuTitle => 'Tema';

  @override
  String get languageMenuTitle => 'Idioma';

  @override
  String get aboutMenuTitle => 'Acerca de';

  @override
  String get termsMenuTitle => 'Términos y condiciones';

  @override
  String get privacyMenuTitle => 'Política de privacidad';

  @override
  String get cachedRecordsMenuTitle => 'Registros en caché';

  @override
  String get cachedRecordsMenuSubtitle =>
      'Solicitudes de datos de eventos guardadas en este dispositivo';

  @override
  String get cachedRecordsTitle => 'Registros en caché';

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
  String get chooseThemeTitle => 'Elegir tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get chooseLanguageTitle => 'Elegir idioma';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get appTagline => 'Eventos de UFC y resultados.';

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get aboutFeaturesHeading => 'Qué puedes hacer';

  @override
  String get aboutBulletEvents => 'Explorar eventos de UFC próximos y pasados';

  @override
  String get aboutBulletFightCards =>
      'Ver carteleras completas, resultados y métodos de victoria';

  @override
  String get aboutBulletFighters =>
      'Consultar perfiles, récords e historial de combates de los peleadores';

  @override
  String get aboutDataHeading => 'Sobre tus datos';

  @override
  String get aboutDataBody =>
      'La cuenta es opcional. Los datos de los eventos se obtienen de una fuente externa y se guardan en caché en este dispositivo para reducir el uso de red.';

  @override
  String get contactLabel => 'Desarrollador';

  @override
  String get developerName => 'Danny Vaca';

  @override
  String get developerEmail => 'danny270793@icloud.com';

  @override
  String get developerGithub => 'GitHub';

  @override
  String get developerWebsite => 'Sitio web';

  @override
  String get developerYoutube => 'YouTube';

  @override
  String get developerLinkedin => 'LinkedIn';

  @override
  String get termsTitle => 'Términos y condiciones';

  @override
  String get termsTagline => 'Léelos antes de usar la app.';

  @override
  String get termsAcceptanceTitle => 'Aceptación de los términos';

  @override
  String get termsAcceptanceBody =>
      'MMAScoreCard se ofrece tal cual, para uso personal y no comercial. El uso continuado de la app implica la aceptación de estos términos; si no estás de acuerdo, deja de usar la app.';

  @override
  String get termsAccountTitle => 'Cuenta opcional';

  @override
  String get termsAccountBody =>
      'Puedes usar la app sin iniciar sesión. Si creas una cuenta, el acceso lo gestiona Supabase. Hoy no subimos contenido generado por la app, como favoritos. Versiones posteriores podrán guardar ese tipo de datos en Supabase cuando hayas iniciado sesión, para sincronizarlos entre tus dispositivos.';

  @override
  String get termsDisclaimerTitle => 'Sin afiliación con la UFC';

  @override
  String get termsDisclaimerBody =>
      'Esta app no está afiliada, respaldada ni patrocinada por la UFC, ni ningún luchador o promotora mencionados.';

  @override
  String get termsLiabilityTitle => 'Sin garantía';

  @override
  String get termsLiabilityBody =>
      'El uso de la app es bajo tu propio riesgo y se ofrece sin garantías de ningún tipo.';

  @override
  String get termsResponsibilitiesTitle => 'Exactitud de los datos';

  @override
  String get termsResponsibilitiesBody =>
      'Los datos de los eventos (fechas, combates, sedes) provienen de un servicio externo de listados de eventos que no controlamos ni operamos; no podemos garantizar su exactitud, disponibilidad ni integridad, y los detalles pueden cambiar o eliminarse en cualquier momento.';

  @override
  String get termsNoticeTitle => 'Cambios en estos términos';

  @override
  String get termsNoticeBody =>
      'Estos términos pueden actualizarse a medida que la app cambie. El uso continuado de la app después de esos cambios implica la aceptación de los términos actualizados.';

  @override
  String get privacyTitle => 'Política de privacidad';

  @override
  String get privacyTagline =>
      'El inicio de sesión es opcional. La caché de eventos se queda en este dispositivo.';

  @override
  String get privacyDataTitle => 'Cuenta (opcional)';

  @override
  String get privacyDataBody =>
      'Puedes usar MMAScoreCard sin cuenta. Si inicias sesión, la autenticación la proporciona Supabase. Tu correo y credenciales los procesa Supabase; esta app no guarda tu contraseña.';

  @override
  String get privacyInfraTitle => 'Qué guardamos hoy — y más adelante';

  @override
  String get privacyInfraBody =>
      'Los listados públicos de eventos se obtienen de una fuente externa por HTTPS y se guardan en caché solo en este dispositivo para no volver a descargarlos cada vez. Tema e idioma se quedan en el dispositivo. Hoy no subimos datos generados por la app, como favoritos. En el futuro, si has iniciado sesión, podremos guardar ese tipo de información en Supabase para sincronizarla entre tus dispositivos. Puedes borrar la caché local de eventos al borrar el almacenamiento de la app.';

  @override
  String get privacySharingTitle => 'Solicitudes a terceros';

  @override
  String get privacySharingBody =>
      'Como los datos se solicitan directamente a esa fuente, tu solicitud de red (por ejemplo, tu dirección IP) es visible para ella según sus propias prácticas de privacidad, que esta app no controla.';

  @override
  String get privacyNoticeTitle => 'Cambios en esta política';

  @override
  String get privacyNoticeBody =>
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
