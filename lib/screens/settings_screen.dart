import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';
import '../services/app_blocker_service.dart';
import '../services/youtube_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box<AppSettings> settingsBox;
  late AppSettings settings;
  List<String> allowedVideos = [];

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box<AppSettings>('settings');
    settings = settingsBox.get('main', defaultValue: AppSettings())!;
    _loadAllowedVideos();
  }

  Future<void> _loadAllowedVideos() async {
    final videos = await YouTubeService.getAllowedVideos();
    setState(() {
      allowedVideos = videos;
    });
  }

  Future<void> _saveSettings() async {
    await settingsBox.put('main', settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Time Settings
          _buildSectionHeader('Learning Schedule'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Time-Based Access'),
                  subtitle: const Text('Control when you can watch videos'),
                  value: settings.isEnabled,
                  onChanged: (value) {
                    setState(() {
                      settings.isEnabled = value;
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: const Text('Start Time'),
                  subtitle: Text(settings.startTime),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.parse(settings.startTime.split(':')[0]),
                        minute: int.parse(settings.startTime.split(':')[1]),
                      ),
                    );
                    if (time != null) {
                      setState(() {
                        settings.startTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.stop),
                  title: const Text('End Time'),
                  subtitle: Text(settings.endTime),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.parse(settings.endTime.split(':')[0]),
                        minute: int.parse(settings.endTime.split(':')[1]),
                      ),
                    );
                    if (time != null) {
                      setState(() {
                        settings.endTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Reminder'),
                  subtitle: Text(settings.reminderMinutes == 0 
                      ? 'Disabled' 
                      : '${settings.reminderMinutes} minutes before'),
                  trailing: DropdownButton<int>(
                    value: settings.reminderMinutes,
                    items: [0, 5, 10, 15, 30].map((minutes) {
                      return DropdownMenuItem(
                        value: minutes,
                        child: Text(minutes == 0 ? 'Off' : '$minutes min'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        settings.reminderMinutes = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quiz Settings
          _buildSectionHeader('Quiz Settings'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Require Quiz to Unlock'),
                  subtitle: const Text('Must pass quiz before watching videos'),
                  value: settings.requireQuizToUnlock,
                  onChanged: (value) {
                    setState(() {
                      settings.requireQuizToUnlock = value;
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.quiz),
                  title: const Text('Quiz Difficulty'),
                  subtitle: Text(_getDifficultyText(settings.quizDifficulty)),
                  trailing: DropdownButton<int>(
                    value: settings.quizDifficulty,
                    items: [1, 2, 3].map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(_getDifficultyText(difficulty)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        settings.quizDifficulty = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Blocking Settings
          _buildSectionHeader('App Blocking'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Block YouTube App'),
                  subtitle: const Text('Prevent access to YouTube app during locked hours'),
                  value: settings.blockYouTubeApp,
                  onChanged: (value) {
                    setState(() {
                      settings.blockYouTubeApp = value;
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Permissions'),
                  subtitle: const Text('Manage app permissions for blocking features'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showPermissionsDialog();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Video Management
          _buildSectionHeader('Allowed Videos'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: Text('${allowedVideos.length} videos allowed'),
                  subtitle: const Text('Manage your educational video list'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showVideoManagementDialog();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Management
          _buildSectionHeader('Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Export Data'),
                  subtitle: const Text('Export your progress and settings'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showExportDialog();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Reset All Data'),
                  subtitle: const Text('Clear all progress and settings'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showResetDialog();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About
          _buildSectionHeader('About'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('FocusTube'),
                  subtitle: Text('Version 1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showHelpDialog();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
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

  void _showPermissionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Permissions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('FocusTube needs these permissions to block apps effectively:'),
            const SizedBox(height: 16),
            _buildPermissionItem('Usage Access', 'Monitor app usage'),
            _buildPermissionItem('Display Over Apps', 'Show blocking overlay'),
            _buildPermissionItem('Notifications', 'Send reminders'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AppBlockerService.requestAllPermissions();
            },
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allowed Videos'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: allowedVideos.isEmpty
              ? const Center(
                  child: Text('No videos added yet.\nAdd videos from the home screen.'),
                )
              : ListView.builder(
                  itemCount: allowedVideos.length,
                  itemBuilder: (context, index) {
                    final videoId = allowedVideos[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          YouTubeService.getVideoThumbnailUrl(videoId),
                          width: 60,
                          height: 45,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 45,
                              color: Colors.grey[300],
                              child: const Icon(Icons.video_library),
                            );
                          },
                        ),
                      ),
                      title: Text(videoId),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await YouTubeService.removeAllowedVideo(videoId);
                          await _loadAllowedVideos();
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('This feature will export your progress data and settings to a file.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text('This will permanently delete all your progress, settings, and allowed videos. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Clear all data
              await Hive.deleteBoxFromDisk('settings');
              await Hive.deleteBoxFromDisk('progress');
              await Hive.deleteBoxFromDisk('videos');
              
              Navigator.pop(context);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data has been reset'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How to use FocusTube:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Set your learning schedule in settings'),
              Text('2. Add educational YouTube videos'),
              Text('3. Take quizzes to unlock video access'),
              Text('4. Track your progress over time'),
              SizedBox(height: 16),
              Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Choose educational channels like Khan Academy'),
              Text('• Set realistic learning schedules'),
              Text('• Review your progress regularly'),
              Text('• Use the blocking feature to stay focused'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

