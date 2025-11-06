# Android Firebase Configuration

This document provides specific instructions for configuring Firebase on Android for the Sicredo app.

## Prerequisites

- Android Studio or IntelliJ IDEA
- Firebase project created (see [FIREBASE_SETUP.md](FIREBASE_SETUP.md))
- google-services.json file downloaded from Firebase Console

## Step-by-Step Configuration

### 1. Add google-services.json

1. Download `google-services.json` from Firebase Console:
   - Go to Project Settings > Your Apps > Android app
   - Click "Download google-services.json"

2. Place the file in the Android app directory:
   ```
   android/app/google-services.json
   ```

3. Verify the file is in the correct location:
   ```bash
   ls android/app/google-services.json
   ```

### 2. Update Root build.gradle.kts

Edit `android/build.gradle.kts` and add the Google Services plugin to the buildscript dependencies:

```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
        // Add this line for Firebase
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ... rest of the file
```

**Note:** If your project uses the newer Kotlin DSL style without a buildscript block, add the plugin to the plugins block in `settings.gradle.kts` instead:

```kotlin
// settings.gradle.kts
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

### 3. Update App build.gradle.kts

Edit `android/app/build.gradle.kts` and apply the Google Services plugin:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Add this line
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.sicredo"
    // ... rest of configuration
}

// ... rest of the file
```

### 4. Update minSdkVersion (if needed)

Firebase requires minimum SDK version 21 (Android 5.0). Verify in `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        minSdk = 21  // Or higher
        // ...
    }
}
```

If using flutter.minSdkVersion, ensure it's at least 21.

### 5. Enable Multidex (if needed)

For apps with many dependencies, enable multidex:

```kotlin
android {
    defaultConfig {
        // ...
        multiDexEnabled = true
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

### 6. Verify Configuration

Run the following to verify the setup:

```bash
cd android
./gradlew app:assembleDebug
```

You should see output like:
```
> Task :app:processDebugGoogleServices
Parsing json file: .../android/app/google-services.json
```

## Troubleshooting

### Error: "File google-services.json is missing"

**Solution:** Ensure the file is placed in `android/app/google-services.json` (not in `android/` or elsewhere).

### Error: "Plugin with id 'com.google.gms.google-services' not found"

**Solution:** Add the plugin to buildscript dependencies in `build.gradle.kts` or `settings.gradle.kts`.

### Error: "Default FirebaseApp is not initialized"

**Solution:** This is a runtime error. Make sure:
1. `google-services.json` is correctly placed
2. Firebase is initialized in `main.dart`:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

### Build fails with "minSdkVersion is less than 21"

**Solution:** Update `minSdk` to at least 21 in `android/app/build.gradle.kts`:
```kotlin
android {
    defaultConfig {
        minSdk = 21
    }
}
```

### Error: "Duplicate class com.google.android.gms..."

**Solution:** This usually indicates a dependency conflict. Check for duplicate Firebase dependencies and ensure all Firebase libraries use compatible versions.

## Multi-Flavor Configuration

If using flavors for dev/prod environments:

```kotlin
android {
    flavorDimensions += "environment"
    
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
        }
        
        create("prod") {
            dimension = "environment"
        }
    }
}
```

Place different `google-services.json` files:
```
android/app/src/dev/google-services.json
android/app/src/prod/google-services.json
```

## Testing

Run the app on an Android device or emulator:

```bash
flutter run
```

Check logs for Firebase initialization:
```bash
flutter logs | grep Firebase
```

Expected output:
```
I/flutter (12345): Firebase initialized successfully
```

## Additional Resources

- [FlutterFire Android Setup](https://firebase.flutter.dev/docs/installation/android)
- [Firebase Android Setup Guide](https://firebase.google.com/docs/android/setup)
- [Google Services Plugin](https://developers.google.com/android/guides/google-services-plugin)
