import 'dart:convert';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repository.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../profile.dart';

class CategoryProgress {
  const CategoryProgress(this.done, this.total);

  final int done;
  final int total;

  double get ratio => total == 0 ? 0 : done / total;
}

/// Персонажи и прогресс прохождения активного из них:
/// отмеченные пункты и сделанные выборы.
class Progress extends ChangeNotifier {
  Progress(
    this._prefs,
    this._repo, {
    this.lang = 'ru',
    this.systemLang = 'ru',
    this.loadRepository,
  }) {
    final raw = _prefs.getString(_profilesKey);
    if (raw != null) {
      _profiles.addAll(
        (jsonDecode(raw) as List).map(
          (p) => Profile.fromJson(p as Map<String, dynamic>),
        ),
      );
    }
    if (_profiles.isEmpty) _createFirstProfile();
    final activeId = _prefs.getString(_activeKey);
    _active = _profiles.firstWhere(
      (p) => p.id == activeId,
      orElse: () => _profiles.first,
    );
    _load();
  }

  static const _profilesKey = 'profiles';
  static const _langKey = 'lang';
  static const _activeKey = 'active_profile';
  // Ключи прогресса до появления профилей; переносятся в первый профиль.
  static const _legacyDoneKey = 'done';
  static const _legacyChoicesKey = 'choices';

  static String _doneKey(String profileId) => 'done:$profileId';
  static String _choicesKey(String profileId) => 'choices:$profileId';

  /// Язык интерфейса и контента: выбранный вручную, иначе системный —
  /// русский для русской системы и английский для всех остальных.
  static String resolveLang(SharedPreferences prefs, String systemLangCode) =>
      prefs.getString(_langKey) ?? (systemLangCode == 'ru' ? 'ru' : 'en');

  final SharedPreferences _prefs;

  /// Загружает данные на другом языке при переключении.
  final Future<Repository> Function(String lang)? loadRepository;
  Repository _repo;
  String lang;

  /// Язык системы, к которому возвращает [setLanguage] с null.
  final String systemLang;
  final List<Profile> _profiles = [];
  late Profile _active;
  final Set<String> _done = {};
  final Map<String, String> _choices = {};

  /// id пункта -> описание выбора, который его закрыл.
  final Map<String, String> _lockedBy = {};

  Repository get repo => _repo;

  /// Язык выбран вручную; null — берётся системный.
  String? get languageOverride => _prefs.getString(_langKey);

  /// Переключает язык; null — снова следовать системному.
  Future<void> setLanguage(String? code) async {
    if (code == null) {
      await _prefs.remove(_langKey);
    } else {
      await _prefs.setString(_langKey, code);
    }
    final next = code ?? (systemLang == 'ru' ? 'ru' : 'en');
    if (next == lang) {
      notifyListeners();
      return;
    }
    final loader = loadRepository;
    if (loader != null) _repo = await loader(next);
    lang = next;
    _rebuildLocks();
    notifyListeners();
  }

  List<Profile> get profiles => List.unmodifiable(_profiles);

  Profile get active => _active;

  bool isDone(String itemId) => _done.contains(itemId);

  String? lockReason(String itemId) => _lockedBy[itemId];

  bool isLocked(String itemId) => _lockedBy.containsKey(itemId);

  String? selectedOption(String choiceId) => _choices[choiceId];

  void toggleDone(String itemId) {
    if (!_done.remove(itemId)) _done.add(itemId);
    _prefs.setStringList(_doneKey(_active.id), _done.toList());
    notifyListeners();
  }

  /// Отмечает несколько пунктов разом (импорт из сохранения).
  /// Уже отмеченные не трогает; возвращает число новых отметок.
  int markDone(Iterable<String> itemIds) {
    final before = _done.length;
    _done.addAll(itemIds);
    final added = _done.length - before;
    if (added > 0) {
      _prefs.setStringList(_doneKey(_active.id), _done.toList());
      notifyListeners();
    }
    return added;
  }

  /// Выбирает вариант развилки; повторный выбор того же варианта снимает его.
  void choose(String choiceId, String optionId) {
    if (_choices[choiceId] == optionId) {
      _choices.remove(choiceId);
    } else {
      _choices[choiceId] = optionId;
    }
    _prefs.setString(_choicesKey(_active.id), jsonEncode(_choices));
    _rebuildLocks();
    notifyListeners();
  }

  /// Сбрасывает прогресс активного персонажа.
  Future<void> reset() async {
    _done.clear();
    _choices.clear();
    _lockedBy.clear();
    await _prefs.remove(_doneKey(_active.id));
    await _prefs.remove(_choicesKey(_active.id));
    notifyListeners();
  }

  CategoryProgress progressOf(Iterable<Item> items) =>
      _count(items, _done, _lockedBy.keys.toSet());

  /// Общий прогресс любого персонажа, не делая его активным.
  CategoryProgress overallOf(Profile profile) {
    if (profile.id == _active.id) return progressOf(repo.items);
    final (done, choices) = _read(profile.id);
    return _count(repo.items, done, _locksFor(choices).keys.toSet());
  }

  void switchTo(Profile profile) {
    _active = profile;
    _prefs.setString(_activeKey, profile.id);
    _load();
    notifyListeners();
  }

  /// Создаёт персонажа и сразу делает его активным.
  void addProfile({
    required String name,
    required Race race,
    required Sex sex,
    String? avatar,
  }) {
    final profile = Profile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      race: race,
      sex: sex,
      avatar: avatar,
    );
    _profiles.add(profile);
    _saveProfiles();
    switchTo(profile);
  }

  void updateProfile(Profile profile) {
    final i = _profiles.indexWhere((p) => p.id == profile.id);
    _profiles[i] = profile;
    if (_active.id == profile.id) _active = profile;
    _saveProfiles();
    notifyListeners();
  }

  /// Удаляет персонажа вместе с прогрессом. Последнего удалить нельзя.
  Future<void> deleteProfile(Profile profile) async {
    if (_profiles.length <= 1) return;
    _profiles.removeWhere((p) => p.id == profile.id);
    _saveProfiles();
    await _prefs.remove(_doneKey(profile.id));
    await _prefs.remove(_choicesKey(profile.id));
    if (_active.id == profile.id) {
      switchTo(_profiles.first);
    } else {
      notifyListeners();
    }
  }

  void _createFirstProfile() {
    final profile = Profile(
      id: 'default',
      name: S.forLang(lang).defaultCharacterName,
      race: Race.nord,
      sex: Sex.male,
    );
    _profiles.add(profile);
    final done = _prefs.getStringList(_legacyDoneKey);
    if (done != null) _prefs.setStringList(_doneKey(profile.id), done);
    final choices = _prefs.getString(_legacyChoicesKey);
    if (choices != null) _prefs.setString(_choicesKey(profile.id), choices);
    _prefs.remove(_legacyDoneKey);
    _prefs.remove(_legacyChoicesKey);
    _saveProfiles();
  }

  void _saveProfiles() => _prefs.setString(
    _profilesKey,
    jsonEncode(_profiles.map((p) => p.toJson()).toList()),
  );

  void _load() {
    final (done, choices) = _read(_active.id);
    _done
      ..clear()
      ..addAll(done);
    _choices
      ..clear()
      ..addAll(choices);
    _rebuildLocks();
  }

  (Set<String>, Map<String, String>) _read(String profileId) {
    final done = (_prefs.getStringList(_doneKey(profileId)) ?? const [])
        .toSet();
    final raw = _prefs.getString(_choicesKey(profileId));
    final choices = raw == null
        ? <String, String>{}
        : (jsonDecode(raw) as Map).cast<String, String>();
    return (done, choices);
  }

  static CategoryProgress _count(
    Iterable<Item> items,
    Set<String> done,
    Set<String> locked,
  ) {
    var doneCount = 0;
    var total = 0;
    for (final item in items) {
      if (locked.contains(item.id)) continue;
      total++;
      if (done.contains(item.id)) doneCount++;
    }
    return CategoryProgress(doneCount, total);
  }

  void _rebuildLocks() {
    _lockedBy
      ..clear()
      ..addAll(_locksFor(_choices));
  }

  Map<String, String> _locksFor(Map<String, String> choices) {
    final locks = <String, String>{};
    for (final item in repo.items) {
      for (final choice in item.choices) {
        final option = choice.option(choices[choice.id]);
        if (option == null) continue;
        for (final locked in option.locks) {
          locks[locked] = S.forLang(lang).lockedBy(option.label, item.title);
        }
      }
    }
    return locks;
  }
}
