import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lym_nutrition/domain/entities/community_recipe.dart';
import 'package:flutter/foundation.dart';

class CommunityRecipesService {
  static const String _recipesKey = 'community_recipes';
  static const String _userIdKey = 'current_user_id';
  static const String _userNameKey = 'current_user_name';

  /// Obtient toutes les recettes communautaires
  static Future<List<CommunityRecipe>> getAllRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = prefs.getString(_recipesKey);
      
      if (recipesJson == null) return [];
      
      final List<dynamic> recipesList = jsonDecode(recipesJson);
      return recipesList
          .map((json) => CommunityRecipe.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des recettes: $e');
      return [];
    }
  }

  /// Sauvegarde une nouvelle recette
  static Future<bool> saveRecipe(CommunityRecipe recipe) async {
    try {
      final recipes = await getAllRecipes();
      recipes.add(recipe);
      
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = jsonEncode(recipes.map((r) => r.toJson()).toList());
      
      await prefs.setString(_recipesKey, recipesJson);
      debugPrint('✅ Recette sauvegardée: ${recipe.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde: $e');
      return false;
    }
  }

  /// Met à jour une recette existante
  static Future<bool> updateRecipe(CommunityRecipe updatedRecipe) async {
    try {
      final recipes = await getAllRecipes();
      final index = recipes.indexWhere((r) => r.id == updatedRecipe.id);
      
      if (index == -1) return false;
      
      recipes[index] = updatedRecipe;
      
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = jsonEncode(recipes.map((r) => r.toJson()).toList());
      
      await prefs.setString(_recipesKey, recipesJson);
      debugPrint('✅ Recette mise à jour: ${updatedRecipe.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour: $e');
      return false;
    }
  }

  /// Supprime une recette
  static Future<bool> deleteRecipe(String recipeId) async {
    try {
      final recipes = await getAllRecipes();
      recipes.removeWhere((r) => r.id == recipeId);
      
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = jsonEncode(recipes.map((r) => r.toJson()).toList());
      
      await prefs.setString(_recipesKey, recipesJson);
      debugPrint('✅ Recette supprimée: $recipeId');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression: $e');
      return false;
    }
  }

  /// Obtient une recette par ID
  static Future<CommunityRecipe?> getRecipeById(String recipeId) async {
    final recipes = await getAllRecipes();
    try {
      return recipes.firstWhere((r) => r.id == recipeId);
    } catch (e) {
      return null;
    }
  }

  /// Obtient les recettes d'un utilisateur spécifique
  static Future<List<CommunityRecipe>> getUserRecipes(String userId) async {
    final recipes = await getAllRecipes();
    return recipes.where((r) => r.authorId == userId).toList();
  }

  /// Ajoute une note à une recette
  static Future<bool> addRating(String recipeId, RecipeRating rating) async {
    try {
      final recipe = await getRecipeById(recipeId);
      if (recipe == null) return false;

      // Supprimer l'ancienne note de cet utilisateur s'il y en a une
      final updatedRatings = recipe.ratings
          .where((r) => r.userId != rating.userId)
          .toList()
        ..add(rating);

      // Recalculer la moyenne
      final averageRating = updatedRatings.isEmpty
          ? 0.0
          : updatedRatings.map((r) => r.rating).reduce((a, b) => a + b) / updatedRatings.length;

      final updatedRecipe = recipe.copyWith(
        ratings: updatedRatings,
        averageRating: averageRating,
        ratingsCount: updatedRatings.length,
        updatedAt: DateTime.now(),
      );

      return await updateRecipe(updatedRecipe);
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'ajout de la note: $e');
      return false;
    }
  }

  /// Ajoute un commentaire à une recette
  static Future<bool> addComment(String recipeId, RecipeComment comment) async {
    try {
      final recipe = await getRecipeById(recipeId);
      if (recipe == null) return false;

      final updatedComments = [...recipe.comments, comment];

      final updatedRecipe = recipe.copyWith(
        comments: updatedComments,
        commentsCount: updatedComments.length,
        updatedAt: DateTime.now(),
      );

      return await updateRecipe(updatedRecipe);
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'ajout du commentaire: $e');
      return false;
    }
  }

  /// Like/Unlike une recette
  static Future<bool> toggleLike(String recipeId, String userId) async {
    try {
      final recipe = await getRecipeById(recipeId);
      if (recipe == null) return false;

      // Pour simplicité, on stocke les likes dans les tags temporairement
      // Dans une vraie app, on aurait une structure séparée
      final likedByUsers = recipe.tags.where((tag) => tag.startsWith('liked_by:')).toList();
      final userLikeTag = 'liked_by:$userId';
      
      int newLikesCount = recipe.likesCount;
      List<String> newTags = recipe.tags.where((tag) => !tag.startsWith('liked_by:')).toList();
      
      if (likedByUsers.contains(userLikeTag)) {
        // Unlike
        newLikesCount = (recipe.likesCount - 1).clamp(0, double.infinity).toInt();
        likedByUsers.remove(userLikeTag);
      } else {
        // Like
        newLikesCount = recipe.likesCount + 1;
        likedByUsers.add(userLikeTag);
      }
      
      newTags.addAll(likedByUsers);

      final updatedRecipe = recipe.copyWith(
        likesCount: newLikesCount,
        tags: newTags,
        updatedAt: DateTime.now(),
      );

      return await updateRecipe(updatedRecipe);
    } catch (e) {
      debugPrint('❌ Erreur lors du toggle like: $e');
      return false;
    }
  }

  /// Like/Unlike un commentaire
  static Future<bool> toggleCommentLike(String recipeId, String commentId, String userId) async {
    try {
      final recipe = await getRecipeById(recipeId);
      if (recipe == null) return false;

      final updatedComments = recipe.comments.map((comment) {
        if (comment.id == commentId) {
          final likedByUsers = List<String>.from(comment.likedByUsers);
          int likesCount = comment.likesCount;

          if (likedByUsers.contains(userId)) {
            likedByUsers.remove(userId);
            likesCount = (likesCount - 1).clamp(0, double.infinity).toInt();
          } else {
            likedByUsers.add(userId);
            likesCount = likesCount + 1;
          }

          return comment.copyWith(
            likesCount: likesCount,
            likedByUsers: likedByUsers,
          );
        }
        return comment;
      }).toList();

      final updatedRecipe = recipe.copyWith(
        comments: updatedComments,
        updatedAt: DateTime.now(),
      );

      return await updateRecipe(updatedRecipe);
    } catch (e) {
      debugPrint('❌ Erreur lors du toggle like commentaire: $e');
      return false;
    }
  }

  /// Obtient l'ID utilisateur actuel
  static Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);
    
    if (userId == null) {
      // Générer un ID unique pour cet utilisateur
      userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_userIdKey, userId);
    }
    
    return userId;
  }

  /// Obtient le nom d'utilisateur actuel
  static Future<String> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString(_userNameKey);
    
    if (userName == null) {
      // Nom par défaut
      userName = 'Utilisateur';
      await prefs.setString(_userNameKey, userName);
    }
    
    return userName;
  }

  /// Met à jour le nom d'utilisateur
  static Future<void> setCurrentUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  /// Obtient les recettes triées par popularité
  static Future<List<CommunityRecipe>> getPopularRecipes() async {
    final recipes = await getAllRecipes();
    recipes.sort((a, b) {
      // Trier par score de popularité (likes + commentaires + notes)
      final scoreA = a.likesCount + a.commentsCount + (a.averageRating * 2).round();
      final scoreB = b.likesCount + b.commentsCount + (b.averageRating * 2).round();
      return scoreB.compareTo(scoreA);
    });
    return recipes;
  }

  /// Obtient les recettes récentes
  static Future<List<CommunityRecipe>> getRecentRecipes() async {
    final recipes = await getAllRecipes();
    recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recipes;
  }

  /// Recherche des recettes par nom ou ingrédients
  static Future<List<CommunityRecipe>> searchRecipes(String query) async {
    final recipes = await getAllRecipes();
    final lowercaseQuery = query.toLowerCase();
    
    return recipes.where((recipe) {
      return recipe.name.toLowerCase().contains(lowercaseQuery) ||
             recipe.ingredients.toLowerCase().contains(lowercaseQuery) ||
             recipe.instructions.toLowerCase().contains(lowercaseQuery) ||
             recipe.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Vérifie si l'utilisateur a liké une recette
  static Future<bool> hasUserLikedRecipe(String recipeId, String userId) async {
    final recipe = await getRecipeById(recipeId);
    if (recipe == null) return false;
    
    return recipe.tags.contains('liked_by:$userId');
  }

  /// Génère un ID unique pour une nouvelle recette
  static String generateRecipeId() {
    return 'recipe_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Génère un ID unique pour un commentaire
  static String generateCommentId() {
    return 'comment_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Génère un ID unique pour une note
  static String generateRatingId() {
    return 'rating_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}
