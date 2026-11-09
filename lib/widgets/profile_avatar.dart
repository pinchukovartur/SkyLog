import 'dart:convert';

import 'package:flutter/material.dart';

import '../profile.dart';

/// Фото персонажа или кружок с первой буквой имени.
class ProfileAvatar extends StatelessWidget {
  ProfileAvatar({super.key, required Profile profile, this.radius = 20})
    : name = profile.name,
      avatar = profile.avatar;

  const ProfileAvatar.raw({
    super.key,
    required this.name,
    required this.avatar,
    this.radius = 20,
  });

  final String name;
  final String? avatar;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final photo = avatar;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primary.withValues(alpha: 0.18),
      foregroundColor: scheme.primary,
      backgroundImage: photo == null ? null : MemoryImage(base64Decode(photo)),
      child: photo != null
          ? null
          : Text(
              name.isEmpty ? '?' : name.characters.first.toUpperCase(),
              style: TextStyle(
                fontSize: radius * 0.9,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
