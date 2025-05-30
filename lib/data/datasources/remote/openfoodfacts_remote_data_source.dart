// lib/data/datasources/remote/openfoodfacts_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lym_nutrition/data/models/openfoodfacts_food_model.dart';
import 'package:lym_nutrition/core/error/exceptions.dart';

abstract class OpenFoodFactsRemoteDataSource {
  /// Recherche des aliments dans l'API OpenFoodFacts
  ///
  /// Retourne une liste de [OpenFoodFactsFoodModel]
  ///
  /// Lance [ServerException] en cas d'erreur
  Future<List<OpenFoodFactsFoodModel>> searchFoods(String query,
      {String? brand});

  /// Récupère un aliment par son code-barres
  ///
  /// Retourne un [OpenFoodFactsFoodModel]
  ///
  /// Lance [ServerException] en cas d'erreur
  Future<OpenFoodFactsFoodModel> getFoodByBarcode(String barcode);
}

class OpenFoodFactsRemoteDataSourceImpl
    implements OpenFoodFactsRemoteDataSource {
  final http.Client client;

  OpenFoodFactsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<OpenFoodFactsFoodModel>> searchFoods(String query,
      {String? brand}) async {
    // Construction de l'URL de recherche avec filtre pour le marché français
    String url =
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&json=1&page_size=50&countries=france';

    // Ajout du filtre par marque si spécifié
    if (brand != null && brand.isNotEmpty) {
      url += '&brands=${Uri.encodeComponent(brand)}';
    }

    // Debug logging
    print('🔍 OpenFoodFacts API Call:');
    print('  Query: "$query"');
    print('  Brand: ${brand ?? "none"}');
    print('  URL: $url');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'LymNutrition - Android - Version 1.0',
        },
      );

      print('📡 API Response:');
      print('  Status Code: ${response.statusCode}');
      print('  Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        print('📦 JSON Data:');
        print('  Keys: ${data.keys.toList()}');

        if (data.containsKey('products')) {
          final List<dynamic> products = data['products'];
          print('  Products found: ${products.length}');

          if (products.isNotEmpty) {
            print('  First product sample:');
            final firstProduct = products[0];
            print('    Name: ${firstProduct['product_name']}');
            print('    Brand: ${firstProduct['brands']}');
            print('    Code: ${firstProduct['code']}');
          }

          final List<OpenFoodFactsFoodModel> parsedProducts = [];
          int successCount = 0;
          int errorCount = 0;

          for (int i = 0; i < products.length; i++) {
            try {
              final model =
                  OpenFoodFactsFoodModel.fromJson({'product': products[i]});
              parsedProducts.add(model);
              successCount++;
            } catch (e) {
              errorCount++;
              print('  ⚠️ Error parsing product $i: $e');
              if (i < 3) {
                // Only log first few errors to avoid spam
                print('    Product data: ${products[i]}');
              }
            }
          }

          print('  ✅ Successfully parsed: $successCount products');
          print('  ❌ Failed to parse: $errorCount products');
          print('  🎯 Final result: ${parsedProducts.length} products');

          return parsedProducts;
        } else {
          print('  ❌ No "products" key found in response');
          return [];
        }
      } else {
        print('  ❌ HTTP Error: ${response.statusCode}');
        throw ServerException(
            'Erreur lors de la recherche: ${response.statusCode}');
      }
    } catch (e) {
      print('  💥 Exception: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<OpenFoodFactsFoodModel> getFoodByBarcode(String barcode) async {
    try {
      final response = await client.get(
        Uri.parse(
            'https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
        headers: {
          'User-Agent': 'LymNutrition - Android - Version 1.0',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 1) {
          return OpenFoodFactsFoodModel.fromJson(data);
        } else {
          throw ServerException('Produit non trouvé');
        }
      } else {
        throw ServerException(
            'Erreur lors de la récupération: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
