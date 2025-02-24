import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this for keyboard events
import '../widgets/word_display.dart';
import '../widgets/controls_panel.dart';
import '../widgets/word_lists.dart';
import '../models/word_processor.dart';
import '../models/settings.dart';  // Add this for settings
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'dart:async';

const double kMaxContentWidth = 800.0;

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _wpmController = TextEditingController();  // Add this
  final FocusNode _keyboardFocusNode = FocusNode();  // Add this
  final ScrollController _scrollController = ScrollController();  // Add this
  final Settings settings = Settings();
  bool _isReading = false;
  bool _isLoading = false;
  int _wpm = 300;
  WordProcessor? _processor;
  String _currentWord = '';
  double _progress = 0;
  bool _isPaused = false;
  String _loadingMessage = '';
  bool _showLoadingOverlay = false;
  final GlobalKey _startButtonKey = GlobalKey();
  bool _isMathMode = false;

  @override
  void initState() {
    super.initState();
    _wpmController.text = _wpm.toString();  // Initialize WPM controller
  }

  void _startReading(bool isSmallScreen) async {
    if (_textController.text.isEmpty) return;
    
    setState(() {
      _showLoadingOverlay = true;
      _loadingMessage = 'Preparing reader...';
      // Check if this is math content by looking for equations
      _isMathMode = _textController.text.contains(' = ?');
    });

    try {
      // Clean up any existing processor
      _processor?.dispose();
      
      _processor = WordProcessor(
        text: _textController.text,
        wpm: _wpm,
        onWord: (word) => setState(() => _currentWord = word),
        onProgress: (progress) => setState(() => _progress = progress),
        onComplete: () => setState(() => _isReading = false),
        isMathMode: _isMathMode,
      );
      
      await _processor!.initialize();
      setState(() {
        _isReading = true;
        // Always start in paused state for text mode, unpause for math mode
        _isPaused = !_isMathMode;
      });
      
      // Start paused only for text mode
      if (!_isMathMode) {
        _processor!.togglePause();
      }
      _keyboardFocusNode.requestFocus();
    } finally {
      setState(() {
        _showLoadingOverlay = false;
      });
    }
  }

  void _togglePause() {
    if (!_isReading || _processor == null) return;
    setState(() {
      _isPaused = !_isPaused;  // Toggle UI state
    });
    _processor!.togglePause();  // Toggle processor state
  }

  void _stopReading() {
    _processor?.stop();
    _processor?.dispose();
    _processor = null;
    
    setState(() {
      _isReading = false;
      _currentWord = '';
      _progress = 0;
    });
  }

  // Update _handleTextChange to enable the start button
  Future<void> _handleTextChange(String text) async {
    setState(() {
    _textController.text = text;
    });
    
    if (text.isNotEmpty) {
      // Wait for next frame to ensure the UI has updated
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  // Update _handleTextSelected to scroll after text is loaded
  Future<void> _handleTextSelected(String text, bool isMathMode) async {
    setState(() {
      _showLoadingOverlay = true;
      _loadingMessage = 'Loading text...';
      _isMathMode = isMathMode;  // Set mode from parameter
    });
    
    try {
      if (text.length > 100000) {
        setState(() => _loadingMessage = 'Processing large text...');
        await Future.delayed(const Duration(milliseconds: 16));
      }
      
      _processor?.dispose();
      _processor = null;
      _textController.text = text;
      
      // Add delay to ensure UI is updated
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Scroll to the button
      final context = _startButtonKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    } finally {
      setState(() {
        _showLoadingOverlay = false;
      });
    }
  }

  // Update _handlePaste to use setState
  Future<void> _handlePaste() async {
    setState(() => _isLoading = true);
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null && data!.text!.isNotEmpty) {
        setState(() {
          _textController.text = data.text!;  // Update text directly
        });
        await _handleTextChange(data.text!);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    print('ReaderScreen: Key pressed: ${event.logicalKey}');

    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
        if (_isReading) {
          print('ReaderScreen: Toggle pause');
          _togglePause();
        }
        break;
      case LogicalKeyboardKey.escape:
        if (_isReading) {
          print('ReaderScreen: Stop reading');
          _stopReading();
        }
        break;
      case LogicalKeyboardKey.arrowUp:
        print('ReaderScreen: Increasing WPM from $_wpm');
        setState(() {
          _wpm = math.min(1000, _wpm + 50);
          _wpmController.text = _wpm.toString();
        });
        if (_isReading) {
          _processor?.updateWPM(_wpm);
        }
        break;
      case LogicalKeyboardKey.arrowDown:
        print('ReaderScreen: Decreasing WPM from $_wpm');
        setState(() {
          _wpm = math.max(60, _wpm - 50);
          _wpmController.text = _wpm.toString();
        });
        if (_isReading) {
          _processor?.updateWPM(_wpm);
        }
        break;
      case LogicalKeyboardKey.arrowRight:
        if (_isReading) {
          _processor?.nextWord();
        }
        break;
      case LogicalKeyboardKey.arrowLeft:
        if (_isReading) {
          _processor?.previousWord();
        }
        break;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _wpmController.dispose();
    _keyboardFocusNode.dispose();
    _scrollController.dispose();  // Add this
    _processor?.dispose();
    _processor = null;
    super.dispose();
  }

  bool get _isSmallScreen => MediaQuery.of(context).size.width < 800;  // Increase threshold

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = _isSmallScreen;  // Use the getter

    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKey: _handleKeyPress,
      child: Scaffold(
        backgroundColor: _isReading 
            ? Theme.of(context).colorScheme.background.withOpacity(0.95)
            : Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isReading
                    ? _buildReaderView(isSmallScreen)
                    : _buildInputView(isSmallScreen),
              ),
              if (_showLoadingOverlay) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputView(bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        controller: _scrollController,  // Add this
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 32,
          vertical: isSmallScreen ? 24 : 48,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero section
              Center(
                child: Column(
                  children: [
                    Text(
                      'Start Your Speed Reading Journey',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter text, paste from clipboard, or choose from our collection',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // Reading Materials section moved up
              WordLists(onWordListSelected: _handleTextSelected),
              const SizedBox(height: 48),
              
              // Text input section
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.text_fields_rounded,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Paste Your Text',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Copy and paste any text you want to speed read',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.outlined(
                                onPressed: _handlePaste,
                                icon: const Icon(Icons.paste_rounded),
                                tooltip: 'Paste from clipboard',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _textController,
                            maxLines: 8,
                            enabled: !_isLoading,
                            onChanged: _handleTextChange,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: 'Paste text or equations here...',
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider
                    Container(
                      height: 1,
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                    // Controls toolbar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // If width is less than 600, use vertical layout
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                              if (!_isMathMode) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton.filled(
                                      onPressed: () {
                                        setState(() {
                                          _wpm = math.max(60, _wpm - 50);
                                          _wpmController.text = _wpm.toString();
                                        });
                                      },
                                      icon: const Icon(Icons.remove_rounded),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        foregroundColor: Theme.of(context).colorScheme.primary,
                                        padding: const EdgeInsets.all(8),
                                      ),
                                    ),
                                    Container(
                                      width: 100,
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      child: TextField(
                                        controller: _wpmController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          suffixText: 'WPM',
                                          suffixStyle: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) {
                                          final newWpm = int.tryParse(value);
                                          if (newWpm != null) {
                                            setState(() {
                                              _wpm = math.min(math.max(newWpm, 60), 1000);
                                              if (_wpm != newWpm) {
                                                _wpmController.text = _wpm.toString();
                                              }
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    IconButton.filled(
                                      onPressed: () {
                                        setState(() {
                                          _wpm = math.min(1000, _wpm + 50);
                                          _wpmController.text = _wpm.toString();
                                        });
                                      },
                                      icon: const Icon(Icons.add_rounded),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        foregroundColor: Theme.of(context).colorScheme.primary,
                                        padding: const EdgeInsets.all(8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                                // Keyboard shortcuts
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.keyboard_rounded,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                    const SizedBox(width: 8),
                                  Text(
                                    _isMathMode 
                                      ? 'Tap to reveal answer • Tap again for next problem'
                                      : 'Space: Pause • Left/Right: Navigate • Esc: Stop',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Start Reading button
                                FilledButton.icon(
                                key: _startButtonKey,
                                onPressed: _textController.text.isEmpty 
                                  ? null 
                                  : () => _startReading(isSmallScreen),
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: const Text('Start Reading'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ],
                            );
                        },
                                      ),
                                    ),
                                  ],
                                  ),
                                ),
                              ],
          ),
        ),
      ),
    );
  }

  Widget _buildReaderView(bool isSmallScreen) {
    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        if (!_isReading) return;
        
        final screenWidth = MediaQuery.of(context).size.width;
        final tapX = details.globalPosition.dx;
        
        if (tapX < screenWidth / 2) {
          // Left side tap - go back
          _processor?.previousWord();
        } else {
          // Right side tap - go forward
          _processor?.nextWord();
        }
      },
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Stack(
          children: [
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WordDisplay(
                  word: _currentWord,
                  focusScale: settings.focusScale,
                  processor: _processor,
                ),
                const SizedBox(height: 16),
                
                // Add progress bar for math mode
                if (_isMathMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                
                // Math mode controls
                if (_isMathMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: _stopReading,
                        icon: const Icon(Icons.stop_rounded),
                        label: const Text('Stop'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: _restartReading,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Restart'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: () {
                          if (_processor != null) {
                            setState(() {
                              _textController.text = _randomizeEquations(_textController.text);
                            });
                            _restartReading();
                          }
                        },
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Randomize'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                
                // Only show WPM controls if not in math mode
                if (!_isMathMode && !isSmallScreen)  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        onPressed: () {
                          setState(() {
                            _wpm = math.max(60, _wpm - 50);
                            _wpmController.text = _wpm.toString();
                          });
                          _processor?.updateWPM(_wpm);
                        },
                        icon: const Icon(Icons.remove_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_wpm WPM',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () {
                          setState(() {
                            _wpm = math.min(1000, _wpm + 50);
                            _wpmController.text = _wpm.toString();
                          });
                          _processor?.updateWPM(_wpm);
                        },
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                // Only show ControlsPanel if not in math mode
                if (!_isMathMode && !isSmallScreen)
                ControlsPanel(
                  progress: _progress,
                  isPaused: _isPaused,
                  onPause: _togglePause,
                  onStop: _stopReading,
                    onRestart: _restartReading,
                ),
              ],
            ),

            // Show mobile controls only on small screens and not in math mode
            if (isSmallScreen && !_isMathMode)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top row - Resume/Restart/Stop buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _togglePause,
                              icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                              label: Text(_isPaused ? 'Resume' : 'Pause'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _restartReading,
                              icon: const Icon(Icons.replay_rounded),
                              label: const Text('Restart'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _stopReading,
                              icon: const Icon(Icons.stop_rounded),
                              label: const Text('Stop'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Middle - WPM controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton.filled(
                              onPressed: () {
                                setState(() {
                                  _wpm = math.max(60, _wpm - 50);
                                  _wpmController.text = _wpm.toString();
                                });
                                _processor?.updateWPM(_wpm);
                              },
                              icon: const Icon(Icons.remove_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                                minimumSize: const Size(48, 48),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                '$_wpm WPM',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton.filled(
                              onPressed: () {
                                setState(() {
                                  _wpm = math.min(1000, _wpm + 50);
                                  _wpmController.text = _wpm.toString();
                                });
                                _processor?.updateWPM(_wpm);
                              },
                              icon: const Icon(Icons.add_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                                minimumSize: const Size(48, 48),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Bottom - Navigation controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton.filled(
                              onPressed: () => _processor?.previousWord(),
                              icon: const Icon(Icons.skip_previous_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                                minimumSize: const Size(48, 48),
                              ),
                            ),
                            IconButton.filled(
                              onPressed: _togglePause,
                              icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                                minimumSize: const Size(64, 64),
                              ),
                            ),
                            IconButton.filled(
                              onPressed: () => _processor?.nextWord(),
                              icon: const Icon(Icons.skip_next_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                                minimumSize: const Size(48, 48),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Show control summary for both math and text modes
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: _buildControlSummary(isSmallScreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return AnimatedOpacity(
      opacity: _showLoadingOverlay ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Visibility(
        visible: _showLoadingOverlay,
        child: Container(
          color: Theme.of(context).colorScheme.background.withOpacity(0.8),
          child: Center(
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _loadingMessage,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateWpm(String value) {
    final wpm = int.tryParse(value);
    if (wpm == null) {
      return 'Enter a number';
    }
    if (wpm < 60) {
      return 'Min: 60 WPM';
    }
    if (wpm > 1000) {
      return 'Max: 1000 WPM';
    }
    return null;
  }

  void _restartReading() {
    if (_processor == null) return;
    _processor?.stop();
    _processor?.dispose();
    
    // Start fresh with same text
    _startReading(_isSmallScreen);  // Use the getter here too
  }

  Widget _buildControlSummary(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _isMathMode
          ? 'Tap or ← → to navigate • Tap to reveal answer'
          : 'Space: Pause • Left/Right: Navigate • Esc: Stop',
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14,
        ),
      ),
    );
  }

  String _randomizeEquations(String text) {
    final equations = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    equations.shuffle();
    return equations.join('\n');
  }
} 