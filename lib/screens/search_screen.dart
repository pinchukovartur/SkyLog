import 'package:flutter/material.dart';

import '../l10n/strings.dart';

import '../state/progress_scope.dart';
import '../widgets/item_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final progress = ProgressScope.of(context);
    final query = _query.trim();
    final results = query.length < 2
        ? const []
        : progress.repo.items.where((i) => i.matches(query)).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: s.searchHint,
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: ListView(
        children: [
          if (query.length >= 2 && results.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(s.nothingFound)),
            ),
          for (final item in results) ItemTile(item: item, showCategory: true),
        ],
      ),
    );
  }
}
