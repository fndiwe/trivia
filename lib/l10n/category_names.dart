import 'package:trivia/l10n/generated/app_localizations.dart';

/// Maps a category slug (as stored in the database and used for the SVG file
/// names) to its localised display name.
///
/// The database keeps the English name as a fallback, but the UI should always
/// go through this so translating the app does not require a data migration.
extension CategoryNames on AppLocalizations {
  String categoryLabel(String categoryId) => switch (categoryId) {
    'general' => categoryGeneral,
    'animals' => categoryAnimals,
    'brain-teasers' => categoryBrainTeasers,
    'celebrities' => categoryCelebrities,
    'entertainment' => categoryEntertainment,
    'geography' => categoryGeography,
    'history' => categoryHistory,
    'hobbies' => categoryHobbies,
    'humanities' => categoryHumanities,
    'kids' => categoryKids,
    'literature' => categoryLiterature,
    'movies' => categoryMovies,
    'music' => categoryMusic,
    'people' => categoryPeople,
    'religion' => categoryReligion,
    'science-technology' => categoryScienceTechnology,
    'sports' => categorySports,
    'television' => categoryTelevision,
    'video-games' => categoryVideoGames,
    'world' => categoryWorld,
    _ => categoryId,
  };
}
