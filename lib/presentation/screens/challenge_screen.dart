// lib/presentation/screens/challenge_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lym_nutrition/core/services/gamification_service.dart';
import 'package:lym_nutrition/domain/entities/gamification_models.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({Key? key}) : super(key: key);

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with TickerProviderStateMixin {
  late GamificationService _gamificationService;
  late TabController _tabController;

  UserLyms? _userLyms;
  LymLevel? _currentLevel;
  List<UserBadge> _badges = [];
  List<LymChallenge> _challenges = [];
  List<LymReward> _rewards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeGamification();
  }

  Future<void> _initializeGamification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _gamificationService = GamificationService(prefs);

      await _gamificationService.handleDailyLogin();
      await _loadGamificationData();
    } catch (e) {
      print('Erreur lors de l\'initialisation: $e');
    }
  }

  Future<void> _loadGamificationData() async {
    try {
      _userLyms = await _gamificationService.getUserLyms();
      _currentLevel = await _gamificationService.getCurrentLevel();
      _badges = await _gamificationService.getUserBadges();
      _challenges = await _gamificationService.getUserChallenges();
      _rewards = await _gamificationService.getUserRewards();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: FreshTheme.primaryMint,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: FreshTheme.cloudWhite,
      appBar: AppBar(
        title: const Text('🏆 Challenge'),
        backgroundColor: FreshTheme.primaryMint,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header avec stats principales
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [FreshTheme.primaryMint, FreshTheme.primaryMintDark],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: _buildStatsHeader(),
          ),

          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: FreshTheme.primaryMint,
              unselectedLabelColor: FreshTheme.stormGray,
              indicatorColor: FreshTheme.primaryMint,
              tabs: const [
                Tab(icon: Icon(Icons.emoji_events), text: 'Badges'),
                Tab(icon: Icon(Icons.flag), text: 'Défis'),
                Tab(icon: Icon(Icons.leaderboard), text: 'Classement'),
                Tab(icon: Icon(Icons.shop), text: 'Boutique'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                BadgesTab(badges: _badges),
                ChallengesTab(
                  challenges: _challenges,
                  gamificationService: _gamificationService,
                  onRefresh: _loadGamificationData,
                ),
                LeaderboardTab(),
                RewardsTab(
                  rewards: _rewards,
                  gamificationService: _gamificationService,
                  onRefresh: _loadGamificationData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    if (_userLyms == null || _currentLevel == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Niveau actuel
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentLevel!.icon,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentLevel!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _currentLevel!.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Stats principales
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatColumn(
              value: '${_userLyms!.totalLyms}',
              label: 'Total Lyms',
              icon: '💎',
            ),
            _StatColumn(
              value: '${_userLyms!.currentStreak}',
              label: 'Série',
              icon: '🔥',
            ),
            _StatColumn(
              value: '${_userLyms!.weeklyLyms}',
              label: 'Cette semaine',
              icon: '📊',
            ),
          ],
        ),
      ],
    );
  }

  Widget _StatColumn({
    required String value,
    required String label,
    required String icon,
  }) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class BadgesTab extends StatelessWidget {
  final List<UserBadge> badges;

  const BadgesTab({Key? key, required this.badges}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final unlockedBadges = badges.where((badge) => badge.isUnlocked).toList();
    final lockedBadges = badges.where((badge) => !badge.isUnlocked).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (unlockedBadges.isNotEmpty) ...[
          const Text(
            '🏆 Badges débloqués',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FreshTheme.midnightGray,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: unlockedBadges.length,
            itemBuilder: (context, index) {
              return BadgeCard(badge: unlockedBadges[index], isUnlocked: true);
            },
          ),
          const SizedBox(height: 32),
        ],
        if (lockedBadges.isNotEmpty) ...[
          const Text(
            '🔒 À débloquer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FreshTheme.midnightGray,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: lockedBadges.length,
            itemBuilder: (context, index) {
              return BadgeCard(badge: lockedBadges[index], isUnlocked: false);
            },
          ),
        ],
      ],
    );
  }
}

class BadgeCard extends StatelessWidget {
  final UserBadge badge;
  final bool isUnlocked;

  const BadgeCard({
    Key? key,
    required this.badge,
    required this.isUnlocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? FreshTheme.primaryMint.withOpacity(0.1)
            : FreshTheme.mistGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? FreshTheme.primaryMint.withOpacity(0.3)
              : FreshTheme.stormGray.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? FreshTheme.primaryMint.withOpacity(0.2)
                  : FreshTheme.stormGray.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                badge.icon,
                style: TextStyle(
                  fontSize: 32,
                  color: isUnlocked
                      ? FreshTheme.primaryMint
                      : FreshTheme.stormGray,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color:
                  isUnlocked ? FreshTheme.midnightGray : FreshTheme.stormGray,
            ),
            textAlign: TextAlign.center,
          ),
          if (!isUnlocked) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: badge.progressPercentage,
              backgroundColor: FreshTheme.mistGray,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(FreshTheme.primaryMint),
            ),
            const SizedBox(height: 4),
            Text(
              '${badge.progress}/${badge.target}',
              style: const TextStyle(
                fontSize: 12,
                color: FreshTheme.stormGray,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChallengesTab extends StatelessWidget {
  final List<LymChallenge> challenges;
  final GamificationService gamificationService;
  final VoidCallback onRefresh;

  const ChallengesTab({
    Key? key,
    required this.challenges,
    required this.gamificationService,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeChallenges = challenges.where((c) => c.isActive).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '🎯 Défis actifs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: FreshTheme.midnightGray,
          ),
        ),
        const SizedBox(height: 16),
        ...activeChallenges.map((challenge) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
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
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            challenge.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: FreshTheme.midnightGray,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: FreshTheme.sunGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${challenge.rewardLyms}',
                            style: const TextStyle(
                              color: FreshTheme.sunGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      challenge.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: FreshTheme.stormGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: challenge.progressPercentage,
                      backgroundColor: FreshTheme.mistGray,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        challenge.isCompleted
                            ? FreshTheme.accentCoral
                            : FreshTheme.primaryMint,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${challenge.progress}/${challenge.target}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: FreshTheme.stormGray,
                          ),
                        ),
                        if (challenge.isCompleted)
                          const Text(
                            '✅ Terminé',
                            style: TextStyle(
                              color: FreshTheme.accentCoral,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Données fictives pour la démo
    final leaderboard = [
      {'rank': 1, 'name': 'Vous', 'lyms': 2500, 'isCurrentUser': true},
      {'rank': 2, 'name': 'Marie L.', 'lyms': 2400, 'isCurrentUser': false},
      {'rank': 3, 'name': 'Jean P.', 'lyms': 2300, 'isCurrentUser': false},
      {'rank': 4, 'name': 'Sophie M.', 'lyms': 2200, 'isCurrentUser': false},
      {'rank': 5, 'name': 'Pierre D.', 'lyms': 2100, 'isCurrentUser': false},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '🏅 Classement général',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: FreshTheme.midnightGray,
          ),
        ),
        const SizedBox(height: 16),
        ...leaderboard.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: entry['isCurrentUser'] as bool
                    ? FreshTheme.primaryMint.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: entry['isCurrentUser'] as bool
                      ? FreshTheme.primaryMint.withOpacity(0.3)
                      : FreshTheme.mistGray,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: entry['rank'] == 1
                          ? FreshTheme.sunGold
                          : entry['rank'] == 2
                              ? FreshTheme.serenityBlue
                              : entry['rank'] == 3
                                  ? FreshTheme.accentCoral
                                  : FreshTheme.stormGray,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '${entry['rank']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: entry['isCurrentUser'] as bool
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: entry['isCurrentUser'] as bool
                            ? FreshTheme.primaryMint
                            : FreshTheme.midnightGray,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: FreshTheme.primaryMint.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${entry['lyms']} 💎',
                      style: const TextStyle(
                        color: FreshTheme.primaryMint,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class RewardsTab extends StatelessWidget {
  final List<LymReward> rewards;
  final GamificationService gamificationService;
  final VoidCallback onRefresh;

  const RewardsTab({
    Key? key,
    required this.rewards,
    required this.gamificationService,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '🛍️ Boutique Lyms',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: FreshTheme.midnightGray,
          ),
        ),
        const SizedBox(height: 16),
        ...rewards.map((reward) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: reward.isOwned
                    ? FreshTheme.accentCoral.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: reward.isOwned
                      ? FreshTheme.accentCoral.withOpacity(0.3)
                      : FreshTheme.mistGray,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: reward.isOwned
                          ? FreshTheme.accentCoral.withOpacity(0.2)
                          : FreshTheme.primaryMint.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        reward.icon,
                        style: TextStyle(
                          fontSize: 28,
                          color: reward.isOwned
                              ? FreshTheme.accentCoral
                              : FreshTheme.primaryMint,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                reward.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: reward.isOwned
                                      ? FreshTheme.stormGray
                                      : FreshTheme.midnightGray,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: FreshTheme.sunGold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${reward.cost} 💎',
                                style: const TextStyle(
                                  color: FreshTheme.sunGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reward.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: FreshTheme.stormGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (reward.isOwned)
                    const Icon(
                      Icons.check_circle,
                      color: FreshTheme.accentCoral,
                      size: 24,
                    )
                  else
                    ElevatedButton(
                      onPressed: () async {
                        // Pour la démo, on simule un achat réussi
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${reward.name} acheté avec succès !'),
                            backgroundColor: FreshTheme.primaryMint,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FreshTheme.primaryMint,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Acheter'),
                    ),
                ],
              ),
            )),
      ],
    );
  }
}
