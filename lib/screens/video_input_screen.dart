import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/youtube_service.dart';

class VideoInputScreen extends StatefulWidget {
  const VideoInputScreen({super.key});

  @override
  State<VideoInputScreen> createState() => _VideoInputScreenState();
}

class _VideoInputScreenState extends State<VideoInputScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String? _videoId;
  bool _isValidUrl = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_validateUrl);
    _checkClipboard();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _checkClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final text = clipboardData!.text!;
        if (YouTubeService.isValidYouTubeUrl(text)) {
          setState(() {
            _urlController.text = text;
          });
          _validateUrl();
        }
      }
    } catch (e) {
      // Clipboard access failed, ignore
    }
  }

  void _validateUrl() {
    final url = _urlController.text.trim();
    final videoId = YouTubeService.extractVideoId(url);
    
    setState(() {
      _videoId = videoId;
      _isValidUrl = videoId != null;
    });
  }

  Future<void> _addVideo() async {
    if (!_isValidUrl || _videoId == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await YouTubeService.addAllowedVideo(_videoId!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchVideo() async {
    if (_videoId == null) return;
    
    final success = await YouTubeService.launchVideo(_videoId!);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open video'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Educational Video'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add educational YouTube videos that you want to watch during your learning sessions.',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // URL Input
            const Text(
              'YouTube Video URL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'Paste YouTube video URL here...',
                border: const OutlineInputBorder(),
                suffixIcon: _isValidUrl 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : _urlController.text.isNotEmpty
                    ? const Icon(Icons.error, color: Colors.red)
                    : null,
                helperText: _isValidUrl 
                  ? 'Valid YouTube URL detected'
                  : _urlController.text.isNotEmpty
                    ? 'Please enter a valid YouTube URL'
                    : null,
                helperStyle: TextStyle(
                  color: _isValidUrl ? Colors.green : Colors.red,
                ),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            
            // Paste from clipboard button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _checkClipboard,
                icon: const Icon(Icons.content_paste),
                label: const Text('Paste from Clipboard'),
              ),
            ),
            const SizedBox(height: 24),
            
            // Video Preview
            if (_isValidUrl && _videoId != null) ...[
              const Text(
                'Video Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        children: [
                          Image.network(
                            YouTubeService.getVideoThumbnailUrl(_videoId!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.video_library,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Video ID: $_videoId',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Video info
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Video Title (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Notes (Optional)',
                              border: OutlineInputBorder(),
                              hintText: 'Add notes about why this video is educational...',
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _launchVideo,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Preview Video'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _addVideo,
                      icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                      label: Text(_isLoading ? 'Adding...' : 'Add Video'),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Tips
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Tips for Educational Videos',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Choose videos from educational channels like Khan Academy, Crash Course, or TED-Ed'),
                    _buildTip('Look for videos that teach specific skills or concepts'),
                    _buildTip('Avoid entertainment content during focus sessions'),
                    _buildTip('Consider the video length - shorter videos are often more focused'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

