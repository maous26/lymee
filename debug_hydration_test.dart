// Simple test to verify hydration data synchronization
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HydrationDebugScreen(),
    );
  }
}

class HydrationDebugScreen extends StatefulWidget {
  @override
  _HydrationDebugScreenState createState() => _HydrationDebugScreenState();
}

class _HydrationDebugScreenState extends State<HydrationDebugScreen> {
  String _debugOutput = '';

  @override
  void initState() {
    super.initState();
    _checkHydrationData();
  }

  Future<void> _checkHydrationData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    
    String output = '🔍 Hydration Debug Report\n';
    output += '=' * 40 + '\n';
    output += 'Date: $today\n\n';
    
    // Check journal data
    final journalKey = 'journal_$today';
    final journalData = prefs.getString(journalKey);
    output += 'Journal Key: $journalKey\n';
    
    if (journalData != null) {
      try {
        final decoded = jsonDecode(journalData) as Map<String, dynamic>;
        output += '✅ Journal data found:\n';
        output += '   Hydration: ${decoded['hydration'] ?? 'NOT FOUND'}\n';
        output += '   Other keys: ${decoded.keys.toList()}\n';
      } catch (e) {
        output += '❌ Error parsing journal data: $e\n';
      }
    } else {
      output += '❌ No journal data found\n';
    }
    
    // Check all keys
    final allKeys = prefs.getKeys().where((key) => 
      key.contains('water') || key.contains('journal') || key.contains('hydration')
    ).toList();
    
    output += '\nAll relevant keys:\n';
    for (final key in allKeys) {
      final value = prefs.get(key);
      output += '  $key: $value\n';
    }
    
    setState(() {
      _debugOutput = output;
    });
  }

  Future<void> _setTestData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final journalKey = 'journal_$today';
    
    final testData = {
      'calories': 0,
      'protein': 0,
      'carbs': 0,
      'fat': 0,
      'meals': [],
      'sports': [],
      'hydration': 2500, // Test value
    };
    
    await prefs.setString(journalKey, jsonEncode(testData));
    
    setState(() {
      _debugOutput += '\n\n✅ Test data set with 2500ml hydration\n';
    });
    
    _checkHydrationData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hydration Debug'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _checkHydrationData,
          ),
          IconButton(
            icon: Icon(Icons.science),
            onPressed: _setTestData,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _checkHydrationData,
              child: Text('Check Data'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _setTestData,
              child: Text('Set Test Data'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _debugOutput,
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
