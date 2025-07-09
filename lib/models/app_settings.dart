import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 0)
class AppSettings extends HiveObject {
  @HiveField(0)
  String startTime;
  
  @HiveField(1)
  String endTime;
  
  @HiveField(2)
  bool isEnabled;
  
  @HiveField(3)
  int reminderMinutes;
  
  @HiveField(4)
  List<String> allowedVideoIds;
  
  @HiveField(5)
  bool blockYouTubeApp;
  
  @HiveField(6)
  int quizDifficulty; // 1-3 (Easy, Medium, Hard)
  
  @HiveField(7)
  bool requireQuizToUnlock;

  AppSettings({
    this.startTime = '20:00',
    this.endTime = '21:00',
    this.isEnabled = true,
    this.reminderMinutes = 5,
    this.allowedVideoIds = const [],
    this.blockYouTubeApp = true,
    this.quizDifficulty = 2,
    this.requireQuizToUnlock = true,
  });
  
  // Helper methods
  DateTime get startDateTime {
    final parts = startTime.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 
        int.parse(parts[0]), int.parse(parts[1]));
  }
  
  DateTime get endDateTime {
    final parts = endTime.split(':');
    final now = DateTime.now();
    var endDate = DateTime(now.year, now.month, now.day, 
        int.parse(parts[0]), int.parse(parts[1]));
    
    // If end time is before start time, it's next day
    if (endDate.isBefore(startDateTime)) {
      endDate = endDate.add(const Duration(days: 1));
    }
    
    return endDate;
  }
  
  bool get isCurrentlyAllowed {
    final now = DateTime.now();
    final start = startDateTime;
    final end = endDateTime;
    
    if (end.day > start.day) {
      // Spans midnight
      return now.isAfter(start) || now.isBefore(end);
    } else {
      // Same day
      return now.isAfter(start) && now.isBefore(end);
    }
  }
  
  Duration get timeUntilNextSession {
    final now = DateTime.now();
    var nextStart = startDateTime;
    
    if (now.isAfter(nextStart)) {
      nextStart = nextStart.add(const Duration(days: 1));
    }
    
    return nextStart.difference(now);
  }
}

