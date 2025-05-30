// Test script to validate search precision improvements
import 'package:flutter/material.dart';
import 'lib/data/datasources/local/ciqual_local_data_source.dart';
import 'lib/data/repositories/food_repository_impl.dart';
import 'lib/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await di.init();
  
  print('🧪 Testing search precision improvements...\n');
  
  // Test the CIQUAL search logic directly
  await testCiqualSearchPrecision();
  
  // Test the unified search
  await testUnifiedSearchPrecision();
}

Future<void> testCiqualSearchPrecision() async {
  print('📊 Testing CIQUAL search precision:');
  
  try {
    final ciqualDataSource = di.sl<CiqualLocalDataSource>();
    
    // Test search for "riz"
    print('\n🔍 Searching for "riz":');
    final rizResults = await ciqualDataSource.searchFoods('riz');
    
    print('Results found: ${rizResults.length}');
    for (int i = 0; i < rizResults.take(10).length; i++) {
      final food = rizResults[i];
      print('  ${i + 1}. ${food.name} (${food.alimGrpNomFr})');
    }
    
    // Test search for "blé"
    print('\n🔍 Searching for "blé":');
    final bleResults = await ciqualDataSource.searchFoods('blé');
    
    print('Results found: ${bleResults.length}');
    for (int i = 0; i < bleResults.take(5).length; i++) {
      final food = bleResults[i];
      print('  ${i + 1}. ${food.name} (${food.alimGrpNomFr})');
    }
    
    // Check if rice results contain wheat products
    final rizContainsWheat = rizResults.any((food) => 
        food.name.toLowerCase().contains('blé') || 
        food.name.toLowerCase().contains('wheat'));
    
    print('\n📈 Analysis:');
    print('  Rice results contain wheat products: $rizContainsWheat');
    
    if (rizContainsWheat) {
      print('  ⚠️ Issue detected: Rice search returns wheat products');
      final wheatInRice = rizResults.where((food) => 
          food.name.toLowerCase().contains('blé') || 
          food.name.toLowerCase().contains('wheat')).toList();
      
      print('  Problematic results:');
      for (final food in wheatInRice.take(3)) {
        print('    - ${food.name}');
      }
    } else {
      print('  ✅ Good: Rice search does not return wheat products');
    }
    
  } catch (e) {
    print('❌ Error testing CIQUAL search: $e');
  }
}

Future<void> testUnifiedSearchPrecision() async {
  print('\n🔄 Testing unified search precision:');
  
  try {
    final foodRepository = di.sl<FoodRepositoryImpl>();
    
    // Test unified search for "riz"
    print('\n🔍 Unified search for "riz":');
    final unifiedResults = await foodRepository.searchFoods('riz');
    
    unifiedResults.fold(
      (failure) => print('❌ Search failed: $failure'),
      (foods) {
        print('Results found: ${foods.length}');
        for (int i = 0; i < foods.take(10).length; i++) {
          final food = foods[i];
          print('  ${i + 1}. ${food.name} (${food.source})');
        }
        
        // Check sources distribution
        final ciqualCount = foods.where((f) => f.source == 'ciqual').length;
        final offCount = foods.where((f) => f.source == 'openfoodfacts').length;
        
        print('\n📊 Sources distribution:');
        print('  CIQUAL: $ciqualCount');
        print('  OpenFoodFacts: $offCount');
        
        // Check if rice results contain wheat
        final containsWheat = foods.any((food) => 
            food.name.toLowerCase().contains('blé') || 
            food.name.toLowerCase().contains('wheat'));
            
        print('  Contains wheat products: $containsWheat');
        
        if (containsWheat) {
          print('  ⚠️ Issue: Unified search still returns wheat for rice query');
        } else {
          print('  ✅ Good: Unified search precision improved');
        }
      },
    );
    
  } catch (e) {
    print('❌ Error testing unified search: $e');
  }
}
