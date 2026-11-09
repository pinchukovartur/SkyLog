import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylog/data/repository.dart';
import 'package:skylog/models.dart';
import 'package:skylog/profile.dart';
import 'package:skylog/state/progress.dart';

Repository _repo() => Repository([
  Category.fromJson({
    'id': 'war',
    'title': 'Война',
    'groups': [
      {
        'title': 'Начало',
        'items': [
          {
            'id': 'war_join',
            'title': 'Выбор стороны',
            'choices': [
              {
                'id': 'war_side',
                'question': 'Чья сторона?',
                'options': [
                  {
                    'id': 'empire',
                    'label': 'Легион',
                    'locks': ['war_storm'],
                  },
                  {
                    'id': 'storm',
                    'label': 'Братья Бури',
                    'locks': ['war_legion'],
                  },
                ],
              },
            ],
          },
          {'id': 'war_legion', 'title': 'Квест Легиона'},
          {'id': 'war_storm', 'title': 'Квест Братьев Бури'},
        ],
      },
    ],
  }),
]);

void main() {
  late Repository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = _repo();
  });

  test('отметки сохраняются между запусками', () async {
    final prefs = await SharedPreferences.getInstance();
    Progress(prefs, repo).toggleDone('war_join');

    final reloaded = Progress(prefs, repo);
    expect(reloaded.isDone('war_join'), isTrue);
    expect(reloaded.progressOf(repo.items).done, 1);
  });

  test(
    'выбор закрывает квесты другой стороны и убирает их из прогресса',
    () async {
      final progress = Progress(await SharedPreferences.getInstance(), repo);
      expect(progress.progressOf(repo.items).total, 3);

      progress.choose('war_side', 'empire');
      expect(progress.isLocked('war_storm'), isTrue);
      expect(progress.isLocked('war_legion'), isFalse);
      expect(progress.progressOf(repo.items).total, 2);

      progress.choose('war_side', 'storm');
      expect(progress.isLocked('war_storm'), isFalse);
      expect(progress.isLocked('war_legion'), isTrue);

      progress.choose('war_side', 'storm');
      expect(progress.selectedOption('war_side'), isNull);
      expect(progress.isLocked('war_legion'), isFalse);
    },
  );

  test('сброс очищает всё', () async {
    final prefs = await SharedPreferences.getInstance();
    final progress = Progress(prefs, repo)
      ..toggleDone('war_join')
      ..choose('war_side', 'empire');
    await progress.reset();

    final reloaded = Progress(prefs, repo);
    expect(reloaded.isDone('war_join'), isFalse);
    expect(reloaded.isLocked('war_storm'), isFalse);
  });

  test('у каждого персонажа свой прогресс', () async {
    final prefs = await SharedPreferences.getInstance();
    final progress = Progress(prefs, repo)..toggleDone('war_join');
    final first = progress.active;

    progress.addProfile(name: 'Лидия', race: Race.nord, sex: Sex.female);
    expect(progress.active.name, 'Лидия');
    expect(progress.isDone('war_join'), isFalse);
    progress.choose('war_side', 'empire');

    progress.switchTo(first);
    expect(progress.isDone('war_join'), isTrue);
    expect(progress.isLocked('war_storm'), isFalse);

    final reloaded = Progress(prefs, repo);
    expect(reloaded.profiles.length, 2);
    expect(reloaded.active.id, first.id);
    final lydia = reloaded.profiles.last;
    expect(reloaded.overallOf(lydia).total, 2);
  });

  test('удаление персонажа стирает его прогресс', () async {
    final prefs = await SharedPreferences.getInstance();
    final progress = Progress(prefs, repo);
    expect(() => progress.deleteProfile(progress.active), returnsNormally);
    expect(progress.profiles.length, 1);

    progress.addProfile(name: 'Тень', race: Race.khajiit, sex: Sex.male);
    progress.toggleDone('war_join');
    final shadow = progress.active;
    await progress.deleteProfile(shadow);
    expect(progress.profiles.length, 1);
    expect(progress.active.id, isNot(shadow.id));
    expect(prefs.getStringList('done:${shadow.id}'), isNull);
  });

  test('старый прогресс переносится в первый профиль', () async {
    SharedPreferences.setMockInitialValues({
      'done': ['war_join'],
    });
    final progress = Progress(await SharedPreferences.getInstance(), repo);
    expect(progress.profiles.single.name, 'Довакин');
    expect(progress.isDone('war_join'), isTrue);
  });

  test('ссылка видна с обеих сторон', () {
    final repo = Repository([
      Category.fromJson({
        'id': 'q',
        'title': 'Квесты',
        'groups': [
          {
            'title': '',
            'items': [
              {'id': 'q_house', 'title': 'Дом ужасов'},
            ],
          },
        ],
      }),
      Category.fromJson({
        'id': 's',
        'title': 'Секреты',
        'groups': [
          {
            'title': '',
            'items': [
              {
                'id': 's_chairs',
                'title': 'Стулья',
                'type': 'secret',
                'related': ['q_house', 'missing'],
              },
            ],
          },
        ],
      }),
    ]);
    expect(repo.linked('q_house').single.id, 's_chairs');
    expect(repo.linked('s_chairs').single.id, 'q_house');
  });

  test(
    'язык: ручной выбор, иначе русский только для русской системы',
    () async {
      final prefs = await SharedPreferences.getInstance();
      expect(Progress.resolveLang(prefs, 'ru'), 'ru');
      expect(Progress.resolveLang(prefs, 'de'), 'en');
      await prefs.setString('lang', 'ru');
      expect(Progress.resolveLang(prefs, 'en'), 'ru');
    },
  );

  test('смена языка подгружает данные и сохраняет прогресс', () async {
    final prefs = await SharedPreferences.getInstance();
    final progress = Progress(
      prefs,
      repo,
      lang: 'ru',
      systemLang: 'de',
      loadRepository: (lang) async => repo,
    )..choose('war_side', 'empire');
    expect(progress.lockReason('war_storm'), contains('Закрыто'));

    await progress.setLanguage('en');
    expect(progress.lang, 'en');
    expect(progress.lockReason('war_storm'), startsWith('Locked'));
    expect(progress.isLocked('war_storm'), isTrue);

    await progress.setLanguage('ru');
    await progress.setLanguage(null);
    expect(progress.lang, 'en');
    expect(progress.languageOverride, isNull);
  });

  test('первый персонаж назван на языке системы', () async {
    final progress = Progress(
      await SharedPreferences.getInstance(),
      repo,
      lang: 'en',
    );
    expect(progress.active.name, 'Dovahkiin');
  });

  test('фото персонажа сохраняется и убирается', () async {
    final prefs = await SharedPreferences.getInstance();
    final progress = Progress(prefs, repo)
      ..addProfile(
        name: 'Серана',
        race: Race.nord,
        sex: Sex.female,
        avatar: 'AAAA',
      );
    expect(Progress(prefs, repo).active.avatar, 'AAAA');

    progress.updateProfile(progress.active.copyWith(avatar: null));
    expect(Progress(prefs, repo).active.avatar, isNull);
  });
}
