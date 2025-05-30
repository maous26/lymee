#!/usr/bin/env dart
// Test script for the new unified search functionality

import 'package:lym_nutrition/main.dart' as app;
import 'package:lym_nutrition/injection_container.dart' as di;
import 'package:lym_nutrition/domain/repositories/food_repository.dart';

Future<void> main() async {
  print('🧪 Testing Unified Search Functionality\n');

  try {
    // Initialize dependencies
    await di.init();
    final repository = di.sl<FoodRepository>();

    // Test cases based on the precise search rules
    final testCases = [
      {
        'query': 'tomate',
        'description': 'Single word - should prioritize basic tomatoes',
        'expectation': 'Basic tomato products from CIQUAL'
      },
      {
        'query': 'sauce tomate',
        'description': 'Multi-word - should find tomato sauce products',
        'expectation': 'Processed tomato sauce products'
      },
      {
        'query': 'sauce',
        'description': 'General term - should find all sauce products',
        'expectation': 'Various sauce products (general term)'
      },
      {
        'query': 'thon',
        'description': 'Single word - should prioritize basic tuna',
        'expectation': 'Basic tuna products'
      },
      {
        'query': 'pizza saumon',
        'description': 'Complex product - should find salmon pizza',
        'expectation': 'Salmon pizza products'
      }
    ];

    for (var testCase in testCases) {
      print('🔍 Test: ${testCase['query']}');
      print('   Description: ${testCase['description']}');
      print('   Expected: ${testCase['expectation']}');

      final result = await repository.searchFoods(testCase['query']!);

      result.fold((failure) => print('   ❌ Error: $failure'), (foods) {
        print('   ✅ Found ${foods.length} products');
        if (foods.isNotEmpty) {
          print('   Top results:');
          for (int i = 0; i < 3 && i < foods.length; i++) {
            print('     - ${foods[i].name}');
          }
        }
      });
      print('');
    }

    print('🎉 Unified search test completed!');
  } catch (e) {
    print('💥 Test failed: $e');
  }
}
