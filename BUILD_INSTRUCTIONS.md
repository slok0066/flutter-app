# FocusTube - Detailed Build Instructions

This document provides step-by-step instructions for building the FocusTube Android app from source code.

## Prerequisites

### Required Software
1. **Flutter SDK 3.32.5+**
   - Download from: https://flutter.dev/docs/get-started/install
   - Add to PATH environment variable

2. **Android SDK**
   - Install via Android Studio or command-line tools
   - Minimum API level: 21 (Android 5.0)
   - Target API level: 34 (Android 14)

3. **Java Development Kit (JDK) 17+**
   - OpenJDK 17 recommended
   - Set JAVA_HOME environment variable

4. **Android Studio** (recommended)
   - Includes Android SDK and emulator
   - Better debugging and build tools

### Environment Setup

#### Windows
```cmd
# Set environment variables
set FLUTTER_ROOT=C:\flutter
set ANDROID_HOME=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
set JAVA_HOME=C:\Program Files\Java\jdk-17
set PATH=%PATH%;%FLUTTER_ROOT%\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin
```

#### macOS/Linux
```bash
# Add to ~/.bashrc or ~/.zshrc
export FLUTTER_ROOT=/path/to/flutter
export ANDROID_HOME=/path/to/android-sdk
export JAVA_HOME=/path/to/java-17
export PATH=$PATH:$FLUTTER_ROOT/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin
```

## Step-by-Step Build Process

### 1. Verify Flutter Installation
```bash
flutter doctor
```
Ensure all checkmarks are green for Android development.

### 2. Clone/Download Project
```bash
# If using Git
git clone <repository-url>
cd focustube

# Or extract downloaded ZIP file
unzip focustube.zip
cd focustube
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Generate Code (if needed)
```bash
# Generate Hive adapters and other generated code
dart run build_runner build --delete-conflicting-outputs
```

### 5. Configure Android Manifest
Ensure the following permissions are in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" />
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

### 6. Build APK

#### Debug Build (Faster)
```bash
flutter build apk --debug
```

#### Release Build (Optimized)
```bash
flutter build apk --release
```

#### Split APKs by Architecture (Smaller file sizes)
```bash
flutter build apk --split-per-abi
```

### 7. Locate Built APK
Built APKs will be in:
```
build/app/outputs/flutter-apk/
├── app-debug.apk           # Debug build
├── app-release.apk         # Release build
├── app-arm64-v8a-release.apk   # ARM64 devices
├── app-armeabi-v7a-release.apk # ARM32 devices
└── app-x86_64-release.apk      # x86 devices
```

## Troubleshooting Common Issues

### Issue 1: Gradle Build Failures
**Error**: `Gradle task assembleRelease failed`

**Solutions**:
```bash
# Clean build cache
cd android
./gradlew clean
cd ..

# Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version=8.12
cd ..

# Increase Gradle memory
echo "org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g" >> android/gradle.properties
```

### Issue 2: Namespace Errors
**Error**: `Namespace not specified for plugin`

**Solution**: Add namespace to plugin's build.gradle:
```gradle
android {
    namespace 'com.plugin.name'
    // ... rest of configuration
}
```

### Issue 3: Permission Errors
**Error**: Android permissions not working

**Solutions**:
1. Check targetSdkVersion in `android/app/build.gradle.kts`
2. Request permissions at runtime in Flutter code
3. Some permissions require manual user approval in Settings

### Issue 4: Device Apps Plugin Issues
**Error**: `device_apps` plugin compilation errors

**Solution**: Replace with alternative implementation:
```dart
// Instead of device_apps, use platform channels
// or remove app detection features temporarily
```

### Issue 5: Memory Issues During Build
**Error**: Out of memory during compilation

**Solutions**:
```bash
# Increase JVM memory
export GRADLE_OPTS="-Xmx4g -XX:MaxMetaspaceSize=1g"

# Use fewer parallel processes
flutter build apk --release --no-tree-shake-icons
```

## Alternative Build Methods

### Method 1: Android Studio
1. Open `android` folder in Android Studio
2. Wait for Gradle sync to complete
3. Build → Generate Signed Bundle/APK
4. Choose APK and follow wizard

### Method 2: VS Code with Flutter Extension
1. Open project in VS Code
2. Install Flutter extension
3. Use Command Palette: "Flutter: Build APK"
4. Select build type (debug/release)

### Method 3: Online CI/CD Services

#### GitHub Actions
Create `.github/workflows/build.yml`:
```yaml
name: Build APK
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-java@v1
      with:
        java-version: '17'
    - uses: subosito/flutter-action@v1
      with:
        flutter-version: '3.32.5'
    - run: flutter pub get
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v2
      with:
        name: apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

#### Codemagic
1. Connect repository to Codemagic
2. Configure build settings for Flutter Android
3. Set environment variables
4. Build automatically on push

## Testing the Built APK

### Install on Physical Device
```bash
# Enable USB debugging on Android device
# Connect via USB cable
adb devices  # Verify device is detected
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Install on Emulator
```bash
# Start Android emulator
emulator -avd <emulator_name>

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Test Core Features
1. **App Launch**: Verify app starts without crashes
2. **Setup Wizard**: Complete initial configuration
3. **Time Settings**: Set learning schedule
4. **Video Addition**: Add YouTube video URLs
5. **Quiz System**: Take sample quiz
6. **Permissions**: Grant required permissions
7. **Notifications**: Test reminder system
8. **Progress Tracking**: Verify data persistence

## Optimizing APK Size

### Enable R8 Code Shrinking
In `android/app/build.gradle.kts`:
```kotlin
buildTypes {
    release {
        minifyEnabled = true
        shrinkResources = true
        proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
    }
}
```

### Split APKs by Architecture
```bash
flutter build apk --split-per-abi
```

### Remove Unused Resources
```bash
flutter build apk --release --tree-shake-icons
```

## Signing APK for Distribution

### Generate Keystore
```bash
keytool -genkey -v -keystore focustube-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias focustube
```

### Configure Signing
Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=focustube
storeFile=../focustube-key.jks
```

Update `android/app/build.gradle.kts`:
```kotlin
signingConfigs {
    release {
        keyAlias = keystoreProperties['keyAlias']
        keyPassword = keystoreProperties['keyPassword']
        storeFile = file(keystoreProperties['storeFile'])
        storePassword = keystoreProperties['storePassword']
    }
}
```

### Build Signed APK
```bash
flutter build apk --release
```

## Performance Optimization

### Build Optimizations
```bash
# Enable multidex for large apps
flutter build apk --release --multidex

# Optimize for specific architecture
flutter build apk --release --target-platform android-arm64

# Enable obfuscation
flutter build apk --release --obfuscate --split-debug-info=debug-info/
```

### Runtime Optimizations
1. Use `const` constructors where possible
2. Implement lazy loading for large lists
3. Optimize image assets and use appropriate formats
4. Cache network requests and database queries
5. Use `ListView.builder` for dynamic lists

## Deployment Considerations

### Google Play Store
1. Build signed release APK
2. Test thoroughly on multiple devices
3. Prepare store listing with screenshots
4. Follow Google Play policies
5. Handle app permissions properly

### Direct Distribution
1. Enable "Install from Unknown Sources" on target devices
2. Distribute APK via secure channels
3. Provide installation instructions
4. Consider using APK signing for security

## Maintenance and Updates

### Version Management
Update version in `pubspec.yaml`:
```yaml
version: 1.0.1+2  # version+build_number
```

### Dependency Updates
```bash
# Check for outdated packages
flutter pub outdated

# Update dependencies
flutter pub upgrade

# Update Flutter SDK
flutter upgrade
```

### Testing Updates
1. Test on multiple Android versions
2. Verify backward compatibility
3. Check permission changes
4. Test upgrade scenarios from previous versions

---

**Note**: Building Android apps can be complex due to various system configurations and dependencies. If you encounter issues not covered here, consider using the pre-built APK or seeking help from the Flutter community.

