// Test OpenFoodFacts API using http package
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  await testOpenFoodFactsHTTP();
}

Future<void> testOpenFoodFactsHTTP() async {
  final client = http.Client();
  
  try {
    // Test exactly as the app does it
    final query = 'thon';
    final url = 'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&json=1&page_size=5';
    
    print('Testing URL: $url');
    
    final response = await client.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'LymNutrition - Android - Version 1.0',
      },
    );
    
    print('Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('Response length: ${response.body.length}');
      
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        print('JSON parsed successfully');
        print('Keys in response: ${data.keys.toList()}');
        
        if (data.containsKey('products')) {
          final List<dynamic> products = data['products'];
          print('Found ${products.length} products');
          
          if (products.isNotEmpty) {
            print('\nFirst product:');
            final firstProduct = products[0];
            print('Name: ${firstProduct['product_name']}');
            print('Brand: ${firstProduct['brands']}');
            print('Code: ${firstProduct['code']}');
            
            // Test parsing as app would do
            final productWrapped = {'product': firstProduct};
            final product = productWrapped['product'] ?? productWrapped;
            
            final barcode = product['code'] ?? product['_id'] ?? '';
            final name = product['product_name'] ?? '';
            final brand = product['brands'] ?? '';
            
            print('\nParsed by app logic:');
            print('Barcode: $barcode');
            print('Name: $name');
            print('Brand: $brand');
            
            // Check if name/brand contains expected terms
            final normalizedName = name.toLowerCase();
            final normalizedBrand = brand.toLowerCase();
            
            print('Contains "thon": ${normalizedName.contains('thon') || normalizedBrand.contains('thon')}');
          }
        } else {
          print('No "products" key found');
        }
      } catch (e) {
        print('JSON parsing error: $e');
        print('Response body: ${response.body.substring(0, 200)}...');
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
