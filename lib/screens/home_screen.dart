import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models.dart';
import '../profile.dart';
import '../state/progress.dart';
import '../state/progress_scope.dart';
import '../ui/theme.dart';
import '../widgets/profile_avatar.dart';
import 'category_screen.dart';
import 'import_screen.dart';
import 'profiles_screen.dart';
import 'search_screen.dart';

/// Вкладка «Главная»: персонаж, прогресс и статистика по разделам.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenSection});

  /// Переход на вкладку раздела по нажатию на его строку статистики.
  final ValueChanged<Section>? onOpenSection;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final progress = ProgressScope.of(context);
    final repo = progress.repo;
    final overall = progress.progressOf(repo.itemsIn(Section.quests));

    return Scaffold(
      appBar: AppBar(
        title: const Text('SKYLOG'),
        actions: [
          TextButton.icon(
            onPressed: () =>
                progress.setLanguage(progress.lang == 'ru' ? 'en' : 'ru'),
            icon: const Icon(Icons.translate, size: 20),
            label: Text(s.languageCode),
          ),
          IconButton(
            tooltip: s.search,
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          PopupMenuButton<String>(
            onSelected: (action) => switch (action) {
              'system' => progress.setLanguage(null),
              'import' => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ImportScreen()),
              ),
              _ => _confirmReset(context, progress),
            },
            itemBuilder: (_) => [
              CheckedPopupMenuItem(
                value: 'system',
                checked: progress.languageOverride == null,
                child: Text(s.useSystemLanguage),
              ),
              PopupMenuItem(value: 'import', child: Text(s.importSave)),
              PopupMenuItem(value: 'reset', child: Text(s.resetProgress)),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _OverallCard(profile: progress.active, progress: overall),
          const SizedBox(height: 20),
          Text(s.statistics, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final section in Section.values)
            if (repo.inSection(section).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _StatCard(
                  section: section,
                  progress: progress.progressOf(repo.itemsIn(section)),
                  onTap: onOpenSection == null
                      ? null
                      : () => onOpenSection!(section),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, Progress progress) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.resetProgressQuestion),
        content: Text(s.resetProgressBody(progress.active.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.reset),
          ),
        ],
      ),
    );
    if (ok == true) await progress.reset();
  }
}

class _OverallCard extends StatelessWidget {
  const _OverallCard({required this.profile, required this.progress});

  final Profile profile;
  final CategoryProgress progress;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProfilesScreen())),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileAvatar(profile: profile, radius: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name, style: theme.textTheme.titleLarge),
                        Text(
                          '${s.raceTitle(profile.race)} · ${s.sexTitle(profile.sex)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.swap_horiz),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${(progress.ratio * 100).round()}%',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress.ratio,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                s.doneOf(progress.done, progress.total),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickTile extends StatelessWidget {
  const QuickTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(title, style: theme.textTheme.titleSmall),
              Text(value, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.progress,
  });

  final Category category;
  final CategoryProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryScreen(categoryId: category.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                categoryIcon(category.icon),
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.ratio,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${progress.done}/${progress.total}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData sectionIcon(Section section) => switch (section) {
  Section.quests => Icons.menu_book,
  Section.secrets => Icons.auto_awesome,
  Section.skills => Icons.fitness_center,
  Section.enchanting => Icons.auto_fix_high,
  Section.followers => Icons.groups,
};

class _StatCard extends StatelessWidget {
  const _StatCard({required this.section, required this.progress, this.onTap});

  final Section section;
  final CategoryProgress progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(sectionIcon(section), color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.sectionStat(section),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.ratio,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${progress.done}/${progress.total}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
