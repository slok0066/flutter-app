import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'models/app_settings.dart';
import 'models/progress_data.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(ProgressDataAdapter());
  
  // Open Hive boxes
  await Hive.openBox<AppSettings>('settings');
  await Hive.openBox<ProgressData>('progress');
  await Hive.openBox('videos');
  
  // Initialize notification service
  await NotificationService.initialize();
  
  // Request permissions
  await _requestPermissions();
  
  runApp(const FocusTubeApp());
}

Future<void> _requestPermissions() async {
  await [
    Permission.notification,
    Permission.systemAlertWindow,
    Permission.accessNotificationPolicy,
  ].request();
}

class FocusTubeApp extends StatelessWidget {
  const FocusTubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusTube',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: FutureBuilder<bool>(
        future: _checkFirstRun(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.data == true) {
            return const SetupScreen();
          } else {
            return const HomeScreen();
          }
        },
      ),
    );
  }
  
  Future<bool> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_run') ?? true;
  }
}

