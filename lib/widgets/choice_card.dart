import 'package:flutter/material.dart';

import '../models.dart';
import '../state/progress_scope.dart';
import '../ui/theme.dart';

/// Развилка с вариантами; выбранный вариант раскрывает последствия.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({super.key, required this.choice});

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final progress = ProgressScope.of(context);
    final theme = Theme.of(context);
    final selected = progress.selectedOption(choice.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.call_split, color: Marks.choice, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    choice.question,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
          for (final option in choice.options)
            ListTile(
              onTap: () => progress.choose(choice.id, option.id),
              selected: option.id == selected,
              selectedColor: Marks.choice,
              leading: Icon(
                option.id == selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(option.label),
              // Последствия видны сразу: игроку важно знать их до выбора.
              subtitle: option.result.isEmpty ? null : Text(option.result),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
