// Clear CIQUAL cache script
// Run this with: dart run clear_ciqual_cache.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final prefs = await SharedPreferences.getInstance();

    // Clear CIQUAL cache
    await prefs.remove('CIQUAL_DATA');
    await prefs.remove('CIQUAL_INITIALIZED');

    print('✅ Cache CIQUAL effacé avec succès!');
    print('🔄 Redémarrez l\'application pour recharger les nouvelles données.');
  } catch (e) {
    print('❌ Erreur lors de l\'effacement du cache: $e');
  }
}
