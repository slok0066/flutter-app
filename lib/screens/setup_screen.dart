import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';
import '../models/progress_data.dart';
import '../services/app_blocker_service.dart';
import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  TimeOfDay _startTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);
  int _reminderMinutes = 5;
  bool _blockYouTubeApp = true;
  int _quizDifficulty = 2;
  bool _requireQuizToUnlock = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 4,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildTimeSettingsPage(),
                  _buildFeaturesPage(),
                  _buildPermissionsPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(),
                  
                  ElevatedButton(
                    onPressed: _currentPage == 3 ? _completeSetup : () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(_currentPage == 3 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 120,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to FocusTube',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Take control of your YouTube viewing with time-based access, educational quizzes, and progress tracking.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildFeatureItem(
                    Icons.access_time,
                    'Time-Based Access',
                    'Set specific hours for educational viewing',
                  ),
                  _buildFeatureItem(
                    Icons.quiz,
                    'Educational Quizzes',
                    'Test your knowledge before watching',
                  ),
                  _buildFeatureItem(
                    Icons.block,
                    'App Blocking',
                    'Prevent distractions during focus time',
                  ),
                  _buildFeatureItem(
                    Icons.analytics,
                    'Progress Tracking',
                    'Monitor your learning journey',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set Your Learning Schedule',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose when you want to have access to educational videos.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.play_arrow),
                    title: const Text('Start Time'),
                    subtitle: Text(_startTime.format(context)),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (time != null) {
                        setState(() {
                          _startTime = time;
                        });
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.stop),
                    title: const Text('End Time'),
                    subtitle: Text(_endTime.format(context)),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (time != null) {
                        setState(() {
                          _endTime = time;
                        });
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Reminder'),
                    subtitle: Text('$_reminderMinutes minutes before'),
                    trailing: DropdownButton<int>(
                      value: _reminderMinutes,
                      items: [0, 5, 10, 15, 30].map((minutes) {
                        return DropdownMenuItem(
                          value: minutes,
                          child: Text(minutes == 0 ? 'Off' : '$minutes min'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _reminderMinutes = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configure Features',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Customize how FocusTube works for you.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Block YouTube App'),
                    subtitle: const Text('Prevent access to YouTube app during locked hours'),
                    value: _blockYouTubeApp,
                    onChanged: (value) {
                      setState(() {
                        _blockYouTubeApp = value;
                      });
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Require Quiz to Unlock'),
                    subtitle: const Text('Must pass quiz before watching videos'),
                    value: _requireQuizToUnlock,
                    onChanged: (value) {
                      setState(() {
                        _requireQuizToUnlock = value;
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Quiz Difficulty'),
                    subtitle: Text(_getDifficultyText(_quizDifficulty)),
                    trailing: DropdownButton<int>(
                      value: _quizDifficulty,
                      items: [1, 2, 3].map((difficulty) {
                        return DropdownMenuItem(
                          value: difficulty,
                          child: Text(_getDifficultyText(difficulty)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _quizDifficulty = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grant Permissions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'FocusTube needs these permissions to work effectively.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildPermissionItem(
                    Icons.notifications,
                    'Notifications',
                    'Show reminders and motivational quotes',
                    true,
                  ),
                  _buildPermissionItem(
                    Icons.apps,
                    'Usage Access',
                    'Monitor app usage for blocking features',
                    _blockYouTubeApp,
                  ),
                  _buildPermissionItem(
                    Icons.layers,
                    'Display Over Apps',
                    'Show blocking overlay when needed',
                    _blockYouTubeApp,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These permissions help FocusTube provide the best experience. You can modify them later in settings.',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String description, bool required) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (required) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Medium';
    }
  }

  Future<void> _completeSetup() async {
    // Save settings
    final settingsBox = Hive.box<AppSettings>('settings');
    final settings = AppSettings(
      startTime: '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
      endTime: '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
      isEnabled: true,
      reminderMinutes: _reminderMinutes,
      blockYouTubeApp: _blockYouTubeApp,
      quizDifficulty: _quizDifficulty,
      requireQuizToUnlock: _requireQuizToUnlock,
    );
    await settingsBox.put('main', settings);
    
    // Initialize progress data
    final progressBox = Hive.box<ProgressData>('progress');
    await progressBox.put('main', ProgressData());
    
    // Request permissions if needed
    if (_blockYouTubeApp) {
      await AppBlockerService.requestAllPermissions();
    }
    
    // Mark setup as complete
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_run', false);
    
    // Navigate to home screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }
}

