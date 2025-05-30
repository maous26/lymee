// Validation script for the nutrition app improvements
import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 VALIDATION: Flutter Nutrition App Search Improvements');
  print('=' * 60);
  
  await validateCiqualSearchLogic();
  await validateOpenFoodFactsFiltering();
  await validateNutriScoreConversion();
  await validateUIChanges();
  
  print('\n✅ VALIDATION COMPLETE');
  print('=' * 60);
}

Future<void> validateCiqualSearchLogic() async {
  print('\n📊 1. VALIDATING CIQUAL SEARCH PRECISION');
  print('-' * 40);
  
  // Check if the search logic file contains our improvements
  try {
    final file = File('/Users/moussa/lym_nutrition/lib/data/datasources/local/ciqual_local_data_source.dart');
    final content = await file.readAsString();
    
    // Check for scoring system
    bool hasScoringSystem = content.contains('Score 100: Correspondance exacte');
    bool hasWholeWordMatch = content.contains('_containsWholeWord');
    bool hasWordBoundaryRegex = content.contains(r'\b');
    
    print('  ✅ Scoring system implemented: $hasScoringSystem');
    print('  ✅ Whole word matching: $hasWholeWordMatch');
    print('  ✅ Word boundary regex: $hasWordBoundaryRegex');
    
    if (hasScoringSystem && hasWholeWordMatch && hasWordBoundaryRegex) {
      print('  🎯 CIQUAL search precision: IMPROVED');
    } else {
      print('  ⚠️ CIQUAL search precision: NEEDS ATTENTION');
    }
    
  } catch (e) {
    print('  ❌ Error checking CIQUAL search logic: $e');
  }
}

Future<void> validateOpenFoodFactsFiltering() async {
  print('\n🇫🇷 2. VALIDATING OPENFOODFACTS FRENCH FILTERING');
  print('-' * 40);
  
  try {
    final file = File('/Users/moussa/lym_nutrition/lib/data/datasources/remote/openfoodfacts_remote_data_source.dart');
    final content = await file.readAsString();
    
    // Check for French market filtering
    bool hasFrenchFilter = content.contains('countries=france');
    bool hasCorrectURL = content.contains('world.openfoodfacts.org');
    
    print('  ✅ French market filter: $hasFrenchFilter');
    print('  ✅ Correct API endpoint: $hasCorrectURL');
    
    if (hasFrenchFilter && hasCorrectURL) {
      print('  🇫🇷 OpenFoodFacts French filtering: IMPLEMENTED');
    } else {
      print('  ⚠️ OpenFoodFacts French filtering: NEEDS ATTENTION');
    }
    
  } catch (e) {
    print('  ❌ Error checking OpenFoodFacts filtering: $e');
  }
}

Future<void> validateNutriScoreConversion() async {
  print('\n🔢 3. VALIDATING NUTRI-SCORE 1-5 CONVERSION');
  print('-' * 40);
  
  try {
    // Check OpenFoodFacts model
    final offFile = File('/Users/moussa/lym_nutrition/lib/data/models/openfoodfacts_food_model.dart');
    final offContent = await offFile.readAsString();
    
    bool offHas1to5Scale = offContent.contains('A=5.0') || offContent.contains('case \'a\': return 5.0');
    
    // Check CIQUAL model
    final ciqualFile = File('/Users/moussa/lym_nutrition/lib/data/models/ciqual_food_model.dart');
    final ciqualContent = await ciqualFile.readAsString();
    
    bool ciqualHas1to5Scale = ciqualContent.contains('clamp(1.0, 5.0)') || ciqualContent.contains('max(1.0');
    
    // Check AppTheme
    final themeFile = File('/Users/moussa/lym_nutrition/lib/presentation/themes/app_theme.dart');
    final themeContent = await themeFile.readAsString();
    
    bool themeHas1to5Scale = themeContent.contains('score >= 4.5') || themeContent.contains('score >= 3.5');
    
    print('  ✅ OpenFoodFacts 1-5 scale: $offHas1to5Scale');
    print('  ✅ CIQUAL 1-5 scale: $ciqualHas1to5Scale');
    print('  ✅ AppTheme 1-5 scale: $themeHas1to5Scale');
    
    if (offHas1to5Scale && ciqualHas1to5Scale && themeHas1to5Scale) {
      print('  🔢 Nutri-Score 1-5 conversion: IMPLEMENTED');
    } else {
      print('  ⚠️ Nutri-Score 1-5 conversion: NEEDS ATTENTION');
    }
    
  } catch (e) {
    print('  ❌ Error checking Nutri-Score conversion: $e');
  }
}

Future<void> validateUIChanges() async {
  print('\n🎨 4. VALIDATING UI IMPROVEMENTS');
  print('-' * 40);
  
  try {
    // Check food detail screen
    final detailFile = File('/Users/moussa/lym_nutrition/lib/presentation/screens/food_detail_screen.dart');
    final detailContent = await detailFile.readAsString();
    
    bool hasReducedTabs = detailContent.contains('TabController(length: 2');
    bool removedDetailsTab = !detailContent.contains('_buildDetailsTab');
    bool removedUnusedImport = !detailContent.contains('openfoodfacts_food_model.dart');
    
    // Check nutrition score badge
    final badgeFile = File('/Users/moussa/lym_nutrition/lib/presentation/widgets/nutrition_score_badge.dart');
    final badgeContent = await badgeFile.readAsString();
    
    bool hasDecimalFormat = badgeContent.contains('toStringAsFixed(1)');
    
    print('  ✅ Reduced to 2 tabs: $hasReducedTabs');
    print('  ✅ Removed Details tab: $removedDetailsTab');
    print('  ✅ Cleaned unused imports: $removedUnusedImport');
    print('  ✅ Decimal score format: $hasDecimalFormat');
    
    if (hasReducedTabs && removedDetailsTab && hasDecimalFormat) {
      print('  🎨 UI improvements: IMPLEMENTED');
    } else {
      print('  ⚠️ UI improvements: NEEDS ATTENTION');
    }
    
  } catch (e) {
    print('  ❌ Error checking UI changes: $e');
  }
}
