import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/strings.dart';
import '../models.dart';
import '../state/progress_scope.dart';
import '../ui/theme.dart';
import '../widgets/choice_card.dart';
import '../widgets/item_tile.dart';

class ItemScreen extends StatelessWidget {
  const ItemScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final progress = ProgressScope.of(context);
    final item = progress.repo.item(itemId)!;
    final category = progress.repo.category(item.categoryId);
    final theme = Theme.of(context);
    final done = progress.isDone(item.id);
    final lockReason = progress.lockReason(item.id);
    final linked = progress.repo.linked(item.id);
    List<Item> ofType(ItemType type) =>
        linked.where((i) => i.type == type).toList();
    final sections = [
      (s.secretsSection, ofType(ItemType.secret)),
      (s.missablesSection, ofType(ItemType.missable)),
      (s.relatedQuests, ofType(ItemType.quest)),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          Text(item.title, style: theme.textTheme.headlineSmall),
          // Оригинальное название полезно только в русской версии.
          if (item.en.isNotEmpty && progress.lang == 'ru')
            Text(
              item.en,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(icon: Icons.folder_outlined, text: item.groupTitle),
              if (item.location != null)
                _Chip(icon: Icons.place_outlined, text: item.location!),
              if (item.giver != null)
                _Chip(icon: Icons.person_outline, text: item.giver!),
              if (item.videoTime != null)
                _Chip(
                  icon: Icons.play_circle_outline,
                  text: s.video(item.videoTime!),
                ),
              for (final tag in item.tags)
                _Chip(icon: Icons.sell_outlined, text: s.tag(tag)),
            ],
          ),
          if (item.mapUri case final uri?) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: () =>
                    launchUrl(uri, mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.map_outlined),
                label: Text('${s.onMap}: ${item.mapPlace}'),
              ),
            ),
          ],
          if (lockReason != null) ...[
            const SizedBox(height: 16),
            _Notice(
              icon: Icons.block,
              color: theme.colorScheme.error,
              text: lockReason,
            ),
          ],
          if (item.repeatable) ...[
            const SizedBox(height: 16),
            _Notice(
              icon: Icons.all_inclusive,
              color: Marks.repeatable,
              text: s.repeatableNotice,
            ),
          ],
          if (item.missable != null) ...[
            const SizedBox(height: 16),
            _Notice(
              icon: Icons.warning_amber,
              color: Marks.missable,
              text: item.missable!,
            ),
          ],
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(item.description, style: theme.textTheme.bodyLarge),
          ],
          if (item.facts.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(s.details, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (final fact in item.facts)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                fact.label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(fact.value)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (item.tips.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(s.tips, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final tip in item.tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(tip)),
                  ],
                ),
              ),
          ],
          if (item.hints.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                leading: Icon(
                  Icons.visibility_off_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(s.hints),
                subtitle: Text(s.hintsHidden),
                shape: const Border(),
                collapsedShape: const Border(),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                children: [
                  for (final (n, hint) in item.hints.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${n + 1}.',
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(hint)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          for (final choice in item.choices) ...[
            const SizedBox(height: 16),
            ChoiceCard(choice: choice),
          ],
          for (final (title, items) in sections)
            if (items.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                '$title · ${items.where((i) => progress.isDone(i.id)).length}'
                '/${items.length}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final i in items)
                      ItemTile(item: i, showCategory: true),
                  ],
                ),
              ),
            ],
        ],
      ),
      floatingActionButton: lockReason != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => progress.toggleDone(item.id),
              icon: Icon(done ? Icons.undo : Icons.check),
              label: Text(done ? s.unmark : s.markDone(item.type)),
            ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    // Свой чип вместо Chip: длинная локация переносится, а не обрезается.
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.primary),
          const SizedBox(width: 8),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
