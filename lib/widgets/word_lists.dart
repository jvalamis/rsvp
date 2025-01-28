import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this for clipboard

class WordLists extends StatefulWidget {
  final Function(String) onWordListSelected;

  const WordLists({
    super.key,
    required this.onWordListSelected,
  });

  @override
  State<WordLists> createState() => _WordListsState();
}

class _WordListsState extends State<WordLists> {
  bool _isExpanded = false;
  bool _isLiteratureExpanded = false;
  bool _isLearningExpanded = false;
  bool _isPracticeExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        title: Row(
          children: [
            Icon(
              Icons.library_books_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Reading Materials',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Classic Literature section
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  margin: EdgeInsets.zero,
                  child: ExpansionTile(
                    initiallyExpanded: _isLiteratureExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() => _isLiteratureExpanded = expanded);
                    },
                    title: Row(
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Classic Literature',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Row(
                          children: [
                            _SampleTextCard(
                              title: 'Crime and Punishment',
                              description: 'by Fyodor Dostoevsky',
                              icon: Icons.auto_stories,
                              onTap: () async {
                                final text = await rootBundle.loadString('assets/crimeandpunishment.txt');
                                widget.onWordListSelected(text);
                              },
                              color: Theme.of(context).colorScheme.primaryContainer,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Learning Materials section
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  margin: EdgeInsets.zero,
                  child: ExpansionTile(
                    initiallyExpanded: _isLearningExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() => _isLearningExpanded = expanded);
                    },
                    title: Row(
                      children: [
                        Icon(
                          Icons.school,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Learning Materials',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Row(
                          children: [
                            _SampleTextCard(
                              title: 'Kindergarten Words',
                              description: '52 essential sight words',
                              icon: Icons.child_care,
                              onTap: () async {
                                final text = await rootBundle.loadString('assets/kindergarten.txt');
                                widget.onWordListSelected(text);
                              },
                              color: Theme.of(context).colorScheme.tertiaryContainer,
                            ),
                            const SizedBox(width: 8),
                            _SampleTextCard(
                              title: 'First Grade Words',
                              description: '31 additional sight words',
                              icon: Icons.school,
                              onTap: () async {
                                final text = await rootBundle.loadString('assets/firstgrade.txt');
                                widget.onWordListSelected(text);
                              },
                              color: Theme.of(context).colorScheme.errorContainer,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Practice section
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  margin: EdgeInsets.zero,
                  child: ExpansionTile(
                    initiallyExpanded: _isPracticeExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() => _isPracticeExpanded = expanded);
                    },
                    title: Row(
                      children: [
                        Icon(
                          Icons.speed,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Practice',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Row(
                          children: [
                            _SampleTextCard(
                              title: 'Quick Test',
                              description: 'Short story to test the reader',
                              icon: Icons.speed,
                              onTap: () async {
                                final text = await rootBundle.loadString('assets/test.txt');
                                widget.onWordListSelected(text);
                              },
                              color: Theme.of(context).colorScheme.secondaryContainer,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Update the card design to be more compact
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
} 