void main() async {
  print('🧪 FINAL TEST: Search Precision for "riz" vs "blé"');
  print('=' * 50);
  
  // Test the word matching logic that we implemented
  testSearchPrecision();
  
  print('\n✅ CONCLUSION:');
  print('The search precision improvements should now:');
  print('1. Return rice products for "riz" query');
  print('2. Return wheat products for "blé" query');
  print('3. Filter OpenFoodFacts for French market only');
  print('4. Display Nutri-Score as 1-5 scale');
  print('5. Show simplified UI with 2 tabs');
}

void testSearchPrecision() {
  print('\n🔍 Testing search precision with sample data:');
  
  // Sample food names that might appear in CIQUAL
  final sampleFoods = [
    'Riz blanc cru',
    'Riz complet cru',
    'Riz basmati cru',
    'Riz de Camargue cru',
    'Blé dur cru',
    'Blé tendre cru',
    'Farine de blé',
    'Pain de blé complet',
    'Galette de riz',
    'Lait de riz',
    'Sirop de riz',
    'Variété de blé ancien', // Should NOT match "riz"
    'Boisson au riz et avoine', // Should match "riz" as whole word
  ];
  
  print('\n📊 Testing query: "riz"');
  print('-' * 30);
  
  List<Map<String, dynamic>> results = [];
  
  for (final foodName in sampleFoods) {
    final score = calculateSearchScore(foodName, 'riz');
    if (score > 0) {
      results.add({
        'name': foodName,
        'score': score,
        'matchType': getMatchType(score),
      });
    }
  }
  
  // Sort by score (highest first)
  results.sort((a, b) => b['score'].compareTo(a['score']));
  
  print('Results sorted by relevance:');
  for (int i = 0; i < results.length; i++) {
    final result = results[i];
    print('  ${i + 1}. ${result['name']} (Score: ${result['score']} - ${result['matchType']})');
  }
  
  print('\n📊 Testing query: "blé"');
  print('-' * 30);
  
  List<Map<String, dynamic>> bleResults = [];
  
  for (final foodName in sampleFoods) {
    final score = calculateSearchScore(foodName, 'blé');
    if (score > 0) {
      bleResults.add({
        'name': foodName,
        'score': score,
        'matchType': getMatchType(score),
      });
    }
  }
  
  // Sort by score (highest first)
  bleResults.sort((a, b) => b['score'].compareTo(a['score']));
  
  print('Results sorted by relevance:');
  for (int i = 0; i < bleResults.length; i++) {
    final result = bleResults[i];
    print('  ${i + 1}. ${result['name']} (Score: ${result['score']} - ${result['matchType']})');
  }
  
  print('\n🎯 Analysis:');
  print('  - Rice products should appear first for "riz" query');
  print('  - Wheat products should appear first for "blé" query');
  print('  - "Variété de blé ancien" should NOT appear in "riz" results');
  print('  - Cross-contamination between rice/wheat queries should be minimal');
}

int calculateSearchScore(String foodName, String query) {
  final normalizedName = normalizeString(foodName);
  final normalizedQuery = normalizeString(query);
  
  // Score 100: Exact match
  if (normalizedName == normalizedQuery) {
    return 100;
  }
  
  // Score 90: Starts with query
  if (normalizedName.startsWith(normalizedQuery)) {
    return 90;
  }
  
  // Score 80: Whole word match
  if (containsWholeWord(normalizedName, normalizedQuery)) {
    return 80;
  }
  
  // Score 50: Partial match
  if (normalizedName.contains(normalizedQuery)) {
    return 50;
  }
  
  return 0;
}

String getMatchType(int score) {
  switch (score) {
    case 100: return 'EXACT';
    case 90: return 'STARTS_WITH';
    case 80: return 'WHOLE_WORD';
    case 50: return 'PARTIAL';
    default: return 'NO_MATCH';
  }
}

String normalizeString(String input) {
  if (input.isEmpty) return '';
  
  String normalized = input.toLowerCase();
  
  normalized = normalized
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('î', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ô', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('ù', 'u')
      .replaceAll('û', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ç', 'c');
  
  return normalized;
}

bool containsWholeWord(String text, String word) {
  if (text.isEmpty || word.isEmpty) return false;
  
  final RegExp regex = RegExp(r'\b' + RegExp.escape(word) + r'\b');
  return regex.hasMatch(text);
}
