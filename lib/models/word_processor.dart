import 'dart:async';

class WordProcessor {
  String text;
  int wpm;
  final Function(String) onWord;
  final Function(double) onProgress;
  final Function() onComplete;
  Timer? _timer;
  bool _isPaused = false;
  List<String> _words = [];
  int _currentIndex = 0;
  bool _isInitialized = false;

  WordProcessor({
    required this.text,
    required this.wpm,
    required this.onWord,
    required this.onProgress,
    required this.onComplete,
  }) {
    // Improved tokenization
    _words = _tokenize(text);
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Process text in chunks to allow UI updates
    const chunkSize = 1000;
    List<String> words = [];
    
    for (var i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      final chunk = text.substring(i, end);
      
      // Tokenize chunk
      words.addAll(_tokenize(chunk));
      
      // Update progress
      onProgress(i / text.length);
      
      // Allow UI to update
      await Future.delayed(const Duration(milliseconds: 1));
    }
    
    _words = words.where((word) => word.isNotEmpty).toList();
    _isInitialized = true;
    onProgress(0); // Reset progress
  }

  List<String> _tokenize(String text) {
    List<String> words = [];
    String currentWord = '';
    bool inAbbreviation = false;

    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      String? nextChar = i < text.length - 1 ? text[i + 1] : null;

      // Handle abbreviations (e.g., "Mr.", "St.", "U.S.A.")
      if (char == '.' && nextChar != null) {
        if (nextChar.trim().isEmpty) {  // End of sentence
          currentWord += char;
          if (currentWord.isNotEmpty) words.add(currentWord.trim());
          currentWord = '';
          inAbbreviation = false;
        } else {  // Part of abbreviation
          currentWord += char;
          inAbbreviation = true;
          continue;
        }
      }
      // Handle contractions and possessives
      else if (char == "'" && nextChar != null && "sStTdDmMvVrRlL".contains(nextChar)) {
        currentWord += char;
        continue;
      }
      // Handle spaces
      else if (char.trim().isEmpty) {
        if (currentWord.isNotEmpty && !inAbbreviation) {
          words.add(currentWord.trim());
          currentWord = '';
        } else if (inAbbreviation) {
          currentWord += char;
        }
      }
      // Handle all other characters
      else {
        currentWord += char;
      }
    }

    // Add final word if exists
    if (currentWord.isNotEmpty) {
      words.add(currentWord.trim());
    }

    return words.where((w) => w.isNotEmpty).toList();
  }

  int _getDelayForWord(String word) {
    final baseDelay = 60000 ~/ wpm;  // Convert WPM to milliseconds
    print('WordProcessor: Base delay for $wpm WPM: $baseDelay ms');
    
    if (RegExp(r'[.!?]$').hasMatch(word)) {
      return (baseDelay * 2).toInt();
    }
    if (RegExp(r'[,;]$').hasMatch(word)) {
      return (baseDelay * 1.5).toInt();
    }
    if (word.length > 8) {
      return (baseDelay * 1.3).toInt();
    }
    
    return baseDelay;
  }

  void start() {
    if (_currentIndex >= _words.length) {
      _currentIndex = 0;
    }
    
    _scheduleNextWord();
  }

  void updateWPM(int newWPM) {
    print('WordProcessor: Updating WPM from $wpm to $newWPM');
    wpm = newWPM;
    
    // Always cancel and reschedule, even if paused
    _timer?.cancel();
    
    // If we're not paused, schedule next word with new speed
    if (!_isPaused) {
      print('WordProcessor: Rescheduling with new WPM: $wpm');
      _scheduleNextWord();
    }
  }

  void _scheduleNextWord() {
    if (_isPaused || _currentIndex >= _words.length) {
      if (_currentIndex >= _words.length) {
        onComplete();
      }
      return;
    }

    final word = _words[_currentIndex];
    onWord(word);
    onProgress(_currentIndex / _words.length);

    final delay = _getDelayForWord(word);
    print('WordProcessor: Next word delay: $delay ms at $wpm WPM');
    
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
    if (!_isPaused) {
      _scheduleNextWord();
    }
  }

  void stop() {
    _timer?.cancel();
    _currentIndex = 0;
    _isPaused = false;
  }

  void dispose() {
    _timer?.cancel();
  }

  void nextWord() {
    if (_currentIndex < _words.length - 1) {
      _timer?.cancel();  // Cancel any pending timer
      _isPaused = true;  // Pause the auto-reading
      _currentIndex++;
      // Just display the word without scheduling next
      final word = _words[_currentIndex];
      onWord(word);
      onProgress(_currentIndex / _words.length);
    }
  }

  void previousWord() {
    if (_currentIndex > 0) {
      _timer?.cancel();  // Cancel any pending timer
      _isPaused = true;  // Pause the auto-reading
      _currentIndex--;
      // Just display the word without scheduling next
      final word = _words[_currentIndex];
      onWord(word);
      onProgress(_currentIndex / _words.length);
    }
  }
} 