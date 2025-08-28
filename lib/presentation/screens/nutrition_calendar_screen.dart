// lib/presentation/screens/nutrition_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';
import 'package:lym_nutrition/presentation/screens/nutrition_dashboard_screen_improved_v2.dart'
    as nd2;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NutritionCalendarScreen extends StatefulWidget {
  const NutritionCalendarScreen({Key? key}) : super(key: key);

  @override
  State<NutritionCalendarScreen> createState() =>
      _NutritionCalendarScreenState();
}

class _NutritionCalendarScreenState extends State<NutritionCalendarScreen> {
  late final ValueNotifier<DateTime> _selectedDay;
  late final ValueNotifier<DateTime> _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Mock data storage - in a real app, this would come from a database
  final Map<DateTime, DayData> _dailyData = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = ValueNotifier(DateTime(now.year, now.month, now.day));
    _focusedDay = ValueNotifier(DateTime(now.year, now.month, now.day));
    _generateMockData();
    _loadSavedMeals();
  }

  @override
  void dispose() {
    _selectedDay.dispose();
    _focusedDay.dispose();
    super.dispose();
  }

  void _generateMockData() {
    // Generate mock data for the past 30 days
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      _dailyData[date] = DayData(
        date: date,
        totalCalories: 1500 + (i * 50 % 800),
        meals: [
          if (i % 3 != 0)
            nd2.MealFood('Petit-déjeuner complet', 450, 15, 60, 15),
          if (i % 2 == 0) nd2.MealFood('Déjeuner équilibré', 650, 30, 70, 20),
          nd2.MealFood('Dîner léger', 400, 25, 40, 12),
        ],
        sportSessions: i % 3 == 0
            ? []
            : [
                nd2.SportSession(
                  sportName: [
                    'Course à pied',
                    'Natation',
                    'Musculation'
                  ][i % 3],
                  duration: 30 + (i * 5 % 60),
                  intensity: nd2.SportIntensity.values[i % 4],
                ),
              ],
        waterConsumed: 1500 + (i * 100 % 1500),
        isAIMealPlan: false,
      );
    }
  }

  Future<void> _loadSavedMeals() async {
    final prefs = await SharedPreferences.getInstance();

    // Load daily AI meals
    final dailyMealsJson = prefs.getString('saved_daily_meals');
    final dailyMealsDate = prefs.getString('saved_daily_meals_date');

    if (dailyMealsJson != null && dailyMealsDate != null) {
      final savedDate = DateTime.parse(dailyMealsDate);
      final dateKey = DateTime(savedDate.year, savedDate.month, savedDate.day);

      final List<dynamic> mealsData = jsonDecode(dailyMealsJson);
      final List<nd2.MealFood> meals = mealsData
          .map<nd2.MealFood>(
              (json) => nd2.MealFood.fromAIMeal(json as Map<String, dynamic>))
          .toList();

      final totalCalories = meals.fold(0.0, (sum, meal) => sum + meal.calories);

      setState(() {
        _dailyData[dateKey] = DayData(
          date: dateKey,
          totalCalories: totalCalories,
          meals: meals,
          sportSessions: _dailyData[dateKey]?.sportSessions ?? [],
          waterConsumed: _dailyData[dateKey]?.waterConsumed ?? 0,
          isAIMealPlan: true,
        );
      });
    }

    // Load individual meals
    final individualMealsJson = prefs.getString('individual_meals_today');
    if (individualMealsJson != null) {
      final savedData = jsonDecode(individualMealsJson);
      final savedDate = savedData['date'];
      final dateKey = DateTime.parse('${savedDate}T00:00:00');

      final List<dynamic> mealsData = savedData['meals'];
      final List<nd2.MealFood> meals = mealsData
          .map<nd2.MealFood>(
              (json) => nd2.MealFood.fromAIMeal(json as Map<String, dynamic>))
          .toList();

      final totalCalories = meals.fold(0.0, (sum, meal) => sum + meal.calories);

      setState(() {
        if (_dailyData[dateKey] != null && !_dailyData[dateKey]!.isAIMealPlan) {
          // Add to existing meals if not AI plan
          _dailyData[dateKey]!.meals.addAll(meals);
          _dailyData[dateKey] = DayData(
            date: dateKey,
            totalCalories: _dailyData[dateKey]!.totalCalories + totalCalories,
            meals: _dailyData[dateKey]!.meals,
            sportSessions: _dailyData[dateKey]!.sportSessions,
            waterConsumed: _dailyData[dateKey]!.waterConsumed,
            isAIMealPlan: false,
          );
        } else if (_dailyData[dateKey] == null) {
          _dailyData[dateKey] = DayData(
            date: dateKey,
            totalCalories: totalCalories,
            meals: meals,
            sportSessions: [],
            waterConsumed: 0,
            isAIMealPlan: false,
          );
        }
      });
    }

    // Load weekly AI meals
    final weeklyMealsJson = prefs.getString('saved_weekly_meals');
    if (weeklyMealsJson != null) {
      final Map<String, dynamic> weeklyData = jsonDecode(weeklyMealsJson);

      weeklyData.forEach((dayName, meals) {
        // Convert day name to date (assuming current week)
        final dayIndex = _getDayIndex(dayName);
        if (dayIndex != -1) {
          final now = DateTime.now();
          final weekday = now.weekday;
          final daysToAdd =
              dayIndex - weekday + 1; // +1 because weekday starts at 1
          final targetDate = now.add(Duration(days: daysToAdd));
          final dateKey =
              DateTime(targetDate.year, targetDate.month, targetDate.day);

          final List<nd2.MealFood> mealsList = (meals as List)
              .map<nd2.MealFood>((json) =>
                  nd2.MealFood.fromAIMeal(json as Map<String, dynamic>))
              .toList();

          final totalCalories =
              mealsList.fold(0.0, (sum, meal) => sum + meal.calories);

          setState(() {
            _dailyData[dateKey] = DayData(
              date: dateKey,
              totalCalories: totalCalories,
              meals: mealsList,
              sportSessions: _dailyData[dateKey]?.sportSessions ?? [],
              waterConsumed: _dailyData[dateKey]?.waterConsumed ?? 0,
              isAIMealPlan: true,
            );
          });
        }
      });
    }
  }

  int _getDayIndex(String dayName) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
    return days.indexOf(dayName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier Nutritionnel'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: FreshTheme.cloudWhite,
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(height: 1),
          Expanded(
            child: ValueListenableBuilder<DateTime>(
              valueListenable: _selectedDay,
              builder: (context, selectedDay, _) {
                return _buildDayDetails(selectedDay);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      color: Colors.white,
      child: TableCalendar<DayData>(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: _focusedDay.value,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay.value, day),
        eventLoader: (day) {
          final dateKey = DateTime(day.year, day.month, day.day);
          return _dailyData[dateKey] != null ? [_dailyData[dateKey]!] : [];
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: const BoxDecoration(
            color: FreshTheme.primaryMint,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: FreshTheme.primaryMint.withAlpha(80),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: FreshTheme.accentCoral,
            shape: BoxShape.circle,
          ),
          markersAlignment: Alignment.bottomCenter,
          markersMaxCount: 1,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: FreshTheme.primaryMint.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: const TextStyle(
            color: FreshTheme.primaryMint,
            fontSize: 14,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay.value, selectedDay)) {
            setState(() {
              _selectedDay.value = selectedDay;
              _focusedDay.value = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay.value = focusedDay;
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;

            final data = events.first;
            final hasCompleteMeals = data.meals.length >= 3;
            final hasSport = data.sportSessions.isNotEmpty;

            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasCompleteMeals)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (hasSport)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: const BoxDecoration(
                        color: FreshTheme.accentCoral,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (data.isAIMealPlan)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: const BoxDecoration(
                        color: FreshTheme.serenityBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayDetails(DateTime selectedDay) {
    final dayData = _dailyData[
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day)];

    if (dayData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune donnée pour cette date',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          _buildDayHeader(selectedDay, dayData),
          const SizedBox(height: 24),

          // Meals Section
          if (dayData.meals.isNotEmpty) ...[
            _buildSectionHeader(
                'Repas', Icons.restaurant_menu_rounded, Colors.green),
            const SizedBox(height: 12),
            ...dayData.meals.map((meal) => _buildMealItem(meal)),
          ],

          if (dayData.sportSessions.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader(
                'Sport', Icons.fitness_center_rounded, FreshTheme.serenityBlue),
            const SizedBox(height: 12),
            ...dayData.sportSessions.map((session) => _buildSportItem(session)),
          ],

          const SizedBox(height: 24),

          // Summary Card
          _buildSummaryCard(dayData),
        ],
      ),
    );
  }

  Widget _buildDayHeader(DateTime selectedDay, DayData dayData) {
    return Card(
      elevation: 2,
      shadowColor: FreshTheme.primaryMint.withAlpha(60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: FreshTheme.primaryMint,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(selectedDay),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: FreshTheme.primaryMint,
                      ),
                ),
                if (dayData.isAIMealPlan) ...[
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: FreshTheme.serenityBlue.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: FreshTheme.serenityBlue,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Plan IA',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: FreshTheme.serenityBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Calories',
                    '${dayData.totalCalories.round()} kcal',
                    Icons.local_fire_department_rounded,
                    FreshTheme.accentCoral,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Eau',
                    '${(dayData.waterConsumed / 1000).toStringAsFixed(1)} L',
                    Icons.water_drop_rounded,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: FreshTheme.stormGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMealItem(nd2.MealFood meal) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withAlpha(20),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withAlpha(30),
          child: const Icon(Icons.restaurant, color: Colors.green, size: 20),
        ),
        title: Text(meal.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${meal.calories.round()} kcal • P:${meal.proteins}g G:${meal.carbs}g L:${meal.fats}g',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildSportItem(nd2.SportSession session) {
    final calories = _calculateSessionCalories(session);
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withAlpha(20),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getIntensityColor(session.intensity).withAlpha(30),
          child: Icon(
            _getSportIcon(session.sportName),
            color: _getIntensityColor(session.intensity),
            size: 20,
          ),
        ),
        title: Text(session.sportName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${session.duration} min • ${_getIntensityLabel(session.intensity)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          '-${calories.round()} kcal',
          style: const TextStyle(
            color: FreshTheme.accentCoral,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(DayData dayData) {
    return Card(
      elevation: 2,
      shadowColor: FreshTheme.serenityBlue.withAlpha(60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: FreshTheme.serenityBlue.withAlpha(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSectionHeader('Résumé du jour', Icons.insights_rounded,
                FreshTheme.serenityBlue),
            const SizedBox(height: 12),
            _buildSummaryRow('Repas consommés', '${dayData.meals.length}'),
            _buildSummaryRow(
                'Séances de sport', '${dayData.sportSessions.length}'),
            _buildSummaryRow(
              'Calories sport',
              '-${_calculateTotalSportCalories(dayData.sportSessions).round()} kcal',
            ),
            const Divider(height: 20),
            _buildSummaryRow(
              'Balance calorique',
              '${(dayData.totalCalories - _calculateTotalSportCalories(dayData.sportSessions)).round()} kcal',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                : textTheme.bodyMedium?.copyWith(color: FreshTheme.stormGray),
          ),
          Text(
            value,
            style: isTotal
                ? textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: FreshTheme.primaryMint)
                : textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: FreshTheme.midnightGray),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    const weekdays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];

    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  double _calculateTotalSportCalories(List<nd2.SportSession> sessions) {
    return sessions.fold(0.0, (total, session) {
      return total + _calculateSessionCalories(session);
    });
  }

  double _calculateSessionCalories(nd2.SportSession session) {
    const baseCaloriesPerMinute = {
      nd2.SportIntensity.low: 3.5,
      nd2.SportIntensity.medium: 7.0,
      nd2.SportIntensity.high: 11.0,
      nd2.SportIntensity.extreme: 15.0,
    };

    return (baseCaloriesPerMinute[session.intensity] ?? 7.0) * session.duration;
  }

  Color _getIntensityColor(nd2.SportIntensity intensity) {
    switch (intensity) {
      case nd2.SportIntensity.low:
        return Colors.green;
      case nd2.SportIntensity.medium:
        return Colors.blue;
      case nd2.SportIntensity.high:
        return Colors.orange;
      case nd2.SportIntensity.extreme:
        return Colors.red;
    }
  }

  String _getIntensityLabel(nd2.SportIntensity intensity) {
    switch (intensity) {
      case nd2.SportIntensity.low:
        return 'Faible';
      case nd2.SportIntensity.medium:
        return 'Modérée';
      case nd2.SportIntensity.high:
        return 'Élevée';
      case nd2.SportIntensity.extreme:
        return 'Extrême';
    }
  }

  IconData _getSportIcon(String sportName) {
    const sportIcons = {
      'Course à pied': Icons.directions_run,
      'Natation': Icons.pool,
      'Cyclisme': Icons.directions_bike,
      'Musculation': Icons.fitness_center,
      'Football': Icons.sports_soccer,
      'Tennis': Icons.sports_tennis,
      'Basketball': Icons.sports_basketball,
      'Yoga': Icons.self_improvement,
      'Randonnée': Icons.hiking,
      'Danse': Icons.music_note,
    };
    return sportIcons[sportName] ?? Icons.sports;
  }
}

class DayData {
  final DateTime date;
  final double totalCalories;
  final List<nd2.MealFood> meals;
  final List<nd2.SportSession> sportSessions;
  final double waterConsumed;
  final bool isAIMealPlan;

  DayData({
    required this.date,
    required this.totalCalories,
    required this.meals,
    required this.sportSessions,
    required this.waterConsumed,
    this.isAIMealPlan = false,
  });
}
