import 'package:flutter/material.dart';

import '../models.dart';
import '../screens/item_screen.dart';
import '../state/progress_scope.dart';
import '../ui/theme.dart';

class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.item, this.showCategory = false});

  final Item item;
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    final progress = ProgressScope.of(context);
    final theme = Theme.of(context);
    final done = progress.isDone(item.id);
    final locked = progress.isLocked(item.id);

    final subtitle = [
      if (showCategory) progress.repo.category(item.categoryId).title,
      if (item.location != null) item.location!,
      if (!showCategory &&
          item.location == null &&
          item.en.isNotEmpty &&
          progress.lang == 'ru')
        item.en,
    ].join(' · ');

    return Opacity(
      opacity: locked ? 0.45 : 1,
      child: ListTile(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => ItemScreen(itemId: item.id))),
        leading: locked
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.block),
              )
            : Checkbox(
                value: done,
                onChanged: (_) => progress.toggleDone(item.id),
              ),
        title: Text(
          item.title,
          style: TextStyle(
            decoration: done || locked ? TextDecoration.lineThrough : null,
            color: done ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        trailing: _Badges(item: item),
      ),
    );
  }
}

class _Badges extends StatelessWidget {
  const _Badges({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final icons = [
      if (item.tags.contains('marriage'))
        const Icon(Icons.favorite, size: 18, color: Marks.marriage),
      if (item.repeatable)
        const Icon(Icons.all_inclusive, size: 18, color: Marks.repeatable),
      if (item.choices.isNotEmpty)
        const Icon(Icons.call_split, size: 18, color: Marks.choice),
      if (item.missable != null || item.type == ItemType.missable)
        const Icon(Icons.warning_amber, size: 18, color: Marks.missable),
      if (item.type == ItemType.secret)
        const Icon(Icons.auto_awesome, size: 18, color: Marks.secret),
    ];
    if (icons.isEmpty) return const SizedBox.shrink();
    return Row(mainAxisSize: MainAxisSize.min, spacing: 4, children: icons);
  }
}
