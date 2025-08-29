// lib/core/services/gamification_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lym_nutrition/domain/entities/gamification_models.dart';

// presentation models re-export domain models; avoid importing presentation layer here

class GamificationService {
  static const String _userLymsKey = 'user_lyms';
  static const String _userBadgesKey = 'user_badges';
  static const String _userRewardsKey = 'user_rewards';
  static const String _challengesKey = 'user_challenges';
  static const String _dailyActionsKey = 'daily_actions';
  static const String _multiplierExpiryKey = 'multiplier_expiry';

  final SharedPreferences _prefs;

  GamificationService(this._prefs);

  // Points Lyms management
  Future<UserLyms> getUserLyms() async {
    final jsonString = _prefs.getString(_userLymsKey);
    if (jsonString != null) {
      return UserLyms.fromJson(jsonDecode(jsonString));
    }
    return const UserLyms(
      totalLyms: 0,
      todayLyms: 0,
      weeklyLyms: 0,
      monthlyLyms: 0,
      currentStreak: 0,
      longestStreak: 0,
    );
  }

  Future<void> saveUserLyms(UserLyms userLyms) async {
    await _prefs.setString(_userLymsKey, jsonEncode(userLyms.toJson()));
  }

  Future<int> awardLyms(LymAction action, {int multiplier = 1}) async {
    final userLyms = await getUserLyms();
    final basePoints = _getActionPoints(action);
    final points = basePoints * multiplier;

    final updatedLyms = userLyms.copyWith(
      totalLyms: userLyms.totalLyms + points,
      todayLyms: userLyms.todayLyms + points,
      weeklyLyms: userLyms.weeklyLyms + points,
      monthlyLyms: userLyms.monthlyLyms + points,
    );

    await saveUserLyms(updatedLyms);
    await _recordDailyAction(action);

    // Check for badges
    await _checkBadgeProgress(action);

    // Check for level up
    await _checkLevelUp(userLyms.totalLyms, updatedLyms.totalLyms);

    return points;
  }

  int _getActionPoints(LymAction action) {
    switch (action) {
      case LymAction.dailyLogin:
        return 10;
      case LymAction.mealLogged:
        return 15;
      case LymAction.hydration:
        return 5;
      case LymAction.dailyWeighIn:
        return 20;
      case LymAction.workoutSession:
        return 30; // Base pour 30min, ajusté selon durée
      case LymAction.onboardingComplete:
        return 200;
      case LymAction.profileComplete:
        return 150;
      case LymAction.firstPhoto:
        return 100;
      case LymAction.instagramFollow:
        return 150;
      case LymAction.instagramShare:
        return 50;
      case LymAction.mealPost:
        return 75;
      case LymAction.tagFriends:
        return 30;
      case LymAction.transformationShare:
        return 100;
      case LymAction.shareHealthyMeal:
        return 25;
      case LymAction.commentUser:
        return 10;
      case LymAction.recipeCreated:
        return 50; // Grosse récompense pour créer une recette
      case LymAction.recipeRated:
        return 15; // Récompense pour noter une recette
      case LymAction.recipeCommented:
        return 20; // Récompense pour commenter une recette
      case LymAction.receiveLike:
        return 5;
      case LymAction.inviteFriend:
        return 200;
      case LymAction.respectMacros:
        return 40;
      case LymAction.reachCalorieGoal:
        return 30;
      case LymAction.fiveFruitsVegetables:
        return 25;
      case LymAction.avoidRedFoods:
        return 20;
      case LymAction.sevenDayStreak:
        return 100;
      case LymAction.thirtyDayStreak:
        return 500;
      case LymAction.weeklyGoalsComplete:
        return 200;
    }
  }

  Future<int> awardWorkoutLyms(int durationMinutes) async {
    final points = durationMinutes >= 60 ? 50 : 30;
    return awardLyms(LymAction.workoutSession, multiplier: points ~/ 30);
  }

  // Daily actions tracking
  Future<void> _recordDailyAction(LymAction action) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final actionsKey = '${_dailyActionsKey}_$today';

    final actions = _prefs.getStringList(actionsKey) ?? [];
    actions.add(action.name);

    await _prefs.setStringList(actionsKey, actions);
  }

  Future<bool> hasCompletedActionToday(LymAction action) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final actionsKey = '${_dailyActionsKey}_$today';

    final actions = _prefs.getStringList(actionsKey) ?? [];
    return actions.contains(action.name);
  }

  Future<int> getTodayMealCount() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final actionsKey = '${_dailyActionsKey}_$today';

    final actions = _prefs.getStringList(actionsKey) ?? [];
    return actions
        .where((action) => action == LymAction.mealLogged.name)
        .length;
  }

  Future<int> getTodayHydrationCount() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final actionsKey = '${_dailyActionsKey}_$today';

    final actions = _prefs.getStringList(actionsKey) ?? [];
    return actions.where((action) => action == LymAction.hydration.name).length;
  }

  Future<List<Quest>> getDailyQuests() async {
    final mealCount = await getTodayMealCount();
    final hydrationCount = await getTodayHydrationCount();

    return [
      Quest(
        id: 'q1',
        type: QuestType.logging,
        title: '3 repas aujourd\'hui',
        description: 'Petit-déj, déjeuner, dîner — la base solide !',
        rewardXP: 25,
        icon: Icons.restaurant_menu,
        target: 3,
        progress: mealCount,
      ),
      Quest(
        id: 'q2',
        type: QuestType.hydration,
        title: '2L d\'eau',
        description: 'Reste hydraté pour des super-pouvoirs métaboliques',
        rewardXP: 20,
        icon: Icons.water_drop,
        target: 2000,
        progress: hydrationCount * 250, // Assuming each hydration is 250ml
      ),
      Quest(
        id: 'q3',
        type: QuestType.consistency,
        title: 'Streak +1',
        description: 'Enregistre au moins un repas aujourd\'hui',
        rewardXP: 15,
        icon: Icons.local_fire_department,
        target: 1,
        progress: mealCount > 0 ? 1 : 0,
      ),
    ];
  }

  // Badge management
  Future<List<UserBadge>> getUserBadges() async {
    final jsonString = _prefs.getString(_userBadgesKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => UserBadge.fromJson(json)).toList();
    }
    return UserBadge.getInitialBadges();
  }

  Future<void> saveUserBadges(List<UserBadge> badges) async {
    final jsonList = badges.map((badge) => badge.toJson()).toList();
    await _prefs.setString(_userBadgesKey, jsonEncode(jsonList));
  }

  Future<void> _checkBadgeProgress(LymAction action) async {
    final badges = await getUserBadges();
    final userLyms = await getUserLyms();

    for (var i = 0; i < badges.length; i++) {
      final badge = badges[i];
      if (!badge.isUnlocked) {
        int newProgress = badge.progress;

        switch (badge.type) {
          case BadgeType.onFire:
            newProgress = userLyms.currentStreak;
            break;
          case BadgeType.athlete:
            if (action == LymAction.workoutSession) {
              newProgress = badge.progress + 1;
            }
            break;
          case BadgeType.healthy:
            if (action == LymAction.mealLogged) {
              newProgress = badge.progress + 1;
            }
            break;
          case BadgeType.hydrated:
            if (action == LymAction.hydration) {
              newProgress = badge.progress + 1;
            }
            break;
          case BadgeType.transformation:
            if (action == LymAction.firstPhoto ||
                action == LymAction.transformationShare) {
              newProgress = badge.progress + 1;
            }
            break;
          case BadgeType.influencer:
            if (action == LymAction.instagramShare ||
                action == LymAction.mealPost ||
                action == LymAction.transformationShare) {
              newProgress = badge.progress + 1;
            }
            break;
          case BadgeType.ambassador:
            if (action == LymAction.inviteFriend) {
              newProgress = badge.progress + 1;
            }
            break;
        }

        if (newProgress >= badge.target && !badge.isUnlocked) {
          badges[i] = badge.copyWith(
            isUnlocked: true,
            unlockedDate: DateTime.now(),
            progress: badge.target,
          );
          // Award bonus Lyms for badge completion
          await awardLyms(LymAction.weeklyGoalsComplete, multiplier: 1);
        } else if (newProgress != badge.progress) {
          badges[i] = badge.copyWith(progress: newProgress);
        }
      }
    }

    await saveUserBadges(badges);
  }

  // Level management
  Future<LymLevel> getCurrentLevel() async {
    final userLyms = await getUserLyms();
    return LymLevel.getLevelForLyms(userLyms.totalLyms);
  }

  Future<int> getProgressToNextLevel() async {
    final userLyms = await getUserLyms();
    return LymLevel.getProgressToNextLevel(userLyms.totalLyms);
  }

  Future<void> _checkLevelUp(int oldLyms, int newLyms) async {
    final oldLevel = LymLevel.getLevelForLyms(oldLyms);
    final newLevel = LymLevel.getLevelForLyms(newLyms);

    if (oldLevel.name != newLevel.name) {
      // Level up! Award bonus Lyms
      await awardLyms(LymAction.onboardingComplete, multiplier: 1);
    }
  }

  // Reward management
  Future<List<LymReward>> getUserRewards() async {
    final jsonString = _prefs.getString(_userRewardsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => LymReward.fromJson(json)).toList();
    }
    return LymReward.getAvailableRewards();
  }

  Future<void> saveUserRewards(List<LymReward> rewards) async {
    final jsonList = rewards.map((reward) => reward.toJson()).toList();
    await _prefs.setString(_userRewardsKey, jsonEncode(jsonList));
  }

  Future<bool> purchaseReward(RewardType type) async {
    final userLyms = await getUserLyms();
    final rewards = await getUserRewards();

    final reward = rewards.firstWhere((r) => r.type == type);
    if (userLyms.totalLyms >= reward.cost && !reward.isOwned) {
      // Deduct Lyms
      final updatedLyms = userLyms.copyWith(
        totalLyms: userLyms.totalLyms - reward.cost,
      );
      await saveUserLyms(updatedLyms);

      // Mark reward as owned
      final rewardIndex = rewards.indexOf(reward);
      rewards[rewardIndex] = reward.copyWith(
        isOwned: true,
        purchaseDate: DateTime.now(),
      );
      await saveUserRewards(rewards);

      // Apply reward effect
      await _applyRewardEffect(type);

      return true;
    }
    return false;
  }

  Future<void> _applyRewardEffect(RewardType type) async {
    switch (type) {
      case RewardType.multiplier2x:
        final expiry = DateTime.now().add(const Duration(hours: 24));
        await _prefs.setString(_multiplierExpiryKey, expiry.toIso8601String());
        break;
      case RewardType.exclusiveBadge:
        // Badge is already marked as owned
        break;
      case RewardType.premiumAvatar:
        // Avatar is already marked as owned
        break;
      case RewardType.customTheme:
        // Theme is already marked as owned
        break;
      case RewardType.premiumRecipes:
        // Recipes access is already marked as owned
        break;
    }
  }

  Future<int> getCurrentMultiplier() async {
    final expiryString = _prefs.getString(_multiplierExpiryKey);
    if (expiryString != null) {
      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isBefore(expiry)) {
        return 2;
      } else {
        await _prefs.remove(_multiplierExpiryKey);
      }
    }
    return 1;
  }

  // Challenge management
  Future<List<LymChallenge>> getUserChallenges() async {
    final jsonString = _prefs.getString(_challengesKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => LymChallenge.fromJson(json)).toList();
    }
    return LymChallenge.getDefaultChallenges();
  }

  Future<void> saveUserChallenges(List<LymChallenge> challenges) async {
    final jsonList = challenges.map((challenge) => challenge.toJson()).toList();
    await _prefs.setString(_challengesKey, jsonEncode(jsonList));
  }

  Future<void> updateChallengeProgress(
      String challengeId, int newProgress) async {
    final challenges = await getUserChallenges();
    final challengeIndex = challenges.indexWhere((c) => c.id == challengeId);

    if (challengeIndex != -1) {
      final challenge = challenges[challengeIndex];
      final updatedChallenge = challenge.copyWith(
        progress: newProgress,
        isCompleted: newProgress >= challenge.target,
      );

      challenges[challengeIndex] = updatedChallenge;
      await saveUserChallenges(challenges);

      // Award Lyms if challenge completed
      if (updatedChallenge.isCompleted && !challenge.isCompleted) {
        await awardLyms(LymAction.weeklyGoalsComplete, multiplier: 1);
      }
    }
  }

  // Daily login and streak management
  Future<void> handleDailyLogin() async {
    final userLyms = await getUserLyms();
    final today = DateTime.now();
    final todayString = today.toIso8601String().split('T').first;

    if (userLyms.lastLoginDate == null) {
      // First login
      final updatedLyms = userLyms.copyWith(
        lastLoginDate: today,
        currentStreak: 1,
        longestStreak: 1,
      );
      await saveUserLyms(updatedLyms);
      await awardLyms(LymAction.dailyLogin);
      return;
    }

    final lastLogin = userLyms.lastLoginDate!;
    final lastLoginString = lastLogin.toIso8601String().split('T').first;

    if (lastLoginString == todayString) {
      // Already logged in today
      return;
    }

    final daysDifference = today.difference(lastLogin).inDays;

    if (daysDifference == 1) {
      // Consecutive day
      final newStreak = userLyms.currentStreak + 1;
      final updatedLyms = userLyms.copyWith(
        lastLoginDate: today,
        currentStreak: newStreak,
        longestStreak: newStreak > userLyms.longestStreak
            ? newStreak
            : userLyms.longestStreak,
      );
      await saveUserLyms(updatedLyms);

      // Check for streak achievements
      if (newStreak == 7) {
        await awardLyms(LymAction.sevenDayStreak);
      } else if (newStreak == 30) {
        await awardLyms(LymAction.thirtyDayStreak);
      }
    } else {
      // Streak broken
      final updatedLyms = userLyms.copyWith(
        lastLoginDate: today,
        currentStreak: 1,
      );
      await saveUserLyms(updatedLyms);
    }

    await awardLyms(LymAction.dailyLogin);
  }

  // Reset daily counters
  Future<void> resetDailyCounters() async {
    final userLyms = await getUserLyms();
    final updatedLyms = userLyms.copyWith(
      todayLyms: 0,
    );
    await saveUserLyms(updatedLyms);
  }

  Future<void> resetWeeklyCounters() async {
    final userLyms = await getUserLyms();
    final updatedLyms = userLyms.copyWith(
      weeklyLyms: 0,
    );
    await saveUserLyms(updatedLyms);
  }

  Future<void> resetMonthlyCounters() async {
    final userLyms = await getUserLyms();
    final updatedLyms = userLyms.copyWith(
      monthlyLyms: 0,
    );
    await saveUserLyms(updatedLyms);
  }
}


