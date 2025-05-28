// lib/presentation/bloc/food_detail/food_detail_state.dart
import 'package:equatable/equatable.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';

abstract class FoodDetailState extends Equatable {
  const FoodDetailState();
  
  @override
  List<Object?> get props => [];
}

class FoodDetailInitial extends FoodDetailState {}

class FoodDetailLoading extends FoodDetailState {}

class FoodDetailLoaded extends FoodDetailState {
  final FoodItem food;

  const FoodDetailLoaded({required this.food});

  @override
  List<Object> get props => [food];
}

class FoodDetailError extends FoodDetailState {
  final String message;

  const FoodDetailError({required this.message});

  @override
  List<Object> get props => [message];
}

class FoodAddedToHistory extends FoodDetailState {}
