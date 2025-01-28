import 'dart:async';
import 'dart:math' as math;

const double kMinAnimationDuration = 0.05; // 50ms minimum duration

class WordProcessor {
  final String text;
  int _wpm;  // Make it private
  final Function(String) onWord;
  final Function(double) onProgress;
  final Function() onComplete;
  Timer? _timer;
  bool _isPaused = false;
  List<String> _words = [];
  int _currentIndex = 0;
  bool _isInitialized = false;
  Duration _wordDuration = Duration.zero;

  WordProcessor({
    required this.text,
    required int wpm,  // Change parameter name
    required this.onWord,
    required this.onProgress,
    required this.onComplete,
  }) : _wpm = wpm {  // Initialize private _wpm
    _words = _tokenize(text);
  }

  // Add getter for wpm if needed
  int get wpm => _wpm;

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

    // Patterns for abbreviations and place names
    final placeNamePattern = RegExp(
      r'[A-Z]\. (?:Place|Street|Road|Bridge|Ave|Boulevard|Square|Park|Building)',
      caseSensitive: true,
    );

    final abbreviationPattern = RegExp(
      r'\b(Mr\.|Mrs\.|Ms\.|Dr\.|Prof\.|Sr\.|Jr\.|St\.|Ave\.|Rd\.|Blvd\.|Apt\.|'
      r'[A-Z]\.|[A-Z]\.[A-Z]\.|[A-Z]\.[A-Z]\.[A-Z]\.)',
      caseSensitive: true,
    );

    // Look-ahead function to check if this is part of a place name
    bool isPlaceName(int index) {
      if (index >= text.length - 2) return false;
      String lookAhead = text.substring(index, math.min(index + 20, text.length));
      return placeNamePattern.hasMatch(lookAhead);
    }

    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      String? nextChar = i < text.length - 1 ? text[i + 1] : null;
      String? prevChar = i > 0 ? text[i - 1] : null;

      // First, check for single-letter place names (e.g., "K. Bridge")
      if (prevChar == null && 
          RegExp(r'[A-Z]').hasMatch(char) && 
          nextChar == '.' && 
          isPlaceName(i)) {
        String lookAhead = text.substring(i, math.min(i + 20, text.length));
        var match = placeNamePattern.firstMatch(lookAhead);
        if (match != null) {
          String placeName = match.group(0)!;
          words.add(placeName);
          i += placeName.length - 1;
          currentWord = '';
          continue;
        }
      }
      // If we're at the start of a word and see a capital letter
      else if ((prevChar?.trim().isEmpty ?? true) && 
               RegExp(r'[A-Z]').hasMatch(char) && 
               isPlaceName(i)) {
        String lookAhead = text.substring(i, math.min(i + 20, text.length));
        var match = placeNamePattern.firstMatch(lookAhead);
        if (match != null) {
          String placeName = match.group(0)!;
          words.add(placeName);
          i += placeName.length - 1;
          currentWord = '';
          continue;
        }
      }

      // Handle abbreviations and periods
      if (char == '.' && nextChar != null) {
        String lookAhead = text.substring(i - 10 >= 0 ? i - 10 : 0, i + 1);
        if (abbreviationPattern.hasMatch(lookAhead)) {
          currentWord += char;
          inAbbreviation = true;
          continue;
        }
        
        // Handle end of sentence
        if (nextChar.trim().isEmpty || nextChar == "\"" || nextChar == "'") {
          currentWord += char;
          if (currentWord.isNotEmpty) words.add(currentWord.trim());
          currentWord = '';
          inAbbreviation = false;
        } else {
          currentWord += char;
          inAbbreviation = true;
        }
      }
      // Handle contractions and possessives
      else if (char == "'" && nextChar != null && 
               (RegExp(r'[sStTdDmMvVrRlL]').hasMatch(nextChar) || 
                (nextChar == 'r' && prevChar == 'e'))) {
        currentWord += char;
        continue;
      }
      // Handle hyphenated words
      else if (char == '-' && 
              nextChar != null && 
              prevChar != null &&
              RegExp(r'[a-zA-Z]').hasMatch(nextChar) &&
              RegExp(r'[a-zA-Z]').hasMatch(prevChar)) {
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
      // Handle numbers with decimals
      else if (RegExp(r'[0-9]').hasMatch(char)) {
        if (currentWord.isEmpty || RegExp(r'[0-9.]').hasMatch(currentWord)) {
          currentWord += char;
          continue;
        }
        if (currentWord.isNotEmpty) {
          words.add(currentWord.trim());
        }
        currentWord = char;
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

    return words.where((w) => w.trim().isNotEmpty).map((w) => w.trim()).toList();
  }

  int _getDelayForWord(String word) {
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

  void start() {
    if (_currentIndex >= _words.length) {
      _currentIndex = 0;
    }
    
    _scheduleNextWord();
  }

  void updateWPM(int wpm) {
    _wpm = wpm;
    // Ensure we have a minimum animation duration even at high speeds
    _wordDuration = Duration(
      milliseconds: math.max(
        (60000 / _wpm).round(),
        (kMinAnimationDuration * 1000).round(),
      ),
    );
    
    // Always cancel and reschedule, even if paused
    _timer?.cancel();
    
    // If we're not paused, schedule next word with new speed
    if (!_isPaused) {
      print('WordProcessor: Rescheduling with new WPM: $_wpm');
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
    print("WordProcessor: Next word delay: $delay ms at $_wpm WPM");
    
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