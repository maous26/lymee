// Test file to isolate iOS compilation issue
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_bloc.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider<FoodDetailBloc>(
        create: (_) => FoodDetailBloc(
          getFoodById: null as dynamic, // Placeholder
          addToHistory: null as dynamic, // Placeholder
        ),
        child: Container(),
      ),
    );
  }
}
