// Comprehensive test to trace the "thon" search issue
// This simulates the exact app flow

import 'dart:convert';

void main() {
  print('🔍 Comprehensive "thon" search flow analysis\n');
  
  // Test 1: Simulate the exact URL and parsing the app uses
  testAppFlow();
  
  // Test 2: Check if the issue is in the logic
  testLogicFlow();
  
  // Test 3: Test different query variations
  testQueryVariations();
}

void testAppFlow() {
  print('📱 Test 1: Simulating App Flow');
  print('='.repeat(50));
  
  // Step 1: Local search (empty initially)
  print('Step 1: Local search for "thon"');
  final localResults = simulateLocalSearch('thon', []);
  print('  Local results: ${localResults.length}');
  
  // Step 2: Check if we should go remote (< 10 results)
  final shouldGoRemote = localResults.length < 10;
  print('  Should go remote: $shouldGoRemote');
  
  if (shouldGoRemote) {
    print('\nStep 2: Remote search for "thon"');
    final remoteResults = simulateRemoteSearch('thon');
    print('  Remote results: ${remoteResults.length}');
    
    if (remoteResults.isNotEmpty) {
      print('\nStep 3: Caching and returning remote results');
      print('  ❌ ISSUE: App returns raw remote results without filtering!');
      print('  Expected: Should filter remote results by query');
    }
  }
  
  print('\n');
}

void testLogicFlow() {
  print('🧠 Test 2: Logic Flow Analysis');
  print('='.repeat(50));
  
  print('Current repository logic:');
  print('1. Search local cache for "thon"');
  print('2. If < 10 results, search OpenFoodFacts API');
  print('3. Cache the results');
  print('4. ❌ Return RAW API results (not filtered by query!)');
  print('');
  print('Correct logic should be:');
  print('1. Search local cache for "thon"');
  print('2. If < 10 results, search OpenFoodFacts API');
  print('3. Cache the results');
  print('4. ✅ Apply local filtering to cached results and return filtered results');
  print('');
  print('🎯 Root cause: The app trusts that OpenFoodFacts API returns only');
  print('   relevant results, but it may return broader results that need filtering.');
  print('\n');
}

void testQueryVariations() {
  print('🌐 Test 3: Query Variations');
  print('='.repeat(50));
  
  final queries = ['thon', 'tuna', 'poisson', 'fish'];
  
  for (final query in queries) {
    print('Query: "$query"');
    final url = 'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&json=1&page_size=50';
    print('  URL: $url');
    print('  Expected: Should return products matching "$query"');
    print('  Reality: May return broader results that need client-side filtering');
    print('');
  }
}

List<String> simulateLocalSearch(String query, List<String> cachedFoods) {
  // Simulate local search with normalization
  final normalizedQuery = normalizeString(query);
  
  return cachedFoods.where((food) {
    final normalizedFood = normalizeString(food);
    return normalizedFood.contains(normalizedQuery);
  }).toList();
}

List<String> simulateRemoteSearch(String query) {
  // Simulate what OpenFoodFacts API might return
  // This is the key issue - the API might return broader results
  return [
    'Thon en conserve',
    'Thon rouge',
    'Salade de thon',
    'Pâtes au thon',
    'Pizza au thon',
    // But also potentially unrelated items that the API considers matches:
    'Poisson en général', // This might come back if API is too broad
    'Produits de la mer', // This might come back if API is too broad
  ];
}

String normalizeString(String input) {
  if (input.isEmpty) return '';
  
  String normalized = input.toLowerCase();
  
  // Remove accents (simplified version)
  normalized = normalized
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('à', 'a')
      .replaceAll('ç', 'c');
  
  return normalized;
}
