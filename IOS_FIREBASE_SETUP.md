# iOS Firebase Configuration

This document provides specific instructions for configuring Firebase on iOS/macOS for the Sicredo app.

## Prerequisites

- Xcode installed
- Firebase project created (see [FIREBASE_SETUP.md](FIREBASE_SETUP.md))
- GoogleService-Info.plist file downloaded from Firebase Console
- CocoaPods installed (`sudo gem install cocoapods`)

## iOS Setup

### 1. Download GoogleService-Info.plist

1. Go to Firebase Console > Project Settings
2. Select your iOS app (or add one if not created)
3. Download `GoogleService-Info.plist`

### 2. Add to Xcode Project

1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
   ⚠️ Important: Open `.xcworkspace`, not `.xcodeproj`

2. Drag `GoogleService-Info.plist` into the Xcode project:
   - Drop it into the `Runner` folder in the file navigator
   - **Check**: "Copy items if needed"
   - **Check**: Add to targets: "Runner"
   - Click "Finish"

3. Verify the file is in the correct location:
   - Should appear in Xcode under `Runner/Runner/`
   - File should physically be at `ios/Runner/GoogleService-Info.plist`

### 3. Update Info.plist (Optional)

For some Firebase features (like Dynamic Links), you may need to add URL schemes to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

### 4. Install Pods

Run pod install to fetch Firebase dependencies:

```bash
cd ios
pod install
cd ..
```

### 5. Update Podfile (if needed)

The Podfile should already work with Firebase, but verify it has:

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'  # Firebase requires iOS 12.0 or higher

# ...

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

### 6. Build and Run

Build the project:

```bash
flutter build ios
```

Or run directly:

```bash
flutter run
```

## macOS Setup

Similar to iOS setup:

### 1. Download GoogleService-Info.plist for macOS

1. In Firebase Console, add a macOS app (separate from iOS)
2. Use the same bundle ID as iOS or a different one
3. Download `GoogleService-Info.plist`

### 2. Add to Xcode Project

1. Open the macOS project:
   ```bash
   open macos/Runner.xcworkspace
   ```

2. Drag `GoogleService-Info.plist` into `Runner` folder
3. Verify it's added to the Runner target

### 3. Update macOS Deployment Target

Ensure minimum macOS version is 10.13 or higher in `macos/Podfile`:

```ruby
platform :osx, '10.13'
```

### 4. Install Pods

```bash
cd macos
pod install
cd ..
```

### 5. Build and Run

```bash
flutter run -d macos
```

## Troubleshooting

### Error: "GoogleService-Info.plist not found"

**Solution:**
1. Verify file is in `ios/Runner/` or `macos/Runner/`
2. Open Xcode and check if file appears in the Navigator
3. Verify file is added to Runner target (select file → Inspector → Target Membership)

### Error: "pod install" fails

**Solution:**
```bash
cd ios  # or macos
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Error: "CocoaPods not installed"

**Solution:**
```bash
sudo gem install cocoapods
pod setup
```

### Build error: "Undefined symbol: _OBJC_CLASS_$_FIRApp"

**Solution:**
1. Clean the build:
   ```bash
   flutter clean
   cd ios && pod install && cd ..
   flutter build ios
   ```
2. In Xcode: Product → Clean Build Folder (⇧⌘K)

### Error: "The iOS deployment target is set to..."

**Solution:** Update the deployment target in Xcode:
1. Select Runner project in Navigator
2. Select Runner target
3. Build Settings → iOS Deployment Target → Set to 12.0 or higher

Or update in `ios/Podfile`:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

### Error: "Multiple commands produce GoogleService-Info.plist"

**Solution:** 
1. In Xcode, go to Build Phases
2. Find "Copy Bundle Resources"
3. Remove duplicate GoogleService-Info.plist entries
4. Keep only one

### App crashes on launch with Firebase error

**Solution:**
1. Verify `GoogleService-Info.plist` is correctly formatted (valid XML)
2. Check that Firebase.initializeApp() is called in main.dart
3. Look at crash logs in Xcode: Window → Devices and Simulators → View Device Logs

## Testing on Simulator/Device

### iOS Simulator

```bash
# List available simulators
flutter devices

# Run on specific simulator
flutter run -d "iPhone 15 Pro"
```

### Physical Device

1. Connect iPhone/iPad via USB
2. Trust the device on Mac
3. In Xcode: Select your device from the device dropdown
4. Run: `flutter run`

### macOS

```bash
flutter run -d macos
```

## Multi-Environment Setup

For dev/prod environments with different Firebase projects:

1. Create schemes in Xcode:
   - Product → Scheme → Manage Schemes
   - Duplicate Runner → Rename to "Runner-Dev"
   - Duplicate Runner → Rename to "Runner-Prod"

2. Add Configuration files:
   ```
   ios/Firebase/Dev/GoogleService-Info.plist
   ios/Firebase/Prod/GoogleService-Info.plist
   ```

3. Add a Run Script phase in Build Phases:
   ```bash
   if [ "${CONFIGURATION}" == "Debug" ]; then
     cp "${PROJECT_DIR}/Firebase/Dev/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
   else
     cp "${PROJECT_DIR}/Firebase/Prod/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
   fi
   ```

## Verification

Check Firebase initialization in logs:

```bash
flutter run
# Look for:
[Firebase/Core] Configuration succeeded
```

Or use Xcode console:
1. Run app from Xcode
2. View → Debug Area → Activate Console
3. Look for Firebase initialization messages

## Additional Resources

- [FlutterFire iOS Setup](https://firebase.flutter.dev/docs/installation/ios)
- [Firebase iOS Setup Guide](https://firebase.google.com/docs/ios/setup)
- [CocoaPods Guides](https://guides.cocoapods.org/)
- [Xcode Help](https://help.apple.com/xcode/)
