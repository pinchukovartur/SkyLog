import 'package:flutter/material.dart';

import '../l10n/strings.dart';

import '../state/progress_scope.dart';
import '../widgets/choice_card.dart';
import 'item_screen.dart';

/// Все развилки игры в одном месте, по категориям.
class ChoicesScreen extends StatelessWidget {
  const ChoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final progress = ProgressScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.choices)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(s.choicesHint, style: theme.textTheme.bodySmall),
          for (final category in progress.repo.categories)
            if (category.items.any((i) => i.choices.isNotEmpty)) ...[
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 4),
                child: Text(
                  category.title.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              for (final item in category.items.where(
                (i) => i.choices.isNotEmpty,
              )) ...[
                TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ItemScreen(itemId: item.id),
                    ),
                  ),
                  icon: const Icon(Icons.chevron_right),
                  label: Text(item.title),
                ),
                for (final choice in item.choices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ChoiceCard(choice: choice),
                  ),
              ],
            ],
        ],
      ),
    );
  }
}
