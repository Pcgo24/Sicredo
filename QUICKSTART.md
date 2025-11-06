# Firebase Quick Start Guide

Quick reference for getting started with Firebase in the Sicredo app.

## Prerequisites Checklist

- [ ] Flutter SDK installed (>=3.0.0)
- [ ] Firebase account created
- [ ] Git repository cloned
- [ ] Internet connection available

## Quick Setup (5 minutes)

### 1. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 2. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select existing project
3. Note your project ID (e.g., `sicredo-dev`)

### 3. Enable Firestore

1. In Firebase Console, click "Firestore Database"
2. Click "Create database"
3. Choose "Start in production mode" (we have security rules)
4. Select location (e.g., `southamerica-east1` for Brazil)
5. Click "Enable"

### 4. Configure Your App

Run this in the project root:

```bash
# Install dependencies
flutter pub get

# Configure Firebase (follow prompts)
flutterfire configure
```

This will:
- Generate `lib/firebase_options.dart`
- Download platform config files
- Set up Android, iOS, Web, and macOS

### 5. Deploy Security Rules

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login
firebase login

# Initialize (select Firestore)
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

### 6. Run the App

```bash
flutter run
```

## Verify Setup

✅ App starts without errors  
✅ You see "Firebase initialized" in logs  
✅ You can add transactions  
✅ Transactions appear in Firebase Console

## Common Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Run integration tests
flutter test integration_test/

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Start local emulator (optional)
firebase emulators:start
```

## Project Structure

```
lib/
├── firebase_options.dart          # Firebase config (generated)
├── main.dart                      # App entry + Firebase init
├── data/
│   ├── models/
│   │   └── transaction_model.dart # Data model
│   └── repositories/
│       └── transaction_repository.dart # Firestore operations
└── screens/
    └── home_screen.dart           # UI using repository

firebase/
├── firestore.rules                # Security rules
└── firestore.indexes.json         # Index definitions
```

## Key Code Locations

**Firebase Initialization:**
```dart
// lib/main.dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

**Repository Usage:**
```dart
// lib/screens/home_screen.dart
final repository = TransactionRepository();
await repository.insertTransaction(transaction);
```

**Model Serialization:**
```dart
// lib/data/models/transaction_model.dart
transaction.toMap()              // To Firestore
TransactionModel.fromFirestore() // From Firestore
```

## Environment Variables

For multiple environments (dev/prod):

```bash
# Development
flutter run --dart-define=ENV=dev

# Production
flutter run --dart-define=ENV=prod
flutter build apk --dart-define=ENV=prod
```

## Testing

```bash
# Unit tests (use FakeFirebaseFirestore)
flutter test test/data/

# Integration tests
flutter test integration_test/

# Single test file
flutter test test/data/repositories/transaction_repository_test.dart
```

## Troubleshooting Quick Fixes

### "Default FirebaseApp is not initialized"
```bash
# Ensure firebase_options.dart exists
ls lib/firebase_options.dart

# Re-run flutterfire configure
flutterfire configure
```

### "google-services.json not found" (Android)
```bash
# Check file exists
ls android/app/google-services.json

# If missing, re-run:
flutterfire configure
```

### "GoogleService-Info.plist not found" (iOS)
```bash
# Check file exists
ls ios/Runner/GoogleService-Info.plist

# If missing, re-run:
flutterfire configure
```

### "PERMISSION_DENIED" when accessing Firestore
```bash
# Check security rules are deployed
firebase deploy --only firestore:rules

# For development, temporarily allow all (NOT for production):
# Edit firebase/firestore.rules:
# match /{document=**} { allow read, write: if true; }
```

### Tests failing
```bash
# Clean and rebuild
flutter clean
flutter pub get

# Ensure fake_cloud_firestore is installed
flutter pub get

# Run specific test
flutter test test/data/repositories/transaction_repository_test.dart -v
```

### Build errors
```bash
# Flutter clean
flutter clean
rm -rf build/

# Android clean
cd android && ./gradlew clean && cd ..

# iOS clean
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..

# Rebuild
flutter pub get
flutter run
```

## Platform-Specific Quick Links

- **Android Setup:** [ANDROID_FIREBASE_SETUP.md](ANDROID_FIREBASE_SETUP.md)
- **iOS Setup:** [IOS_FIREBASE_SETUP.md](IOS_FIREBASE_SETUP.md)
- **Complete Guide:** [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- **Migration Guide:** [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)

## Firestore Console

Access your data:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click "Firestore Database"
4. Navigate: `users/{userId}/transactions`

## Security Rules Testing

Test rules in Firebase Console:
1. Firestore Database → Rules tab
2. Click "Rules Playground"
3. Test read/write operations
4. Verify permissions work correctly

## Next Steps After Setup

1. ✅ **Test basic functionality** - Add/delete transactions
2. ✅ **Check data in console** - Verify Firestore updates
3. ✅ **Run tests** - Ensure all tests pass
4. 🔄 **Add authentication** - See [FIREBASE_SETUP.md](FIREBASE_SETUP.md#7-autenticação-opcional)
5. 🔄 **Customize UI** - Modify screens as needed
6. 🔄 **Deploy to production** - Build release versions

## Support

- **Setup Issues:** See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) → Troubleshooting
- **Migration Questions:** See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)
- **Platform Issues:** See platform-specific guides
- **Firebase Docs:** https://firebase.flutter.dev/

## Quick Tips

💡 **Tip 1:** Use `flutter run -v` for verbose logging  
💡 **Tip 2:** Keep Firebase Console open to monitor data changes  
💡 **Tip 3:** Use emulator for local testing (no quota usage)  
💡 **Tip 4:** Enable offline persistence for better UX  
💡 **Tip 5:** Test security rules before deploying to production

## Status Indicators

During development, watch for:

✅ **Good Signs:**
- Firebase initialization log appears
- Transactions save successfully
- Data appears in Firebase Console
- Tests pass

⚠️ **Warning Signs:**
- Permission denied errors → Check security rules
- Network errors → Check internet connection
- Initialization errors → Check config files
- Build errors → Clean and rebuild

🚫 **Critical Issues:**
- App crashes on startup → Check Firebase init
- Data not persisting → Check repository calls
- Tests all failing → Check dependencies

---

**Ready to start?** Run:
```bash
flutterfire configure && flutter run
```

**Need help?** Check the detailed guides in the links above.
