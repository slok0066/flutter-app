import 'package:url_launcher/url_launcher.dart';
import 'package:hive/hive.dart';

class YouTubeService {
  static const String _youtubeAppPackage = 'com.google.android.youtube';
  static const String _youtubeWebUrl = 'https://www.youtube.com/watch?v=';
  
  static String? extractVideoId(String url) {
    // Extract video ID from various YouTube URL formats
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
  
  static bool isValidYouTubeUrl(String url) {
    return extractVideoId(url) != null;
  }
  
  static Future<bool> launchVideo(String videoId) async {
    try {
      // Try to open in YouTube app first
      final youtubeAppUrl = Uri.parse('youtube://watch?v=$videoId');
      if (await canLaunchUrl(youtubeAppUrl)) {
        return await launchUrl(youtubeAppUrl);
      }
      
      // Fallback to web browser
      final webUrl = Uri.parse('$_youtubeWebUrl$videoId');
      return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error launching video: $e');
      return false;
    }
  }
  
  static Future<void> addAllowedVideo(String videoId) async {
    final box = Hive.box('videos');
    final allowedVideos = List<String>.from(box.get('allowed', defaultValue: []));
    
    if (!allowedVideos.contains(videoId)) {
      allowedVideos.add(videoId);
      await box.put('allowed', allowedVideos);
    }
  }
  
  static Future<void> removeAllowedVideo(String videoId) async {
    final box = Hive.box('videos');
    final allowedVideos = List<String>.from(box.get('allowed', defaultValue: []));
    
    allowedVideos.remove(videoId);
    await box.put('allowed', allowedVideos);
  }
  
  static Future<List<String>> getAllowedVideos() async {
    final box = Hive.box('videos');
    return List<String>.from(box.get('allowed', defaultValue: []));
  }
  
  static Future<bool> isVideoAllowed(String videoId) async {
    final allowedVideos = await getAllowedVideos();
    return allowedVideos.contains(videoId);
  }
  
  static String getVideoThumbnailUrl(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }
  
  static String getVideoUrl(String videoId) {
    return '$_youtubeWebUrl$videoId';
  }
  
  // Store video session data
  static Future<void> recordVideoSession(String videoId, Duration watchTime) async {
    final box = Hive.box('videos');
    final sessions = Map<String, dynamic>.from(box.get('sessions', defaultValue: {}));
    
    final sessionData = {
      'videoId': videoId,
      'watchTime': watchTime.inSeconds,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    final videoSessions = List<Map<String, dynamic>>.from(
      sessions[videoId] ?? []
    );
    videoSessions.add(sessionData);
    sessions[videoId] = videoSessions;
    
    await box.put('sessions', sessions);
  }
  
  static Future<Duration> getTotalWatchTime(String videoId) async {
    final box = Hive.box('videos');
    final sessions = Map<String, dynamic>.from(box.get('sessions', defaultValue: {}));
    
    final videoSessions = List<Map<String, dynamic>>.from(
      sessions[videoId] ?? []
    );
    
    int totalSeconds = 0;
    for (final session in videoSessions) {
      totalSeconds += (session['watchTime'] as int? ?? 0);
    }
    
    return Duration(seconds: totalSeconds);
  }
}

