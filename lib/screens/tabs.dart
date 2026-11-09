import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models.dart';
import '../state/progress_scope.dart';
import '../ui/theme.dart';
import 'category_screen.dart';
import 'choices_screen.dart';
import 'home_screen.dart';
import 'item_list_screen.dart';
import 'search_screen.dart';

/// Кнопка поиска для шапки любой вкладки.
class SearchAction extends StatelessWidget {
  const SearchAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: S.of(context).search,
      icon: const Icon(Icons.search),
      onPressed: () =>
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SearchScreen())),
    );
  }
}

/// Вкладка «Квесты»: развилки, упускаемое, все категории квестов и секреты.
class QuestsTab extends StatelessWidget {
  const QuestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final progress = ProgressScope.of(context);
    final repo = progress.repo;
    final quests = repo.itemsIn(Section.quests).toList();
    final choices = quests.expand((i) => i.choices).toList();
    final choicesMade = choices
        .where((c) => progress.selectedOption(c.id) != null)
        .length;
    final atRisk = quests
        .where(
          (i) =>
              i.missable != null &&
              !progress.isDone(i.id) &&
              !progress.isLocked(i.id),
        )
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(s.tabQuests), actions: const [SearchAction()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: QuickTile(
                  icon: Icons.call_split,
                  color: Marks.choice,
                  title: s.choices,
                  value: '$choicesMade / ${choices.length}',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChoicesScreen()),
                  ),
                ),
              ),
              Expanded(
                child: QuickTile(
                  icon: Icons.warning_amber,
                  color: Marks.missable,
                  title: s.dontMiss,
                  value: '$atRisk',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ItemListScreen(
                        title: s.dontMiss,
                        hint: s.dontMissHint,
                        filter: (p, i) =>
                            i.missable != null &&
                            !p.isDone(i.id) &&
                            !p.isLocked(i.id),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (final category in [
            ...repo.inSection(Section.quests),
            ...repo.inSection(Section.secrets),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CategoryCard(
                category: category,
                progress: progress.progressOf(category.items),
              ),
            ),
        ],
      ),
    );
  }
}

/// Вкладка справочного раздела: секреты, навыки, зачарования, спутники.
/// Показывает категории раздела целиком, с фильтрами.
class SectionTab extends StatelessWidget {
  const SectionTab({super.key, required this.section, required this.title});

  final Section section;
  final String title;

  @override
  Widget build(BuildContext context) {
    final categories = ProgressScope.of(context).repo
        .inSection(section)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: const [SearchAction()]),
      body: switch (categories) {
        [] => const Center(child: Icon(Icons.hourglass_empty, size: 48)),
        [final only] => CategoryBody(
          key: ValueKey(only.id),
          categoryId: only.id,
        ),
        _ => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final c in categories)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CategoryCard(
                  category: c,
                  progress: ProgressScope.of(context).progressOf(c.items),
                ),
              ),
          ],
        ),
      },
    );
  }
}
