# SkyLog — материалы для Google Play

Пакет: `com.Pinchukov.skylog`.

Политика конфиденциальности (ссылка для Google Play):
https://pinchukovartur.github.io/SkyLog/privacy-policy.html

Картинки собирает `python3 store/make_store.py`. Подписи к скриншотам — в
`SHOTS` там же. Кадры снимаются с эмулятора debug-сборкой на демо-прохождении
(`store/demo/make_demo.py`, там же команды заливки) со строкой состояния в
demo-режиме (9:30).

| Файл | Что это | Требование магазина |
|---|---|---|
| `icon_512.png` | Значок приложения | PNG 512×512, до 1 МБ |
| `feature_graphic.png` | Картинка для описания | PNG/JPEG 1024×500, до 15 МБ |
| `screenshots/01…08_*.png` | Скриншоты телефона, 8 шт. | PNG/JPEG 9:16, стороны 320–3840, до 8 МБ |
| `source/app_icon_source.png` | Исходник иконки 1254×1254 | — |
| `raw/*.png` | Сырые кадры эмулятора 1080×2400 на демо-данных | — |
| `demo/make_demo.py` | Генератор демо-прохождения (без реальных данных) | — |
| `fonts/` | Roboto (Apache 2.0) — шрифт приложения для подписей | — |

## Русский

**Название** (≤30 символов, сейчас 22):
```
SkyLog: трекер квестов
```

**Краткое описание** (≤80 символов, сейчас 74):
```
Квесты, секреты, зачарования и спутники Skyrim: отмечайте всё, что прошли.
```

**Полное описание** (≤4000 символов, сейчас ~2200):
```
SkyLog — трекер прохождения Skyrim. Весь мир игры в одном списке: квесты, секреты, навыки, зачарования и спутники. Отмечайте пройденное, следите за прогрессом и не упускайте то, что закрывается навсегда.

ЧТО ВНУТРИ
• 418 квестов: основной сюжет, Гражданская война, Соратники, Коллегия Винтерхолда, Гильдия воров, Тёмное Братство, даэдрические задания и больше 200 побочных.
• Дополнения Dawnguard и Dragonborn (Солстейм).
• 292 секрета и пасхалки.
• 18 навыков: где учиться и кто тренирует до мастера.
• 68 зачарований: где изучить и работают ли они на спутнике.
• 70 спутников: где найти, как нанять, на ком можно жениться и кто бессмертен.

СПРАВКА БЕЗ СПОЙЛЕРОВ
• У каждого квеста — где он начинается, кто выдаёт, суть в двух словах и практичные советы.
• Подсказки по прохождению спрятаны: откройте, только если застряли.
• Ссылка на интерактивную карту — сразу на нужное место.
• Связанные задания — со статусом, пройдены они или нет.

РАЗВИЛКИ И «НЕ УПУСТИ»
• 30 развилок: за кого бежать из Хелгена, чью сторону принять в войне, что сделать с Партурнаксом. Видно, к чему ведёт каждый вариант.
• Отметили свой выбор — квесты, которые он закрыл, больше не портят прогресс.
• Раздел «Не упусти»: всё, что закрывается навсегда по ходу игры, — пока ещё не поздно.

ПРОГРЕСС И ПЕРСОНАЖИ
• Общий процент прохождения и прогресс по каждой ветке.
• Фильтры «Осталось» и «Готово», метки: повторяемые задания, поручения для тана, DLC.
• Несколько персонажей: у воина, мага и вора — свои отметки и свои выборы.
• Поиск по квестам, местам и NPC.

ИМПОРТ СОХРАНЕНИЯ
• Загрузите сохранение с ПК (.ess) — SkyLog сам найдёт пройденные квесты и изученные зачарования.
• Ничего не применяется без вашего подтверждения.
• Поддерживаются Special Edition и Anniversary Edition, Legendary Edition — экспериментально.

БЕЗ ЛИШНЕГО
• Без рекламы и встроенных покупок.
• Без регистрации: прогресс хранится только на вашем телефоне.
• Работает офлайн.
• Русский и английский язык — названия квестов из официальной локализации.

SkyLog — неофициальное приложение-помощник, созданное фанатом. Оно не связано с Bethesda Softworks, ZeniMax Media и Microsoft и не одобрено ими. The Elder Scrolls и Skyrim — товарные знаки их владельцев.
```

## English

**Title** (≤30 characters, now 21):
```
SkyLog: Quest Tracker
```

**Short description** (≤80 characters, now 75):
```
Skyrim quests, secrets, enchantments and followers: check off what you did.
```

**Full description** (≤4000 characters, now ~2200):
```
SkyLog is a completion tracker for Skyrim. The whole game in one list: quests, secrets, skills, enchantments and followers. Check off what you've done, watch your progress and never miss what closes forever.

WHAT'S INSIDE
• 418 quests: the main story, the Civil War, the Companions, the College of Winterhold, the Thieves Guild, the Dark Brotherhood, Daedric quests and 200+ side quests.
• Dawnguard and Dragonborn (Solstheim).
• 292 secrets and Easter eggs.
• 18 skills: where to learn them and who trains them to master level.
• 68 enchantments: where to learn them and whether they work on followers.
• 70 followers: where to find them, how to recruit them, who can be married and who is essential.

SPOILER-FREE GUIDE
• Every quest shows where it starts, who gives it, what it is about and practical tips.
• Walkthrough hints stay hidden until you tap — only if you're stuck.
• A link to the interactive map, right to the spot.
• Related quests, with their completion status.

CHOICES AND "DON'T MISS"
• 30 key choices: who to follow out of Helgen, which side to take in the war, what to do with Paarthurnax. See where each option leads.
• Mark your choice — quests it locks no longer count against your progress.
• "Don't miss": everything that closes forever as the game goes on, while there's still time.

PROGRESS AND CHARACTERS
• Overall completion and progress for every questline.
• "To do" and "Done" filters, tags for repeatable quests, thane favors and DLC.
• Several characters: your warrior, mage and thief each keep their own marks and choices.
• Search across quests, places and NPCs.

SAVE IMPORT
• Load a PC save (.ess) — SkyLog finds completed quests and learned enchantments for you.
• Nothing is applied until you confirm.
• Special Edition and Anniversary Edition supported; Legendary Edition is experimental.

NOTHING EXTRA
• No ads and no in-app purchases.
• No sign-up: your progress stays on your phone.
• Works offline.
• English and Russian.

SkyLog is an unofficial fan-made companion app. It is not affiliated with or endorsed by Bethesda Softworks, ZeniMax Media or Microsoft. The Elder Scrolls and Skyrim are trademarks of their respective owners.
```

## Чек-лист загрузки в Play Console

- [ ] Скриншоты телефона: `store/screenshots/01…08_*.png` (1080×1920), порядок правильный.
- [ ] Feature graphic: `store/feature_graphic.png` (1024×500).
- [ ] Значок 512×512: `store/icon_512.png`.
- [ ] Политика конфиденциальности: ссылка выше. Перед этим включить GitHub
      Pages: репозиторий → Settings → Pages → Deploy from a branch → `main`,
      папка `/docs`.
- [ ] Data safety: данные не собираются и не передаются (см. `PRIVACY.md`).
- [ ] Реклама: нет. Встроенные покупки: нет.
- [ ] Категория: Books & Reference (или Entertainment). Возрастной рейтинг —
      анкета IARC; в тексте упоминаются убийства и вампиры из игры, но
      насилия в самом приложении нет.
- [ ] Целевая аудитория — 13+ (или 18+): приложение для игроков в Skyrim
      (рейтинг игры M / PEGI 18), не для детей.

## Откуда взяты числа

Всё считается по `assets/data/*.json` (порядок — `index.json`):

| Что | Сколько |
|---|---|
| квестов (`type: quest`) | 418 |
| из них побочных (`side.json`) | 203 |
| пунктов «можно упустить» (`missables.json`) | 27 |
| секретов | 292 |
| навыков | 18 |
| зачарований | 68 |
| спутников | 70 |
| развилок (`choices`) | 30 |
| пунктов с советами / со скрытыми подсказками | 459 / 144 |
| всего пунктов | 894 |

В приложении на главной «Квесты пройдены … /436» — это квесты плюс пункты
«Можно упустить» за вычетом закрытых выбором, поэтому число не совпадает с 418.

## Заметки

- **«Skyrim» в названии нет намеренно.** Google Play отклоняет приложения,
  которые выглядят как официальные (политика об интеллектуальной
  собственности и выдаче себя за другого). В кратком и полном описании
  игра названа — это допустимое описательное упоминание, а в конце стоит
  оговорка о неофициальном статусе. Если модерация всё же придерётся —
  первым убрать «Skyrim» из краткого описания.
- Иконка нарисована с нуля: книга с руной, без логотипа и дракона-символа
  серии.
- Названия квестов — из официальной локализации (в `assets/data` поле
  `title`), это тоже описательное использование.
- Импорт сохранения работает только с ПК-сохранениями: на консолях файлов
  нет. Это сказано и в описании, и на экране импорта.
- «Работает офлайн» — верно: в релизной сборке нет разрешения INTERNET.
  Карта UESP открывается во внешнем браузере.
