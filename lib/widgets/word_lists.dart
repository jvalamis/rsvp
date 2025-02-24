import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this for clipboard

class WordLists extends StatefulWidget {
  final Function(String, bool isMathMode) onWordListSelected;

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
  bool _isMathExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(  // Wrap in Column to show multiple categories
      children: [
        // Math Materials Category
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpansionTile(
            initiallyExpanded: _isMathExpanded,
            onExpansionChanged: (expanded) {
              setState(() => _isMathExpanded = expanded);
            },
            title: Row(
              children: [
                Icon(
                  Icons.calculate_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Math Materials',
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
                    // Learning Materials subsection
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
                              Icons.school_rounded,
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
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _SampleTextCard(
                                  title: 'Kindergarten Addition',
                                  description: 'Basic addition practice',
                                  icon: Icons.add_circle_outline,
                                  onTap: () async {
                                    final text = await rootBundle.loadString('assets/kindergarten_addition.txt');
                                    widget.onWordListSelected(text, true);
                                  },
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                _SampleTextCard(
                                  title: 'Kindergarten Subtraction',
                                  description: 'Basic subtraction practice',
                                  icon: Icons.remove_circle_outline,
                                  onTap: () async {
                                    final text = await rootBundle.loadString('assets/kindergarten_subtraction.txt');
                                    widget.onWordListSelected(text, false);
                                  },
                                  color: Theme.of(context).colorScheme.secondary,
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
        ),
        
        const SizedBox(height: 16),  // Add spacing between categories
        
        // Original Reading Materials Category
        Card(
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.start,
                              children: [
                                _SampleTextCard(
                                  title: 'Crime and Punishment',
                                  description: 'By Fyodor Dostoevsky',
                                  icon: Icons.auto_stories,
                                  onTap: () async {
                                    final text = await rootBundle.loadString('assets/crimeandpunishment.txt');
                                    widget.onWordListSelected(text, false);
                                  },
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                ),
                                _SampleTextCard(
                                  title: 'Thus Spake Zarathustra',
                                  description: 'By Friedrich Nietzsche',
                                  icon: Icons.auto_stories,
                                  onTap: () async {
                                    final text = await rootBundle.loadString('assets/zarathustra.txt');
                                    widget.onWordListSelected(text, false);
                                  },
                                  color: Theme.of(context).colorScheme.secondaryContainer,
                                ),
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.start,
                              children: [
                                _SampleTextCard(
                                  title: 'Kindergarten Words',
                                  description: '40 essential sight words',
                                  icon: Icons.child_care,
                                  onTap: () async {
                                    final text = await rootBundle.loadString('assets/kindergarten.txt');
                                    widget.onWordListSelected(text, false);
                                  },
                                  color: Theme.of(context).colorScheme.tertiaryContainer,
                                ),
                                _SampleTextCard(
                                  title: 'First Grade Words',
                                  description: '49 additional sight words',
                                  icon: Icons.menu_book_rounded,
                                  onTap: () async {
                                    final text = await rootBundle.loadString('assets/firstgrade.txt');
                                    widget.onWordListSelected(text, false);
                                  },
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                ),
                                _SampleTextCard(
                                  title: 'Second Grade Words',
                                  description: '46 advanced sight words',
                                  icon: Icons.auto_stories_rounded,
                                  onTap: () async {
                                    final text = await rootBundle.loadString('assets/secondgrade.txt');
                                    widget.onWordListSelected(text, false);
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
        ),
      ],
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
          constraints: const BoxConstraints(
            minWidth: 200,
            maxWidth: 300,
          ),
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