// lib/presentation/bloc/food_search/food_search_event.dart
import 'package:equatable/equatable.dart';

abstract class FoodSearchEvent extends Equatable {
  const FoodSearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchAllFoodsEvent extends FoodSearchEvent {
  final String query;
  final String? brand;

  const SearchAllFoodsEvent({
    required this.query,
    this.brand,
  });

  @override
  List<Object?> get props => [query, brand];
}

class SearchFreshFoodsEvent extends FoodSearchEvent {
  final String query;

  const SearchFreshFoodsEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class SearchProcessedFoodsEvent extends FoodSearchEvent {
  final String query;
  final String? brand;

  const SearchProcessedFoodsEvent({
    required this.query,
    this.brand,
  });

  @override
  List<Object?> get props => [query, brand];
}

class GetFoodHistoryEvent extends FoodSearchEvent {}

class ClearSearchEvent extends FoodSearchEvent {}