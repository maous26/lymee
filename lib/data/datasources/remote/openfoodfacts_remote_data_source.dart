// lib/data/datasources/remote/openfoodfacts_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lym_nutrition/data/models/openfoodfacts_food_model.dart';
import 'package:lym_nutrition/core/error/exceptions.dart';
import 'package:lym_nutrition/core/util/rate_limiter.dart';

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

  // Rate limiters conformes à la documentation OFF
  static final RateLimiter _searchRateLimiter = RateLimiter.forSearch();
  static final RateLimiter _productRateLimiter = RateLimiter.forProduct();

  OpenFoodFactsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<OpenFoodFactsFoodModel>> searchFoods(String query,
      {String? brand}) async {
    // Construction de l'URL de recherche optimisée pour le marché français
    // Selon la documentation OFF: https://openfoodfacts.github.io/openfoodfacts-server/api/
    String url = 'https://world.openfoodfacts.org/cgi/search.pl?'
        'search_terms=${Uri.encodeComponent(query)}&'
        'json=1&'
        'page_size=50&'
        'sort_by=popularity&'
        'tagtype_0=countries&tag_contains_0=contains&tag_0=france';

    // Ajout du filtre par marque si spécifié - méthode optimisée selon la doc OFF
    if (brand != null && brand.isNotEmpty) {
      // Utilisation de la syntaxe recommandée pour les marques
      url +=
          '&tagtype_1=brands&tag_contains_1=contains&tag_1=${Uri.encodeComponent(brand)}';

      // Amélioration de la recherche en combinant marque et produit
      if (query.isNotEmpty) {
        url = url.replaceFirst('search_terms=${Uri.encodeComponent(query)}',
            'search_terms=${Uri.encodeComponent('$query $brand')}');
      } else {
        url = url.replaceFirst(
            'search_terms=', 'search_terms=${Uri.encodeComponent(brand)}');
      }
    }

    // Debug logging
    print('🔍 OpenFoodFacts API Call:');
    print('  Query: "$query"');
    print('  Brand: ${brand ?? "none"}');
    print('  URL: $url');

    try {
      // Respect des limites de taux OFF: 10 req/min pour les recherches
      final response = await _searchRateLimiter.execute(() async {
        return client.get(
          Uri.parse(url),
          headers: {
            // Conforme à la documentation OFF: AppName/Version (ContactEmail)
            'User-Agent': 'LymNutrition/1.0 (lym.nutrition.app@gmail.com)',
            'Accept': 'application/json',
            'Accept-Language': 'fr-FR,fr;q=0.9,en;q=0.8',
          },
        );
      });

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
      // Respect des limites de taux OFF: 100 req/min pour les produits
      final response = await _productRateLimiter.execute(() async {
        return client.get(
          Uri.parse(
              'https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
          headers: {
            // Conforme à la documentation OFF: AppName/Version (ContactEmail)
            'User-Agent': 'LymNutrition/1.0 (lym.nutrition.app@gmail.com)',
            'Accept': 'application/json',
            'Accept-Language': 'fr-FR,fr;q=0.9,en;q=0.8',
          },
        );
      });

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
