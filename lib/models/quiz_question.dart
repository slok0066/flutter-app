class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String category;
  final int difficulty; // 1-3

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.category,
    required this.difficulty,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      explanation: json['explanation'],
      category: json['category'],
      difficulty: json['difficulty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'category': category,
      'difficulty': difficulty,
    };
  }
}

// Predefined quiz questions for educational content
class QuizDatabase {
  static List<QuizQuestion> getQuestions(int difficulty) {
    final allQuestions = [
      // Easy questions (difficulty 1)
      QuizQuestion(
        question: "What is the largest planet in our solar system?",
        options: ["Earth", "Jupiter", "Saturn", "Mars"],
        correctAnswerIndex: 1,
        explanation: "Jupiter is the largest planet in our solar system, with a mass greater than all other planets combined.",
        category: "Science",
        difficulty: 1,
      ),
      QuizQuestion(
        question: "Who wrote the play 'Romeo and Juliet'?",
        options: ["Charles Dickens", "William Shakespeare", "Mark Twain", "Jane Austen"],
        correctAnswerIndex: 1,
        explanation: "William Shakespeare wrote Romeo and Juliet, one of his most famous tragedies.",
        category: "Literature",
        difficulty: 1,
      ),
      QuizQuestion(
        question: "What is 15 + 27?",
        options: ["40", "42", "44", "46"],
        correctAnswerIndex: 1,
        explanation: "15 + 27 = 42",
        category: "Mathematics",
        difficulty: 1,
      ),
      
      // Medium questions (difficulty 2)
      QuizQuestion(
        question: "What is the chemical symbol for gold?",
        options: ["Go", "Gd", "Au", "Ag"],
        correctAnswerIndex: 2,
        explanation: "Au is the chemical symbol for gold, derived from the Latin word 'aurum'.",
        category: "Science",
        difficulty: 2,
      ),
      QuizQuestion(
        question: "In which year did World War II end?",
        options: ["1944", "1945", "1946", "1947"],
        correctAnswerIndex: 1,
        explanation: "World War II ended in 1945 with the surrender of Japan in September.",
        category: "History",
        difficulty: 2,
      ),
      QuizQuestion(
        question: "What is the square root of 144?",
        options: ["10", "11", "12", "13"],
        correctAnswerIndex: 2,
        explanation: "The square root of 144 is 12, because 12 × 12 = 144.",
        category: "Mathematics",
        difficulty: 2,
      ),
      
      // Hard questions (difficulty 3)
      QuizQuestion(
        question: "What is the powerhouse of the cell?",
        options: ["Nucleus", "Ribosome", "Mitochondria", "Endoplasmic Reticulum"],
        correctAnswerIndex: 2,
        explanation: "Mitochondria are known as the powerhouse of the cell because they produce ATP, the cell's main energy currency.",
        category: "Biology",
        difficulty: 3,
      ),
      QuizQuestion(
        question: "Who developed the theory of relativity?",
        options: ["Isaac Newton", "Albert Einstein", "Galileo Galilei", "Stephen Hawking"],
        correctAnswerIndex: 1,
        explanation: "Albert Einstein developed both the special and general theories of relativity.",
        category: "Physics",
        difficulty: 3,
      ),
      QuizQuestion(
        question: "What is the derivative of x²?",
        options: ["x", "2x", "x²", "2x²"],
        correctAnswerIndex: 1,
        explanation: "The derivative of x² is 2x, using the power rule of differentiation.",
        category: "Mathematics",
        difficulty: 3,
      ),
    ];
    
    return allQuestions.where((q) => q.difficulty == difficulty).toList();
  }
  
  static List<QuizQuestion> getRandomQuestions(int difficulty, int count) {
    final questions = getQuestions(difficulty);
    questions.shuffle();
    return questions.take(count).toList();
  }
}

