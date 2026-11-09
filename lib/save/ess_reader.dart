import 'dart:convert';
import 'dart:io' show ZLibCodec;
import 'dart:typed_data';

/// Ошибка разбора: файл не сохранение Skyrim или формат не поддерживается.
class SaveFormatException implements Exception {
  SaveFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Состояние квеста в сохранении.
class SavedQuest {
  const SavedQuest({required this.completed, required this.failed});

  final bool completed;
  final bool failed;
}

/// Данные, которые SkyLog достаёт из сохранения.
class SaveData {
  SaveData({
    required this.version,
    required this.playerName,
    required this.playerLevel,
    required this.playerRace,
    required this.isFemale,
    required this.location,
    required this.plugins,
    required this.quests,
    required this.knownEnchantments,
  });

  /// 9 — Skyrim LE, 12 — Special/Anniversary Edition.
  final int version;
  final String playerName;
  final int playerLevel;
  final String playerRace;
  final bool isFemale;
  final String location;
  final List<String> plugins;

  /// Ключ «Плагин.esm:FFFFFF» → состояние квеста.
  final Map<String, SavedQuest> quests;

  /// Ключи «Плагин.esm:FFFFFF» изученных игроком зачарований.
  final Set<String> knownEnchantments;

  bool get isSpecialEdition => version >= 12;
}

/// Разбор .ess по описанию UESP «Skyrim Mod:Save File Format».
/// Читаются заголовок и изменённые записи: квесты (QUST) и зачарования (ENCH).
SaveData readSave(Uint8List bytes) {
  final r = _Reader(bytes);
  if (bytes.length < 17 || ascii.decode(r.raw(13)) != 'TESV_SAVEGAME') {
    throw SaveFormatException('not_a_save');
  }
  final headerSize = r.u32();
  final headerEnd = r.pos + headerSize;
  final version = r.u32();
  if (version != 12 && (version < 7 || version > 9)) {
    throw SaveFormatException('version_$version');
  }
  r.u32(); // saveNumber
  final name = r.wstring();
  final level = r.u32();
  final location = r.wstring();
  r.wstring(); // gameDate
  final race = r.wstring();
  final sex = r.u16();
  r.skip(4 + 4 + 8); // опыт, опыт до уровня, FILETIME
  final shotWidth = r.u32();
  final shotHeight = r.u32();
  final compression = version >= 12 ? r.u16() : 0;
  r.pos = headerEnd;
  r.skip(shotWidth * shotHeight * (version >= 12 ? 4 : 3));

  final Uint8List body;
  switch (compression) {
    case 0:
      body = Uint8List.sublistView(bytes, r.pos);
    case 1 || 2:
      final rawLength = r.u32();
      final packedLength = r.u32();
      final packed = Uint8List.sublistView(bytes, r.pos, r.pos + packedLength);
      body = compression == 2
          ? lz4BlockDecompress(packed, rawLength)
          : Uint8List.fromList(ZLibCodec().decode(packed));
    default:
      throw SaveFormatException('compression_$compression');
  }

  final d = _Reader(body);
  final formVersion = d.u8();
  final pluginInfoSize = d.u32();
  final pluginInfoEnd = d.pos + pluginInfoSize;
  final plugins = [for (var i = d.u8(); i > 0; i--) d.wstring()];
  // ESL-плагины лежат внутри того же блока; их записи получают индекс 0xFE.
  if (formVersion >= 78) {
    for (var i = d.u16(); i > 0; i--) {
      d.wstring();
    }
  }
  d.pos = pluginInfoEnd;

  final formIdArrayOffset = d.u32();
  d.u32(); // unknownTable3Offset
  final globalData1Offset = d.u32();
  d.u32(); // globalDataTable2Offset
  final changeFormsOffset = d.u32();
  d.u32(); // globalDataTable3Offset
  d.skip(12); // числа записей в таблицах глобальных данных
  final changeFormCount = d.u32();
  d.skip(60);
  // Смещения считаются от начала файла без сжатия; первая глобальная
  // запись лежит сразу за таблицей смещений — от неё и берём базу.
  final base = globalData1Offset - d.pos;

  d.pos = formIdArrayOffset - base;
  final formIds = [for (var i = d.u32(); i > 0; i--) d.u32()];

  String? key(int b0, int b1, int b2) {
    final value = ((b0 & 0x3F) << 16) | (b1 << 8) | b2;
    final int formId;
    switch (b0 >> 6) {
      case 0:
        if (value == 0 || value > formIds.length) return null;
        formId = formIds[value - 1];
      case 1:
        formId = value;
      default:
        return null; // созданные в игре объекты нам не нужны
    }
    final index = formId >>> 24;
    if (index >= plugins.length) return null;
    return '${plugins[index]}:'
        '${(formId & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}';
  }

  final quests = <String, SavedQuest>{};
  final enchantments = <String>{};
  d.pos = changeFormsOffset - base;
  for (var i = 0; i < changeFormCount; i++) {
    final b0 = d.u8(), b1 = d.u8(), b2 = d.u8();
    final flags = d.u32();
    final typeByte = d.u8();
    d.u8(); // version
    final int Function() length = switch (typeByte >> 6) {
      0 => d.u8,
      1 => d.u16,
      _ => d.u32,
    };
    final length1 = length();
    final length2 = length();
    final type = typeByte & 0x3F;
    const quest = 8, enchantment = 48;
    if (type != quest && type != enchantment) {
      d.skip(length1);
      continue;
    }
    var data = d.raw(length1);
    if (length2 != 0) {
      data = Uint8List.fromList(ZLibCodec().decode(data));
    }
    final id = key(b0, b1, b2);
    if (id == null) continue;
    final dr = _Reader(data);
    if (type == quest) {
      // CHANGE_FORM_FLAGS (6 байт), затем CHANGE_QUEST_FLAGS (uint16).
      if (flags & 0x2 == 0) continue;
      if (flags & 0x1 != 0) dr.skip(6);
      if (dr.remaining < 2) continue;
      final questFlags = dr.u16();
      quests[id] = SavedQuest(
        completed: questFlags & 0x2 != 0,
        failed: questFlags & 0x40 != 0,
      );
    } else if (flags & 0x1 != 0 && dr.remaining >= 4) {
      // Флаг записи 0x40 — зачарование известно игроку.
      if (dr.u32() & 0x40 != 0) enchantments.add(id);
    }
  }

  return SaveData(
    version: version,
    playerName: name,
    playerLevel: level,
    playerRace: race,
    isFemale: sex == 1,
    location: location,
    plugins: plugins,
    quests: quests,
    knownEnchantments: enchantments,
  );
}

/// Распаковка LZ4 в блочном формате (без заголовка кадра).
Uint8List lz4BlockDecompress(Uint8List src, int outLength) {
  final dst = Uint8List(outLength);
  var i = 0, o = 0;
  while (i < src.length) {
    final token = src[i++];
    var literals = token >> 4;
    if (literals == 15) {
      int b;
      do {
        b = src[i++];
        literals += b;
      } while (b == 255);
    }
    dst.setRange(o, o + literals, src, i);
    i += literals;
    o += literals;
    if (i >= src.length) break;
    final offset = src[i] | (src[i + 1] << 8);
    i += 2;
    var match = token & 15;
    if (match == 15) {
      int b;
      do {
        b = src[i++];
        match += b;
      } while (b == 255);
    }
    match += 4;
    // Совпадение может перекрывать само себя — копируем по байту.
    for (var k = 0; k < match; k++, o++) {
      dst[o] = dst[o - offset];
    }
  }
  if (o != outLength) throw SaveFormatException('lz4');
  return dst;
}

class _Reader {
  _Reader(this.bytes) : view = ByteData.sublistView(bytes);

  final Uint8List bytes;
  final ByteData view;
  int pos = 0;

  int get remaining => bytes.length - pos;

  int u8() => bytes[pos++];

  int u16() {
    final v = view.getUint16(pos, Endian.little);
    pos += 2;
    return v;
  }

  int u32() {
    final v = view.getUint32(pos, Endian.little);
    pos += 4;
    return v;
  }

  void skip(int n) => pos += n;

  Uint8List raw(int n) {
    final v = Uint8List.sublistView(bytes, pos, pos + n);
    pos += n;
    return v;
  }

  String wstring() => utf8.decode(raw(u16()), allowMalformed: true);
}
