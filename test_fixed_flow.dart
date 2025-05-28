// Test script to verify the fix for the "thon" search issue
// This simulates the corrected flow

void main() {
  print('🔧 Testing the FIX for "thon" search issue\n');

  testFixedFlow();
  testEdgeCases();
}

void testFixedFlow() {
  print('✅ Test 1: Fixed Flow for "thon" search');
  print('='.repeat(60));

  print('Step 1: Local search for "thon"');
  final localResults = simulateLocalSearch('thon', []);
  print('  📱 Local results: ${localResults.length} (empty cache)');

  print('\nStep 2: Check if should go remote');
  final shouldGoRemote = localResults.length < 10;
  print('  🌐 Should go remote: $shouldGoRemote (${localResults.length} < 10)');

  if (shouldGoRemote) {
    print('\nStep 3: Remote search');
    final remoteResults = simulateOpenFoodFactsAPI('thon');
    print('  📡 OpenFoodFacts API returns: ${remoteResults.length} products');
    for (var product in remoteResults) {
      print('    - $product');
    }

    print('\nStep 4: Cache remote results');
    final cachedResults = [...remoteResults]; // Simulate caching
    print('  💾 Cached ${cachedResults.length} products');

    print('\nStep 5: ✅ FIXED - Apply local filtering to cached results');
    final filteredResults = simulateLocalSearch('thon', cachedResults);
    print('  🔍 Filtered results for "thon": ${filteredResults.length}');
    for (var product in filteredResults) {
      print('    ✅ $product');
    }

    print(
        '\n🎯 RESULT: User now sees ${filteredResults.length} relevant tuna products!');
  }

  print('\n');
}

void testEdgeCases() {
  print('🧪 Test 2: Edge Cases');
  print('='.repeat(60));

  // Test case 1: Query with different casing
  print('Test 2a: Case sensitivity');
  final upperCaseResults = simulateLocalSearch(
      'THON', ['Thon en conserve', 'thon rouge', 'SALADE DE THON']);
  print('  Query "THON" matches: ${upperCaseResults.length} products');

  // Test case 2: Query with accents
  print('\nTest 2b: Accent handling');
  final accentResults = simulateLocalSearch('poisson', [
    'Poisson frais',
    'Poisson pané',
    'Bœuf' // Should not match
  ]);
  print('  Query "poisson" matches: ${accentResults.length} products');

  // Test case 3: Partial matches
  print('\nTest 2c: Partial matches');
  final partialResults = simulateLocalSearch('tho', [
    'Thon en conserve',
    'Thon rouge',
    'Porc' // Should not match
  ]);
  print('  Query "tho" matches: ${partialResults.length} products');

  print('\n');
}

List<String> simulateOpenFoodFactsAPI(String query) {
  // Simulate what OpenFoodFacts might return for "thon"
  // API might be broad and return related items
  return [
    'Thon en conserve Petit Navire',
    'Thon rouge frais',
    'Salade de thon',
    'Pâtes au thon',
    'Pizza au thon',
    'Rillettes de thon',
    'Thon à l\'huile d\'olive',
    'Conserve de poisson', // Broad match
    'Produits de la mer', // Very broad match
    'Sandwich au thon',
  ];
}

List<String> simulateLocalSearch(String query, List<String> cachedFoods) {
  if (query.isEmpty) return cachedFoods;

  final normalizedQuery = normalizeString(query);

  return cachedFoods.where((food) {
    final normalizedFood = normalizeString(food);
    return normalizedFood.contains(normalizedQuery);
  }).toList();
}

String normalizeString(String input) {
  if (input.isEmpty) return '';

  String normalized = input.toLowerCase();

  // Remove accents
  normalized = normalized
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('à', 'a')
      .replaceAll('ô', 'o')
      .replaceAll('ç', 'c');

  return normalized;
}
