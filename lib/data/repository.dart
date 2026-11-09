import 'dart:convert';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';

import '../models.dart';

/// Справочник игры: категории, загруженные из assets/data.
class Repository {
  Repository(this.categories)
    : _items = {for (final i in categories.expand((c) => c.items)) i.id: i} {
    // Ссылка, указанная с одной стороны, видна с обеих.
    for (final item in _items.values) {
      for (final id in item.related) {
        if (!_items.containsKey(id)) continue;
        (_links[item.id] ??= {}).add(id);
        (_links[id] ??= {}).add(item.id);
      }
    }
  }

  final List<Category> categories;
  final Map<String, Item> _items;
  final Map<String, Set<String>> _links = {};

  /// Загружает данные на языке [lang]. Английские файлы лежат в
  /// assets/data/en; если перевода категории нет, берётся русский файл.
  static Future<Repository> load(
    AssetBundle bundle, {
    String lang = 'ru',
  }) async {
    final index = (jsonDecode(
      await bundle.loadString('assets/data/index.json'),
    ) as List).cast<String>();
    final categories = <Category>[];
    for (final id in index) {
      final String raw;
      try {
        raw = await _loadFirst(bundle, [
          if (lang != 'ru') 'assets/data/$lang/$id.json',
          'assets/data/$id.json',
        ]);
      } on FlutterError {
        // Категория объявлена в index.json, но файла ещё нет.
        continue;
      }
      categories.add(
        Category.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      );
    }
    return Repository(categories);
  }

  static Future<String> _loadFirst(
    AssetBundle bundle,
    List<String> paths,
  ) async {
    for (final path in paths.take(paths.length - 1)) {
      try {
        return await bundle.loadString(path);
      } on FlutterError {
        continue;
      }
    }
    return bundle.loadString(paths.last);
  }

  Iterable<Item> get items => _items.values;

  Item? item(String id) => _items[id];

  /// Пункты, связанные с [id] в любую сторону.
  List<Item> linked(String id) => [
    for (final other in _links[id] ?? const <String>{}) _items[other]!,
  ];

  Category category(String id) => categories.firstWhere((c) => c.id == id);

  Iterable<Category> inSection(Section section) =>
      categories.where((c) => c.section == section);

  Iterable<Item> itemsIn(Section section) =>
      inSection(section).expand((c) => c.items);
}
