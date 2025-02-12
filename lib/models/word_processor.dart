import 'dart:async';
import 'dart:math' as math;

const double kMinAnimationDuration = 0.05; // 50ms minimum duration

class WordProcessor {
  final String text;
  int _wpm;
  final Function(String) onWord;
  final Function(double) onProgress;
  final Function() onComplete;
  Timer? _timer;
  bool _isPaused = false;
  List<String> _words = [];
  int _currentIndex = 0;
  bool _isInitialized = false;
  bool _isMathMode = false;

  // Add a map to store answers
  final Map<String, String> _answers = {};

  WordProcessor({
    required this.text,
    required int wpm,
    required this.onWord,
    required this.onProgress,
    required this.onComplete,
  }) : _wpm = wpm {
    // Remove tokenization from constructor
  }

  int get wpm => _wpm;

  List<String> _tokenize(String text) {
    // Check if this is math content
    _isMathMode = text.contains(' = ?');
    
    if (_isMathMode) {
      // For math, treat each line as one complete equation
      return text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
    }

    // Original tokenization for regular text
    return text
        .split(RegExp(r'(\s+)'))
        .where((word) => word.trim().isNotEmpty)
        .toList();
  }

  String? getAnswer(String problem) {
    print('Getting answer for: $problem');  // Debug print 1
    
    if (!problem.contains('=')) return null;
    
    final parts = problem.split(' = ');
    if (parts.length != 2) return null;

    final equation = parts[0].trim();
    print('Equation: $equation');  // Debug print 2
    
    final operands = equation.split(RegExp(r'[\+\-]'));
    print('Operands: $operands');  // Debug print 3
    
    if (operands.length != 2) return null;

    try {
      final num1 = int.parse(operands[0].trim());
      final num2 = int.parse(operands[1].trim());
      
      if (equation.contains('+')) {
        final answer = (num1 + num2).toString();
        print('Addition result: $answer');  // Debug print 4
        return answer;
      } else if (equation.contains('-')) {
        final answer = (num1 - num2).toString();
        print('Subtraction result: $answer');  // Debug print 5
        return answer;
      }
    } catch (e) {
      print('Error calculating: $e');
      return null;
    }
    
    return null;
  }

  void start() {
    if (_words.isEmpty) return;  // Guard against empty list
    
    _currentIndex = 0;  // Always start at beginning
    onWord(_words[0]);  // Show first word immediately
    onProgress(0);      // Reset progress
    _scheduleNextWord();
  }

  void _scheduleNextWord() {
    if (_isPaused || _currentIndex >= _words.length) {
      if (_currentIndex >= _words.length) {
        onComplete();
        _currentIndex = 0;
      }
      return;
    }

    final word = _words[_currentIndex];
    onWord(word);
    onProgress(_currentIndex / _words.length);

    final delay = _isMathMode ? 3000 : _getDelayForWord(word);
    
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: delay), () {
      if (!_isPaused) {
        _currentIndex++;
        _scheduleNextWord();
      }
    });
  }

  void togglePause() {
    _isPaused = !_isPaused;
    if (!_isPaused) _scheduleNextWord();
  }

  void nextWord() {
    if (_currentIndex < _words.length - 1) {
      _timer?.cancel();
      _isPaused = true;
      _currentIndex++;
      onWord(_words[_currentIndex]);
      onProgress(_currentIndex / _words.length);
    } else {
      // At the end, call onComplete
      onComplete();
    }
  }

  void previousWord() {
    if (_currentIndex > 0) {
      _timer?.cancel();
      _isPaused = true;
      _currentIndex--;
      onWord(_words[_currentIndex]);
      onProgress(_currentIndex / _words.length);
    }
  }

  void updateWPM(int wpm) {
    _wpm = wpm;
    if (!_isPaused) {
      _timer?.cancel();
      _scheduleNextWord();
    }
  }

  void dispose() {
    _timer?.cancel();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Do tokenization here instead
    _words = _tokenize(text);
    
    if (_words.isNotEmpty) {
      onWord(_words[0]);  // Show first word immediately
    }
    
    _isInitialized = true;
    onProgress(0); // Reset progress
  }

  void stop() {
    _timer?.cancel();
    _currentIndex = 0;
    _isPaused = false;
  }

  String peekCurrentWord() {
    if (_words.isEmpty) return '';
    return _words[_currentIndex];
  }

  int _getDelayForWord(String word) {
    if (_isMathMode) {
      // Give 3 seconds for each math problem
      return 3000;
    }

    final baseDelay = 60000 ~/ _wpm;
    print('WordProcessor: Base delay for $_wpm WPM: $baseDelay ms');
    
    if (RegExp(r'[.!?]\b').hasMatch(word)) {
      return (baseDelay * 2).toInt();
    }
    if (RegExp(r'[,;]\b').hasMatch(word)) {
      return (baseDelay * 1.5).toInt();
    }
    if (word.length > 8) {
      return (baseDelay * 1.3).toInt();
    }
    
    return baseDelay;
  }

  int _calculateAnswer(String equation) {
    final parts = equation.split(RegExp(r'[\+\-]'));
    final num1 = int.parse(parts[0].trim());
    final num2 = int.parse(parts[1].trim());
    
    if (equation.contains('+')) {
      return num1 + num2;
    } else if (equation.contains('-')) {
      return num1 - num2;
    }
    
    return 0;
  }
} 