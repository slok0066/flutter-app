import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import '../models/quiz_question.dart';
import '../models/app_settings.dart';
import '../models/progress_data.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;
  bool _quizCompleted = false;
  Timer? _timer;
  int _timeLeft = 30; // 30 seconds per question
  
  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadQuiz() {
    final settingsBox = Hive.box<AppSettings>('settings');
    final settings = settingsBox.get('main', defaultValue: AppSettings())!;
    
    _questions = QuizDatabase.getRandomQuestions(settings.quizDifficulty, 5);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
      });
      
      if (_timeLeft <= 0) {
        _timer?.cancel();
        _submitAnswer(null); // Auto-submit with no answer
      }
    });
  }

  void _submitAnswer(int? answerIndex) {
    if (_showExplanation) return;
    
    _timer?.cancel();
    
    setState(() {
      _selectedAnswer = answerIndex;
      _showExplanation = true;
    });

    final currentQuestion = _questions[_currentQuestionIndex];
    if (answerIndex == currentQuestion.correctAnswerIndex) {
      _score += 20; // 20 points per correct answer
    }

    // Show explanation for 3 seconds, then move to next question
    Timer(const Duration(seconds: 3), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
          _showExplanation = false;
        });
        _startTimer();
      } else {
        _completeQuiz();
      }
    });
  }

  void _completeQuiz() {
    _timer?.cancel();
    
    setState(() {
      _quizCompleted = true;
    });

    // Save quiz result
    final progressBox = Hive.box<ProgressData>('progress');
    final progress = progressBox.get('main', defaultValue: ProgressData())!;
    progress.addQuizResult('quiz_${DateTime.now().millisecondsSinceEpoch}', _score);
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_quizCompleted) {
      return _buildResultScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz ${_currentQuestionIndex + 1}/${_questions.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '$_timeLeft s',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _timeLeft <= 10 ? Colors.red : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $_score',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getDifficultyText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Question
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _questions[_currentQuestionIndex].question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Answer options
            Expanded(
              child: ListView.builder(
                itemCount: _questions[_currentQuestionIndex].options.length,
                itemBuilder: (context, index) {
                  return _buildAnswerOption(index);
                },
              ),
            ),
            
            // Explanation
            if (_showExplanation) ...[
              Card(
                color: _selectedAnswer == _questions[_currentQuestionIndex].correctAnswerIndex
                    ? Colors.green[50]
                    : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _selectedAnswer == _questions[_currentQuestionIndex].correctAnswerIndex
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _selectedAnswer == _questions[_currentQuestionIndex].correctAnswerIndex
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedAnswer == _questions[_currentQuestionIndex].correctAnswerIndex
                                ? 'Correct!'
                                : 'Incorrect',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedAnswer == _questions[_currentQuestionIndex].correctAnswerIndex
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_questions[_currentQuestionIndex].explanation),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(int index) {
    final question = _questions[_currentQuestionIndex];
    final isSelected = _selectedAnswer == index;
    final isCorrect = index == question.correctAnswerIndex;
    final showResult = _showExplanation;
    
    Color? backgroundColor;
    Color? borderColor;
    
    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green[100];
        borderColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red[100];
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
      borderColor = Theme.of(context).primaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: showResult ? null : () => _submitAnswer(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor ?? Colors.grey[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected || (showResult && isCorrect)
                        ? (isCorrect ? Colors.green : Colors.red)
                        : Colors.grey[300],
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        color: isSelected || (showResult && isCorrect)
                            ? Colors.white
                            : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    question.options[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                if (showResult && isCorrect)
                  const Icon(Icons.check, color: Colors.green),
                if (showResult && isSelected && !isCorrect)
                  const Icon(Icons.close, color: Colors.red),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / 100) * 100;
    final passed = percentage >= 70;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              passed ? Icons.celebration : Icons.sentiment_dissatisfied,
              size: 100,
              color: passed ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              passed ? 'Congratulations!' : 'Keep Learning!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              passed 
                  ? 'You passed the quiz and can now watch educational videos!'
                  : 'You need 70% to pass. Try again to improve your score.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Score display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      '$_score / 100',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: passed ? Colors.green : Colors.orange,
                      ),
                    ),
                    Text(
                      '${percentage.toInt()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        passed ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(passed ? 'Start Learning!' : 'Back to Home'),
              ),
            ),
            if (!passed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex = 0;
                      _score = 0;
                      _selectedAnswer = null;
                      _showExplanation = false;
                      _quizCompleted = false;
                    });
                    _loadQuiz();
                  },
                  child: const Text('Try Again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getDifficultyText() {
    final settingsBox = Hive.box<AppSettings>('settings');
    final settings = settingsBox.get('main', defaultValue: AppSettings())!;
    
    switch (settings.quizDifficulty) {
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

  Color _getDifficultyColor() {
    final settingsBox = Hive.box<AppSettings>('settings');
    final settings = settingsBox.get('main', defaultValue: AppSettings())!;
    
    switch (settings.quizDifficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

