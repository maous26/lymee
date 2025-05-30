// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lym_nutrition/injection_container.dart' as di;
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_history/food_history_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_event.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_state.dart';
import 'package:lym_nutrition/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:lym_nutrition/presentation/screens/nutrition_dashboard_screen.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/themes/wellness_theme.dart';

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
        BlocProvider<UserProfileBloc>(
          create: (_) => di.sl<UserProfileBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Lym Nutrition',
        debugShowCheckedModeBanner: false,
        theme: WellnessTheme.lightTheme,
        darkTheme: WellnessTheme.lightTheme, // Utiliser le même thème pour l'instant
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/dashboard': (context) => const NutritionDashboardScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Ajouter un délai pour s'assurer que le splash screen est visible
    Future.delayed(const Duration(seconds: 2), () {
      // Vérifier si l'onboarding a été complété
      context.read<UserProfileBloc>().add(CheckOnboardingCompletedEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is OnboardingCompleted) {
            print(
                "État d'onboarding détecté: ${state.isCompleted ? 'complété' : 'non complété'}");

            // Naviguer vers l'écran approprié en fonction de l'état de l'onboarding
            if (state.isCompleted) {
              Navigator.pushReplacementNamed(context, '/dashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/onboarding');
            }
          } else if (state is UserProfileError) {
            print("Erreur détectée: ${state.message}");

            // En cas d'erreur, diriger vers l'onboarding par défaut
            Navigator.pushReplacementNamed(context, '/onboarding');
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PremiumTheme.primaryDark,
                PremiumTheme.primaryLight,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo de l'application
                const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Lym Nutrition',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre coach nutritionnel personnalisé',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
