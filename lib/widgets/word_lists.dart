import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this for clipboard

class WordLists extends StatelessWidget {
  final Function(String) onWordListSelected;

  const WordLists({
    super.key,
    required this.onWordListSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sample Texts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SampleTextCard(
              title: 'Crime and Punishment',
              description: 'Classic novel by Dostoevsky',
              icon: Icons.auto_stories,
              onTap: () async {
                final text = await rootBundle.loadString('assets/crimeandpunishment.txt');
                onWordListSelected(text);
              },
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            _SampleTextCard(
              title: 'Quick Test',
              description: 'Short story to test the reader',
              icon: Icons.speed,
              onTap: () async {
                final text = await rootBundle.loadString('assets/test.txt');
                onWordListSelected(text);
              },
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            _SampleTextCard(
              title: 'Kindergarten Words',
              description: '52 essential sight words',
              icon: Icons.child_care,
              onTap: () async {
                final text = await rootBundle.loadString('assets/kindergarten.txt');
                onWordListSelected(text);
              },
              color: Theme.of(context).colorScheme.tertiaryContainer,
            ),
            _SampleTextCard(
              title: 'First Grade Words',
              description: '31 additional sight words',
              icon: Icons.school,
              onTap: () async {
                final text = await rootBundle.loadString('assets/firstgrade.txt');
                onWordListSelected(text);
              },
              color: Theme.of(context).colorScheme.errorContainer,
            ),
          ],
        ),
      ],
    );
  }
}

class _SampleTextCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _SampleTextCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4), // Less rounded
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 