// lib/presentation/bloc/food_history/food_history_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/usecases/get_food_history_usecase.dart';
import 'package:lym_nutrition/presentation/bloc/food_history/food_history_event.dart';
import 'package:lym_nutrition/presentation/bloc/food_history/food_history_state.dart';

class FoodHistoryBloc extends Bloc<FoodHistoryEvent, FoodHistoryState> {
  final GetFoodHistoryUseCase getFoodHistory;

  FoodHistoryBloc({required this.getFoodHistory})
      : super(FoodHistoryInitial()) {
    on<GetFoodHistoryItemsEvent>(_onGetFoodHistoryItems);
  }

  Future<void> _onGetFoodHistoryItems(
    GetFoodHistoryItemsEvent event,
    Emitter<FoodHistoryState> emit,
  ) async {
    emit(FoodHistoryLoading());

    final result = await getFoodHistory(NoParams());

    result.fold(
      (failure) => emit(FoodHistoryLoadError(message: failure.message)),
      (historyItems) =>
          emit(FoodHistoryLoadSuccess(historyItems: historyItems)),
    );
  }
}
