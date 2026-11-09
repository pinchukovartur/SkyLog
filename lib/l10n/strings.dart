import 'package:flutter/widgets.dart';

import '../models.dart';
import '../profile.dart';
import '../state/progress_scope.dart';

/// Строки интерфейса. Контент игры переводится отдельно, в assets/data/en.
abstract class S {
  const S();

  static S of(BuildContext context) => forLang(ProgressScope.of(context).lang);

  static S forLang(String lang) => lang == 'ru' ? const _Ru() : const _En();

  String get languageCode;
  String get languageName;
  String get useSystemLanguage;

  String get search;
  String get searchHint;
  String get nothingFound;
  String get resetProgress;
  String get resetProgressQuestion;
  String resetProgressBody(String name);
  String get reset;
  String get cancel;
  String get delete;
  String get edit;
  String doneOf(int done, int total);

  String get choices;
  String get choicesHint;
  String get dontMiss;
  String get dontMissHint;
  String get allClear;

  String get filterAll;
  String get filterTodo;
  String get filterDone;
  String get repeatableQuests;

  String get tips;
  String get secretsSection;
  String get missablesSection;
  String get relatedQuests;
  String video(String time);
  String get repeatableNotice;
  String get unmark;
  String markDone(ItemType type);
  String get details;
  String get importSave;
  String get importIntro;
  String get supportedFormats;
  String get formatSe;
  String get formatLe;
  String get formatConsole;
  String get formatMods;
  String get saveLocation;
  String get chooseFile;
  String get readingSave;
  String get questsCompleted;
  String get enchantmentsKnown;
  String get alreadyMarked;
  String get apply;
  String get applyAll;
  String get notRecognized;
  String get importTarget;
  String get nothingToImport;
  String unrecognizedBody(int quests, int enchantments);
  String applied(int count);
  String saveError(String code);
  String get onMap;
  String get avatarGallery;
  String get avatarCamera;
  String get avatarRemove;
  String get hints;
  String get hintsHidden;

  String get tabHome;
  String get tabQuests;
  String get tabSkills;
  String get tabEnchanting;
  String get tabFollowers;
  String get statistics;
  String sectionStat(Section section);

  /// Подпись метки из данных; неизвестный ключ показывается как есть.
  String tag(String key);
  String lockedBy(String option, String item);

  String get characters;
  String get charactersHint;
  String get newCharacter;
  String get character;
  String get name;
  String get race;
  String get create;
  String get save;
  String deleteCharacterQuestion(String name);
  String get deleteCharacterBody;
  String get defaultCharacterName;
  String raceTitle(Race race);
  String sexTitle(Sex sex);
}

class _Ru extends S {
  const _Ru();

  @override
  String get languageCode => 'RU';
  @override
  String get languageName => 'Русский';
  @override
  String get useSystemLanguage => 'Язык как в системе';

  @override
  String get search => 'Поиск';
  @override
  String get searchHint => 'Квест, место, NPC…';
  @override
  String get nothingFound => 'Ничего не найдено';
  @override
  String get resetProgress => 'Сбросить прогресс';
  @override
  String get resetProgressQuestion => 'Сбросить прогресс?';
  @override
  String resetProgressBody(String name) =>
      'Все отметки и выборы персонажа «$name» будут удалены. '
      'Это нельзя отменить.';
  @override
  String get reset => 'Сбросить';
  @override
  String get cancel => 'Отмена';
  @override
  String get delete => 'Удалить';
  @override
  String get edit => 'Изменить';
  @override
  String doneOf(int done, int total) => 'Отмечено $done из $total';

  @override
  String get choices => 'Развилки';
  @override
  String get choicesHint =>
      'Выборы, которые меняют прохождение. Отметь свой — квесты, '
      'ставшие недоступными, перестанут учитываться в прогрессе.';
  @override
  String get dontMiss => 'Не упусти';
  @override
  String get dontMissHint =>
      'Пункты, которые закрываются навсегда. '
      'Пройденные и закрытые выбором не показываются.';
  @override
  String get allClear => 'Пусто — всё под контролем';

  @override
  String get filterAll => 'Все';
  @override
  String get filterTodo => 'Осталось';
  @override
  String get filterDone => 'Готово';
  @override
  String get repeatableQuests => 'Повторяемые задания';

  @override
  String get tips => 'Советы';
  @override
  String get secretsSection => 'Секреты и пасхалки';
  @override
  String get missablesSection => 'Можно упустить';
  @override
  String get relatedQuests => 'Связанные задания';
  @override
  String video(String time) => 'Видео $time';
  @override
  String get repeatableNotice =>
      'Повторяемое задание: его выдают снова и снова. '
      'Отметка значит «выполнено хотя бы раз».';
  @override
  String get unmark => 'Снять отметку';
  @override
  String markDone(ItemType type) => switch (type) {
    ItemType.quest => 'Пройдено',
    ItemType.missable => 'Получено',
    ItemType.secret => 'Найдено',
    ItemType.skill => 'Прокачан до 100',
    ItemType.enchantment => 'Изучено',
    ItemType.follower => 'Нанят',
  };
  @override
  String get details => 'Справка';
  @override
  String get importSave => 'Импорт сохранения';
  @override
  String get importIntro =>
      'Загрузите сохранение Skyrim — SkyLog отметит пройденные квесты и изученные зачарования. Ничего не применяется без вашего подтверждения.';
  @override
  String get supportedFormats => 'Поддерживаемые форматы';
  @override
  String get formatSe =>
      'Skyrim Special Edition / Anniversary Edition, ПК (.ess) — квесты и зачарования';
  @override
  String get formatLe =>
      'Skyrim Legendary Edition, ПК (.ess) — экспериментально';
  @override
  String get formatConsole =>
      'Консоли (PlayStation, Xbox, Switch) — файлы сохранений недоступны';
  @override
  String get formatMods => 'Квесты из модов не распознаются';
  @override
  String get saveLocation =>
      'Где файл на ПК: Документы\\My Games\\Skyrim Special Edition\\Saves. Скопируйте .ess на телефон.';
  @override
  String get chooseFile => 'Выбрать файл .ess';
  @override
  String get readingSave => 'Читаю сохранение…';
  @override
  String get questsCompleted => 'Квесты пройдены';
  @override
  String get enchantmentsKnown => 'Зачарования изучены';
  @override
  String get alreadyMarked => 'уже отмечено';
  @override
  String get apply => 'Применить';
  @override
  String get applyAll => 'Применить всё';
  @override
  String get notRecognized => 'Не распознано';
  @override
  String get importTarget => 'Отметки получит персонаж';
  @override
  String get nothingToImport => 'Ничего нового — всё уже отмечено.';
  @override
  String unrecognizedBody(int quests, int enchantments) =>
      'В сохранении $quests завершённых квестов и $enchantments зачарований, '
      'которых нет в SkyLog: служебные, общие радианты или из модов. '
      'Автоматически не определяются секреты, поручения жителей с общими '
      'квестами, навыки, спутники и выборы на развилках — их отметьте сами.';
  @override
  String applied(int count) => 'Отмечено: $count';
  @override
  String saveError(String code) => switch (code) {
    'not_a_save' => 'Это не сохранение Skyrim (.ess).',
    'lz4' => 'Файл повреждён: не удалось распаковать.',
    _ => 'Формат сохранения не поддерживается ($code).',
  };
  @override
  String get onMap => 'На карте';
  @override
  String get avatarGallery => 'Выбрать из галереи';
  @override
  String get avatarCamera => 'Сделать фото';
  @override
  String get avatarRemove => 'Убрать фото';
  @override
  String get hints => 'Подсказки по прохождению';
  @override
  String get hintsHidden =>
      'Скрыты, чтобы не спойлерить — нажмите, чтобы открыть';

  @override
  String get tabHome => 'Главная';
  @override
  String get tabQuests => 'Квесты';
  @override
  String get tabSkills => 'Навыки';
  @override
  String get tabEnchanting => 'Чары';
  @override
  String get tabFollowers => 'Спутники';
  @override
  String get statistics => 'Статистика';
  @override
  String sectionStat(Section section) => switch (section) {
    Section.quests => 'Квесты пройдены',
    Section.secrets => 'Секреты найдены',
    Section.skills => 'Навыки до 100',
    Section.enchanting => 'Зачарования изучены',
    Section.followers => 'Спутники наняты',
  };
  @override
  String tag(String key) => switch (key) {
    'warrior' => 'Воин',
    'mage' => 'Маг',
    'thief' => 'Вор',
    'weapon' => 'Оружие',
    'armor' => 'Броня',
    'followers_yes' => 'Работает на спутнике',
    'followers_no' => 'Не работает на спутнике',
    'unique' => 'Нельзя изучить',
    'dlc' => 'DLC',
    'marriage' => 'Можно жениться',
    'essential' => 'Бессмертный',
    'protected' => 'Защищённый',
    'housecarl' => 'Хускарл',
    'limited' => 'Временный',
    'favor' => 'Поручение',
    'thane' => 'Для тана',
    _ => key,
  };
  @override
  String lockedBy(String option, String item) =>
      'Закрыто выбором «$option» в «$item»';

  @override
  String get characters => 'Персонажи';
  @override
  String get charactersHint =>
      'У каждого персонажа свои отметки и свои выборы на развилках.';
  @override
  String get newCharacter => 'Новый персонаж';
  @override
  String get character => 'Персонаж';
  @override
  String get name => 'Имя';
  @override
  String get race => 'Раса';
  @override
  String get create => 'Создать';
  @override
  String get save => 'Сохранить';
  @override
  String deleteCharacterQuestion(String name) => 'Удалить «$name»?';
  @override
  String get deleteCharacterBody =>
      'Персонаж и весь его прогресс будут удалены. Это нельзя отменить.';
  @override
  String get defaultCharacterName => 'Довакин';
  @override
  String raceTitle(Race race) => switch (race) {
    Race.nord => 'Норд',
    Race.imperial => 'Имперец',
    Race.breton => 'Бретонец',
    Race.redguard => 'Редгард',
    Race.altmer => 'Высокий эльф',
    Race.dunmer => 'Тёмный эльф',
    Race.bosmer => 'Лесной эльф',
    Race.orc => 'Орк',
    Race.khajiit => 'Каджит',
    Race.argonian => 'Аргонианин',
  };
  @override
  String sexTitle(Sex sex) => switch (sex) {
    Sex.male => 'Мужчина',
    Sex.female => 'Женщина',
  };
}

class _En extends S {
  const _En();

  @override
  String get languageCode => 'EN';
  @override
  String get languageName => 'English';
  @override
  String get useSystemLanguage => 'Use system language';

  @override
  String get search => 'Search';
  @override
  String get searchHint => 'Quest, place, NPC…';
  @override
  String get nothingFound => 'Nothing found';
  @override
  String get resetProgress => 'Reset progress';
  @override
  String get resetProgressQuestion => 'Reset progress?';
  @override
  String resetProgressBody(String name) =>
      'All checkmarks and choices of “$name” will be deleted. '
      'This cannot be undone.';
  @override
  String get reset => 'Reset';
  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String doneOf(int done, int total) => '$done of $total completed';

  @override
  String get choices => 'Choices';
  @override
  String get choicesHint =>
      'Decisions that change your playthrough. Mark yours — quests it '
      'locks out will no longer count toward progress.';
  @override
  String get dontMiss => "Don't miss";
  @override
  String get dontMissHint =>
      'Things that close for good. '
      'Completed ones and those locked by your choices are hidden.';
  @override
  String get allClear => 'Nothing here — all under control';

  @override
  String get filterAll => 'All';
  @override
  String get filterTodo => 'To do';
  @override
  String get filterDone => 'Done';
  @override
  String get repeatableQuests => 'Repeatable quests';

  @override
  String get tips => 'Tips';
  @override
  String get secretsSection => 'Secrets and easter eggs';
  @override
  String get missablesSection => 'Missable';
  @override
  String get relatedQuests => 'Related quests';
  @override
  String video(String time) => 'Video $time';
  @override
  String get repeatableNotice =>
      'Repeatable quest: it is handed out again and again. '
      'The checkmark means “done at least once”.';
  @override
  String get unmark => 'Unmark';
  @override
  String markDone(ItemType type) => switch (type) {
    ItemType.quest => 'Completed',
    ItemType.missable => 'Obtained',
    ItemType.secret => 'Found',
    ItemType.skill => 'Mastered (100)',
    ItemType.enchantment => 'Learned',
    ItemType.follower => 'Recruited',
  };
  @override
  String get details => 'Details';
  @override
  String get importSave => 'Import a save';
  @override
  String get importIntro =>
      'Load a Skyrim save and SkyLog will check off completed quests and learned enchantments. Nothing is applied without your confirmation.';
  @override
  String get supportedFormats => 'Supported formats';
  @override
  String get formatSe =>
      'Skyrim Special Edition / Anniversary Edition, PC (.ess) — quests and enchantments';
  @override
  String get formatLe => 'Skyrim Legendary Edition, PC (.ess) — experimental';
  @override
  String get formatConsole =>
      'Consoles (PlayStation, Xbox, Switch) — save files are not accessible';
  @override
  String get formatMods => 'Quests from mods are not recognized';
  @override
  String get saveLocation =>
      'On PC the file is in Documents\\My Games\\Skyrim Special Edition\\Saves. Copy the .ess to your phone.';
  @override
  String get chooseFile => 'Choose a .ess file';
  @override
  String get readingSave => 'Reading the save…';
  @override
  String get questsCompleted => 'Quests completed';
  @override
  String get enchantmentsKnown => 'Enchantments learned';
  @override
  String get alreadyMarked => 'already marked';
  @override
  String get apply => 'Apply';
  @override
  String get applyAll => 'Apply all';
  @override
  String get notRecognized => 'Not recognized';
  @override
  String get importTarget => 'Checkmarks go to character';
  @override
  String get nothingToImport => 'Nothing new — everything is already checked.';
  @override
  String unrecognizedBody(int quests, int enchantments) =>
      'The save has $quests completed quests and $enchantments enchantments '
      "that SkyLog doesn't track: internal, shared radiant or from mods. "
      "Secrets, favors that share one quest, skills, followers and choices "
      "can't be detected — check those yourself.";
  @override
  String applied(int count) => 'Checked off: $count';
  @override
  String saveError(String code) => switch (code) {
    'not_a_save' => 'This is not a Skyrim save (.ess).',
    'lz4' => 'The file is damaged: could not decompress it.',
    _ => 'This save format is not supported ($code).',
  };
  @override
  String get onMap => 'On the map';
  @override
  String get avatarGallery => 'Choose from gallery';
  @override
  String get avatarCamera => 'Take a photo';
  @override
  String get avatarRemove => 'Remove photo';
  @override
  String get hints => 'Walkthrough hints';
  @override
  String get hintsHidden => 'Hidden to avoid spoilers — tap to reveal';

  @override
  String get tabHome => 'Home';
  @override
  String get tabQuests => 'Quests';
  @override
  String get tabSkills => 'Skills';
  @override
  String get tabEnchanting => 'Enchanting';
  @override
  String get tabFollowers => 'Followers';
  @override
  String get statistics => 'Statistics';
  @override
  String sectionStat(Section section) => switch (section) {
    Section.quests => 'Quests completed',
    Section.secrets => 'Secrets found',
    Section.skills => 'Skills at 100',
    Section.enchanting => 'Enchantments learned',
    Section.followers => 'Followers recruited',
  };
  @override
  String tag(String key) => switch (key) {
    'warrior' => 'Warrior',
    'mage' => 'Mage',
    'thief' => 'Thief',
    'weapon' => 'Weapon',
    'armor' => 'Armor',
    'followers_yes' => 'Works on followers',
    'followers_no' => "Doesn't work on followers",
    'unique' => "Can't be learned",
    'dlc' => 'DLC',
    'marriage' => 'Marriageable',
    'essential' => 'Essential',
    'protected' => 'Protected',
    'housecarl' => 'Housecarl',
    'limited' => 'Temporary',
    'favor' => 'Favor',
    'thane' => 'Counts for Thane',
    _ => key,
  };
  @override
  String lockedBy(String option, String item) =>
      'Locked by choosing “$option” in “$item”';

  @override
  String get characters => 'Characters';
  @override
  String get charactersHint =>
      'Each character has their own checkmarks and choices.';
  @override
  String get newCharacter => 'New character';
  @override
  String get character => 'Character';
  @override
  String get name => 'Name';
  @override
  String get race => 'Race';
  @override
  String get create => 'Create';
  @override
  String get save => 'Save';
  @override
  String deleteCharacterQuestion(String name) => 'Delete “$name”?';
  @override
  String get deleteCharacterBody =>
      'The character and all their progress will be deleted. '
      'This cannot be undone.';
  @override
  String get defaultCharacterName => 'Dovahkiin';
  @override
  String raceTitle(Race race) => switch (race) {
    Race.nord => 'Nord',
    Race.imperial => 'Imperial',
    Race.breton => 'Breton',
    Race.redguard => 'Redguard',
    Race.altmer => 'High Elf',
    Race.dunmer => 'Dark Elf',
    Race.bosmer => 'Wood Elf',
    Race.orc => 'Orc',
    Race.khajiit => 'Khajiit',
    Race.argonian => 'Argonian',
  };
  @override
  String sexTitle(Sex sex) => switch (sex) {
    Sex.male => 'Male',
    Sex.female => 'Female',
  };
}
