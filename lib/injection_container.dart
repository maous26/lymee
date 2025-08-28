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
import 'data/datasources/local/user_profile_data_source.dart';
import 'data/datasources/remote/openfoodfacts_remote_data_source.dart';
import 'data/repositories/food_repository_impl.dart';
import 'data/repositories/user_profile_repository_impl.dart';
import 'domain/repositories/food_repository.dart';
import 'domain/repositories/user_profile_repository.dart';
import 'domain/usecases/search_foods_usecase.dart';
import 'domain/usecases/search_fresh_foods_usecase.dart';
import 'domain/usecases/search_processed_foods_usecase.dart';
import 'domain/usecases/get_food_by_id_usecase.dart';
import 'domain/usecases/get_food_history_usecase.dart';
import 'domain/usecases/add_to_history_usecase.dart';
import 'domain/usecases/get_user_dietary_preferences_usecase.dart';
import 'domain/usecases/filter_foods_by_preferences_usecase.dart';
import 'domain/usecases/get_user_profile_usecase.dart';
import 'domain/usecases/has_user_profile_usecase.dart';
import 'domain/usecases/save_user_profile_usecase.dart';
import 'domain/usecases/has_completed_onboarding_usecase.dart';
import 'domain/usecases/reset_user_profile_usecase.dart';
import 'domain/usecases/auth/get_current_user_usecase.dart';
import 'domain/usecases/auth/is_authenticated_usecase.dart';
import 'domain/usecases/auth/sign_in_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';
import 'domain/usecases/auth/sign_up_usecase.dart';
import 'domain/usecases/auth/send_password_reset_usecase.dart';
import 'domain/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/datasources/local/auth_local_data_source.dart';
import 'presentation/bloc/food_search/food_search_bloc.dart';
import 'presentation/bloc/food_detail/food_detail_bloc.dart';
import 'presentation/bloc/food_history/food_history_bloc.dart';
import 'presentation/bloc/user_profile/user_profile_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';

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
    () => FoodDetailBloc(
      getFoodById: sl(),
      addToHistory: sl(),
    ),
  );

  sl.registerFactory(
    () => FoodHistoryBloc(
      getFoodHistory: sl(),
    ),
  );

  //! Feature - User Profile
  sl.registerFactory(
    () => UserProfileBloc(
      getUserProfile: sl(),
      hasUserProfile: sl(),
      saveUserProfile: sl(),
      hasCompletedOnboarding: sl(),
      resetUserProfile: sl(),
    ),
  );

  //! Feature - Authentication
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUser: sl(),
      isAuthenticated: sl(),
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      sendPasswordReset: sl(),
      authRepository: sl(),
    ),
  );

  // Use cases - Food
  sl.registerLazySingleton(() => SearchFoodsUseCase(sl()));
  sl.registerLazySingleton(() => SearchFreshFoodsUseCase(sl()));
  sl.registerLazySingleton(() => SearchProcessedFoodsUseCase(sl()));
  sl.registerLazySingleton(() => GetFoodByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetFoodHistoryUseCase(sl()));
  sl.registerLazySingleton(() => AddToHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetUserDietaryPreferencesUseCase(sl()));
  sl.registerLazySingleton(() => FilterFoodsByPreferencesUseCase(sl()));

  // Use cases - User Profile
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => HasUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => SaveUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => HasCompletedOnboardingUseCase(sl()));
  sl.registerLazySingleton(() => ResetUserProfileUseCase(sl()));

  // Use cases - Authentication
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => IsAuthenticatedUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetUseCase(sl()));

  // Repository - Food
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

  // Repository - User Profile
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Repository - Authentication
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources - Food
  sl.registerLazySingleton<CiqualLocalDataSource>(
    () => CiqualLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<OpenFoodFactsLocalDataSource>(
    () => OpenFoodFactsLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<OpenFoodFactsRemoteDataSource>(
    () => OpenFoodFactsRemoteDataSourceImpl(
      client: sl(),
    ),
  );

  sl.registerLazySingleton<FoodHistoryDataSource>(
    () => FoodHistoryDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<UserPreferencesDataSource>(
    () => UserPreferencesDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  // Data sources - User Profile
  sl.registerLazySingleton<UserProfileDataSource>(
    () => UserProfileDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  // Data sources - Authentication
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}
