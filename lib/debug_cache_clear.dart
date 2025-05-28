// Quick debug method to clear CIQUAL cache
// Call this from anywhere in your app during development

import 'package:shared_preferences/shared_preferences.dart';

class DebugCacheClear {
  static Future<void> clearCiqualCache() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear CIQUAL cache keys
    await prefs.remove('CIQUAL_DATA');
    await prefs.remove('CIQUAL_INITIALIZED');
    
    print('✅ Cache CIQUAL effacé - redémarrez l\'app pour voir les nouvelles données');
  }
  
  // Alternative: Clear all SharedPreferences (nuclear option)
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🧹 Tout le cache effacé - redémarrez l\'app');
  }
}
