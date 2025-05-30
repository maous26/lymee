import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Testing search precision for "riz" vs "blé"...\n');
  
  // Test the word boundary logic
  testWordBoundary();
}

void testWordBoundary() {
  print('📊 Testing word boundary detection:');
  
  // Test cases for rice (riz)
  final List<String> testNames = [
    'Riz blanc cru',
    'Riz complet cru', 
    'Riz basmati cru',
    'Blé dur cru',
    'Blé tendre cru',
    'Variété de blé riziforme', // This should have lower score for "riz"
    'Riz de Camargue',
    'Sauce au blé et riz', // This should match both
    'Rizotto aux champignons', // This should have lower score for "riz"
    'Farine de riz',
  ];
  
  final String query = 'riz';
  
  print('\n🔍 Testing for query: "$query"');
  
  for (final name in testNames) {
    final normalizedName = _normalizeString(name);
    final normalizedQuery = _normalizeString(query);
    
    bool exactMatch = normalizedName == normalizedQuery;
    bool startsWithQuery = normalizedName.startsWith(normalizedQuery);
    bool wholeWordMatch = _containsWholeWord(normalizedName, normalizedQuery);
    bool partialMatch = normalizedName.contains(normalizedQuery);
    
    int score = 0;
    String matchType = '';
    
    if (exactMatch) {
      score = 100;
      matchType = 'EXACT';
    } else if (startsWithQuery) {
      score = 90;
      matchType = 'STARTS_WITH';
    } else if (wholeWordMatch) {
      score = 80;
      matchType = 'WHOLE_WORD';
    } else if (partialMatch) {
      score = 50;
      matchType = 'PARTIAL';
    }
    
    if (score > 0) {
      print('  ✅ $name → Score: $score ($matchType)');
    } else {
      print('  ❌ $name → No match');
    }
  }
  
  print('\n📈 Analysis:');
  print('  - "Riz blanc cru" should get high score (STARTS_WITH or WHOLE_WORD)');
  print('  - "Blé dur cru" should NOT match');
  print('  - "Rizotto aux champignons" should get lower score (PARTIAL)');
  print('  - "Variété de blé riziforme" should get lower score (PARTIAL)');
}

String _normalizeString(String input) {
  if (input.isEmpty) return '';
  
  // Conversion en minuscules
  String normalized = input.toLowerCase();
  
  // Suppression des accents
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

bool _containsWholeWord(String text, String word) {
  if (text.isEmpty || word.isEmpty) return false;
  
  // Utilise des délimiteurs de mots (espaces, ponctuation, etc.)
  final RegExp regex = RegExp(r'\b' + RegExp.escape(word) + r'\b');
  return regex.hasMatch(text);
}
