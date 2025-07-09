import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/progress_data.dart';
import '../widgets/progress_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Box<ProgressData> progressBox;
  late ProgressData progress;

  @override
  void initState() {
    super.initState();
    progressBox = Hive.box<ProgressData>('progress');
    progress = progressBox.get('main', defaultValue: ProgressData())!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: progressBox.listenable(),
        builder: (context, box, widget) {
          progress = box.get('main', defaultValue: ProgressData())!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                _buildOverviewCards(),
                const SizedBox(height: 24),
                
                // Streak Section
                _buildStreakSection(),
                const SizedBox(height: 24),
                
                // Statistics
                _buildStatisticsSection(),
                const SizedBox(height: 24),
                
                // Progress Chart
                _buildProgressChart(),
                const SizedBox(height: 24),
                
                // Achievements
                _buildAchievementsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Videos Watched',
          progress.videosWatched.toString(),
          Icons.play_circle_outline,
          Colors.blue,
        ),
        _buildStatCard(
          'Quizzes Passed',
          progress.quizzesPassed.toString(),
          Icons.quiz,
          Colors.green,
        ),
        _buildStatCard(
          'Current Streak',
          '${progress.currentStreak} days',
          Icons.local_fire_department,
          Colors.orange,
        ),
        _buildStatCard(
          'Hours Learned',
          '${progress.totalHoursWatched.toStringAsFixed(1)}h',
          Icons.access_time,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Learning Streak',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${progress.currentStreak}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                    Text(
                      'Current Streak',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${progress.longestStreak}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Best Streak',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.currentStreak / (progress.longestStreak > 0 ? progress.longestStreak : 1),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
            ),
            const SizedBox(height: 8),
            Text(
              progress.currentStreak > 0 
                  ? 'Keep it up! You\'re on a roll! 🔥'
                  : 'Start a new streak today! 💪',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatRow(
                  'Average Quiz Score',
                  '${progress.averageQuizScore.toStringAsFixed(1)}%',
                  Icons.grade,
                ),
                const Divider(),
                _buildStatRow(
                  'Sessions This Week',
                  progress.sessionsThisWeek.toString(),
                  Icons.calendar_today,
                ),
                const Divider(),
                _buildStatRow(
                  'Total Videos Completed',
                  progress.completedVideoIds.length.toString(),
                  Icons.video_library,
                ),
                const Divider(),
                _buildStatRow(
                  'Learning Time Today',
                  _getTodayLearningTime(),
                  Icons.today,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 200,
              child: ProgressChart(progress: progress),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = _getAchievements();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (achievements.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No achievements yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Keep learning to unlock achievements!',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...achievements.map((achievement) => _buildAchievementCard(achievement)),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      child: ListTile(
        leading: Icon(
          achievement.icon,
          color: achievement.unlocked ? Colors.amber : Colors.grey,
          size: 32,
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: achievement.unlocked ? null : Colors.grey,
          ),
        ),
        subtitle: Text(achievement.description),
        trailing: achievement.unlocked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
    );
  }

  String _getTodayLearningTime() {
    final today = DateTime.now();
    final todaySessions = progress.sessionDates.where((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day).length;
    
    // Estimate 30 minutes per session
    final minutes = todaySessions * 30;
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      return '${(minutes / 60).toStringAsFixed(1)}h';
    }
  }

  List<Achievement> _getAchievements() {
    final achievements = <Achievement>[];
    
    // First Video Achievement
    achievements.add(Achievement(
      title: 'First Steps',
      description: 'Watch your first educational video',
      icon: Icons.play_circle,
      unlocked: progress.videosWatched > 0,
    ));
    
    // Quiz Master Achievement
    achievements.add(Achievement(
      title: 'Quiz Master',
      description: 'Pass 10 quizzes',
      icon: Icons.quiz,
      unlocked: progress.quizzesPassed >= 10,
    ));
    
    // Streak Achievement
    achievements.add(Achievement(
      title: 'Consistent Learner',
      description: 'Maintain a 7-day learning streak',
      icon: Icons.local_fire_department,
      unlocked: progress.longestStreak >= 7,
    ));
    
    // Hours Achievement
    achievements.add(Achievement(
      title: 'Dedicated Student',
      description: 'Complete 10 hours of learning',
      icon: Icons.school,
      unlocked: progress.totalHoursWatched >= 10,
    ));
    
    // Perfect Score Achievement
    achievements.add(Achievement(
      title: 'Perfect Score',
      description: 'Get 100% on a quiz',
      icon: Icons.star,
      unlocked: progress.quizScores.values.any((score) => score >= 100),
    ));
    
    return achievements;
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });
}

