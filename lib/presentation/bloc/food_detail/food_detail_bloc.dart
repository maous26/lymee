// lib/presentation/bloc/food_detail/food_detail_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/domain/usecases/get_food_by_id_usecase.dart';
import 'package:lym_nutrition/domain/usecases/add_to_history_usecase.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_event.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_state.dart';

class FoodDetailBloc extends Bloc<FoodDetailEvent, FoodDetailState> {
  final GetFoodByIdUseCase getFoodById;
  final AddToHistoryUseCase addToHistory;
  FoodItem? currentFood;

  FoodDetailBloc({
    required this.getFoodById,
    required this.addToHistory,
  }) : super(FoodDetailInitial()) {
    on<GetFoodDetailEvent>(_onGetFoodDetail);
    on<AddFoodToHistoryEvent>(_onAddFoodToHistory);
  }

  Future<void> _onGetFoodDetail(
    GetFoodDetailEvent event,
    Emitter<FoodDetailState> emit,
  ) async {
    emit(FoodDetailLoading());

    final result = await getFoodById(
      FoodIdParams(id: event.id, source: event.source),
    );

    await result.fold(
      (failure) async {
        emit(FoodDetailError(message: failure.message));
      },
      (food) async {
        currentFood = food;
        emit(FoodDetailLoaded(food: food));

        // Ajouter automatiquement à l'historique
        await _addFoodToHistory(food);
      },
    );
  }

  Future<void> _onAddFoodToHistory(
    AddFoodToHistoryEvent event,
    Emitter<FoodDetailState> emit,
  ) async {
    if (currentFood == null) {
      // Charger d'abord les détails de l'aliment
      final result = await getFoodById(
        FoodIdParams(id: event.id, source: event.source),
      );

      await result.fold(
        (failure) async {
          emit(FoodDetailError(message: failure.message));
        },
        (food) async {
          currentFood = food;
          await _addFoodToHistory(food);
          emit(FoodAddedToHistory());
        },
      );
    } else {
      await _addFoodToHistory(currentFood!);
      emit(FoodAddedToHistory());
    }
  }

  Future<void> _addFoodToHistory(FoodItem food) async {
    await addToHistory(FoodParams(food: food));
  }
}
