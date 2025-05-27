// lib/domain/entities/user_dietary_preferences.dart

class UserDietaryPreferences {
  final bool isVegetarian;
  final bool isVegan;
  final bool isHalal;
  final bool isKosher;
  final bool isGlutenFree;
  final bool isLactoseFree;
  final List<String> allergies;

  UserDietaryPreferences({
    this.isVegetarian = false,
    this.isVegan = false,
    this.isHalal = false,
    this.isKosher = false,
    this.isGlutenFree = false,
    this.isLactoseFree = false,
    this.allergies = const [],
  });

  UserDietaryPreferences copyWith({
    bool? isVegetarian,
    bool? isVegan,
    bool? isHalal,
    bool? isKosher,
    bool? isGlutenFree,
    bool? isLactoseFree,
    List<String>? allergies,
  }) {
    return UserDietaryPreferences(
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isHalal: isHalal ?? this.isHalal,
      isKosher: isKosher ?? this.isKosher,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isLactoseFree: isLactoseFree ?? this.isLactoseFree,
      allergies: allergies ?? this.allergies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isHalal': isHalal,
      'isKosher': isKosher,
      'isGlutenFree': isGlutenFree,
      'isLactoseFree': isLactoseFree,
      'allergies': allergies,
    };
  }

  factory UserDietaryPreferences.fromJson(Map<String, dynamic> json) {
    return UserDietaryPreferences(
      isVegetarian: json['isVegetarian'] ?? false,
      isVegan: json['isVegan'] ?? false,
      isHalal: json['isHalal'] ?? false,
      isKosher: json['isKosher'] ?? false,
      isGlutenFree: json['isGlutenFree'] ?? false,
      isLactoseFree: json['isLactoseFree'] ?? false,
      allergies: List<String>.from(json['allergies'] ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserDietaryPreferences &&
        other.isVegetarian == isVegetarian &&
        other.isVegan == isVegan &&
        other.isHalal == isHalal &&
        other.isKosher == isKosher &&
        other.isGlutenFree == isGlutenFree &&
        other.isLactoseFree == isLactoseFree &&
        _listEquals(other.allergies, allergies);
  }

  @override
  int get hashCode {
    return isVegetarian.hashCode ^
        isVegan.hashCode ^
        isHalal.hashCode ^
        isKosher.hashCode ^
        isGlutenFree.hashCode ^
        isLactoseFree.hashCode ^
        allergies.hashCode;
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
