import 'package:flutter/material.dart';
import 'package:rsvp_reader/models/word_processor.dart';

class WordDisplay extends StatefulWidget {
  final String word;
  final double focusScale;
  final WordProcessor? processor;

  const WordDisplay({
    super.key,
    required this.word,
    this.focusScale = 1.0,
    this.processor,
  });

  @override
  State<WordDisplay> createState() => _WordDisplayState();
}

class _WordDisplayState extends State<WordDisplay> with SingleTickerProviderStateMixin {
  bool _showAnswer = false;
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WordDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word != widget.word) {
      setState(() => _showAnswer = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final screenWidth = size.width;
    
    // Check if this is a math equation
    final isMathEquation = widget.word.contains('=');
    
    // Dynamic sizing based on screen width
    final containerHeight = isLandscape 
        ? size.height * 0.7  // Take up more vertical space in landscape
        : screenWidth < 600 
            ? size.height * 0.4  // Smaller height on mobile
            : size.height * 0.5;  // Larger height on tablets/desktop

    // Dynamic font sizing
    final baseFontSize = screenWidth < 600 
        ? 32.0 
        : screenWidth < 1200 
            ? 48.0 
            : 64.0;

    if (isMathEquation) {
      return GestureDetector(
        onTap: () {
          print('Tapped, current state: $_showAnswer');
          if (_showAnswer) {
            // If we're showing the answer, move to next equation
            widget.processor?.nextWord();
            setState(() => _showAnswer = false);  // Reset for next equation
          } else {
            // If showing equation, reveal answer
            setState(() => _showAnswer = true);
          }
          print('New state: $_showAnswer');
        },
        child: Container(
          height: containerHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                ),
                child: _showAnswer
                  ? Text(
                      widget.processor?.getAnswer(widget.word) ?? '?',
                      style: TextStyle(
                        fontSize: baseFontSize * 2.4,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 12,
                        height: 1.2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Text(
                      widget.word,
                      style: TextStyle(
                        fontSize: baseFontSize * 1.6,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 8,
                        height: 1.2,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
              ),
            ),
          ),
        ),
      );
    }

    final pivotIndex = _findOptimalPivot(widget.word);
    final before = widget.word.substring(0, pivotIndex);
    final pivot = widget.word[pivotIndex];
    final after = widget.word.substring(pivotIndex + 1);

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Guide lines
          Positioned.fill(
            child: CustomPaint(
              painter: GuideLinesPainter(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
          ),
          // Word display
          Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                ),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: baseFontSize,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: before,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      TextSpan(
                        text: pivot,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: baseFontSize * widget.focusScale,
                        ),
                      ),
                      TextSpan(
                        text: after,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _findOptimalPivot(String word) {
    final length = word.length;
    if (length <= 1) return 0;
    if (length <= 5) return 1;
    if (length <= 9) return 2;
    if (length <= 13) return 3;
    return (length * 0.3).floor();
  }
}

// Custom painter for guide lines
class GuideLinesPainter extends CustomPainter {
  final Color color;

  GuideLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // Vertical line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Horizontal line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(GuideLinesPainter oldDelegate) => false;
} 