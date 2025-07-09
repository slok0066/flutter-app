import 'package:hive/hive.dart';

part 'progress_data.g.dart';

@HiveType(typeId: 1)
class ProgressData extends HiveObject {
  @HiveField(0)
  int videosWatched;
  
  @HiveField(1)
  int quizzesPassed;
  
  @HiveField(2)
  int currentStreak;
  
  @HiveField(3)
  int longestStreak;
  
  @HiveField(4)
  double totalHoursWatched;
  
  @HiveField(5)
  DateTime lastSessionDate;
  
  @HiveField(6)
  List<String> completedVideoIds;
  
  @HiveField(7)
  Map<String, int> quizScores; // videoId -> score
  
  @HiveField(8)
  List<DateTime> sessionDates;

  ProgressData({
    this.videosWatched = 0,
    this.quizzesPassed = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalHoursWatched = 0.0,
    DateTime? lastSessionDate,
    this.completedVideoIds = const [],
    this.quizScores = const {},
    this.sessionDates = const [],
  }) : lastSessionDate = lastSessionDate ?? DateTime.now();
  
  void addVideoSession(String videoId, Duration watchTime) {
    videosWatched++;
    totalHoursWatched += watchTime.inMinutes / 60.0;
    
    if (!completedVideoIds.contains(videoId)) {
      completedVideoIds = [...completedVideoIds, videoId];
    }
    
    _updateStreak();
    lastSessionDate = DateTime.now();
    sessionDates = [...sessionDates, DateTime.now()];
    save();
  }
  
  void addQuizResult(String videoId, int score) {
    if (score >= 70) { // Passing score
      quizzesPassed++;
    }
    
    final newScores = Map<String, int>.from(quizScores);
    newScores[videoId] = score;
    quizScores = newScores;
    save();
  }
  
  void _updateStreak() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (_isSameDay(lastSessionDate, yesterday) || 
        _isSameDay(lastSessionDate, today)) {
      if (!_isSameDay(lastSessionDate, today)) {
        currentStreak++;
      }
    } else {
      currentStreak = 1;
    }
    
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  double get averageQuizScore {
    if (quizScores.isEmpty) return 0.0;
    final total = quizScores.values.reduce((a, b) => a + b);
    return total / quizScores.length;
  }
  
  int get sessionsThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    return sessionDates.where((date) => 
        date.isAfter(weekStart) && date.isBefore(now.add(const Duration(days: 1)))
    ).length;
  }
}

