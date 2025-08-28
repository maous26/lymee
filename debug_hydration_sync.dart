// Debug script to verify hydration data synchronization
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> debugHydrationSync() async {
  print('🔍 Debug: Hydration Synchronization Analysis');
  print('=' * 50);
  
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now().toIso8601String().split('T').first;
  
  print('📅 Today\'s date: $today');
  print('');
  
  // Check journal data
  final journalKey = 'journal_$today';
  final journalRaw = prefs.getString(journalKey);
  
  print('🗂️  Journal Key: $journalKey');
  if (journalRaw != null) {
    try {
      final journalData = jsonDecode(journalRaw) as Map<String, dynamic>;
      print('✅ Journal data found:');
      print('   Hydration: ${journalData['hydration'] ?? 'NOT FOUND'}');
      print('   Calories: ${journalData['calories'] ?? 0}');
      print('   Meals count: ${(journalData['meals'] as List?)?.length ?? 0}');
      print('   Sports count: ${(journalData['sports'] as List?)?.length ?? 0}');
      print('   Full data: $journalData');
    } catch (e) {
      print('❌ Error parsing journal data: $e');
      print('   Raw data: $journalRaw');
    }
  } else {
    print('❌ No journal data found for today');
  }
  
  print('');
  
  // Check legacy water data
  final waterKey = 'water_$today';
  final waterRaw = prefs.getString(waterKey);
  
  print('💧 Legacy Water Key: $waterKey');
  if (waterRaw != null) {
    print('✅ Legacy water data found: $waterRaw');
  } else {
    print('❌ No legacy water data found');
  }
  
  print('');
  
  // List all keys containing today's date
  final allKeys = prefs.getKeys();
  final todayKeys = allKeys.where((key) => key.contains(today)).toList();
  
  print('🔑 All keys for today ($today):');
  for (final key in todayKeys) {
    print('   - $key');
  }
  
  print('');
  print('🎯 Dashboard _loadHydrationData() simulation:');
  
  int consumed = 0;
  const int target = 2000;
  
  if (journalRaw != null) {
    try {
      final journalData = jsonDecode(journalRaw) as Map<String, dynamic>;
      consumed = (journalData['hydration'] as int?) ?? 0;
      print('✅ Dashboard would load: $consumed ml');
    } catch (e) {
      print('❌ Dashboard would fail to load data: $e');
    }
  } else {
    print('❌ Dashboard would show 0 ml (no journal data)');
  }
  
  print('');
  print('📊 Final result:');
  print('   Consumed: $consumed ml');
  print('   Target: $target ml');
  print('   Percentage: ${target > 0 ? (consumed / target * 100).clamp(0, 100) : 0}%');
}

void main() async {
  await debugHydrationSync();
}
