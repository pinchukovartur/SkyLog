import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models.dart';
import '../state/progress.dart';
import '../state/progress_scope.dart';
import '../widgets/item_tile.dart';

enum _Filter { all, todo, done }

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final category = ProgressScope.of(context).repo.category(categoryId);
    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: CategoryBody(categoryId: categoryId),
    );
  }
}

/// Список категории с фильтрами; используется и как экран, и как вкладка.
class CategoryBody extends StatefulWidget {
  const CategoryBody({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<CategoryBody> createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<CategoryBody> {
  _Filter _filter = _Filter.all;
  bool _showRepeatable = true;
  final Set<String> _tags = {};

  bool _visible(Progress progress, Item item) {
    if (item.repeatable && !_showRepeatable) return false;
    if (!_tags.every(item.tags.contains)) return false;
    return switch (_filter) {
      _Filter.all => true,
      _Filter.todo => !progress.isDone(item.id) && !progress.isLocked(item.id),
      _Filter.done => progress.isDone(item.id),
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final progress = ProgressScope.of(context);
    final category = progress.repo.category(widget.categoryId);
    final theme = Theme.of(context);
    final overall = progress.progressOf(category.items);
    final tags = {for (final i in category.items) ...i.tags}.toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category.description.isNotEmpty)
                  Text(category.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: overall.ratio,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                SegmentedButton<_Filter>(
                  segments: [
                    ButtonSegment(value: _Filter.all, label: Text(s.filterAll)),
                    ButtonSegment(
                      value: _Filter.todo,
                      label: Text(s.filterTodo),
                    ),
                    ButtonSegment(
                      value: _Filter.done,
                      label: Text(s.filterDone),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (s) => setState(() => _filter = s.first),
                ),
                if (category.items.any((i) => i.repeatable)) ...[
                  const SizedBox(height: 8),
                  FilterChip(
                    avatar: const Icon(Icons.all_inclusive, size: 18),
                    label: Text(s.repeatableQuests),
                    selected: _showRepeatable,
                    onSelected: (v) => setState(() => _showRepeatable = v),
                  ),
                ],
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final tag in tags)
                        FilterChip(
                          label: Text(s.tag(tag)),
                          selected: _tags.contains(tag),
                          onSelected: (v) => setState(
                            () => v ? _tags.add(tag) : _tags.remove(tag),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        for (final group in category.groups) ...[
          if (group.items.any((i) => _visible(progress, i))) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  group.title.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
            SliverList.list(
              children: [
                for (final item in group.items)
                  if (_visible(progress, item)) ItemTile(item: item),
              ],
            ),
          ],
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
