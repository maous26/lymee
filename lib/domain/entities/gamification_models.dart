// lib/domain/entities/gamification_models.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum LymAction {
  dailyLogin,
  mealLogged,
  hydration,
  dailyWeighIn,
  workoutSession,
  onboardingComplete,
  profileComplete,
  firstPhoto,
  instagramFollow,
  instagramShare,
  mealPost,
  tagFriends,
  transformationShare,
  shareHealthyMeal,
  commentUser,
  recipeCreated,
  recipeRated,
  recipeCommented,
  receiveLike,
  inviteFriend,
  respectMacros,
  reachCalorieGoal,
  fiveFruitsVegetables,
  avoidRedFoods,
  sevenDayStreak,
  thirtyDayStreak,
  weeklyGoalsComplete,
}

enum BadgeType {
  onFire, // 7 jours consécutifs
  athlete, // 20 séances de sport
  healthy, // 50 repas équilibrés
  hydrated, // objectif eau 30 jours
  transformation, // photos régulières
  influencer, // partages Instagram réguliers
  ambassador, // 5 parrainages réussis
}

enum RewardType {
  multiplier2x,
  exclusiveBadge,
  premiumAvatar,
  customTheme,
  premiumRecipes,
}

class UserLyms extends Equatable {
  final int totalLyms;
  final int todayLyms;
  final int weeklyLyms;
  final int monthlyLyms;
  final DateTime? lastLoginDate;
  final int currentStreak;
  final int longestStreak;

  const UserLyms({
    required this.totalLyms,
    required this.todayLyms,
    required this.weeklyLyms,
    required this.monthlyLyms,
    this.lastLoginDate,
    required this.currentStreak,
    required this.longestStreak,
  });

  UserLyms copyWith({
    int? totalLyms,
    int? todayLyms,
    int? weeklyLyms,
    int? monthlyLyms,
    DateTime? lastLoginDate,
    int? currentStreak,
    int? longestStreak,
  }) {
    return UserLyms(
      totalLyms: totalLyms ?? this.totalLyms,
      todayLyms: todayLyms ?? this.todayLyms,
      weeklyLyms: weeklyLyms ?? this.weeklyLyms,
      monthlyLyms: monthlyLyms ?? this.monthlyLyms,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalLyms': totalLyms,
      'todayLyms': todayLyms,
      'weeklyLyms': weeklyLyms,
      'monthlyLyms': monthlyLyms,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  factory UserLyms.fromJson(Map<String, dynamic> json) {
    return UserLyms(
      totalLyms: json['totalLyms'] ?? 0,
      todayLyms: json['todayLyms'] ?? 0,
      weeklyLyms: json['weeklyLyms'] ?? 0,
      monthlyLyms: json['monthlyLyms'] ?? 0,
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.parse(json['lastLoginDate'])
          : null,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        totalLyms,
        todayLyms,
        weeklyLyms,
        monthlyLyms,
        lastLoginDate,
        currentStreak,
        longestStreak,
      ];
}

class LymLevel extends Equatable {
  final String name;
  final int minLyms;
  final int maxLyms;
  final String description;
  final String icon;

  const LymLevel({
    required this.name,
    required this.minLyms,
    required this.maxLyms,
    required this.description,
    required this.icon,
  });

  static const levels = [
    LymLevel(
      name: 'Débutant Lym',
      minLyms: 0,
      maxLyms: 500,
      description: 'Bienvenue dans l\'aventure Lym !',
      icon: '🌱',
    ),
    LymLevel(
      name: 'Lym Motivé',
      minLyms: 501,
      maxLyms: 1500,
      description: 'Vous prenez de bonnes habitudes !',
      icon: '💪',
    ),
    LymLevel(
      name: 'Lym Régulier',
      minLyms: 1501,
      maxLyms: 3000,
      description: 'La régularité paie !',
      icon: '🔥',
    ),
    LymLevel(
      name: 'Lym Expert',
      minLyms: 3001,
      maxLyms: 5000,
      description: 'Vous êtes un expert de la nutrition !',
      icon: '⭐',
    ),
    LymLevel(
      name: 'Lym Champion',
      minLyms: 5001,
      maxLyms: 8000,
      description: 'Champion de la santé !',
      icon: '🏆',
    ),
    LymLevel(
      name: 'Lym Légende',
      minLyms: 8001,
      maxLyms: 999999,
      description: 'Vous êtes une légende !',
      icon: '👑',
    ),
  ];

  static LymLevel getLevelForLyms(int lyms) {
    return levels.firstWhere(
      (level) => lyms >= level.minLyms && lyms <= level.maxLyms,
      orElse: () => levels.last,
    );
  }

  static int getProgressToNextLevel(int currentLyms) {
    final currentLevel = getLevelForLyms(currentLyms);
    final nextLevelIndex = levels.indexOf(currentLevel) + 1;

    if (nextLevelIndex >= levels.length) {
      return 0; // Dernier niveau atteint
    }

    final nextLevel = levels[nextLevelIndex];
    final progress = currentLyms - currentLevel.minLyms;
    final totalNeeded = nextLevel.minLyms - currentLevel.minLyms;

    return ((progress / totalNeeded) * 100).round();
  }

  @override
  List<Object> get props => [name, minLyms, maxLyms, description, icon];
}

class UserBadge extends Equatable {
  final BadgeType type;
  final String name;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final int progress;
  final int target;

  const UserBadge({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedDate,
    required this.progress,
    required this.target,
  });

  double get progressPercentage {
    if (target == 0) return 1.0;
    return progress / target;
  }

  UserBadge copyWith({
    BadgeType? type,
    String? name,
    String? description,
    String? icon,
    bool? isUnlocked,
    DateTime? unlockedDate,
    int? progress,
    int? target,
  }) {
    return UserBadge(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'description': description,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'progress': progress,
      'target': target,
    };
  }

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      type: BadgeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BadgeType.onFire,
      ),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.parse(json['unlockedDate'])
          : null,
      progress: json['progress'] ?? 0,
      target: json['target'] ?? 0,
    );
  }

  static List<UserBadge> getInitialBadges() {
    return [
      UserBadge(
        type: BadgeType.onFire,
        name: 'En feu 🔥',
        description: '7 jours consécutifs',
        icon: '🔥',
        isUnlocked: false,
        progress: 0,
        target: 7,
      ),
      UserBadge(
        type: BadgeType.athlete,
        name: 'Athlète 💪',
        description: '20 séances de sport',
        icon: '💪',
        isUnlocked: false,
        progress: 0,
        target: 20,
      ),
      UserBadge(
        type: BadgeType.healthy,
        name: 'Healthy 🥗',
        description: '50 repas équilibrés',
        icon: '🥗',
        isUnlocked: false,
        progress: 0,
        target: 50,
      ),
      UserBadge(
        type: BadgeType.hydrated,
        name: 'Hydraté 💧',
        description: 'Objectif eau 30 jours',
        icon: '💧',
        isUnlocked: false,
        progress: 0,
        target: 30,
      ),
      UserBadge(
        type: BadgeType.transformation,
        name: 'Transformation 📸',
        description: 'Photos régulières',
        icon: '📸',
        isUnlocked: false,
        progress: 0,
        target: 10,
      ),
      UserBadge(
        type: BadgeType.influencer,
        name: 'Influenceur 📱',
        description: 'Partages Instagram réguliers',
        icon: '📱',
        isUnlocked: false,
        progress: 0,
        target: 15,
      ),
      UserBadge(
        type: BadgeType.ambassador,
        name: 'Ambassadeur 👥',
        description: '5 parrainages réussis',
        icon: '👥',
        isUnlocked: false,
        progress: 0,
        target: 5,
      ),
    ];
  }

  @override
  List<Object?> get props => [
        type,
        name,
        description,
        icon,
        isUnlocked,
        unlockedDate,
        progress,
        target,
      ];
}

class LymReward extends Equatable {
  final RewardType type;
  final String name;
  final String description;
  final String icon;
  final int cost;
  final bool isOwned;
  final DateTime? purchaseDate;

  const LymReward({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.cost,
    required this.isOwned,
    this.purchaseDate,
  });

  LymReward copyWith({
    RewardType? type,
    String? name,
    String? description,
    String? icon,
    int? cost,
    bool? isOwned,
    DateTime? purchaseDate,
  }) {
    return LymReward(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      cost: cost ?? this.cost,
      isOwned: isOwned ?? this.isOwned,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'description': description,
      'icon': icon,
      'cost': cost,
      'isOwned': isOwned,
      'purchaseDate': purchaseDate?.toIso8601String(),
    };
  }

  factory LymReward.fromJson(Map<String, dynamic> json) {
    return LymReward(
      type: RewardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RewardType.multiplier2x,
      ),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      cost: json['cost'] ?? 0,
      isOwned: json['isOwned'] ?? false,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'])
          : null,
    );
  }

  static List<LymReward> getAvailableRewards() {
    return [
      LymReward(
        type: RewardType.multiplier2x,
        name: 'Multiplicateur x2 (24h)',
        description: 'Doublez vos Lyms pendant 24 heures',
        icon: '⚡',
        cost: 500,
        isOwned: false,
      ),
      LymReward(
        type: RewardType.exclusiveBadge,
        name: 'Badge exclusif',
        description: 'Badge spécial pour votre profil',
        icon: '🏅',
        cost: 300,
        isOwned: false,
      ),
      LymReward(
        type: RewardType.premiumAvatar,
        name: 'Avatar premium',
        description: 'Nouvel avatar exclusif',
        icon: '👤',
        cost: 200,
        isOwned: false,
      ),
      LymReward(
        type: RewardType.customTheme,
        name: 'Thème personnalisé',
        description: 'Changez l\'apparence de l\'app',
        icon: '🎨',
        cost: 400,
        isOwned: false,
      ),
      LymReward(
        type: RewardType.premiumRecipes,
        name: 'Recettes premium (1 mois)',
        description: 'Accès aux recettes exclusives',
        icon: '👨‍🍳',
        cost: 800,
        isOwned: false,
      ),
    ];
  }

  @override
  List<Object?> get props => [
        type,
        name,
        description,
        icon,
        cost,
        isOwned,
        purchaseDate,
      ];
}

class LymChallenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int rewardLyms;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int progress;
  final int target;
  final bool isCompleted;

  const LymChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rewardLyms,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.progress,
    required this.target,
    required this.isCompleted,
  });

  double get progressPercentage {
    if (target == 0) return 1.0;
    return progress / target;
  }

  LymChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? rewardLyms,
    int? durationDays,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? progress,
    int? target,
    bool? isCompleted,
  }) {
    return LymChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      rewardLyms: rewardLyms ?? this.rewardLyms,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'rewardLyms': rewardLyms,
      'durationDays': durationDays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'progress': progress,
      'target': target,
      'isCompleted': isCompleted,
    };
  }

  factory LymChallenge.fromJson(Map<String, dynamic> json) {
    return LymChallenge(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      rewardLyms: json['rewardLyms'] ?? 0,
      durationDays: json['durationDays'] ?? 0,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? false,
      progress: json['progress'] ?? 0,
      target: json['target'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  static List<LymChallenge> getDefaultChallenges() {
    final now = DateTime.now();
    return [
      LymChallenge(
        id: 'lym_challenge',
        title: 'Lym Challenge',
        description: 'Poster 7 repas healthy avec #LymChallenge',
        icon: '🏆',
        rewardLyms: 500,
        durationDays: 7,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        isActive: true,
        progress: 0,
        target: 7,
        isCompleted: false,
      ),
      LymChallenge(
        id: 'transformation_tuesday',
        title: 'Transformation Tuesday',
        description: 'Partager son évolution ce mardi',
        icon: '📸',
        rewardLyms: 200,
        durationDays: 1,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        isActive: true,
        progress: 0,
        target: 1,
        isCompleted: false,
      ),
      LymChallenge(
        id: 'motivation_monday',
        title: 'Motivation Monday',
        description: 'Partager sa séance sport ce lundi',
        icon: '💪',
        rewardLyms: 100,
        durationDays: 1,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        isActive: true,
        progress: 0,
        target: 1,
        isCompleted: false,
      ),
    ];
  }

  @override
  List<Object> get props => [
        id,
        title,
        description,
        icon,
        rewardLyms,
        durationDays,
        startDate,
        endDate,
        isActive,
        progress,
        target,
        isCompleted,
      ];
}

// Presentation-friendly gamification models (shared canonical definitions)
enum QuestType { logging, hydration, exercise, consistency, exploration }

class Quest {
  final String id;
  final QuestType type;
  final String title;
  final String description;
  final int rewardXP;
  final IconData icon;
  final int target;
  final int progress;

  const Quest({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.rewardXP,
    required this.icon,
    required this.target,
    this.progress = 0,
  });

  double get completionPercent => (progress / (target == 0 ? 1 : target)).clamp(0.0, 1.0);

  bool get isCompleted => progress >= target;

  Quest copyWith({int? progress}) => Quest(
        id: id,
        type: type,
        title: title,
        description: description,
        rewardXP: rewardXP,
        icon: icon,
        target: target,
        progress: progress ?? this.progress,
      );
}

class Badge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.unlocked = false,
  });

  Badge unlock() => Badge(
        id: id,
        name: name,
        description: description,
        icon: icon,
        color: color,
        unlocked: true,
      );
}

class StreakInfo {
  final int currentStreakDays;
  final int bestStreakDays;
  final bool activeToday;

  const StreakInfo({
    required this.currentStreakDays,
    required this.bestStreakDays,
    required this.activeToday,
  });
}


