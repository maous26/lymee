// Re-export canonical gamification models from domain so UI can import from this path
export 'package:lym_nutrition/domain/entities/gamification_models.dart';

// Intentionally no local GamificationService here — use the core SharedPreferences-backed service.
// This file keeps the previous import path stable for widgets while preventing duplicate symbols.
