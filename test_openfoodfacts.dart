// Test script to debug OpenFoodFacts API integration
import 'dart:convert';
import 'dart:io';

void main() async {
  await testOpenFoodFactsAPI();
}

Future<void> testOpenFoodFactsAPI() async {
  final client = HttpClient();

  try {
    // Test exactly as the app does it
    final query = 'thon';
    final url =
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&json=1&page_size=5';

    print('Testing URL: $url');

    final uri = Uri.parse(url);
    final request = await client.getUrl(uri);
    request.headers.add('User-Agent', 'LymNutrition - Android - Version 1.0');

    final response = await request.close();

    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final String responseBody = await response.transform(utf8.decoder).join();
      print('Response length: ${responseBody.length}');

      try {
        final Map<String, dynamic> data = json.decode(responseBody);
        print('JSON parsed successfully');
        print('Keys in response: ${data.keys.toList()}');

        if (data.containsKey('products')) {
          final List<dynamic> products = data['products'];
          print('Found ${products.length} products');

          if (products.isNotEmpty) {
            print('\nFirst product structure:');
            final firstProduct = products[0];
            print('Product keys: ${firstProduct.keys.toList()}');
            print('Product name: ${firstProduct['product_name']}');
            print('Brands: ${firstProduct['brands']}');
            print('Code: ${firstProduct['code']}');
            print('Categories: ${firstProduct['categories_tags']}');

            // Test the JSON parsing as the app would do it
            try {
              print('\nTesting app\'s JSON parsing...');
              final productWithWrapper = {'product': firstProduct};
              print(
                  'Wrapped product keys: ${productWithWrapper.keys.toList()}');

              // Simulate the OpenFoodFactsFoodModel.fromJson logic
              final product =
                  productWithWrapper['product'] ?? productWithWrapper;
              final nutrients = product['nutriments'] ?? {};
              final imageUrl = product['image_url'] ?? '';

              print('Product after unwrapping: ${product['product_name']}');
              print('Nutrients keys: ${nutrients.keys.toList()}');
              print('Image URL: $imageUrl');

              final barcode = product['code'] ?? product['_id'] ?? '';
              final name = product['product_name'] ?? '';
              final category = product['categories_tags']?.isNotEmpty == true
                  ? product['categories_tags'][0]
                  : 'Non catégorisé';
              final brand = product['brands'] ?? '';

              print('\nParsed values:');
              print('Barcode: $barcode');
              print('Name: $name');
              print('Category: $category');
              print('Brand: $brand');
            } catch (e) {
              print('Error in app\'s JSON parsing: $e');
            }
          }
        } else {
          print('No "products" key found in response');
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        print(
            'Response body (first 500 chars): ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}');
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Network error: $e');
  } finally {
    client.close();
  }
}
