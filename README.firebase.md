# Firebase Integration Guide - Sicredo

This guide provides step-by-step instructions for setting up Firebase in the Sicredo app for Android, iOS, and Web platforms.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Firebase Project Setup](#firebase-project-setup)
3. [Platform Configuration](#platform-configuration)
4. [Environment Variables](#environment-variables)
5. [FlutterFire CLI Setup](#flutterfire-cli-setup)
6. [Authentication Setup](#authentication-setup)
7. [Firestore Setup](#firestore-setup)
8. [Security Rules](#security-rules)
9. [Running the App](#running-the-app)
10. [Testing](#testing)
11. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Flutter SDK (>=3.0.0)
- Firebase CLI installed: `npm install -g firebase-tools`
- FlutterFire CLI installed: `dart pub global activate flutterfire_cli`
- A Google account
- Firebase Project ID: `sicredo-34f2e`

---

## Firebase Project Setup

The Firebase project `sicredo-34f2e` should already be created. If you need to verify or access it:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select the project `sicredo-34f2e`
3. Ensure you have appropriate permissions

---

## Platform Configuration

### Android Setup

1. In Firebase Console, go to Project Settings > Your apps
2. Click "Add app" and select Android
3. Register your app with package name: `com.example.sicredo` (or your actual package name)
4. Download `google-services.json`
5. Place it in `android/app/google-services.json`
6. Verify `android/build.gradle` has the Google Services plugin:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

7. Verify `android/app/build.gradle` applies the plugin at the bottom:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### iOS Setup

1. In Firebase Console, go to Project Settings > Your apps
2. Click "Add app" and select iOS
3. Register your app with bundle ID from `ios/Runner/Info.plist`
4. Download `GoogleService-Info.plist`
5. Open `ios/Runner.xcworkspace` in Xcode
6. Drag `GoogleService-Info.plist` into the `Runner` folder in Xcode
7. Ensure "Copy items if needed" is checked

**Important for Google Sign-In on iOS:**

Add URL scheme to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reverse client ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

Find the `REVERSED_CLIENT_ID` in your `GoogleService-Info.plist` file.

### Web Setup

1. In Firebase Console, go to Project Settings > Your apps
2. Click "Add app" and select Web
3. Register your web app with a nickname (e.g., "Sicredo Web")
4. Copy the Firebase configuration
5. Update `web/index.html` to include Firebase SDK scripts (this will be handled by FlutterFire CLI)

---

## Environment Variables

1. Copy the example environment file:

```bash
cp .env.example .env
```

2. Edit `.env` with your settings:

```env
ENV=dev
FIREBASE_PROJECT_ID=sicredo-34f2e
USE_FIREBASE_EMULATOR=false
FIRESTORE_EMULATOR_PORT=8080
AUTH_EMULATOR_PORT=9099
```

3. **Important:** The `.env` file is gitignored. Never commit sensitive credentials.

4. For production, you can create a `.env.production` file with production settings.

### Using Firebase Emulator (Optional for Local Development)

To use Firebase Emulator for local development:

1. Install Firebase Emulator:

```bash
firebase setup:emulators:firestore
firebase setup:emulators:auth
```

2. Set in your `.env`:

```env
USE_FIREBASE_EMULATOR=true
FIRESTORE_EMULATOR_PORT=8080
AUTH_EMULATOR_PORT=9099
```

3. Start the emulator:

```bash
firebase emulators:start
```

4. Uncomment the emulator configuration in `lib/main.dart`

---

## FlutterFire CLI Setup

The FlutterFire CLI automatically generates the `lib/firebase_options.dart` file with your platform-specific Firebase configuration.

1. Ensure you're logged into Firebase:

```bash
firebase login
```

2. Run FlutterFire configuration:

```bash
flutterfire configure --project=sicredo-34f2e
```

3. Select the platforms you want to support (Android, iOS, Web)

4. The CLI will generate `lib/firebase_options.dart` automatically

5. **Note:** `firebase_options.dart` is gitignored. Each developer must generate it locally.

6. After generation, uncomment the Firebase initialization code in `lib/main.dart`:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## Authentication Setup

### Enable Email/Password Authentication

1. In Firebase Console, go to Authentication > Sign-in method
2. Enable "Email/Password" provider
3. Save changes

### Enable Google Sign-In

1. In Firebase Console, go to Authentication > Sign-in method
2. Enable "Google" provider
3. Configure support email
4. Save changes

**For Android:**
- SHA-1 fingerprint must be added to Firebase project
- Get SHA-1: `cd android && ./gradlew signingReport`
- Add it in Project Settings > Your apps > Android app

**For iOS:**
- URL scheme configuration (see iOS Setup section)
- Xcode configuration is automatic with `GoogleService-Info.plist`

**For Web:**
- Works automatically after enabling in Firebase Console

---

## Firestore Setup

### Create Firestore Database

1. In Firebase Console, go to Firestore Database
2. Click "Create database"
3. Select "Start in production mode" (we'll use custom rules)
4. Choose a region close to your users (e.g., southamerica-east1 for Brazil)
5. Click "Enable"

### Deploy Security Rules

The security rules are defined in `firebase/firestore.rules`. To deploy them:

```bash
firebase deploy --only firestore:rules
```

Or manually copy the rules from `firebase/firestore.rules` to Firebase Console > Firestore Database > Rules.

### Data Model

The app uses the following Firestore structure:

#### Users Collection (`users/{uid}`)

```
{
  uid: string,
  email: string,
  displayName: string (optional),
  createdAt: Timestamp
}
```

#### Transactions Collection (`transactions/{autoId}`)

```
{
  userId: string,
  nome: string,
  amountCents: int,
  date: Timestamp,
  dateStr: string (dd/MM/yyyy),
  type: string ("entrada" | "saida")
}
```

### Composite Indexes

Firestore may require composite indexes for queries. The first time you query transactions by userId and date, Firestore will provide a link to create the index automatically.

Alternatively, create the index manually:

1. Go to Firestore Database > Indexes
2. Create a composite index:
   - Collection: `transactions`
   - Fields: `userId` (Ascending), `date` (Descending)
   - Query scope: Collection

---

## Running the App

1. Install dependencies:

```bash
flutter pub get
```

2. Ensure you have:
   - Generated `firebase_options.dart` via FlutterFire CLI
   - Platform configuration files in place
   - Created `.env` file from `.env.example`
   - Uncommented Firebase initialization in `main.dart`

3. Run the app:

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

---

## Testing

### Unit Tests

Run unit tests for repositories and services:

```bash
flutter test
```

The tests use `fake_cloud_firestore` and `firebase_auth_mocks` to mock Firebase services.

### Integration Tests

Integration tests require Firebase Emulator or a test Firebase project:

```bash
# Start Firebase Emulator
firebase emulators:start

# In another terminal
flutter test integration_test/
```

### Manual Testing Checklist

- [ ] Email/Password sign up
- [ ] Email/Password sign in
- [ ] Google Sign-In (Android)
- [ ] Google Sign-In (iOS)
- [ ] Google Sign-In (Web)
- [ ] Add transaction
- [ ] View transactions
- [ ] Update transaction
- [ ] Delete transaction
- [ ] Sign out
- [ ] Data persists after sign out/sign in

---

## Troubleshooting

### Common Issues

#### 1. `firebase_options.dart` not found

**Solution:** Run `flutterfire configure --project=sicredo-34f2e`

#### 2. Google Sign-In fails on iOS

**Solution:** 
- Verify URL scheme is correctly set in `Info.plist`
- Check that `GoogleService-Info.plist` is in Xcode project
- Ensure `REVERSED_CLIENT_ID` matches the one from `GoogleService-Info.plist`

#### 3. `google-services.json` not found (Android)

**Solution:** Download from Firebase Console and place in `android/app/`

#### 4. Firestore permission denied

**Solution:**
- Check security rules are deployed
- Ensure user is authenticated
- Verify `userId` matches `request.auth.uid`

#### 5. Missing index error

**Solution:** Click the link in the error message to create the required index in Firebase Console

#### 6. Build fails with "Duplicate class" error

**Solution:** Check for dependency conflicts in `pubspec.yaml` and run `flutter clean && flutter pub get`

---

## Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

## Support

For issues specific to this project, please open an issue in the GitHub repository.

For Firebase-related issues, consult the [Firebase Support](https://firebase.google.com/support).
