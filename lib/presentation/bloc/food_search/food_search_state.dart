// lib/presentation/bloc/food_search/food_search_state.dart
import 'package:equatable/equatable.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';

abstract class FoodSearchState extends Equatable {
  const FoodSearchState();
  
  @override
  List<Object?> get props => [];
}

class FoodSearchInitial extends FoodSearchState {}

class FoodSearchLoading extends FoodSearchState {}

class FoodSearchSuccess extends FoodSearchState {
  final List<FoodItem> foods;
  final bool isSearchResult;
  final String? searchQuery;

  const FoodSearchSuccess({
    required this.foods,
    this.isSearchResult = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [foods, isSearchResult, searchQuery];
}

class FoodHistoryLoaded extends FoodSearchState {
  final List<FoodItem> historyItems;

  const FoodHistoryLoaded({required this.historyItems});

  @override
  List<Object> get props => [historyItems];
}

class FoodSearchError extends FoodSearchState {
  final String message;

  const FoodSearchError({required this.message});

  @override
  List<Object> get props => [message];
}
