import '../models/category.dart';

class Categories {
  static const general = 'general';
  static const animals = 'animals';
  static const brainTeaser = 'brain-teasers';
  static const celebrities = 'celebrities';
  static const entertainment = 'entertainment';
  static const geography = 'geography';
  static const history = 'history';
  static const hobbies = 'hobbies';
  static const humanity = 'humanities';
  static const kids = 'kids';
  static const literature = 'literature';
  static const movies = 'movies';
  static const music = 'music';
  static const people = 'people';
  static const religion = 'religion';
  static const scienceAndTech = 'science-technology';
  static const sports = 'sports';
  static const television = 'television';
  static const videoGames = 'video-games';
  static const world = 'world';

  static List<Category> categories = [
    Category(categoryId: general, name: 'General'),
    Category(categoryId: animals, name: 'Animals'),
    Category(categoryId: brainTeaser, name: 'Brain teasers'),
    Category(categoryId: celebrities, name: 'Celebrities'),
    Category(categoryId: entertainment, name: 'Entertainment'),
    Category(categoryId: geography, name: 'Geography'),
    Category(categoryId: history, name: 'History'),
    Category(categoryId: hobbies, name: 'Hobbies'),
    Category(categoryId: humanity, name: 'Humanities'),
    Category(categoryId: kids, name: 'Kids'),
    Category(categoryId: literature, name: 'Literature'),
    Category(categoryId: movies, name: 'Movies'),
    Category(categoryId: music, name: 'Music'),
    Category(categoryId: people, name: 'People'),
    Category(categoryId: religion, name: 'Religion'),
    Category(categoryId: scienceAndTech, name: 'Science and Tech'),
    Category(categoryId: sports, name: 'Sports'),
    Category(categoryId: television, name: 'Television'),
    Category(categoryId: videoGames, name: 'Video games'),
    Category(categoryId: world, name: 'World'),
  ];
}
