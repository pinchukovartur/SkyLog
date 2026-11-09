import 'package:flutter/services.dart';

/// Системный выбор файла (реализация — MainActivity.kt).
/// Возвращает имя и содержимое или null, если пользователь отменил выбор.
Future<({String? name, Uint8List bytes})?> pickFile() async {
  const channel = MethodChannel('skylog/files');
  final result = await channel.invokeMapMethod<String, Object?>('pickFile');
  final bytes = result?['bytes'];
  if (bytes is! Uint8List) return null;
  return (name: result?['name'] as String?, bytes: bytes);
}
