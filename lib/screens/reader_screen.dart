import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this for keyboard events
import '../widgets/word_display.dart';
import '../widgets/controls_panel.dart';
import '../widgets/word_lists.dart';
import '../models/word_processor.dart';
import '../models/settings.dart';  // Add this for settings
import 'dart:math' as math;
import 'package:flutter/rendering.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _wpmController = TextEditingController();  // Add this
  final FocusNode _keyboardFocusNode = FocusNode();  // Add this
  final Settings settings = Settings();
  bool _isReading = false;
  bool _isLoading = false;
  int _wpm = 300;
  WordProcessor? _processor;
  String _currentWord = '';
  double _progress = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _wpmController.text = _wpm.toString();  // Initialize WPM controller
  }

  void _startReading() async {
    if (_textController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _isReading = true;
      _isPaused = false;
      _progress = 0;
    });

    try {
      _processor = WordProcessor(
        text: _textController.text,
        wpm: _wpm,
        onWord: (word) => setState(() => _currentWord = word),
        onProgress: (progress) => setState(() => _progress = progress),
        onComplete: () => setState(() => _isReading = false),
      );
      
      // Initialize and start
      await _processor!.initialize();
      _processor!.start();
      _keyboardFocusNode.requestFocus();  // Add this
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_processor != null) {
        _processor!.togglePause();
      }
    });
  }

  void _stopReading() {
    _processor?.stop();
    setState(() {
      _isReading = false;
      _currentWord = '';
      _progress = 0;
    });
  }

  // Add this method to handle text changes with loading state
  Future<void> _handleTextChange(String text) async {
    setState(() => _isLoading = true);
    try {
      _textController.text = text;
      // Add a small delay to show loading for very short texts
      await Future.delayed(const Duration(milliseconds: 100));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Update WordLists callback
  Future<void> _handleTextSelected(String text) async {
    setState(() => _isLoading = true);
    try {
      _processor?.dispose();  // Remove await since dispose() is void
      _processor = null;      // Clear the processor
      _textController.text = text;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Update paste callback
  Future<void> _handlePaste() async {
    setState(() => _isLoading = true);
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null && data!.text!.isNotEmpty) {
        _textController.text = data.text!;
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
        if (_isReading) {
          print('ReaderScreen: Increasing WPM from $_wpm');
          setState(() {
            _wpm = math.min(1000, _wpm + 50);
            _wpmController.text = _wpm.toString();
          });
          print('ReaderScreen: New WPM: $_wpm');
          _processor?.updateWPM(_wpm);
        }
        break;
      case LogicalKeyboardKey.arrowDown:
        if (_isReading) {
          print('ReaderScreen: Decreasing WPM from $_wpm');
          setState(() {
            _wpm = math.max(60, _wpm - 50);
            _wpmController.text = _wpm.toString();
          });
          print('ReaderScreen: New WPM: $_wpm');
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
    _keyboardFocusNode.dispose();  // Add this
    _processor?.dispose();
    _processor = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,  // Use our focus node
      autofocus: true,  // Add this
      onKey: _handleKeyPress,
      child: Scaffold(
        backgroundColor: _isReading 
            ? Theme.of(context).colorScheme.background.withOpacity(0.95)
            : Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isReading
                ? Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WordDisplay(
                              word: _currentWord,
                              focusScale: settings.focusScale,
                            ),
                            const SizedBox(height: 32),
                            ControlsPanel(
                              progress: _progress,
                              isPaused: _isPaused,
                              onPause: _togglePause,
                              onStop: _stopReading,
                            ),
                          ],
                        ),
                        // Keyboard shortcuts hint at bottom
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 16,
                          child: Column(
                            children: [
                              Text(
                                'Space: Pause/Resume | Esc: Stop | ↑↓: Speed | ←→: Navigate Words',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Current Speed: $_wpm WPM',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'RSVP (Rapid Serial Visual Presentation) is a reading technique that shows words one at a time in the same position, reducing eye movement and potentially increasing reading speed and comprehension.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            WordLists(
                              onWordListSelected: _handleTextSelected,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _textController,
                              maxLines: 6,
                              enabled: !_isLoading,  // Disable while loading
                              onChanged: _handleTextChange,  // Add this
                              decoration: InputDecoration(
                                hintText: 'Paste your text here...',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                ),
                                // Show loading indicator in the text field
                                suffixIcon: _isLoading 
                                  ? Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('Words per minute:'),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: _wpmController,  // Use the dedicated controller
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Words per minute',
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(4)),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: -0.5,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _wpm = int.tryParse(value) ?? 300;
                                      });
                                    },
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: _startReading,
                                  child: const Text('Start Reading'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Use arrow keys ↑↓ to adjust speed, or type directly',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
} 