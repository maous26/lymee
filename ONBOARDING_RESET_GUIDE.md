# Onboarding Reset for Testing

## 📋 Overview
This guide explains how to reset the onboarding process for testing purposes in the Lym Nutrition Flutter app.

## ✅ Current Status: TESTING MODE ACTIVE

The onboarding will now reset **every time** the app is launched, allowing you to test the complete onboarding flow repeatedly.

## 🔧 Implementation Details

### Modified File
- **File**: `/lib/data/datasources/local/user_profile_data_source.dart`
- **Method**: `hasCompletedOnboarding()`
- **Change**: Always returns `false` instead of checking SharedPreferences

### Code Changes
```dart
/// Vérifie si l'utilisateur a terminé l'onboarding
Future<bool> hasCompletedOnboarding() async {
  // TESTING MODE: Always return false to reset onboarding on each app launch
  // This forces the onboarding to restart every time for testing purposes
  // TODO: Remove this when moving to production
  return false;
  
  // Original implementation (commented out for testing):
  // return sharedPreferences.getBool(HAS_COMPLETED_ONBOARDING_KEY) ?? false;
}
```

## 🔄 How to Toggle Between Testing and Production Mode

### Enable Testing Mode (Current State)
```dart
Future<bool> hasCompletedOnboarding() async {
  return false; // Always show onboarding
}
```

### Restore Production Mode (When Ready for Release)
```dart
Future<bool> hasCompletedOnboarding() async {
  return sharedPreferences.getBool(HAS_COMPLETED_ONBOARDING_KEY) ?? false;
}
```

## 🧪 Testing Workflow

1. **Launch App**: Onboarding will always start from the beginning
2. **Complete Onboarding**: Go through all steps and save profile
3. **Close App**: Completely close the Flutter app
4. **Relaunch App**: Onboarding will restart automatically
5. **Repeat**: Test different scenarios and user flows

## 🎯 What This Enables

- ✅ Test all onboarding steps repeatedly
- ✅ Verify French translations work correctly
- ✅ Test new orange/green/purple color scheme
- ✅ Validate user input validation
- ✅ Ensure profile data is saved correctly
- ✅ Test navigation between onboarding steps

## ⚠️ Important Notes

- **DO NOT** deploy to production with testing mode enabled
- Remember to restore the original implementation before release
- The `TODO` comment serves as a reminder to change this back
- User profiles are still saved normally, only the completion check is bypassed

## 🚀 Ready for Production

When ready to release:

1. Uncomment the original line:
   ```dart
   return sharedPreferences.getBool(HAS_COMPLETED_ONBOARDING_KEY) ?? false;
   ```

2. Remove the testing return statement:
   ```dart
   return false;
   ```

3. Remove the testing comments

4. Test that onboarding works normally (shows once, then remembers completion)

## 📱 Verification

The following log messages confirm the reset is working:
```
flutter: Vérification de l'état d'onboarding...
flutter: Onboarding complété: false
flutter: État d'onboarding détecté: non complété
```

---
**Last Updated**: 30 mai 2025  
**Status**: Testing Mode Active ✅
