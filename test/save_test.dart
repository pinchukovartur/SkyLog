import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:skylog/save/ess_reader.dart';
import 'package:skylog/save/save_import.dart';

// Настоящие сохранения не входят в репозиторий: путь задаётся через
// SKYLOG_SAVES, иначе эти тесты пропускаются.
final _dir = Platform.environment['SKYLOG_SAVES'];

List<File> _saves() => _dir == null
    ? const []
    : (Directory(_dir!)
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.ess')))
          .toList();

void main() {
  test('LZ4: литералы и самоперекрывающееся совпадение', () {
    // «ab» литералами, затем совпадение длиной 6 со смещением 2 → «abababab».
    final packed = Uint8List.fromList([0x22, 0x61, 0x62, 0x02, 0x00]);
    expect(String.fromCharCodes(lz4BlockDecompress(packed, 8)), 'abababab');
  });

  test('не сохранение — понятная ошибка', () {
    expect(
      () => readSave(Uint8List.fromList(List.filled(64, 0))),
      throwsA(isA<SaveFormatException>()),
    );
  });

  test('настоящие сохранения читаются и сопоставляются', () {
    final map = SaveMap.fromJson(
      File('assets/data/save_map.json').readAsStringSync(),
    );
    for (final file in _saves()) {
      final save = readSave(file.readAsBytesSync());
      final result = matchSave(save, map);
      // ignore: avoid_print
      print(
        '${save.playerName} ${save.playerLevel} ${save.playerRace}: '
        'квестов ${result.completedQuests.length}, '
        'начато ${result.startedQuests.length}, '
        'зачарований ${result.knownEnchantments.length}, '
        'неизвестных ${result.unknownCompleted}',
      );
      expect(save.isSpecialEdition, isTrue);
      expect(result.completedQuests, contains('main_unbound'));
    }
  }, skip: _dir == null ? 'нет SKYLOG_SAVES' : null);
}
