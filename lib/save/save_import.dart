import 'dart:convert';

import 'ess_reader.dart';

/// Таблица «запись в сохранении → пункты SkyLog» из assets/data/save_map.json.
class SaveMap {
  SaveMap({required this.quests, required this.enchantments});

  factory SaveMap.fromJson(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    Map<String, List<String>> read(String key) => {
      for (final e in (json[key] as Map<String, dynamic>).entries)
        e.key: (e.value as List).cast<String>(),
    };
    return SaveMap(quests: read('quests'), enchantments: read('enchantments'));
  }

  final Map<String, List<String>> quests;
  final Map<String, List<String>> enchantments;
}

/// Что удалось сопоставить при импорте.
class ImportResult {
  ImportResult({
    required this.save,
    required this.completedQuests,
    required this.startedQuests,
    required this.knownEnchantments,
    required this.unknownCompleted,
    required this.unknownEnchantments,
  });

  final SaveData save;

  /// id пунктов SkyLog: квест завершён в сохранении.
  final List<String> completedQuests;

  /// Начаты, но не завершены — только для сведения.
  final List<String> startedQuests;

  /// id пунктов-зачарований, изученных в сохранении.
  final List<String> knownEnchantments;

  /// Завершённые квесты из сохранения, которых нет в SkyLog
  /// (служебные, радиантные, из модов).
  final int unknownCompleted;

  /// Изученные зачарования без пары в SkyLog (из модов и т.п.).
  final int unknownEnchantments;
}

ImportResult matchSave(SaveData save, SaveMap map) {
  final completed = <String>{}, started = <String>{};
  var unknownCompleted = 0;
  for (final MapEntry(:key, :value) in save.quests.entries) {
    final ids = map.quests[key];
    if (ids == null) {
      if (value.completed) unknownCompleted++;
      continue;
    }
    // Проваленный квест не считаем пройденным.
    (value.completed && !value.failed ? completed : started).addAll(ids);
  }
  final enchantments = <String>{};
  var unknownEnchantments = 0;
  for (final key in save.knownEnchantments) {
    final ids = map.enchantments[key];
    if (ids == null) {
      unknownEnchantments++;
    } else {
      enchantments.addAll(ids);
    }
  }
  return ImportResult(
    save: save,
    completedQuests: completed.toList(),
    startedQuests: started.difference(completed).toList(),
    knownEnchantments: enchantments.toList(),
    unknownCompleted: unknownCompleted,
    unknownEnchantments: unknownEnchantments,
  );
}
