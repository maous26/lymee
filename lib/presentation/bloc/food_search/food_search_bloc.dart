// lib/presentation/bloc/food_search/food_search_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/usecases/search_foods_usecase.dart';
import 'package:lym_nutrition/domain/usecases/search_fresh_foods_usecase.dart';
import 'package:lym_nutrition/domain/usecases/search_processed_foods_usecase.dart';
import 'package:lym_nutrition/domain/usecases/get_food_history_usecase.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_event.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_state.dart';

class FoodSearchBloc extends Bloc<FoodSearchEvent, FoodSearchState> {
  final SearchFoodsUseCase searchFoods;
  final SearchFreshFoodsUseCase searchFreshFoods;
  final SearchProcessedFoodsUseCase searchProcessedFoods;
  final GetFoodHistoryUseCase getFoodHistory;

  FoodSearchBloc({
    required this.searchFoods,
    required this.searchFreshFoods,
    required this.searchProcessedFoods,
    required this.getFoodHistory,
  }) : super(FoodSearchInitial()) {
    on<SearchAllFoodsEvent>(_onSearchAllFoods);
    on<SearchFreshFoodsEvent>(_onSearchFreshFoods);
    on<SearchProcessedFoodsEvent>(_onSearchProcessedFoods);
    on<GetFoodHistoryEvent>(_onGetFoodHistory);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchAllFoods(
    SearchAllFoodsEvent event,
    Emitter<FoodSearchState> emit,
  ) async {
    emit(FoodSearchLoading());

    final result = await searchFoods(
      SearchParams(query: event.query, brand: event.brand),
    );

    result.fold(
      (failure) => emit(FoodSearchError(message: failure.message)),
      (foods) => emit(FoodSearchSuccess(
        foods: foods,
        isSearchResult: true,
        searchQuery: event.query,
      )),
    );
  }

  Future<void> _onSearchFreshFoods(
    SearchFreshFoodsEvent event,
    Emitter<FoodSearchState> emit,
  ) async {
    emit(FoodSearchLoading());

    final result = await searchFreshFoods(QueryParams(query: event.query));

    result.fold(
      (failure) => emit(FoodSearchError(message: failure.message)),
      (foods) => emit(FoodSearchSuccess(
        foods: foods,
        isSearchResult: true,
        searchQuery: event.query,
      )),
    );
  }

  Future<void> _onSearchProcessedFoods(
    SearchProcessedFoodsEvent event,
    Emitter<FoodSearchState> emit,
  ) async {
    emit(FoodSearchLoading());

    final result = await searchProcessedFoods(
      SearchParams(query: event.query, brand: event.brand),
    );

    result.fold(
      (failure) => emit(FoodSearchError(message: failure.message)),
      (foods) => emit(FoodSearchSuccess(
        foods: foods,
        isSearchResult: true,
        searchQuery: event.query,
      )),
    );
  }

  Future<void> _onGetFoodHistory(
    GetFoodHistoryEvent event,
    Emitter<FoodSearchState> emit,
  ) async {
    emit(FoodSearchLoading());

    final result = await getFoodHistory(NoParams());

    result.fold(
      (failure) => emit(FoodSearchError(message: failure.message)),
      (historyItems) => emit(FoodHistoryLoaded(historyItems: historyItems)),
    );
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<FoodSearchState> emit,
  ) {
    emit(FoodSearchInitial());
  }
}
