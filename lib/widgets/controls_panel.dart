import 'package:flutter/material.dart';

class ControlsPanel extends StatelessWidget {
  final VoidCallback onStop;
  final bool isPaused;
  final VoidCallback onPause;
  final double progress;

  const ControlsPanel({
    super.key,
    required this.onStop,
    required this.isPaused,
    required this.onPause,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: onPause,
              icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
              label: Text(isPaused ? 'Resume' : 'Pause'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onStop,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 