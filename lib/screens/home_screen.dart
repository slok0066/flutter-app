import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'dart:math';
import '../models/app_settings.dart';
import '../models/progress_data.dart';
import '../services/notification_service.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/progress_card.dart';
import '../widgets/motivational_quote.dart';
import 'settings_screen.dart';
import 'video_input_screen.dart';
import 'quiz_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<AppSettings> settingsBox;
  late Box<ProgressData> progressBox;
  List<String> motivationalQuotes = [];

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box<AppSettings>('settings');
    progressBox = Hive.box<ProgressData>('progress');
    _loadQuotes();
    _scheduleNotifications();
  }

  Future<void> _loadQuotes() async {
    try {
      final String quotesJson = await DefaultAssetBundle.of(context)
          .loadString('assets/quotes/motivational_quotes.json');
      final List<dynamic> quotesList = json.decode(quotesJson);
      setState(() {
        motivationalQuotes = quotesList.cast<String>();
      });
    } catch (e) {
      // Fallback quotes if file loading fails
      motivationalQuotes = [
        "Discipline is the bridge between goals and accomplishment.",
        "Learn now. Win later.",
        "Success is the sum of small efforts repeated day in and day out.",
      ];
    }
  }

  void _scheduleNotifications() {
    final settings = _getSettings();
    if (settings.isEnabled && settings.reminderMinutes > 0) {
      final reminderTime = settings.startDateTime
          .subtract(Duration(minutes: settings.reminderMinutes));
      
      if (reminderTime.isAfter(DateTime.now())) {
        NotificationService.scheduleReminder(
          'Upcoming Learning Session',
          "Your learning session starts in ${settings.reminderMinutes} minutes! Get ready to focus.",
          reminderTime,
        );
      }
    }
  }

  AppSettings _getSettings() {
    return settingsBox.get('main', defaultValue: AppSettings())!;
  }

  ProgressData _getProgress() {
    return progressBox.get('main', defaultValue: ProgressData())!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: settingsBox.listenable(),
        builder: (context, box, widget) {
          final settings = _getSettings();
          final isAllowed = settings.isCurrentlyAllowed;
          
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'FocusTube',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 80,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      _buildStatusCard(settings, isAllowed),
                      const SizedBox(height: 20),
                      
                      // Motivational Quotes Carousel
                      if (motivationalQuotes.isNotEmpty) ...[
                        const Text(
                          'Daily Motivation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildQuotesCarousel(),
                        const SizedBox(height: 20),
                      ],
                      
                      // Quick Actions
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildQuickActions(isAllowed),
                      const SizedBox(height: 20),
                      
                      // Progress Overview
                      ValueListenableBuilder(
                        valueListenable: progressBox.listenable(),
                        builder: (context, box, widget) {
                          final progress = _getProgress();
                          return ProgressCard(progress: progress);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(AppSettings settings, bool isAllowed) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isAllowed ? Icons.check_circle : Icons.access_time,
                  color: isAllowed ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAllowed ? 'Learning Time Active' : 'Learning Time Locked',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isAllowed 
                          ? 'You can watch educational videos now!'
                          : 'Next session: ${settings.startTime} - ${settings.endTime}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isAllowed) ...[
              const SizedBox(height: 16),
              CountdownTimer(targetTime: settings.startDateTime),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuotesCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 120,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: motivationalQuotes.map((quote) {
        return MotivationalQuote(quote: quote);
      }).toList(),
    );
  }

  Widget _buildQuickActions(bool isAllowed) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildActionCard(
          icon: Icons.video_library,
          title: 'Add Video',
          subtitle: 'Add educational video',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VideoInputScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.quiz,
          title: 'Take Quiz',
          subtitle: 'Test your knowledge',
          onTap: isAllowed ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QuizScreen(),
              ),
            );
          } : null,
        ),
        _buildActionCard(
          icon: Icons.analytics,
          title: 'Progress',
          subtitle: 'View your stats',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProgressScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'Configure app',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: onTap != null 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: onTap != null ? null : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: onTap != null ? Colors.grey[600] : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

