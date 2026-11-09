import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models.dart';
import '../state/progress.dart';
import '../state/progress_scope.dart';
import '../widgets/item_tile.dart';

/// Плоский список пунктов из всех категорий по условию.
class ItemListScreen extends StatelessWidget {
  const ItemListScreen({
    super.key,
    required this.title,
    required this.filter,
    this.hint,
  });

  final String title;
  final String? hint;
  final bool Function(Progress progress, Item item) filter;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final progress = ProgressScope.of(context);
    final items = progress.repo.items
        .where((i) => filter(progress, i))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        children: [
          if (hint != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(hint!, style: Theme.of(context).textTheme.bodySmall),
            ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(s.allClear)),
            ),
          for (final item in items) ItemTile(item: item, showCategory: true),
        ],
      ),
    );
  }
}
