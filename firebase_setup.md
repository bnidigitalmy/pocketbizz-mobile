# Firebase Setup for PocketBizz Mobile

## Prerequisites
1. Firebase account (free)
2. Firebase CLI installed
3. Flutter app built

## Step 1: Install Firebase CLI

```powershell
# Install via npm
npm install -g firebase-tools

# Or download installer from:
# https://firebase.google.com/docs/cli#windows-standalone-binary
```

## Step 2: Login to Firebase

```powershell
firebase login
```

## Step 3: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Name: `pocketbizz-mobile`
4. Enable Google Analytics (optional)
5. Create project

## Step 4: Add Flutter Apps to Firebase

```powershell
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Make sure it's in PATH, then run:
flutterfire configure
```

**Select:**
- Project: `pocketbizz-mobile`
- Platforms: Android, iOS
- Bundle ID (iOS): `my.bnidigital.pocketbizz`
- Package name (Android): `my.bnidigital.pocketbizz`

This will generate `firebase_options.dart` and update platform-specific configs.

## Step 5: Add Firebase Dependencies

```powershell
flutter pub add firebase_core firebase_analytics firebase_crashlytics
```

## Step 6: Update Main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: PocketBizzApp()));
}
```

## Step 7: Build Release APK/IPA

### Android APK
```powershell
flutter build apk --release --dart-define=BASE_URL=https://mobile.pocketbizz.my
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)
```powershell
flutter build appbundle --release --dart-define=BASE_URL=https://mobile.pocketbizz.my
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (requires macOS)
```powershell
flutter build ipa --release --dart-define=BASE_URL=https://mobile.pocketbizz.my
```

## Step 8: Setup App Distribution

```powershell
# Get your Firebase App ID from console
# Android: Go to Project Settings > General > Your apps
# Format: 1:1234567890:android:abcdef123456

# Distribute APK
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:YOUR_APP_ID:android:YOUR_HASH \
  --groups "beta-testers" \
  --release-notes "Initial beta release with Auth & Subscription modules"
```

## Step 9: Add Testers

### Via Firebase Console:
1. Go to https://console.firebase.google.com
2. Select project: `pocketbizz-mobile`
3. Left menu: App Distribution
4. Click "Testers & Groups"
5. Add emails or create groups

### Via CLI:
```powershell
# Add individual tester
firebase appdistribution:testers:add --emails "user@example.com"

# Add group
firebase appdistribution:groups:create beta-testers
```

## Step 10: Testers Download App

Testers will receive email with link to:
- Download Firebase App Tester app from Play Store/App Store
- Access PocketBizz beta builds
- Get automatic update notifications

## CI/CD with GitHub Actions (Bonus)

Create `.github/workflows/firebase-distribution.yml`:

```yaml
name: Firebase App Distribution

on:
  push:
    branches: [ main, develop ]

jobs:
  build-and-distribute:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '17'
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release --dart-define=BASE_URL=https://mobile.pocketbizz.my
    
    - name: Upload to Firebase App Distribution
      uses: wzieba/Firebase-Distribution-Github-Action@v1
      with:
        appId: ${{ secrets.FIREBASE_APP_ID }}
        serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
        groups: beta-testers
        file: build/app/outputs/flutter-apk/app-release.apk
```

### Setup GitHub Secrets:
1. Go to GitHub repo: Settings > Secrets and variables > Actions
2. Add secrets:
   - `FIREBASE_APP_ID`: Your Firebase Android App ID
   - `FIREBASE_SERVICE_ACCOUNT`: Service account JSON from Firebase Console

## Important Notes

### Android Signing (Required for Distribution)
Create keystore for signing:

```powershell
keytool -genkey -v -keystore pocketbizz-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pocketbizz
```

Create `android/key.properties`:
```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=pocketbizz
storeFile=../pocketbizz-release-key.jks
```

Update `android/app/build.gradle.kts`:
```kotlin
// Add before android block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ... existing config
        }
    }
}
```

**IMPORTANT**: Add to `.gitignore`:
```
*.jks
key.properties
```

### iOS Provisioning (Requires macOS + Apple Developer Account)
1. Enroll in Apple Developer Program (RM 400/year)
2. Create App ID: `my.bnidigital.pocketbizz`
3. Create provisioning profile
4. Configure in Xcode

## Useful Commands

```powershell
# List all releases
firebase appdistribution:releases:list --app YOUR_APP_ID

# Delete release
firebase appdistribution:releases:delete RELEASE_ID --app YOUR_APP_ID

# List testers
firebase appdistribution:testers:list

# Remove tester
firebase appdistribution:testers:remove --emails "user@example.com"
```

## Troubleshooting

**Build failed**: Run `flutter clean && flutter pub get`

**Firebase CLI not found**: Ensure npm bin in PATH or use full path

**App not signed**: Setup Android keystore (see above)

**Testers not receiving email**: Check spam folder, verify email in Firebase Console

## Cost

- **Firebase App Distribution**: FREE
- **Firebase Analytics**: FREE (up to 500 distinct events)
- **Firebase Crashlytics**: FREE
- **Build minutes (GitHub Actions)**: FREE (2000 min/month for public repos)

---

Ready for beta testing! 🚀
