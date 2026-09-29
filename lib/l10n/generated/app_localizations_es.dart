// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'TriviaHQ';

  @override
  String get tabLevels => 'Niveles';

  @override
  String get tabCategories => 'Categorías';

  @override
  String get settingsTooltip => 'Ajustes';

  @override
  String get statisticsTooltip => 'Estadísticas';

  @override
  String streakBadge(int count) {
    return '$count días seguidos';
  }

  @override
  String streakBadgeNew(int count) {
    return '¡$count días seguidos!';
  }

  @override
  String streakSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días seguidos',
      one: '1 día seguido',
    );
    return '$_temp0';
  }

  @override
  String get preparingBank => 'Preparando el banco de preguntas';

  @override
  String importProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get couldNotPrepare =>
      'No se pudieron preparar los datos del cuestionario.';

  @override
  String get dailyChallengeTitle => 'Reto diario';

  @override
  String get dailyChallengeDone => 'Hecho por hoy: vuelve mañana';

  @override
  String get dailyChallengeSubtitle =>
      'Diez preguntas, las mismas para todos hoy';

  @override
  String get practiceTitle => 'Practica tus errores';

  @override
  String practiceSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preguntas por repasar',
      one: '1 pregunta por repasar',
    );
    return '$_temp0';
  }

  @override
  String unlockHint(int previous, int next) {
    return 'Supera el nivel $previous para desbloquear el nivel $next.';
  }

  @override
  String questionCounter(int current, int total) {
    return 'P: $current/$total';
  }

  @override
  String scoreLabel(int score) {
    return 'Puntos: $score';
  }

  @override
  String levelLabel(int number) {
    return 'Nivel $number';
  }

  @override
  String levelSemantics(int number) {
    return 'Nivel $number';
  }

  @override
  String levelLockedSemantics(int number) {
    return 'Nivel $number, bloqueado';
  }

  @override
  String get levelWord => 'Nivel';

  @override
  String get modeDaily => 'Reto diario';

  @override
  String get modePractice => 'Práctica';

  @override
  String get modeLevel => 'Nivel';

  @override
  String get modeCategory => 'Categoría';

  @override
  String get noTimeLimit => 'Sin límite de tiempo';

  @override
  String get timeRemaining => 'Tiempo restante';

  @override
  String secondsValue(int seconds) {
    return '$seconds segundos';
  }

  @override
  String get noTimerLabel => 'Sin cronómetro';

  @override
  String get lifeline5050 => '50:50 - elimina dos respuestas incorrectas';

  @override
  String get lifeline5050Used => '50:50 ya usado';

  @override
  String get lifelineSkip => 'Saltar esta pregunta';

  @override
  String get lifelineSkipUsed => 'Salto ya usado';

  @override
  String lifelineExtraTime(int seconds) {
    return '+$seconds segundos';
  }

  @override
  String get lifelineExtraTimeUsed => 'Tiempo extra ya usado';

  @override
  String get pauseTooltip => 'Pausar';

  @override
  String get resumeTooltip => 'Continuar';

  @override
  String get pausedTitle => 'En pausa';

  @override
  String get pausedSubtitle => 'Tu progreso en esta ronda se conserva.';

  @override
  String get resume => 'Continuar';

  @override
  String get quitRound => 'Abandonar ronda';

  @override
  String get exitGameTitle => '¿Salir de la partida?';

  @override
  String get exitGameBody =>
      '¿Quieres detener la partida? Perderás el progreso actual.';

  @override
  String get exit => 'Salir';

  @override
  String get continueGame => 'Seguir jugando';

  @override
  String get noQuestions => 'Todavía no hay preguntas para este cuestionario.';

  @override
  String get nothingToPractise =>
      'Aún no hay nada que practicar. Juega algunas rondas y las preguntas que falles aparecerán aquí.';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get couldNotLoad => 'No se pudieron cargar las preguntas.';

  @override
  String get resultsTitle => 'Resultados';

  @override
  String get playAgain => 'Jugar otra vez';

  @override
  String get home => 'Inicio';

  @override
  String practiseTheseMistakes(int count) {
    return 'Practicar estos errores ($count)';
  }

  @override
  String get review => 'Repaso';

  @override
  String allCorrect(int total) {
    return 'Las $total correctas';
  }

  @override
  String correctOfTotal(int correct, int total) {
    return '$correct/$total correctas';
  }

  @override
  String get newBestScore => '¡Nuevo récord!';

  @override
  String levelUnlocked(int number) {
    return '¡Nivel $number desbloqueado!';
  }

  @override
  String get couldNotSave => 'No se pudo guardar esta ronda';

  @override
  String get verdictCorrect => 'Correcta';

  @override
  String get verdictWrong => 'Incorrecta';

  @override
  String get verdictOutOfTime => 'Se acabó el tiempo';

  @override
  String get verdictSkipped => 'Saltada';

  @override
  String get youAnswered => 'Respondiste';

  @override
  String get answerLabel => 'Respuesta';

  @override
  String starRatingSemantics(int earned, int max) {
    return '$earned de $max estrellas';
  }

  @override
  String questionsCount(int count) {
    return '$count preguntas';
  }

  @override
  String bestScore(int score, int total) {
    return 'Récord: $score/$total';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get sectionAppearance => 'Apariencia';

  @override
  String get sectionGameplay => 'Juego';

  @override
  String get sectionData => 'Datos';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get questionsPerRound => 'Preguntas por ronda';

  @override
  String questionsPerRoundValue(int count) {
    return '$count preguntas';
  }

  @override
  String get secondsPerQuestion => 'Segundos por pregunta';

  @override
  String get timerOff => 'Desactivado';

  @override
  String timerSeconds(int seconds) {
    return '$seconds segundos';
  }

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get soundEffectsSubtitle =>
      'Reproduce un sonido al acertar y al fallar.';

  @override
  String get vibration => 'Vibración';

  @override
  String get vibrationSubtitle => 'Vibración ligera al responder.';

  @override
  String get resetProgressTitle => 'Reiniciar progreso';

  @override
  String get resetProgressSubtitle =>
      'Borra puntuaciones, desbloqueos, historial y estadísticas.';

  @override
  String get resetProgressQuestion => '¿Reiniciar el progreso?';

  @override
  String get resetProgressBody =>
      'Se borrarán las puntuaciones de todos los niveles, se volverán a bloquear todos menos el primero, se borrarán los récords por categoría y se eliminarán el historial de rondas, las estadísticas por pregunta y la racha. No se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get reset => 'Reiniciar';

  @override
  String get progressReset => 'Progreso reiniciado.';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statAccuracy => 'Acierto';

  @override
  String get statRounds => 'Rondas';

  @override
  String get statBestRound => 'Mejor ronda';

  @override
  String get statQuestionsSeen => 'Preguntas vistas';

  @override
  String get statMastered => 'Dominadas';

  @override
  String get statToPractise => 'Por practicar';

  @override
  String get recentRounds => 'Rondas recientes';

  @override
  String get noRoundsYet => 'Aún no has jugado ninguna ronda';

  @override
  String get noRoundsHint =>
      'Termina un nivel o una ronda de categoría y aquí verás tu porcentaje de acierto, tu récord y las preguntas más difíciles.';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryAnimals => 'Animales';

  @override
  String get categoryBrainTeasers => 'Acertijos';

  @override
  String get categoryCelebrities => 'Famosos';

  @override
  String get categoryEntertainment => 'Entretenimiento';

  @override
  String get categoryGeography => 'Geografía';

  @override
  String get categoryHistory => 'Historia';

  @override
  String get categoryHobbies => 'Aficiones';

  @override
  String get categoryHumanities => 'Humanidades';

  @override
  String get categoryKids => 'Infantil';

  @override
  String get categoryLiterature => 'Literatura';

  @override
  String get categoryMovies => 'Cine';

  @override
  String get categoryMusic => 'Música';

  @override
  String get categoryPeople => 'Gente';

  @override
  String get categoryReligion => 'Religión';

  @override
  String get categoryScienceTechnology => 'Ciencia y tecnología';

  @override
  String get categorySports => 'Deportes';

  @override
  String get categoryTelevision => 'Televisión';

  @override
  String get categoryVideoGames => 'Videojuegos';

  @override
  String get categoryWorld => 'Mundo';

  @override
  String get byCategory => 'Por categoría';

  @override
  String get hardestQuestions => 'Preguntas más difíciles';

  @override
  String accuracyOf(int percent, int correct, int total) {
    return '$percent% ($correct/$total)';
  }

  @override
  String get rebalanceTitle => 'Reequilibrar campaña';

  @override
  String get rebalanceSubtitle =>
      'Reordena los niveles por dificultad usando tus estadísticas.';

  @override
  String rebalanceDone(int moved) {
    return 'Campaña reequilibrada ($moved preguntas movidas).';
  }

  @override
  String get rebalanceNothing => 'La campaña ya está bien ordenada.';
}
