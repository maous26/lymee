import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/auth/auth_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/auth/auth_event.dart';
import 'package:lym_nutrition/presentation/bloc/auth/auth_state.dart';
import 'package:lym_nutrition/presentation/screens/landing_page.dart';
import 'package:lym_nutrition/presentation/screens/main_app_shell.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';
import 'package:lym_nutrition/injection_container.dart' as di;

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>()..add(AuthStatusRequested()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const _SplashScreen();
          } else if (state is AuthAuthenticated) {
            return const MainAppShell();
          } else {
            return const LandingPage();
          }
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              FreshTheme.primaryMint,
              FreshTheme.serenityBlue,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: FreshTheme.primaryMint,
                  size: 60,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'LYM Nutrition',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Votre coach nutritionnel personnalisé',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
