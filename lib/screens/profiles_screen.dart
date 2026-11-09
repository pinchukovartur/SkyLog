import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/strings.dart';

import '../profile.dart';
import '../state/progress.dart';
import '../state/progress_scope.dart';
import '../widgets/profile_avatar.dart';

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final progress = ProgressScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.characters)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          for (final profile in progress.profiles)
            _ProfileTile(
              profile: profile,
              active: profile.id == progress.active.id,
              stats: progress.overallOf(profile),
              canDelete: progress.profiles.length > 1,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(s.charactersHint, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProfileEditor(context),
        icon: const Icon(Icons.person_add_alt),
        label: Text(s.newCharacter),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.profile,
    required this.active,
    required this.stats,
    required this.canDelete,
  });

  final Profile profile;
  final bool active;
  final CategoryProgress stats;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final progress = ProgressScope.of(context);
    return ListTile(
      selected: active,
      onTap: () {
        progress.switchTo(profile);
        Navigator.of(context).pop();
      },
      leading: ProfileAvatar(profile: profile),
      title: Text(profile.name),
      subtitle: Text(
        '${s.raceTitle(profile.race)} · ${s.sexTitle(profile.sex)} · '
        '${(stats.ratio * 100).round()}%',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (action) => switch (action) {
          'edit' => showProfileEditor(context, profile: profile),
          _ => _confirmDelete(context, progress),
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Text(s.edit)),
          if (canDelete) PopupMenuItem(value: 'delete', child: Text(s.delete)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Progress progress) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.deleteCharacterQuestion(profile.name)),
        content: Text(s.deleteCharacterBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (ok == true) await progress.deleteProfile(profile);
  }
}

/// Создание персонажа или редактирование [profile].
Future<void> showProfileEditor(BuildContext context, {Profile? profile}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ProfileEditor(profile: profile),
    );

class _ProfileEditor extends StatefulWidget {
  const _ProfileEditor({this.profile});

  final Profile? profile;

  @override
  State<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<_ProfileEditor> {
  late final _name = TextEditingController(text: widget.profile?.name);
  late Race _race = widget.profile?.race ?? Race.nord;
  late Sex _sex = widget.profile?.sex ?? Sex.male;
  late String? _avatar = widget.profile?.avatar;

  Future<void> _pickAvatar() async {
    final s = S.of(context);
    final source = await showModalBottomSheet<Object>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(s.avatarGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(s.avatarCamera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            if (_avatar != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(s.avatarRemove),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (source == 'remove') {
      setState(() => _avatar = null);
      return;
    }
    if (source is! ImageSource) return;
    // Маленькая картинка: профиль хранится в SharedPreferences.
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 256,
      maxHeight: 256,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) setState(() => _avatar = base64Encode(bytes));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final progress = ProgressScope.of(context);
    final profile = widget.profile;
    if (profile == null) {
      progress.addProfile(name: name, race: _race, sex: _sex, avatar: _avatar);
    } else {
      progress.updateProfile(
        profile.copyWith(name: name, race: _race, sex: _sex, avatar: _avatar),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.profile == null ? s.newCharacter : s.character,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  ProfileAvatar.raw(
                    name: _name.text,
                    avatar: _avatar,
                    radius: 40,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.photo_camera,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: widget.profile == null,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: s.name,
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          DropdownMenu<Race>(
            initialSelection: _race,
            label: Text(s.race),
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: [
              for (final race in Race.values)
                DropdownMenuEntry(value: race, label: s.raceTitle(race)),
            ],
            onSelected: (race) => setState(() => _race = race ?? _race),
          ),
          const SizedBox(height: 16),
          SegmentedButton<Sex>(
            segments: [
              for (final sex in Sex.values)
                ButtonSegment(value: sex, label: Text(s.sexTitle(sex))),
            ],
            selected: {_sex},
            onSelectionChanged: (s) => setState(() => _sex = s.first),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _name.text.trim().isEmpty ? null : _save,
            child: Text(widget.profile == null ? s.create : s.save),
          ),
        ],
      ),
    );
  }
}
