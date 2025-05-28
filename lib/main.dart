// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lym_nutrition/injection_container.dart' as di;
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_history/food_history_bloc.dart';
import 'package:lym_nutrition/presentation/screens/food_search_screen.dart';
import 'package:lym_nutrition/presentation/themes/app_theme.dart';

void main() async {
  // Assurer que les widgets Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser l'injection de dépendances
  await di.init();

  // Fixer l'orientation de l'application en mode portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Définir la couleur de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FoodSearchBloc>(
          create: (_) => di.sl<FoodSearchBloc>(),
        ),
        BlocProvider<FoodDetailBloc>(
          create: (_) => di.sl<FoodDetailBloc>(),
        ),
        BlocProvider<FoodHistoryBloc>(
          create: (_) => di.sl<FoodHistoryBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Lym Nutrition',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const FoodSearchScreen(),
      ),
    );
  }
}
