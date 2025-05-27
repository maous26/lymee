// lib/presentation/bloc/food_history/food_history_event.dart
import 'package:equatable/equatable.dart';

abstract class FoodHistoryEvent extends Equatable {
  const FoodHistoryEvent();

  @override
  List<Object> get props => [];
}

class GetFoodHistoryItemsEvent extends FoodHistoryEvent {}
