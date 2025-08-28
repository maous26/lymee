// lib/presentation/widgets/gamification_widgets.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/domain/entities/gamification_models.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';

class LymDisplayWidget extends StatelessWidget {
  final int lyms;
  final int? todayLyms;
  final bool showToday;

  const LymDisplayWidget({
    Key? key,
    required this.lyms,
    this.todayLyms,
    this.showToday = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [FreshTheme.primaryMint, FreshTheme.primaryMintDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: FreshTheme.primaryMint.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '💎',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            lyms.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (showToday && todayLyms != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '+$todayLyms',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LevelProgressWidget extends StatelessWidget {
  final LymLevel currentLevel;
  final int progressPercentage;
  final int currentLyms;

  const LevelProgressWidget({
    Key? key,
    required this.currentLevel,
    required this.progressPercentage,
    required this.currentLyms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, FreshTheme.mistGray],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: FreshTheme.primaryMint.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentLevel.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentLevel.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: FreshTheme.midnightGray,
                    ),
                  ),
                  Text(
                    '${currentLyms} / ${currentLevel.maxLyms} Lyms',
                    style: const TextStyle(
                      fontSize: 14,
                      color: FreshTheme.stormGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: FreshTheme.mistGray,
            valueColor:
                const AlwaysStoppedAnimation<Color>(FreshTheme.primaryMint),
          ),
          const SizedBox(height: 8),
          Text(
            '$progressPercentage% vers le niveau suivant',
            style: const TextStyle(
              fontSize: 12,
              color: FreshTheme.stormGray,
            ),
          ),
        ],
      ),
    );
  }
}

class BadgeGridWidget extends StatelessWidget {
  final List<UserBadge> badges;
  final int maxBadges;
  final VoidCallback? onBadgeTap;

  const BadgeGridWidget({
    Key? key,
    required this.badges,
    this.maxBadges = 6,
    this.onBadgeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayBadges = badges.take(maxBadges).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: displayBadges.length,
      itemBuilder: (context, index) {
        final badge = displayBadges[index];
        return BadgeItemWidget(
          badge: badge,
          onTap: onBadgeTap,
        );
      },
    );
  }
}

class BadgeItemWidget extends StatelessWidget {
  final UserBadge badge;
  final VoidCallback? onTap;

  const BadgeItemWidget({
    Key? key,
    required this.badge,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: badge.isUnlocked
              ? FreshTheme.primaryMint.withOpacity(0.1)
              : FreshTheme.mistGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: badge.isUnlocked
                ? FreshTheme.primaryMint.withOpacity(0.3)
                : FreshTheme.stormGray.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge.icon,
              style: TextStyle(
                fontSize: 24,
                color: badge.isUnlocked
                    ? FreshTheme.primaryMint
                    : FreshTheme.stormGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: badge.isUnlocked
                    ? FreshTheme.midnightGray
                    : FreshTheme.stormGray,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!badge.isUnlocked && badge.target > 0) ...[
              const SizedBox(height: 2),
              Text(
                '${badge.progress}/${badge.target}',
                style: const TextStyle(
                  fontSize: 8,
                  color: FreshTheme.stormGray,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final bool showLongest;

  const StreakWidget({
    Key? key,
    required this.currentStreak,
    required this.longestStreak,
    this.showLongest = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [FreshTheme.accentCoral, FreshTheme.accentCoralDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: FreshTheme.accentCoral.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            '$currentStreak j',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (showLongest && longestStreak > currentStreak) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Record: $longestStreak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChallengeProgressWidget extends StatelessWidget {
  final LymChallenge challenge;
  final VoidCallback? onTap;

  const ChallengeProgressWidget({
    Key? key,
    required this.challenge,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: challenge.isCompleted
              ? FreshTheme.accentCoral.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: challenge.isCompleted
                ? FreshTheme.accentCoral.withOpacity(0.3)
                : FreshTheme.mistGray,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  challenge.icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    challenge.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: FreshTheme.midnightGray,
                    ),
                  ),
                ),
                Text(
                  '+${challenge.rewardLyms}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: FreshTheme.primaryMint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: challenge.progressPercentage,
              backgroundColor: FreshTheme.mistGray,
              valueColor: AlwaysStoppedAnimation<Color>(
                challenge.isCompleted
                    ? FreshTheme.accentCoral
                    : FreshTheme.primaryMint,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${challenge.progress}/${challenge.target}',
              style: const TextStyle(
                fontSize: 12,
                color: FreshTheme.stormGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final String label;
  final String icon;
  final int lymsReward;
  final VoidCallback onPressed;
  final bool isCompleted;

  const QuickActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.lymsReward,
    required this.onPressed,
    this.isCompleted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isCompleted
            ? FreshTheme.accentCoral.withOpacity(0.1)
            : Colors.white,
        foregroundColor:
            isCompleted ? FreshTheme.accentCoral : FreshTheme.midnightGray,
        elevation: isCompleted ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isCompleted
                ? FreshTheme.accentCoral.withOpacity(0.3)
                : FreshTheme.mistGray,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '+$lymsReward',
            style: const TextStyle(
              fontSize: 12,
              color: FreshTheme.primaryMint,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementNotification extends StatelessWidget {
  final String title;
  final String message;
  final String icon;
  final VoidCallback? onDismiss;

  const AchievementNotification({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FreshTheme.primaryMint, FreshTheme.primaryMintDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: FreshTheme.primaryMint.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}


