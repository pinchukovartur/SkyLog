enum Race {
  nord,
  imperial,
  breton,
  redguard,
  altmer,
  dunmer,
  bosmer,
  orc,
  khajiit,
  argonian,
}

enum Sex { male, female }

/// Персонаж: у каждого своё прохождение.
class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.race,
    required this.sex,
    this.avatar,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    name: json['name'] as String,
    race: Race.values.asNameMap()[json['race']] ?? Race.nord,
    sex: Sex.values.asNameMap()[json['sex']] ?? Sex.male,
    avatar: json['avatar'] as String?,
  );

  final String id;
  final String name;
  final Race race;
  final Sex sex;

  /// Фото персонажа: уменьшенный JPEG в base64; null — буква имени.
  final String? avatar;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'race': race.name,
    'sex': sex.name,
    'avatar': ?avatar,
  };

  /// [avatar] заменяет фото целиком: передайте текущее, чтобы оставить его.
  Profile copyWith({
    String? name,
    Race? race,
    Sex? sex,
    required String? avatar,
  }) => Profile(
    id: id,
    name: name ?? this.name,
    race: race ?? this.race,
    sex: sex ?? this.sex,
    avatar: avatar,
  );
}
