// lib/domain/entities/user_profile.dart
import 'package:equatable/equatable.dart';
import 'package:lym_nutrition/domain/entities/user_dietary_preferences.dart';

enum Gender { male, female, other }

enum ActivityLevel {
  sedentary, // Activité physique minimale
  lightlyActive, // Activité légère (1-3 jours par semaine)
  moderatelyActive, // Activité modérée (3-5 jours par semaine)
  veryActive, // Activité intense (6-7 jours par semaine)
  extremelyActive // Activité très intense (athlètes professionnels)
}

enum WeightGoal {
  lose, // Perte de poids
  maintain, // Maintien du poids
  gain, // Prise de poids
  healthyEating // Manger sainement (nouveau)
}

enum IntermittentFastingType {
  none, // Pas de jeûne intermittent
  fasting16_8, // Jeûne 16/8 (16h de jeûne, 8h de prise alimentaire)
  fasting18_6, // Jeûne 18/6
  fasting20_4, // Jeûne 20/4 (warrior diet)
  fasting5_2, // 5 jours normaux, 2 jours à calories réduites
  alternateDay, // Jeûne un jour sur deux
  custom // Paramètres personnalisés
}

enum CookingLevel {
  beginner, // Débutant - repas simples, peu d'expérience
  intermediate, // Intermédiaire - peut suivre des recettes variées
  advanced, // Avancé - maîtrise les techniques, créatif
  expert // Expert - chef ou passionné, techniques complexes
}

enum CookingTime {
  minimal, // < 15 min par repas
  short, // 15-30 min par repas
  moderate, // 30-60 min par repas
  long // > 60 min par repas
}

enum FoodBudget {
  tight, // Budget serré (< 50€/semaine)
  moderate, // Budget modéré (50-100€/semaine)
  comfortable, // Budget confortable (100-150€/semaine)
  generous // Budget généreux (> 150€/semaine)
}

enum SportIntensity {
  low, // Faible intensité (marche, yoga doux)
  medium, // Intensité moyenne (jogging, vélo, natation)
  high, // Haute intensité (HIIT, course, musculation)
  extreme // Intensité extrême (sports de compétition, crossfit intensif)
}

class UserSportActivity {
  final String name;
  final SportIntensity intensity;
  final int minutesPerSession;
  final int sessionsPerWeek;

  UserSportActivity({
    required this.name,
    required this.intensity,
    required this.minutesPerSession,
    required this.sessionsPerWeek,
  });

  // Calcule les calories brûlées par semaine (estimation simplifiée)
  int estimateCaloriesBurnedPerWeek(double weightKg) {
    double caloriesPerMinute;

    switch (intensity) {
      case SportIntensity.low:
        caloriesPerMinute = 0.05 * weightKg;
        break;
      case SportIntensity.medium:
        caloriesPerMinute = 0.1 * weightKg;
        break;
      case SportIntensity.high:
        caloriesPerMinute = 0.15 * weightKg;
        break;
      case SportIntensity.extreme:
        caloriesPerMinute = 0.2 * weightKg;
        break;
    }

    return (caloriesPerMinute * minutesPerSession * sessionsPerWeek).round();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'intensity': intensity.index,
      'minutesPerSession': minutesPerSession,
      'sessionsPerWeek': sessionsPerWeek,
    };
  }

  factory UserSportActivity.fromJson(Map<String, dynamic> json) {
    return UserSportActivity(
      name: json['name'],
      intensity: SportIntensity.values[json['intensity']],
      minutesPerSession: json['minutesPerSession'],
      sessionsPerWeek: json['sessionsPerWeek'],
    );
  }
}

class MealPlanningPreferences {
  final CookingLevel cookingLevel;
  final CookingTime weekdayCookingTime;
  final CookingTime weekendCookingTime;
  final FoodBudget weeklyBudget;
  final double? specificBudgetAmount; // Optional specific amount in euros

  MealPlanningPreferences({
    required this.cookingLevel,
    required this.weekdayCookingTime,
    required this.weekendCookingTime,
    required this.weeklyBudget,
    this.specificBudgetAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'cookingLevel': cookingLevel.index,
      'weekdayCookingTime': weekdayCookingTime.index,
      'weekendCookingTime': weekendCookingTime.index,
      'weeklyBudget': weeklyBudget.index,
      'specificBudgetAmount': specificBudgetAmount,
    };
  }

  factory MealPlanningPreferences.fromJson(Map<String, dynamic> json) {
    return MealPlanningPreferences(
      cookingLevel: CookingLevel.values[json['cookingLevel'] ?? 0],
      weekdayCookingTime: CookingTime.values[json['weekdayCookingTime'] ?? 1],
      weekendCookingTime: CookingTime.values[json['weekendCookingTime'] ?? 2],
      weeklyBudget: FoodBudget.values[json['weeklyBudget'] ?? 1],
      specificBudgetAmount: json['specificBudgetAmount']?.toDouble(),
    );
  }

  factory MealPlanningPreferences.defaultPreferences() {
    return MealPlanningPreferences(
      cookingLevel: CookingLevel.intermediate,
      weekdayCookingTime: CookingTime.short,
      weekendCookingTime: CookingTime.moderate,
      weeklyBudget: FoodBudget.moderate,
    );
  }

  MealPlanningPreferences copyWith({
    CookingLevel? cookingLevel,
    CookingTime? weekdayCookingTime,
    CookingTime? weekendCookingTime,
    FoodBudget? weeklyBudget,
    double? specificBudgetAmount,
  }) {
    return MealPlanningPreferences(
      cookingLevel: cookingLevel ?? this.cookingLevel,
      weekdayCookingTime: weekdayCookingTime ?? this.weekdayCookingTime,
      weekendCookingTime: weekendCookingTime ?? this.weekendCookingTime,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      specificBudgetAmount: specificBudgetAmount ?? this.specificBudgetAmount,
    );
  }
}

class IntermittentFastingSchedule {
  final IntermittentFastingType type;
  final int fastingHours; // Pour les types personnalisés
  final int eatingHours; // Pour les types personnalisés
  final List<int> fastingDays; // Pour 5:2 ou alternance (1-7, où 1=lundi)
  final String fastingStartTime; // Format "HH:MM", exemple "20:00"
  final String fastingEndTime; // Format "HH:MM", exemple "12:00"

  IntermittentFastingSchedule({
    required this.type,
    this.fastingHours = 16,
    this.eatingHours = 8,
    this.fastingDays = const [],
    this.fastingStartTime = "20:00",
    this.fastingEndTime = "12:00",
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'fastingHours': fastingHours,
      'eatingHours': eatingHours,
      'fastingDays': fastingDays,
      'fastingStartTime': fastingStartTime,
      'fastingEndTime': fastingEndTime,
    };
  }

  factory IntermittentFastingSchedule.fromJson(Map<String, dynamic> json) {
    return IntermittentFastingSchedule(
      type: IntermittentFastingType.values[json['type']],
      fastingHours: json['fastingHours'] ?? 16,
      eatingHours: json['eatingHours'] ?? 8,
      fastingDays: List<int>.from(json['fastingDays'] ?? []),
      fastingStartTime: json['fastingStartTime'] ?? "20:00",
      fastingEndTime: json['fastingEndTime'] ?? "12:00",
    );
  }

  factory IntermittentFastingSchedule.defaultSchedule() {
    return IntermittentFastingSchedule(
      type: IntermittentFastingType.none,
    );
  }

  // Créer un horaire basé sur le type de jeûne
  factory IntermittentFastingSchedule.fromType(IntermittentFastingType type) {
    switch (type) {
      case IntermittentFastingType.none:
        return IntermittentFastingSchedule(type: type);
      case IntermittentFastingType.fasting16_8:
        return IntermittentFastingSchedule(
          type: type,
          fastingHours: 16,
          eatingHours: 8,
          fastingStartTime: "20:00",
          fastingEndTime: "12:00",
        );
      case IntermittentFastingType.fasting18_6:
        return IntermittentFastingSchedule(
          type: type,
          fastingHours: 18,
          eatingHours: 6,
          fastingStartTime: "18:00",
          fastingEndTime: "12:00",
        );
      case IntermittentFastingType.fasting20_4:
        return IntermittentFastingSchedule(
          type: type,
          fastingHours: 20,
          eatingHours: 4,
          fastingStartTime: "18:00",
          fastingEndTime: "14:00",
        );
      case IntermittentFastingType.fasting5_2:
        return IntermittentFastingSchedule(
          type: type,
          fastingDays: [1, 4], // Lundi et jeudi par défaut
        );
      case IntermittentFastingType.alternateDay:
        return IntermittentFastingSchedule(
          type: type,
          fastingDays: [1, 3, 5, 7], // Lundi, mercredi, vendredi, dimanche
        );
      case IntermittentFastingType.custom:
        return IntermittentFastingSchedule(
          type: type,
          fastingHours: 16,
          eatingHours: 8,
          fastingStartTime: "20:00",
          fastingEndTime: "12:00",
        );
    }
  }

  IntermittentFastingSchedule copyWith({
    IntermittentFastingType? type,
    int? fastingHours,
    int? eatingHours,
    List<int>? fastingDays,
    String? fastingStartTime,
    String? fastingEndTime,
  }) {
    return IntermittentFastingSchedule(
      type: type ?? this.type,
      fastingHours: fastingHours ?? this.fastingHours,
      eatingHours: eatingHours ?? this.eatingHours,
      fastingDays: fastingDays ?? this.fastingDays,
      fastingStartTime: fastingStartTime ?? this.fastingStartTime,
      fastingEndTime: fastingEndTime ?? this.fastingEndTime,
    );
  }
}

class Supplement {
  final String name;
  final String dosage;
  final String unit; // mg, mcg, g, UI, etc.
  final String timing; // Matin, midi, soir, avec repas, etc.
  final String? notes;

  Supplement({
    required this.name,
    required this.dosage,
    required this.unit,
    required this.timing,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'unit': unit,
      'timing': timing,
      'notes': notes,
    };
  }

  factory Supplement.fromJson(Map<String, dynamic> json) {
    return Supplement(
      name: json['name'],
      dosage: json['dosage'],
      unit: json['unit'],
      timing: json['timing'],
      notes: json['notes'],
    );
  }
}

// Add this class for calculated needs
class CalculatedDailyNeeds extends Equatable {
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams;

  const CalculatedDailyNeeds({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.fiberGrams,
  });

  @override
  List<Object?> get props =>
      [calories, proteinGrams, carbsGrams, fatGrams, fiberGrams];

  // Optional: Add toJson and fromJson if you need to serialize this separately
  Map<String, dynamic> toJson() => {
        'calories': calories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'fiberGrams': fiberGrams,
      };

  factory CalculatedDailyNeeds.fromJson(Map<String, dynamic> json) =>
      CalculatedDailyNeeds(
        calories: (json['calories'] as num?)?.toDouble() ?? 0,
        proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 0,
        carbsGrams: (json['carbsGrams'] as num?)?.toDouble() ?? 0,
        fatGrams: (json['fatGrams'] as num?)?.toDouble() ?? 0,
        fiberGrams: (json['fiberGrams'] as num?)?.toDouble() ?? 0,
      );
}

class UserProfile extends Equatable {
  final String userId;
  final String? name;
  final int age;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final List<UserSportActivity> sportActivities;
  final WeightGoal weightGoal;
  final double weightGoalKgPerWeek; // Combien de kg par semaine (perte ou gain)
  final UserDietaryPreferences dietaryPreferences;
  final IntermittentFastingSchedule fastingSchedule;
  final List<Supplement> supplements;
  final MealPlanningPreferences mealPlanningPreferences;
  final Map<String, double>
      dailyNutrientGoals; // Nutriments personnalisés (legacy or specific overrides)
  final CalculatedDailyNeeds? calculatedDailyNeeds; // New field

  // Constructeur
  const UserProfile({
    required this.userId,
    this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    this.sportActivities = const [],
    required this.weightGoal,
    this.weightGoalKgPerWeek = 0.5,
    required this.dietaryPreferences,
    required this.fastingSchedule,
    this.supplements = const [],
    required this.mealPlanningPreferences,
    this.dailyNutrientGoals = const {},
    this.calculatedDailyNeeds, // Initialize new field
  });

  // Méthode pour calculer les besoins caloriques de base (BMR) avec l'équation de Mifflin-St Jeor
  double calculateBMR() {
    if (gender == Gender.male) {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  // Facteur d'activité basé sur le niveau d'activité
  double getActivityFactor() {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extremelyActive:
        return 1.9;
    }
  }

  // Calculer les calories brûlées par les activités sportives par jour
  double calculateSportCaloriesPerDay() {
    if (sportActivities.isEmpty) return 0;

    double totalCaloriesPerWeek = 0;
    for (var activity in sportActivities) {
      totalCaloriesPerWeek += activity.estimateCaloriesBurnedPerWeek(weightKg);
    }

    return totalCaloriesPerWeek / 7; // Moyenne par jour
  }

  // Calculer les besoins caloriques quotidiens totaux
  double calculateTDEE() {
    double bmr = calculateBMR();
    double activityFactor = getActivityFactor();
    double sportCalories = calculateSportCaloriesPerDay();

    return (bmr * activityFactor) + sportCalories;
  }

  // Calculer les besoins caloriques ajustés selon l'objectif de poids
  double calculateDailyCalories() {
    double tdee = calculateTDEE();

    switch (weightGoal) {
      case WeightGoal.lose:
        // Déficit calorique pour perdre du poids (1kg de graisse = ~7700 kcal)
        return tdee - ((weightGoalKgPerWeek * 7700) / 7);
      case WeightGoal.gain:
        // Surplus calorique pour gagner du poids
        return tdee + ((weightGoalKgPerWeek * 7700) / 7);
      case WeightGoal.maintain:
      case WeightGoal.healthyEating:
        // Pour maintenir le poids ou manger sainement, utiliser le TDEE
        return tdee;
    }
  }

  // Change return type to CalculatedDailyNeeds
  CalculatedDailyNeeds calculateMacroTargetsObject() {
    double dailyCalories = calculateDailyCalories();

    // Distribution par défaut des macros
    double proteinPercentage = 0.25; // 25% des calories
    double carbPercentage = 0.45; // 45% des calories
    double fatPercentage = 0.30; // 30% des calories

    // Ajuster selon l'objectif
    if (weightGoal == WeightGoal.lose) {
      proteinPercentage = 0.30;
      carbPercentage = 0.40;
      fatPercentage = 0.30;
    } else if (weightGoal == WeightGoal.gain) {
      proteinPercentage = 0.25;
      carbPercentage = 0.50;
      fatPercentage = 0.25;
    } else if (weightGoal == WeightGoal.healthyEating) {
      // Pour manger sainement, équilibre optimal
      proteinPercentage = 0.20;
      carbPercentage = 0.50;
      fatPercentage = 0.30;
    }

    // Calculer les grammes par macro
    double proteinGrams = (dailyCalories * proteinPercentage) /
        4; // 4 calories par gramme de protéine
    double carbGrams = (dailyCalories * carbPercentage) /
        4; // 4 calories par gramme de glucide
    double fatGrams =
        (dailyCalories * fatPercentage) / 9; // 9 calories par gramme de lipide

    // Calculer les fibres (25-30g par jour ou ~14g par 1000 calories)
    double fiberGrams = dailyCalories * 0.014;

    return CalculatedDailyNeeds(
      calories: dailyCalories,
      proteinGrams: proteinGrams,
      carbsGrams: carbGrams,
      fatGrams: fatGrams,
      fiberGrams: fiberGrams,
    );
  }

  // Keep the old method for compatibility if needed, or remove it
  Map<String, double> calculateMacroTargets() {
    final needs = calculateMacroTargetsObject();
    return {
      'calories': needs.calories,
      'protein': needs.proteinGrams,
      'carbs': needs.carbsGrams,
      'fat': needs.fatGrams,
      'fiber': needs.fiberGrams,
    };
  }

  // Vérifier si l'utilisateur devrait jeûner maintenant
  bool shouldBeFasting(DateTime now) {
    if (fastingSchedule.type == IntermittentFastingType.none) {
      return false;
    }

    // Pour les types basés sur des jours spécifiques (5:2, alternance)
    if (fastingSchedule.type == IntermittentFastingType.fasting5_2 ||
        fastingSchedule.type == IntermittentFastingType.alternateDay) {
      int dayOfWeek = now.weekday; // 1-7 où 1 est lundi
      return fastingSchedule.fastingDays.contains(dayOfWeek);
    }

    // Pour les types basés sur des heures (16:8, 18:6, 20:4, personnalisé)
    // Convertir les heures en minutes pour comparer facilement
    int currentMinutes = now.hour * 60 + now.minute;

    List<int> startTimeParts =
        fastingSchedule.fastingStartTime.split(':').map(int.parse).toList();
    int startMinutes = startTimeParts[0] * 60 + startTimeParts[1];

    List<int> endTimeParts =
        fastingSchedule.fastingEndTime.split(':').map(int.parse).toList();
    int endMinutes = endTimeParts[0] * 60 + endTimeParts[1];

    // Si l'heure de début est après l'heure de fin, cela signifie que le jeûne continue pendant la nuit
    if (startMinutes > endMinutes) {
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    } else {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
  }

  // Nombre d'heures jusqu'à la fin du jeûne
  double hoursUntilFastingEnds(DateTime now) {
    if (fastingSchedule.type == IntermittentFastingType.none ||
        !shouldBeFasting(now)) {
      return 0;
    }

    List<int> endTimeParts =
        fastingSchedule.fastingEndTime.split(':').map(int.parse).toList();

    DateTime endTime = DateTime(
        now.year, now.month, now.day, endTimeParts[0], endTimeParts[1]);

    // Si l'heure de fin est déjà passée aujourd'hui, elle sera demain
    if (endTime.isBefore(now)) {
      endTime = endTime.add(const Duration(days: 1));
    }

    return endTime.difference(now).inMinutes / 60;
  }

  // Nombre d'heures jusqu'au début du jeûne
  double hoursUntilFastingStarts(DateTime now) {
    if (fastingSchedule.type == IntermittentFastingType.none ||
        shouldBeFasting(now)) {
      return 0;
    }

    List<int> startTimeParts =
        fastingSchedule.fastingStartTime.split(':').map(int.parse).toList();

    DateTime startTime = DateTime(
        now.year, now.month, now.day, startTimeParts[0], startTimeParts[1]);

    // Si l'heure de début est déjà passée aujourd'hui, elle sera demain
    if (startTime.isBefore(now)) {
      startTime = startTime.add(const Duration(days: 1));
    }

    return startTime.difference(now).inMinutes / 60;
  }

  // Créer une copie avec des modifications
  UserProfile copyWith({
    String? userId,
    String? name,
    int? age,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    List<UserSportActivity>? sportActivities,
    WeightGoal? weightGoal,
    double? weightGoalKgPerWeek,
    UserDietaryPreferences? dietaryPreferences,
    IntermittentFastingSchedule? fastingSchedule,
    List<Supplement>? supplements,
    MealPlanningPreferences? mealPlanningPreferences,
    Map<String, double>? dailyNutrientGoals,
    CalculatedDailyNeeds? calculatedDailyNeeds, // Add to copyWith
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      sportActivities: sportActivities ?? this.sportActivities,
      weightGoal: weightGoal ?? this.weightGoal,
      weightGoalKgPerWeek: weightGoalKgPerWeek ?? this.weightGoalKgPerWeek,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      fastingSchedule: fastingSchedule ?? this.fastingSchedule,
      supplements: supplements ?? this.supplements,
      mealPlanningPreferences:
          mealPlanningPreferences ?? this.mealPlanningPreferences,
      dailyNutrientGoals: dailyNutrientGoals ?? this.dailyNutrientGoals,
      calculatedDailyNeeds:
          calculatedDailyNeeds ?? this.calculatedDailyNeeds, // Update copyWith
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'age': age,
      'gender': gender.index,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel.index,
      'sportActivities':
          sportActivities.map((activity) => activity.toJson()).toList(),
      'weightGoal': weightGoal.index,
      'weightGoalKgPerWeek': weightGoalKgPerWeek,
      'dietaryPreferences': dietaryPreferences.toJson(),
      'fastingSchedule': fastingSchedule.toJson(),
      'supplements': supplements.map((s) => s.toJson()).toList(),
      'mealPlanningPreferences': mealPlanningPreferences.toJson(),
      'dailyNutrientGoals': dailyNutrientGoals,
      'calculatedDailyNeeds': calculatedDailyNeeds?.toJson(), // Add to toJson
    };
  }

  // Créer à partir de JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      name: json['name'],
      age: json['age'],
      gender: Gender.values[json['gender']],
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      activityLevel: ActivityLevel.values[json['activityLevel']],
      sportActivities: (json['sportActivities'] as List? ?? [])
          .map((activity) => UserSportActivity.fromJson(activity))
          .toList(),
      weightGoal: WeightGoal.values[json['weightGoal']],
      weightGoalKgPerWeek:
          (json['weightGoalKgPerWeek'] as num?)?.toDouble() ?? 0.5,
      dietaryPreferences:
          UserDietaryPreferences.fromJson(json['dietaryPreferences']),
      fastingSchedule:
          IntermittentFastingSchedule.fromJson(json['fastingSchedule']),
      supplements: (json['supplements'] as List? ?? [])
          .map((s) => Supplement.fromJson(s))
          .toList(),
      mealPlanningPreferences: json['mealPlanningPreferences'] != null
          ? MealPlanningPreferences.fromJson(json['mealPlanningPreferences'])
          : MealPlanningPreferences.defaultPreferences(),
      dailyNutrientGoals:
          Map<String, double>.from(json['dailyNutrientGoals'] ?? {}),
      calculatedDailyNeeds: json['calculatedDailyNeeds'] != null
          ? CalculatedDailyNeeds.fromJson(json['calculatedDailyNeeds'])
          : null, // Add to fromJson
    );
  }

  // Props pour Equatable
  @override
  List<Object?> get props => [
        userId,
        name,
        age,
        gender,
        heightCm,
        weightKg,
        activityLevel,
        sportActivities,
        weightGoal,
        weightGoalKgPerWeek,
        dietaryPreferences,
        fastingSchedule,
        supplements,
        mealPlanningPreferences,
        dailyNutrientGoals,
        calculatedDailyNeeds, // Add to props
      ];

  // Méthode statique pour un profil utilisateur initial ou par défaut
  static UserProfile empty(String userId) {
    return UserProfile(
      userId: userId,
      age: 30,
      gender: Gender.other,
      heightCm: 170,
      weightKg: 70,
      activityLevel: ActivityLevel.moderatelyActive,
      weightGoal: WeightGoal.maintain,
      dietaryPreferences: UserDietaryPreferences(), // Changed this line
      fastingSchedule: IntermittentFastingSchedule.defaultSchedule(),
      mealPlanningPreferences: MealPlanningPreferences.defaultPreferences(),
      // Initialize calculatedDailyNeeds, perhaps by calculating it here or leaving it null
      // For example, to calculate it:
      // calculatedDailyNeeds: UserProfile(...).calculateMacroTargetsObject(), // This would require a temporary UserProfile instance
    );
  }

  // Helper to update profile with calculated needs
  UserProfile withCalculatedNeeds() {
    return copyWith(calculatedDailyNeeds: calculateMacroTargetsObject());
  }
}
