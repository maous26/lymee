// Test file to verify imports are working
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_event.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_state.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_history/food_history_bloc.dart';
import 'package:lym_nutrition/domain/usecases/get_food_history_usecase.dart';

void main() {
  print('All imports are working correctly');

  // Test instantiation would happen here if needed
  print('FoodSearchBloc type: ${FoodSearchBloc}');
  print('FoodSearchEvent type: ${FoodSearchEvent}');
  print('FoodSearchState type: ${FoodSearchState}');
  print('GetFoodHistoryUseCase type: ${GetFoodHistoryUseCase}');
}
