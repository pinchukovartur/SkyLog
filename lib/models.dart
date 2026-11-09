enum ItemType { quest, missable, secret, skill, enchantment, follower }

/// Вкладка приложения, на которой показывается категория.
enum Section { quests, secrets, skills, enchanting, followers }

/// Строка справки «параметр — значение».
class Fact {
  const Fact(this.label, this.value);

  factory Fact.fromJson(Map<String, dynamic> json) =>
      Fact(json['label'] as String, json['value'] as String);

  final String label;
  final String value;
}

class ChoiceOption {
  ChoiceOption({
    required this.id,
    required this.label,
    required this.result,
    required this.locks,
  });

  factory ChoiceOption.fromJson(Map<String, dynamic> json) => ChoiceOption(
    id: json['id'] as String,
    label: json['label'] as String,
    result: json['result'] as String? ?? '',
    locks: (json['locks'] as List?)?.cast<String>() ?? const [],
  );

  final String id;
  final String label;
  final String result;
  final List<String> locks;
}

class Choice {
  Choice({required this.id, required this.question, required this.options});

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
    id: json['id'] as String,
    question: json['question'] as String,
    options: (json['options'] as List)
        .map((o) => ChoiceOption.fromJson(o as Map<String, dynamic>))
        .toList(),
  );

  final String id;
  final String question;
  final List<ChoiceOption> options;

  ChoiceOption? option(String? optionId) {
    for (final o in options) {
      if (o.id == optionId) return o;
    }
    return null;
  }
}

class Item {
  Item({
    required this.id,
    required this.title,
    required this.en,
    required this.type,
    required this.description,
    required this.tips,
    this.hints = const [],
    required this.choices,
    required this.related,
    required this.categoryId,
    required this.groupTitle,
    this.location,
    this.giver,
    this.videoTime,
    this.mapPlace,
    this.mapWorld = 'Skyrim',
    this.missable,
    this.repeatable = false,
    this.facts = const [],
    this.tags = const [],
  });

  factory Item.fromJson(
    Map<String, dynamic> json, {
    required String categoryId,
    required String groupTitle,
  }) => Item(
    id: json['id'] as String,
    title: json['title'] as String,
    en: json['en'] as String? ?? '',
    type: switch (json['type']) {
      'missable' => ItemType.missable,
      'secret' => ItemType.secret,
      'skill' => ItemType.skill,
      'enchantment' => ItemType.enchantment,
      'follower' => ItemType.follower,
      _ => ItemType.quest,
    },
    location: json['location'] as String?,
    giver: json['giver'] as String?,
    videoTime: json['chapter'] as String?,
    mapPlace: json['map'] as String?,
    mapWorld: json['mapWorld'] as String? ?? 'Skyrim',
    description: json['description'] as String? ?? '',
    tips: (json['tips'] as List?)?.cast<String>() ?? const [],
    hints: (json['hints'] as List?)?.cast<String>() ?? const [],
    related: (json['related'] as List?)?.cast<String>() ?? const [],
    missable: json['missable'] as String?,
    repeatable: json['repeatable'] == true,
    facts:
        (json['facts'] as List?)
            ?.map((f) => Fact.fromJson(f as Map<String, dynamic>))
            .toList() ??
        const [],
    tags: (json['tags'] as List?)?.cast<String>() ?? const [],
    choices:
        (json['choices'] as List?)
            ?.map((c) => Choice.fromJson(c as Map<String, dynamic>))
            .toList() ??
        const [],
    categoryId: categoryId,
    groupTitle: groupTitle,
  );

  final String id;
  final String title;
  final String en;
  final ItemType type;
  final String? location;
  final String? giver;

  /// Время в видео-источнике, где показан секрет.
  final String? videoTime;

  /// Название места на карте UESP (по-английски) и мир карты.
  final String? mapPlace;
  final String mapWorld;

  Uri? get mapUri => mapPlace == null
      ? null
      : Uri.https('gamemap.uesp.net', '/sr/', {
          'world': mapWorld,
          'centeron': mapPlace,
        });
  final String description;
  final List<String> tips;

  /// Подсказки по прохождению: скрыты, пока игрок сам их не развернёт.
  final List<String> hints;
  final String? missable;

  /// Радиант-задание: его можно брать снова и снова.
  final bool repeatable;
  final List<Choice> choices;

  /// id пунктов из любых категорий, которые стоит показать рядом.
  final List<String> related;

  /// Справка для навыков, зачарований и спутников.
  final List<Fact> facts;

  /// Ключи меток: marriage, followers_yes, mage… Подписи — в [S.tag].
  final List<String> tags;
  final String categoryId;
  final String groupTitle;

  bool matches(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        en.toLowerCase().contains(q) ||
        (location?.toLowerCase().contains(q) ?? false) ||
        (giver?.toLowerCase().contains(q) ?? false);
  }
}

class Group {
  Group({required this.title, required this.items});

  final String title;
  final List<Item> items;
}

class Category {
  Category({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.groups,
    this.section = Section.quests,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return Category(
      id: id,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? 'map',
      description: json['description'] as String? ?? '',
      section: Section.values.asNameMap()[json['section']] ?? Section.quests,
      groups: (json['groups'] as List).map((g) {
        final group = g as Map<String, dynamic>;
        final title = group['title'] as String? ?? '';
        return Group(
          title: title,
          items: (group['items'] as List)
              .map(
                (i) => Item.fromJson(
                  i as Map<String, dynamic>,
                  categoryId: id,
                  groupTitle: title,
                ),
              )
              .toList(),
        );
      }).toList(),
    );
  }

  final String id;
  final String title;
  final String icon;
  final String description;
  final Section section;
  final List<Group> groups;

  Iterable<Item> get items => groups.expand((g) => g.items);
}
