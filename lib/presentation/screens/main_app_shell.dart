// lib/presentation/screens/main_app_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/presentation/screens/nutrition_dashboard_screen_improved_v2.dart';
import 'package:lym_nutrition/presentation/screens/chat/chatbot_screen.dart';
import 'package:lym_nutrition/presentation/screens/journal_screen.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';

import 'package:lym_nutrition/presentation/screens/profile/personal_info_screen.dart';
import 'package:lym_nutrition/presentation/screens/profile/nutritional_goals_screen.dart';
import 'package:lym_nutrition/presentation/bloc/auth/auth_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/auth/auth_event.dart';
import 'package:lym_nutrition/presentation/screens/landing_page.dart';

class MainAppShell extends StatefulWidget {
  final int initialIndex;
  const MainAppShell({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  // Global key to access dashboard screen state
  final GlobalKey<NutritionDashboardScreenV2State> _dashboardKey = GlobalKey();

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Tableau de bord',
    ),
    const BottomNavigationBarItem(
      label: 'Journal',
      icon: Icon(Icons.book_outlined),
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline),
      label: 'Lymee',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      NutritionDashboardScreenV2(key: _dashboardKey),
      const JournalScreen(),
      const ChatbotScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;

            // Refresh dashboard when navigating to it
            if (index == 0 && _dashboardKey.currentState != null) {
              _dashboardKey.currentState!.refreshDashboardData();
            }
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: FreshTheme.primaryMint,
        unselectedItemColor: FreshTheme.stormGray,
        selectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        unselectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        elevation: 8,
        items: _navItems,
      ),
    );
  }
}

// Stats tab replaced by ChatbotScreen

// Placeholder Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: FreshTheme.primaryMint,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Show logout confirmation
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content:
                      const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.read<AuthBloc>().add(SignOutRequested());
                        // Navigate back to landing page
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const LandingPage()),
                          (route) => false,
                        );
                      },
                      child: const Text('Déconnecter'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: FreshTheme.primaryMint,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Votre Profil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: FreshTheme.midnightGray,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Gérez vos informations personnelles',
              style: TextStyle(
                fontSize: 14,
                color: FreshTheme.stormGray,
              ),
            ),
            SizedBox(height: 32),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading:
                          Icon(Icons.person, color: FreshTheme.primaryMint),
                      title: Text('Informations personnelles'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PersonalInfoScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.track_changes,
                          color: FreshTheme.primaryMint),
                      title: Text('Objectifs nutritionnels'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const NutritionalGoalsScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.notifications,
                          color: FreshTheme.primaryMint),
                      title: Text('Notifications'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Paramètres de notifications - Bientôt disponible !'),
                            backgroundColor: FreshTheme.serenityBlue,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.help, color: FreshTheme.primaryMint),
                      title: Text('Aide et support'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Aide et support'),
                            content: const Text(
                                'Pour toute question ou assistance :\n\n'
                                '• Consultez les info-bulles (ℹ️) dans l\'app\n'
                                '• Email : support@lymnutrition.com\n'
                                '• Version : 1.0.0'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Fermer'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
