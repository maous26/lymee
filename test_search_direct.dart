import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Testing search components for "thon"...\n');

  // Test the exact URL that the app uses
  await testOpenFoodFactsAPI();
}

Future<void> testOpenFoodFactsAPI() async {
  print('📡 Testing OpenFoodFacts API with app configuration');

  const query = 'thon';
  final url =
      'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&json=1&page_size=50';

  print('Query: "$query"');
  print('URL: $url\n');

  final httpClient = HttpClient();

  try {
    final request = await httpClient.getUrl(Uri.parse(url));
    request.headers.add('User-Agent', 'LymNutrition - Android - Version 1.0');

    final response = await request.close();
    print('Status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Response length: ${responseBody.length} characters');

      try {
        final jsonData = jsonDecode(responseBody);
        print('JSON structure: ${jsonData.keys.toList()}');

        if (jsonData.containsKey('products')) {
          final products = jsonData['products'] as List;
          print('Total products found: ${products.length}');

          if (products.isNotEmpty) {
            print('\nFirst 5 products:');
            for (int i = 0; i < products.length && i < 5; i++) {
              final product = products[i];
              print(
                  '${i + 1}. ${product['product_name'] ?? product['product_name_fr'] ?? 'No name'}');
              print('   Brands: ${product['brands'] ?? 'No brand'}');
              print(
                  '   Categories: ${product['categories'] ?? 'No categories'}');

              // Test the JSON structure that our parser expects
              final hasRequiredFields = product.containsKey('code') &&
                  (product.containsKey('product_name') ||
                      product.containsKey('product_name_fr'));
              print('   Has required fields for parsing: $hasRequiredFields');

              if (product.containsKey('nutriments')) {
                print('   Has nutriments: true');
              }

              print('');
            }

            // Test if we can wrap it in the expected format
            print('Testing JSON wrapping:');
            final firstProduct = products[0];
            final wrappedProduct = {'product': firstProduct};
            print('Wrapped product keys: ${wrappedProduct.keys.toList()}');
            print(
                'Wrapped product[\'product\'] keys: ${wrappedProduct['product'].keys.toList()}');
          }
        } else {
          print('❌ No "products" key found in response');
          print('Available keys: ${jsonData.keys.toList()}');
        }
      } catch (e) {
        print('❌ JSON parsing error: $e');
        print('Response preview: ${responseBody.substring(0, 500)}...');
      }
    } else {
      print('❌ HTTP error: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Request error: $e');
  } finally {
    httpClient.close();
  }
}
