# SkyLog

SkyLog — трекер прохождения Skyrim на Flutter (Android).

- **Квесты** — основной сюжет, гильдии, Гражданская война, даэдрические задания, Dawnguard, Dragonborn и 200+ побочных; развилки с последствиями и раздел «Не упусти».
- **Справочники** — секреты, навыки, зачарования и спутники.
- **Персонажи** — у каждого свои отметки и выборы.
- **Импорт сохранения** — `.ess` с ПК отмечает пройденные квесты и изученные зачарования.
- Русский и английский язык, работает офлайн.

Контент лежит в `assets/data/*.json` (формат — [assets/data/SCHEMA.md](assets/data/SCHEMA.md)), прогресс хранится локально в SharedPreferences; приложение ничего не собирает и не ходит в сеть.

Политика конфиденциальности: [PRIVACY.md](PRIVACY.md), опубликованная версия — https://pinchukovartur.github.io/SkyLog/privacy-policy.html (GitHub Pages из папки `docs/`).

Материалы для Google Play — в [store/](store/texts.md).

## Сборка

```
flutter build appbundle --release   # для Google Play
flutter build apk --release         # для установки на телефон
```

Release подписывается ключом из `android/key.properties` (в git не попадает); без него — debug-ключом.
