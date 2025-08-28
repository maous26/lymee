// Debug script to test the entire OpenFoodFacts flow

// Simple debug test to verify the OpenFoodFacts parsing logic
void main() {
  print('Testing OpenFoodFacts JSON parsing...');

  // Simulate a response from OpenFoodFacts API
  final mockApiResponse = {
    "products": [
      {
        "code": "3256220881081",
        "product_name": "Thon au naturel",
        "brands": "Petit Navire",
        "categories_tags": ["en:fish", "en:tuna"],
        "image_url": "https://example.com/image.jpg",
        "nutriments": {
          "energy-kcal_100g": 116,
          "proteins_100g": 26.5,
          "carbohydrates_100g": 0,
          "fat_100g": 1.0,
          "sugars_100g": 0,
          "fiber_100g": 0
        },
        "nutriscore_grade": "a",
        "ingredients_tags": ["en:tuna", "en:water"],
        "allergens_tags": ["en:fish"]
      }
    ]
  };

  print('Mock API response created');

  // Test the parsing logic exactly as done in the app
  if (mockApiResponse.containsKey('products')) {
    final List<dynamic> products =
        List<dynamic>.from(mockApiResponse['products'] as List);
    print('Found ${products.length} products');

    if (products.isNotEmpty) {
      for (int i = 0; i < products.length; i++) {
        final product = products[i];
        print('\n--- Product $i ---');

        // Test the wrapping logic from remote data source
        final wrappedProduct = {'product': product};
        print('Created wrapped product');

        // Test the fromJson logic from OpenFoodFactsFoodModel
        try {
          final productData = wrappedProduct['product'] ?? wrappedProduct;
          final nutrients = productData['nutriments'] ?? {};
          final imageUrl = productData['image_url'] ?? '';

          final barcode = productData['code'] ?? productData['_id'] ?? '';
          final name = productData['product_name'] ?? '';
          final category = productData['categories_tags']?.isNotEmpty == true
              ? productData['categories_tags'][0]
              : 'Non catégorisé';
          final brand = productData['brands'] ?? '';
          final calories = _getDoubleValue(nutrients, 'energy-kcal_100g') ?? 0;
          final proteins = _getDoubleValue(nutrients, 'proteins_100g') ?? 0;
          final carbs = _getDoubleValue(nutrients, 'carbohydrates_100g') ?? 0;
          final fats = _getDoubleValue(nutrients, 'fat_100g') ?? 0;
          final sugar = _getDoubleValue(nutrients, 'sugars_100g') ?? 0;
          final fiber = _getDoubleValue(nutrients, 'fiber_100g') ?? 0;

          print('Successfully parsed:');
          print('  Barcode: $barcode');
          print('  Name: $name');
          print('  Category: $category');
          print('  Brand: $brand');
          print('  Calories: $calories');
          print('  Proteins: $proteins');
          print('  Carbs: $carbs');
          print('  Fats: $fats');
          print('  Sugar: $sugar');
          print('  Fiber: $fiber');
          print('  Image URL: $imageUrl');

          // Test the search filtering logic
          const query = 'thon';
          final normalizedQuery = _normalizeString(query);
          final normalizedName = _normalizeString(name);
          final normalizedCategory = _normalizeString(category);

          final matchesQuery = normalizedName.contains(normalizedQuery) ||
              normalizedCategory.contains(normalizedQuery);

          print('  Query: $query');
          print('  Normalized query: $normalizedQuery');
          print('  Normalized name: $normalizedName');
          print('  Normalized category: $normalizedCategory');
          print('  Matches query: $matchesQuery');
        } catch (e) {
          print('Error parsing product: $e');
        }
      }
    }
  } else {
    print('No products key found in mock response');
  }
}

// Helper function from the original code
double? _getDoubleValue(Map<String, dynamic> map, String key) {
  if (map[key] == null) return null;

  if (map[key] is String) {
    return double.tryParse(map[key]);
  }

  return (map[key] as num).toDouble();
}

// Helper function from the original code
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
