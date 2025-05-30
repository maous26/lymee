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
  gain // Prise de poids
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
  final Map<String, double> dailyNutrientGoals; // Nutriments personnalisés

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
    this.dailyNutrientGoals = const {},
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
        return tdee;
    }
  }

  // Calculer les objectifs de macronutriments
  Map<String, double> calculateMacroTargets() {
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

    return {
      'calories': dailyCalories,
      'protein': proteinGrams,
      'carbs': carbGrams,
      'fat': fatGrams,
      'fiber': fiberGrams,
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
    Map<String, double>? dailyNutrientGoals,
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
      dailyNutrientGoals: dailyNutrientGoals ?? this.dailyNutrientGoals,
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
      'supplements':
          supplements.map((supplement) => supplement.toJson()).toList(),
      'dailyNutrientGoals': dailyNutrientGoals,
    };
  }

  // Créer à partir de JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      name: json['name'],
      age: json['age'],
      gender: Gender.values[json['gender']],
      heightCm: json['heightCm'],
      weightKg: json['weightKg'],
      activityLevel: ActivityLevel.values[json['activityLevel']],
      sportActivities: (json['sportActivities'] as List?)
              ?.map((activity) => UserSportActivity.fromJson(activity))
              .toList() ??
          [],
      weightGoal: WeightGoal.values[json['weightGoal']],
      weightGoalKgPerWeek: json['weightGoalKgPerWeek'] ?? 0.5,
      dietaryPreferences:
          UserDietaryPreferences.fromJson(json['dietaryPreferences']),
      fastingSchedule: json['fastingSchedule'] != null
          ? IntermittentFastingSchedule.fromJson(json['fastingSchedule'])
          : IntermittentFastingSchedule.defaultSchedule(),
      supplements: (json['supplements'] as List?)
              ?.map((supplement) => Supplement.fromJson(supplement))
              .toList() ??
          [],
      dailyNutrientGoals:
          (json['dailyNutrientGoals'] as Map<String, dynamic>?)?.map(
                (key, value) =>
                    MapEntry(key, value is int ? value.toDouble() : value),
              ) ??
              {},
    );
  }

  // Créer un profil par défaut
  factory UserProfile.defaultProfile(String userId) {
    return UserProfile(
      userId: userId,
      name: null,
      age: 30,
      gender: Gender.male,
      heightCm: 175,
      weightKg: 70,
      activityLevel: ActivityLevel.moderatelyActive,
      sportActivities: [],
      weightGoal: WeightGoal.maintain,
      weightGoalKgPerWeek: 0.5,
      dietaryPreferences: UserDietaryPreferences(),
      fastingSchedule: IntermittentFastingSchedule.defaultSchedule(),
      supplements: [],
      dailyNutrientGoals: {},
    );
  }

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
        dailyNutrientGoals,
      ];
}
