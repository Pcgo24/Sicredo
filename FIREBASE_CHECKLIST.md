# Firebase Setup Checklist

Use this checklist to ensure Firebase is properly configured for the Sicredo app.

## Pre-Setup

- [ ] Flutter SDK installed (run `flutter --version`)
- [ ] Firebase account created at [console.firebase.google.com](https://console.firebase.google.com/)
- [ ] Repository cloned locally
- [ ] Terminal/command prompt open in project directory

## Firebase Console Setup

- [ ] Created new Firebase project (or selected existing one)
- [ ] Project ID noted (e.g., `sicredo-dev`)
- [ ] Firestore Database enabled
- [ ] Firestore location selected (e.g., `southamerica-east1`)
- [ ] Starting mode selected (Production mode recommended)

## FlutterFire CLI

- [ ] FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)
- [ ] Added to PATH (run `flutterfire --version` to verify)
- [ ] Logged in to Firebase (if required by CLI)

## Project Configuration

- [ ] Ran `flutter pub get` successfully
- [ ] Ran `flutterfire configure` successfully
- [ ] Selected/created Firebase project
- [ ] Selected platforms (Android, iOS, Web, macOS as needed)
- [ ] Verified `lib/firebase_options.dart` was generated

## Android Configuration

- [ ] `android/app/google-services.json` file exists
- [ ] `android/build.gradle.kts` updated (if needed)
- [ ] `android/app/build.gradle.kts` has Google Services plugin
- [ ] Minimum SDK version is 21 or higher
- [ ] Android app builds without errors (`flutter build apk --debug`)

## iOS Configuration

- [ ] `ios/Runner/GoogleService-Info.plist` file exists
- [ ] File added to Xcode project (visible in Runner folder)
- [ ] File added to Runner target (check Target Membership)
- [ ] Pods installed (`cd ios && pod install && cd ..`)
- [ ] iOS deployment target is 12.0 or higher
- [ ] iOS app builds without errors (`flutter build ios --debug`)

## macOS Configuration (Optional)

- [ ] `macos/Runner/GoogleService-Info.plist` file exists
- [ ] File added to Xcode project
- [ ] File added to Runner target
- [ ] Pods installed (`cd macos && pod install && cd ..`)
- [ ] macOS deployment target is 10.13 or higher

## Web Configuration (Optional)

- [ ] Web configuration included in `firebase_options.dart`
- [ ] Web app registered in Firebase Console
- [ ] Web builds without errors (`flutter build web`)

## Security Rules

- [ ] Firebase CLI installed (`npm install -g firebase-tools`)
- [ ] Logged in to Firebase CLI (`firebase login`)
- [ ] Project initialized (`firebase init firestore`)
- [ ] Rules file points to `firebase/firestore.rules`
- [ ] Rules deployed (`firebase deploy --only firestore:rules`)
- [ ] Rules verified in Firebase Console

## Code Verification

- [ ] `lib/firebase_options.dart` exists and has no placeholder values
- [ ] `lib/main.dart` initializes Firebase before `runApp()`
- [ ] `TransactionRepository` uses Firestore (not SQLite)
- [ ] No import errors in any Dart files
- [ ] No references to old `database_helper.dart`

## Testing

- [ ] Unit tests run successfully (`flutter test`)
- [ ] Model tests pass (`flutter test test/data/models/`)
- [ ] Repository tests pass (`flutter test test/data/repositories/`)
- [ ] Integration tests configured (even if not running yet)
- [ ] No import errors in test files
- [ ] Tests use `fake_cloud_firestore`, not SQLite

## Running the App

- [ ] App starts without errors (`flutter run`)
- [ ] Firebase initialization message in logs
- [ ] No "FirebaseApp not initialized" errors
- [ ] No "google-services.json not found" errors
- [ ] No permission denied errors

## Functional Testing

- [ ] Can add new transaction (income)
- [ ] Transaction appears in UI
- [ ] Transaction visible in Firebase Console → Firestore Database
- [ ] Can add expense transaction
- [ ] Balance updates correctly
- [ ] Can delete transaction (swipe)
- [ ] Transaction removed from Firebase Console
- [ ] App works offline (add transaction without internet)
- [ ] Data syncs when coming back online

## Firebase Console Verification

- [ ] Project visible in Firebase Console
- [ ] Firestore Database active
- [ ] Collection `users` exists after first transaction
- [ ] Document for user exists
- [ ] Subcollection `transactions` exists
- [ ] Security rules deployed and active
- [ ] Rules show in Firestore → Rules tab

## Documentation Review

- [ ] Read QUICKSTART.md
- [ ] Reviewed FIREBASE_SETUP.md
- [ ] Checked platform-specific guide (Android or iOS)
- [ ] Understand MIGRATION_GUIDE.md (if migrating from SQLite)
- [ ] Know where to find troubleshooting info

## Optional: Emulator Setup

- [ ] Firebase Emulator Suite installed
- [ ] Emulator started (`firebase emulators:start`)
- [ ] App configured to use emulator (if in debug mode)
- [ ] Can test without affecting production data

## Optional: Multiple Environments

- [ ] Development Firebase project created
- [ ] Production Firebase project created
- [ ] Separate configurations set up
- [ ] Understand how to switch between environments
- [ ] Tested both environments work

## Optional: Authentication Setup

- [ ] Firebase Authentication enabled in console
- [ ] Sign-in methods configured (email, Google, etc.)
- [ ] `firebase_auth` dependency added (if using auth)
- [ ] Security rules updated for authenticated users
- [ ] Login flow implemented in app

## Git Configuration

- [ ] `.gitignore` updated (should already be done)
- [ ] `google-services.json` NOT committed (in .gitignore)
- [ ] `GoogleService-Info.plist` NOT committed (in .gitignore)
- [ ] `firebase_options.dart` template committed (with placeholders)
- [ ] Security rules committed (`firebase/firestore.rules`)

## Production Readiness (When Deploying)

- [ ] All tests passing
- [ ] Security rules reviewed and tested
- [ ] Production Firebase project configured
- [ ] Release builds tested
- [ ] No debug/development code in production
- [ ] Error handling implemented
- [ ] Analytics configured (optional)
- [ ] Monitoring set up (optional)

## Troubleshooting Completed

If you encountered issues, check which you resolved:

- [ ] Resolved "FirebaseApp not initialized" error
- [ ] Resolved "google-services.json not found" error
- [ ] Resolved permission denied errors
- [ ] Resolved build errors
- [ ] Resolved test failures
- [ ] Resolved pod install issues (iOS/macOS)
- [ ] Resolved gradle build issues (Android)

## Next Steps

After completing this checklist:

- [ ] Team members know how to set up Firebase
- [ ] Documentation bookmarked for reference
- [ ] Development workflow established
- [ ] Backup strategy planned
- [ ] Monitoring solution considered
- [ ] Analytics implementation planned (optional)

---

## Quick Verification Commands

Run these to verify your setup:

```bash
# Check Flutter
flutter --version
flutter doctor

# Check dependencies
flutter pub get

# Check FlutterFire CLI
flutterfire --version

# Verify Firebase files
ls lib/firebase_options.dart
ls android/app/google-services.json
ls ios/Runner/GoogleService-Info.plist

# Run tests
flutter test

# Run app
flutter run

# Check Firebase CLI
firebase --version
firebase projects:list
```

## Minimum Viable Setup

At minimum, you must have:

1. ✅ Firebase project created
2. ✅ Firestore enabled
3. ✅ `flutterfire configure` run successfully
4. ✅ `lib/firebase_options.dart` generated
5. ✅ Platform config files in place
6. ✅ App runs without errors
7. ✅ Can create and view transactions

## Final Verification

✅ **Setup Complete When:**
- App starts without Firebase errors
- Transactions save to Firestore
- Data visible in Firebase Console
- Tests pass
- Team can replicate setup

🎉 **Congratulations!** Your Firebase setup is complete.

---

**Having issues?** Check the troubleshooting sections in:
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- [ANDROID_FIREBASE_SETUP.md](ANDROID_FIREBASE_SETUP.md) (Android)
- [IOS_FIREBASE_SETUP.md](IOS_FIREBASE_SETUP.md) (iOS/macOS)
- [QUICKSTART.md](QUICKSTART.md)

**Need more help?** Review [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for detailed explanations.
