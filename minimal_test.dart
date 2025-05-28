// Minimal test for FoodDetailBloc import issue
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Test importing just the BLoC to isolate the issue
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_bloc.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Text('FoodDetailBloc type test: ${FoodDetailBloc.toString()}'),
      ),
    );
  }
}
