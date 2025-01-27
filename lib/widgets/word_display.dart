import 'package:flutter/material.dart';

class WordDisplay extends StatelessWidget {
  final String word;
  final double focusScale;

  const WordDisplay({
    super.key,
    required this.word,
    this.focusScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final screenWidth = size.width;
    
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

    final pivotIndex = _findOptimalPivot(word);
    final before = word.substring(0, pivotIndex);
    final pivot = word[pivotIndex];
    final after = word.substring(pivotIndex + 1);

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
                          fontSize: baseFontSize * focusScale,
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