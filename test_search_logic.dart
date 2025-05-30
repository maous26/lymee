#!/usr/bin/env dart
// Simple test for unified search

void main() async {
  print('🧪 Testing Search Logic\n');

  // Test the search logic patterns
  print('Testing search query patterns:');

  final queries = ['tomate', 'sauce tomate', 'sauce', 'thon', 'pizza saumon'];

  for (String query in queries) {
    final words = query.toLowerCase().trim().split(RegExp(r'\s+'));
    print('Query: "$query" -> Words: $words (${words.length} words)');

    if (words.length == 1) {
      print('  -> Single word search - prioritize basic products');

      if (_isGeneralTerm(query)) {
        print('  -> General term detected - also search processed foods');
      }
    } else {
      print('  -> Multi-word search - look for specific combinations');
    }
    print('');
  }

  print('✅ Search logic test completed!');
}

bool _isGeneralTerm(String query) {
  final generalTerms = [
    'sauce',
    'pizza',
    'pain',
    'pâtes',
    'riz',
    'soupe',
    'salade',
    'fromage',
    'yaourt',
    'biscuit',
    'chocolat',
    'gâteau',
    'tarte',
    'jus',
    'boisson',
    'thé',
    'café',
    'eau',
    'lait'
  ];

  return generalTerms.any((term) =>
      query.toLowerCase().contains(term) || term.contains(query.toLowerCase()));
}
