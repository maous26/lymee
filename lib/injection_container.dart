// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'data/datasources/local/ciqual_local_data_source.dart';
import 'data/datasources/local/openfoodfacts_local_data_source.dart';
import 'data/datasources/local/food_history_data_source.dart';
import 'data/datasources/local/user_preferences_data_source.dart';
import 'data/datasources/remote/openfoodfacts_remote_data_source.dart';
import 'data/repositories/food_repository_impl.dart';
import 'domain/repositories/food_repository.dart';
import 'domain/usecases/search_foods_usecase.dart';
import 'domain/usecases/search_fresh_foods_usecase.dart';
import 'domain/usecases/search_processed_foods_usecase.dart';
import 'domain/usecases/get_food_by_id_usecase.dart';
import 'domain/usecases/get_food_history_usecase.dart';
import 'domain/usecases/add_to_history_usecase.dart';
import 'domain/usecases/get_user_dietary_preferences_usecase.dart';
import 'domain/usecases/filter_foods_by_preferences_usecase.dart';
import 'presentation/bloc/food_search/food_search_bloc.dart';
import 'presentation/bloc/food_detail/food_detail_bloc.dart';
import 'presentation/bloc/food_history/food_history_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Food Search
  // Bloc
  sl.registerFactory(
    () => FoodSearchBloc(
      searchFoods: sl(),
      searchFreshFoods: sl(),
      searchProcessedFoods: sl(),
      getFoodHistory: sl(),
    ),
  );

  sl.registerFactory(
    () => FoodDetailBloc(getFoodById: sl(), addToHistory: sl()),
  );

  sl.registerFactory(() => FoodHistoryBloc(getFoodHistory: sl()));

  // Use cases
  sl.registerLazySingleton(() => SearchFoodsUseCase(sl()));
  sl.registerLazySingleton(() => SearchFreshFoodsUseCase(sl()));
  sl.registerLazySingleton(() => SearchProcessedFoodsUseCase(sl()));
  sl.registerLazySingleton(() => GetFoodByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetFoodHistoryUseCase(sl()));
  sl.registerLazySingleton(() => AddToHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetUserDietaryPreferencesUseCase(sl()));
  sl.registerLazySingleton(() => FilterFoodsByPreferencesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<FoodRepository>(
    () => FoodRepositoryImpl(
      ciqualLocalDataSource: sl(),
      openFoodFactsLocalDataSource: sl(),
      openFoodFactsRemoteDataSource: sl(),
      foodHistoryDataSource: sl(),
      userPreferencesDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CiqualLocalDataSource>(
    () => CiqualLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<OpenFoodFactsLocalDataSource>(
    () => OpenFoodFactsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<OpenFoodFactsRemoteDataSource>(
    () => OpenFoodFactsRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<FoodHistoryDataSource>(
    () => FoodHistoryDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<UserPreferencesDataSource>(
    () => UserPreferencesDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}
