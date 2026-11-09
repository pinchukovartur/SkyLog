import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../models.dart';
import '../profile.dart';
import '../save/ess_reader.dart';
import '../save/file_picker.dart';
import '../save/save_import.dart';
import '../state/progress_scope.dart';
import '../ui/theme.dart';
import '../widgets/profile_avatar.dart';

/// Верхнеуровневая функция: в изолят уходят только байты и таблица.
ImportResult _parseSave((Uint8List, String) args) =>
    matchSave(readSave(args.$1), SaveMap.fromJson(args.$2));

/// Раса из сохранения («NordRace», «NordRaceVampire») в подпись SkyLog.
String _race(S s, String editorId) {
  const ids = {
    'Nord': Race.nord,
    'Imperial': Race.imperial,
    'Breton': Race.breton,
    'Redguard': Race.redguard,
    'HighElf': Race.altmer,
    'DarkElf': Race.dunmer,
    'WoodElf': Race.bosmer,
    'Orc': Race.orc,
    'Khajiit': Race.khajiit,
    'Argonian': Race.argonian,
  };
  for (final MapEntry(:key, :value) in ids.entries) {
    if (editorId.startsWith('${key}Race')) return s.raceTitle(value);
  }
  return editorId;
}

/// Импорт прогресса из сохранения Skyrim (.ess).
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _busy = false;
  String? _error;
  ImportResult? _result;

  /// Отмеченные к применению пункты (по умолчанию — все новые).
  final Set<String> _selected = {};

  Future<void> _pick() async {
    final s = S.of(context);
    final file = await pickFile();
    if (file == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final raw = await rootBundle.loadString('assets/data/save_map.json');
      // Распаковка 10–20 МБ — в отдельном изоляте, чтобы не тормозил интерфейс.
      final result = await compute(_parseSave, (file.bytes, raw));
      if (!mounted) return;
      final progress = ProgressScope.of(context);
      setState(() {
        _result = result;
        _selected
          ..clear()
          ..addAll(
            [
              ...result.completedQuests,
              ...result.knownEnchantments,
            ].where((id) => !progress.isDone(id)),
          );
      });
    } on SaveFormatException catch (e) {
      setState(() => _error = s.saveError(e.message));
    } catch (e, stack) {
      debugPrint('save import failed: $e\n$stack');
      setState(() => _error = s.saveError('unknown'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _apply(Iterable<String> ids) {
    final progress = ProgressScope.of(context);
    final chosen = ids.where(_selected.contains).toList();
    final added = progress.markDone(chosen);
    setState(() => _selected.removeAll(chosen));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(S.of(context).applied(added))));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: Text(s.importSave)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Text(s.importIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          const _Formats(),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _pick,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(s.chooseFile),
          ),
          if (_busy) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            Center(child: Text(s.readingSave)),
          ],
          if (_error case final error?) ...[
            const SizedBox(height: 16),
            Text(error, style: TextStyle(color: theme.colorScheme.error)),
          ],
          if (result != null) ..._results(result),
        ],
      ),
    );
  }

  List<Widget> _results(ImportResult result) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final progress = ProgressScope.of(context);
    final save = result.save;
    final all = [...result.completedQuests, ...result.knownEnchantments];
    return [
      const SizedBox(height: 20),
      Card(
        child: ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text('${save.playerName} · ${save.playerLevel}'),
          subtitle: Text('${_race(s, save.playerRace)} · ${save.location}'),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          ProfileAvatar(profile: progress.active, radius: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${s.importTarget}: ${progress.active.name}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
      if (all.every(progress.isDone)) ...[
        const SizedBox(height: 16),
        Text(s.nothingToImport),
      ],
      _Section(
        title: s.questsCompleted,
        ids: result.completedQuests,
        selected: _selected,
        onToggle: (id, v) =>
            setState(() => v ? _selected.add(id) : _selected.remove(id)),
        onApply: () => _apply(result.completedQuests),
      ),
      _Section(
        title: s.enchantmentsKnown,
        ids: result.knownEnchantments,
        selected: _selected,
        onToggle: (id, v) =>
            setState(() => v ? _selected.add(id) : _selected.remove(id)),
        onApply: () => _apply(result.knownEnchantments),
      ),
      const SizedBox(height: 16),
      Card(
        child: ListTile(
          leading: const Icon(Icons.help_outline, color: Marks.missable),
          title: Text(s.notRecognized),
          subtitle: Text(
            s.unrecognizedBody(
              result.unknownCompleted,
              result.unknownEnchantments,
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: all.any(_selected.contains) ? () => _apply(all) : null,
        child: Text(s.applyAll),
      ),
    ];
  }
}

class _Formats extends StatelessWidget {
  const _Formats();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    Widget row(IconData icon, Color color, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.supportedFormats, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            row(Icons.check_circle, theme.colorScheme.primary, s.formatSe),
            row(Icons.science_outlined, Marks.missable, s.formatLe),
            row(Icons.block, theme.colorScheme.error, s.formatConsole),
            row(Icons.block, theme.colorScheme.error, s.formatMods),
            Text(s.saveLocation, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Список распознанных пунктов с галочками и кнопкой «Применить».
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.ids,
    required this.selected,
    required this.onToggle,
    required this.onApply,
  });

  final String title;
  final List<String> ids;
  final Set<String> selected;
  final void Function(String id, bool value) onToggle;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final progress = ProgressScope.of(context);
    final items = [for (final id in ids) ?progress.repo.item(id)]
      ..sort((a, b) => a.title.compareTo(b.title));
    if (items.isEmpty) return const SizedBox.shrink();
    final pending = items.where((i) => selected.contains(i.id)).length;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          initiallyExpanded: true,
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text('$title · ${items.length}'),
          subtitle: Text('${s.apply}: $pending'),
          children: [
            for (final Item item in items)
              CheckboxListTile(
                value: progress.isDone(item.id) || selected.contains(item.id),
                onChanged: progress.isDone(item.id)
                    ? null
                    : (v) => onToggle(item.id, v ?? false),
                title: Text(item.title),
                subtitle: Text(
                  progress.isDone(item.id)
                      ? s.alreadyMarked
                      : progress.repo.category(item.categoryId).title,
                  style: theme.textTheme.bodySmall,
                ),
                dense: true,
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: pending == 0 ? null : onApply,
                  child: Text('${s.apply} ($pending)'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
