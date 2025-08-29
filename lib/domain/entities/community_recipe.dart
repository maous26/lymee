import 'package:equatable/equatable.dart';

class CommunityRecipe extends Equatable {
  final String id;
  final String name;
  final String ingredients;
  final String instructions;
  final String authorId;
  final String authorName;
  final int difficulty; // 1-5
  final int preparationTime; // en minutes
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double averageRating;
  final int ratingsCount;
  final int likesCount;
  final int commentsCount;
  final List<RecipeRating> ratings;
  final List<RecipeComment> comments;
  final bool isPublic;
  final List<String> tags;

  // Informations nutritionnelles estimées
  final double? estimatedCalories;
  final double? estimatedProteins;
  final double? estimatedCarbs;
  final double? estimatedFats;

  const CommunityRecipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.authorId,
    required this.authorName,
    required this.difficulty,
    required this.preparationTime,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.averageRating = 0.0,
    this.ratingsCount = 0,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.ratings = const [],
    this.comments = const [],
    this.isPublic = true,
    this.tags = const [],
    this.estimatedCalories,
    this.estimatedProteins,
    this.estimatedCarbs,
    this.estimatedFats,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        ingredients,
        instructions,
        authorId,
        authorName,
        difficulty,
        preparationTime,
        imageUrl,
        createdAt,
        updatedAt,
        averageRating,
        ratingsCount,
        likesCount,
        commentsCount,
        ratings,
        comments,
        isPublic,
        tags,
        estimatedCalories,
        estimatedProteins,
        estimatedCarbs,
        estimatedFats,
      ];

  CommunityRecipe copyWith({
    String? id,
    String? name,
    String? ingredients,
    String? instructions,
    String? authorId,
    String? authorName,
    int? difficulty,
    int? preparationTime,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? averageRating,
    int? ratingsCount,
    int? likesCount,
    int? commentsCount,
    List<RecipeRating>? ratings,
    List<RecipeComment>? comments,
    bool? isPublic,
    List<String>? tags,
    double? estimatedCalories,
    double? estimatedProteins,
    double? estimatedCarbs,
    double? estimatedFats,
  }) {
    return CommunityRecipe(
      id: id ?? this.id,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      difficulty: difficulty ?? this.difficulty,
      preparationTime: preparationTime ?? this.preparationTime,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      ratings: ratings ?? this.ratings,
      comments: comments ?? this.comments,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      estimatedProteins: estimatedProteins ?? this.estimatedProteins,
      estimatedCarbs: estimatedCarbs ?? this.estimatedCarbs,
      estimatedFats: estimatedFats ?? this.estimatedFats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'instructions': instructions,
      'authorId': authorId,
      'authorName': authorName,
      'difficulty': difficulty,
      'preparationTime': preparationTime,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'averageRating': averageRating,
      'ratingsCount': ratingsCount,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'ratings': ratings.map((r) => r.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'isPublic': isPublic,
      'tags': tags,
      'estimatedCalories': estimatedCalories,
      'estimatedProteins': estimatedProteins,
      'estimatedCarbs': estimatedCarbs,
      'estimatedFats': estimatedFats,
    };
  }

  factory CommunityRecipe.fromJson(Map<String, dynamic> json) {
    return CommunityRecipe(
      id: json['id'] as String,
      name: json['name'] as String,
      ingredients: json['ingredients'] as String,
      instructions: json['instructions'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      difficulty: json['difficulty'] as int,
      preparationTime: json['preparationTime'] as int,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: json['ratingsCount'] as int? ?? 0,
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      ratings: (json['ratings'] as List<dynamic>?)
              ?.map((r) => RecipeRating.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      comments: (json['comments'] as List<dynamic>?)
              ?.map((c) => RecipeComment.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      isPublic: json['isPublic'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      estimatedCalories: (json['estimatedCalories'] as num?)?.toDouble(),
      estimatedProteins: (json['estimatedProteins'] as num?)?.toDouble(),
      estimatedCarbs: (json['estimatedCarbs'] as num?)?.toDouble(),
      estimatedFats: (json['estimatedFats'] as num?)?.toDouble(),
    );
  }
}

class RecipeRating extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final int rating; // 1-5 étoiles
  final String? comment;
  final DateTime createdAt;

  const RecipeRating({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, userName, rating, comment, createdAt];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RecipeRating.fromJson(Map<String, dynamic> json) {
    return RecipeRating(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class RecipeComment extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final List<String> likedByUsers;

  const RecipeComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.likedByUsers = const [],
  });

  @override
  List<Object?> get props =>
      [id, userId, userName, content, createdAt, likesCount, likedByUsers];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'likedByUsers': likedByUsers,
    };
  }

  factory RecipeComment.fromJson(Map<String, dynamic> json) {
    return RecipeComment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likesCount: json['likesCount'] as int? ?? 0,
      likedByUsers:
          (json['likedByUsers'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  RecipeComment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? content,
    DateTime? createdAt,
    int? likesCount,
    List<String>? likedByUsers,
  }) {
    return RecipeComment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      likedByUsers: likedByUsers ?? this.likedByUsers,
    );
  }
}
