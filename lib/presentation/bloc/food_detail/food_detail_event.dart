// lib/presentation/bloc/food_detail/food_detail_event.dart
import 'package:equatable/equatable.dart';

abstract class FoodDetailEvent extends Equatable {
  const FoodDetailEvent();

  @override
  List<Object> get props => [];
}

class GetFoodDetailEvent extends FoodDetailEvent {
  final String id;
  final String source;

  const GetFoodDetailEvent({
    required this.id,
    required this.source,
  });

  @override
  List<Object> get props => [id, source];
}

class AddFoodToHistoryEvent extends FoodDetailEvent {
  final String id;
  final String source;

  const AddFoodToHistoryEvent({
    required this.id,
    required this.source,
  });

  @override
  List<Object> get props => [id, source];
}