// Minimal test for FoodDetailBloc import issue
import 'package:flutter/material.dart';

// Test importing just the BLoC to isolate the issue
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_bloc.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Reference the class to ensure import is used
    final blocType = FoodDetailBloc;
    return MaterialApp(
      home: Scaffold(
        body: Text('FoodDetailBloc type test: $blocType'),
      ),
    );
  }
}
