// Test file to verify BLoC types are working
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/injection_container.dart' as di;
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_history/food_history_bloc.dart';

void main() async {
  await di.init();

  // Test that we can create instances of each BLoC
  final foodSearchBloc = di.sl<FoodSearchBloc>();
  final foodDetailBloc = di.sl<FoodDetailBloc>();
  final foodHistoryBloc = di.sl<FoodHistoryBloc>();

  print('FoodSearchBloc: ${foodSearchBloc.runtimeType}');
  print('FoodDetailBloc: ${foodDetailBloc.runtimeType}');
  print('FoodHistoryBloc: ${foodHistoryBloc.runtimeType}');

  // Test BlocProvider type instantiation
  final providers = [
    BlocProvider<FoodSearchBloc>(create: (_) => foodSearchBloc),
    BlocProvider<FoodDetailBloc>(create: (_) => foodDetailBloc),
    BlocProvider<FoodHistoryBloc>(create: (_) => foodHistoryBloc),
  ];

  print('All BlocProviders created successfully');
  print('Number of providers: ${providers.length}');
}
