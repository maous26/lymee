// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Tracing search flow for "thon"...\n');

  // Test 1: Direct OpenFoodFacts API call
  await testDirectAPI();

  // Test 2: Check URL construction
  testURLConstruction();

  // Test 3: Test the search terms in different languages
  await testMultiLanguageSearch();
}

Future<void> testDirectAPI() async {
  print('📡 Test 1: Direct OpenFoodFacts API call');

  const query = 'thon';
  final url =
      'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&json=1&page_size=50';

  print('  URL: $url');

  try {
    final client = http.Client();
    final response = await client.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'LymNutrition - Android - Version 1.0',
      },
    );

    print('  Status Code: ${response.statusCode}');
    print('  Response length: ${response.body.length} characters');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('  JSON keys: ${jsonData.keys.toList()}');

      if (jsonData.containsKey('products')) {
        final products = jsonData['products'] as List;
        print('  Found ${products.length} products');

        if (products.isNotEmpty) {
          print('  First product:');
          final firstProduct = products[0];
          print('    Product name: ${firstProduct['product_name'] ?? 'N/A'}');
          print(
              '    Product name fr: ${firstProduct['product_name_fr'] ?? 'N/A'}');
          print('    Brands: ${firstProduct['brands'] ?? 'N/A'}');
          print('    Categories: ${firstProduct['categories'] ?? 'N/A'}');
        }
      }
    }

    client.close();
  } catch (e) {
    print('  ❌ Error: $e');
  }

  print('');
}

void testURLConstruction() {
  print('🔧 Test 2: URL Construction');

  const queries = ['thon', 'tuna', 'poisson', 'fish'];

  for (final query in queries) {
    final encodedQuery = Uri.encodeComponent(query);
    final url =
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$encodedQuery&json=1&page_size=50';
    print('  Query: "$query" -> Encoded: "$encodedQuery"');
    print('  Full URL: $url');
  }

  print('');
}

Future<void> testMultiLanguageSearch() async {
  print('🌐 Test 3: Multi-language search');

  const searchTerms = ['thon', 'tuna', 'atun', 'tonno'];

  for (final term in searchTerms) {
    print('  Testing term: "$term"');

    try {
      final url =
          'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(term)}&json=1&page_size=10';
      final client = http.Client();
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'LymNutrition - Android - Version 1.0',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData.containsKey('products')) {
          final products = jsonData['products'] as List;
          print('    Found ${products.length} products');

          // Show first few product names
          for (int i = 0; i < products.length && i < 3; i++) {
            final product = products[i];
            final name = product['product_name'] ??
                product['product_name_fr'] ??
                'Unknown';
            print('      ${i + 1}. $name');
          }
        }
      }

      client.close();
    } catch (e) {
      print('    ❌ Error: $e');
    }

    print('');
  }
}
