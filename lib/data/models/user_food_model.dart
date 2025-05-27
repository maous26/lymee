// lib/data/models/user_food_model.dart
import 'package:lym_nutrition/domain/entities/food_item.dart';

class UserFoodModel extends FoodItem {
  final String userId;
  final DateTime createdAt;
  final String? description;
  final String? originType; // 'manual', 'voice', 'photo', 'receipt'

  UserFoodModel({
    required String id,
    required String name,
    required String category,
    required bool isProcessed,
    required double calories,
    required double proteins,
    required double carbs,
    required double fats,
    required double sugar,
    required double fiber,
    required Map<String, dynamic> nutrients,
    required String imageUrl,
    String? brand,
    required this.userId,
    required this.createdAt,
    this.description,
    this.originType,
    required double nutritionScore,
  }) : super(
         id: id,
         name: name,
         category: category,
         isProcessed: isProcessed,
         calories: calories,
         proteins: proteins,
         carbs: carbs,
         fats: fats,
         sugar: sugar,
         fiber: fiber,
         nutrients: nutrients,
         imageUrl: imageUrl,
         source: 'user',
         brand: brand,
         nutritionScore: nutritionScore,
       );

  factory UserFoodModel.fromJson(Map<String, dynamic> json) {
    return UserFoodModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      isProcessed: json['isProcessed'] ?? false,
      calories: json['calories']?.toDouble() ?? 0.0,
      proteins: json['proteins']?.toDouble() ?? 0.0,
      carbs: json['carbs']?.toDouble() ?? 0.0,
      fats: json['fats']?.toDouble() ?? 0.0,
      sugar: json['sugar']?.toDouble() ?? 0.0,
      fiber: json['fiber']?.toDouble() ?? 0.0,
      nutrients: json['nutrients'] ?? {},
      imageUrl: json['imageUrl'] ?? '',
      brand: json['brand'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'],
      originType: json['originType'],
      nutritionScore: json['nutritionScore']?.toDouble() ?? 50.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'isProcessed': isProcessed,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'sugar': sugar,
      'fiber': fiber,
      'nutrients': nutrients,
      'imageUrl': imageUrl,
      'brand': brand,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'originType': originType,
      'source': 'user',
      'nutritionScore': nutritionScore,
    };
  }
}
