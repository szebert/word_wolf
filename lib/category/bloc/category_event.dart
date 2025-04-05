part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

/// Initializes the category management with stored categories
class CategoryInitialized extends CategoryEvent {
  const CategoryInitialized();
}

/// Updates the search text for category filtering
class CategorySearchUpdated extends CategoryEvent {
  const CategorySearchUpdated({
    required this.searchText,
  });

  final String searchText;

  @override
  List<Object> get props => [searchText];
}

/// Selects a category for the game
class CategorySelected extends CategoryEvent {
  const CategorySelected({
    required this.categoryName,
  });

  final String categoryName;

  @override
  List<Object> get props => [categoryName];
}

/// Removes a category from storage
class CategoryRemoved extends CategoryEvent {
  const CategoryRemoved({
    required this.categoryName,
  });

  final String categoryName;

  @override
  List<Object> get props => [categoryName];
}
