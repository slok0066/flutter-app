# FocusTube - Educational YouTube Control App

FocusTube is a Flutter Android app designed to help users control their YouTube viewing habits through time-based access, educational quizzes, and progress tracking.

## Features

### 🕒 Time-Based YouTube Access
- Set daily time windows for educational video viewing (e.g., 8:00 PM to 9:00 PM)
- Block YouTube app access outside designated hours
- Motivational quotes and countdown timers before sessions
- Customizable reminder notifications

### 📺 Controlled YouTube Launch
- Add specific YouTube video URLs/IDs to your allowed list
- Launch videos directly through the app using Intent
- Monitor video session start and stop times
- Track viewing progress and completion

### 🧠 Educational Quiz System
- Take quizzes before accessing videos (optional)
- Multiple difficulty levels (Easy, Medium, Hard)
- Educational questions covering various topics
- Score tracking and progress monitoring
- Pass requirement (70% minimum) to unlock videos

### 🔒 Distraction Prevention
- Block YouTube app during locked periods
- Overlay system to redirect users back to FocusTube
- Usage monitoring and statistics
- Motivational UI during restriction periods

### 📊 Progress Tracking
- Track videos watched and quizzes completed
- Learning streaks and achievements system
- Weekly progress charts and statistics
- Session time tracking and analytics
- Export progress data

## Screenshots

The app features a modern, minimalist UI with:
- Clean home screen with countdown timer
- Interactive quiz interface with explanations
- Progress dashboard with charts and statistics
- Settings screen for customization
- Motivational quote carousel

## Technical Architecture

### Dependencies
- **Flutter**: Cross-platform mobile development framework
- **Hive**: Local database for storing user data and settings
- **flutter_local_notifications**: Push notifications and reminders
- **url_launcher**: Opening YouTube videos in native app
- **permission_handler**: Managing Android permissions
- **device_apps**: Detecting and monitoring installed apps
- **shared_preferences**: Simple key-value storage
- **timezone**: Handling time zones for notifications

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── app_settings.dart     # User settings model
│   ├── progress_data.dart    # Progress tracking model
│   └── quiz_question.dart    # Quiz question model
├── screens/                  # UI screens
│   ├── home_screen.dart      # Main dashboard
│   ├── setup_screen.dart     # Initial setup wizard
│   ├── quiz_screen.dart      # Quiz interface
│   ├── progress_screen.dart  # Progress tracking
│   ├── settings_screen.dart  # App configuration
│   └── video_input_screen.dart # Add YouTube videos
├── services/                 # Business logic
│   ├── notification_service.dart # Push notifications
│   ├── youtube_service.dart     # YouTube integration
│   └── app_blocker_service.dart # App blocking features
├── widgets/                  # Reusable UI components
│   ├── countdown_timer.dart  # Timer widget
│   ├── progress_card.dart    # Progress display
│   ├── progress_chart.dart   # Weekly chart
│   └── motivational_quote.dart # Quote carousel
└── utils/                    # Helper functions
```

## Building the App

### Prerequisites
1. **Flutter SDK** (3.32.5 or later)
2. **Android SDK** with API level 21+
3. **Java 17** or later
4. **Android Studio** (recommended) or command-line tools

### Setup Instructions

1. **Clone or download the project**
   ```bash
   # If you have the source code
   cd focustube
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters** (if needed)
   ```bash
   dart run build_runner build
   ```

4. **Configure Android SDK**
   ```bash
   flutter config --android-sdk /path/to/android-sdk
   flutter doctor --android-licenses
   ```

5. **Build the APK**
   ```bash
   # For release build
   flutter build apk --release
   
   # For debug build (faster)
   flutter build apk --debug
   ```

6. **Install on device**
   ```bash
   # Connect Android device via USB with debugging enabled
   flutter install
   
   # Or manually install the APK
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

### Troubleshooting Build Issues

#### Common Issues and Solutions

1. **Namespace errors with device_apps plugin**
   - The device_apps plugin may need namespace configuration
   - Consider replacing with alternative app detection methods

2. **Gradle build failures**
   - Ensure Java 17 is installed and JAVA_HOME is set
   - Clear Gradle cache: `./gradlew clean`
   - Update Gradle wrapper if needed

3. **Permission issues**
   - Some permissions require manual user approval
   - Usage stats permission needs system settings access
   - Overlay permission for app blocking features

4. **Android SDK issues**
   - Run `flutter doctor` to check setup
   - Install required SDK components via Android Studio
   - Accept all Android licenses

### Alternative Build Methods

If you encounter build issues, try these alternatives:

1. **Use Android Studio**
   - Open the `android` folder in Android Studio
   - Build the project using the IDE
   - More detailed error messages and debugging

2. **Simplify dependencies**
   - Remove problematic plugins temporarily
   - Build core functionality first
   - Add advanced features incrementally

3. **Use online build services**
   - Codemagic, GitHub Actions, or similar CI/CD
   - Cloud-based building with pre-configured environments

## App Permissions

The app requires these Android permissions:

- **INTERNET**: YouTube video access and content loading
- **POST_NOTIFICATIONS**: Learning reminders and motivational quotes
- **SYSTEM_ALERT_WINDOW**: Overlay for app blocking features
- **PACKAGE_USAGE_STATS**: Monitor YouTube app usage (manual approval required)
- **QUERY_ALL_PACKAGES**: Detect installed apps
- **WAKE_LOCK**: Background monitoring services
- **FOREGROUND_SERVICE**: Persistent app monitoring

## Usage Guide

### Initial Setup
1. Launch FocusTube for the first time
2. Complete the setup wizard:
   - Set your learning schedule (start/end times)
   - Configure quiz difficulty and requirements
   - Enable app blocking features
   - Grant necessary permissions

### Adding Educational Videos
1. Go to "Add Video" screen
2. Paste YouTube URL or enter video ID
3. Video is added to your allowed list
4. Access during designated learning hours

### Taking Quizzes
1. Quizzes appear before video access (if enabled)
2. Answer multiple-choice questions
3. Achieve 70% or higher to pass
4. View explanations for incorrect answers
5. Track your quiz performance over time

### Monitoring Progress
1. View daily/weekly learning statistics
2. Track video completion and quiz scores
3. Monitor learning streaks and achievements
4. Export data for external analysis

### Customizing Settings
1. Adjust learning schedule as needed
2. Change quiz difficulty levels
3. Enable/disable app blocking features
4. Configure notification preferences
5. Manage allowed video list

## Educational Content

The app includes a built-in quiz database covering:
- Science and Technology
- Mathematics and Logic
- History and Geography
- Language and Literature
- General Knowledge

Questions are categorized by difficulty and topic for personalized learning experiences.

## Privacy and Data

- All data stored locally on device using Hive database
- No personal information sent to external servers
- YouTube integration uses public APIs only
- User can export/delete all data at any time

## Future Enhancements

Potential features for future versions:
- Cloud sync for multi-device usage
- Parental controls and family sharing
- Integration with educational platforms
- Advanced analytics and insights
- Social features and learning groups
- Offline quiz content and videos

## Support and Contributing

For issues, suggestions, or contributions:
1. Check existing documentation and troubleshooting guides
2. Review common build and setup issues
3. Consider contributing improvements or bug fixes
4. Share feedback on user experience and features

## License

This project is created for educational purposes. Please ensure compliance with YouTube's Terms of Service and Android development guidelines when using or modifying this code.

---

**Note**: This app is designed to promote healthy, educational YouTube consumption. It requires user cooperation and cannot completely prevent determined users from bypassing restrictions. The goal is to encourage mindful learning habits rather than enforce strict controls.

