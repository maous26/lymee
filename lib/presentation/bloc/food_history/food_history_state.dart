// lib/presentation/bloc/food_history/food_history_state.dart
import 'package:equatable/equatable.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';

abstract class FoodHistoryState extends Equatable {
  const FoodHistoryState();

  @override
  List<Object?> get props => [];
}

class FoodHistoryInitial extends FoodHistoryState {}

class FoodHistoryLoading extends FoodHistoryState {}

class FoodHistoryLoadSuccess extends FoodHistoryState {
  final List<FoodItem> historyItems;

  const FoodHistoryLoadSuccess({required this.historyItems});

  @override
  List<Object> get props => [historyItems];
}

class FoodHistoryLoadError extends FoodHistoryState {
  final String message;

  const FoodHistoryLoadError({required this.message});

  @override
  List<Object> get props => [message];
}
