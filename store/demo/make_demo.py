"""Демо-прохождение для скриншотов стора — без реальных данных.

Печатает в stdout FlutterSharedPreferences.xml в base64: три персонажа,
у активного «Рагнара» ~30 % квестов, развилки и часть секретов.
Заливка на эмулятор (нужна debug-сборка, иначе run-as не пустит):

    PKG=com.Pinchukov.skylog
    B64=$(python3 store/demo/make_demo.py ru)      # или en
    adb shell am force-stop $PKG
    adb shell "echo $B64 | base64 -d | run-as $PKG sh -c 'cat > shared_prefs/FlutterSharedPreferences.xml'"
    adb shell am start -n $PKG/com.skylog.skylog.MainActivity

Строка состояния — demo-режим SystemUI (9:30, без уведомлений):
    adb shell settings put global sysui_demo_allowed 1
    adb shell am broadcast -a com.android.systemui.demo -e command enter
    adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0930
    adb shell am broadcast -a com.android.systemui.demo -e command network -e mobile hide
    adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false
"""
import json, sys, html, base64
import os
ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'assets', 'data')
idx = json.load(open(f'{ROOT}/index.json'))
items = {}
for c in idx:
    d = json.load(open(f'{ROOT}/{c}.json'))
    items[c] = [it['id'] for g in d['groups'] for it in g['items']]
# сколько отмечено в каждой категории (с начала списка)
take = {'main': 14, 'civil_war': 9, 'companions': 20, 'college': 11, 'thieves': 7,
        'dark_brotherhood': 4, 'daedric': 7, 'dawnguard': 0, 'dragonborn': 0,
        'side': 0, 'missables': 9, 'secrets': 0, 'skills': 6, 'enchanting': 31, 'followers': 0}
done = []
for c, n in take.items():
    done += items[c][:n]
# побочные и секреты — вразброс, а не первые N подряд
done += items['side'][::3]
done += items['secrets'][::4]
done += items['followers'][::7]
choices = {'main_unbound_side': 'ralof', 'civil_war_side': 'stormcloaks',
           'companions_lycanthropy_cure': 'stay_werewolf',
           'daedric_the_black_star_choice': 'azura',
           'daedric_a_daedras_best_friend_choice': 'spare_barbas',
           'side_in_my_time_of_need_choice': 'saadia',
           'side_a_lovely_letter_choice': 'faendal'}
profiles = [
    {'id': 'p1', 'name': 'Рагнар', 'race': 'nord', 'sex': 'male'},
    {'id': 'p2', 'name': 'Ингрид', 'race': 'breton', 'sex': 'female'},
    {'id': 'p3', 'name': "Дж'Зар", 'race': 'khajiit', 'sex': 'male'},
]
p2 = items['main'][:5] + items['college'] + items['enchanting'][:40]
p3 = items['main'][:3] + items['thieves'][:20] + items['dark_brotherhood'][:10]
LIST = 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!'
lang = sys.argv[1] if len(sys.argv) > 1 else 'ru'
if lang == 'en':
    profiles[0]['name'] = 'Ragnar'; profiles[1]['name'] = 'Ingrid'; profiles[2]['name'] = "J'Zar"
kv = {'flutter.lang': lang, 'flutter.active_profile': 'p1',
      'flutter.profiles': json.dumps(profiles, ensure_ascii=False),
      'flutter.done:p1': LIST + json.dumps(done), 'flutter.choices:p1': json.dumps(choices),
      'flutter.done:p2': LIST + json.dumps(p2), 'flutter.choices:p2': '{}',
      'flutter.done:p3': LIST + json.dumps(p3), 'flutter.choices:p3': '{}'}
xml = "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>\n<map>\n" + ''.join(
    f'    <string name="{k}">{html.escape(v, quote=True)}</string>\n' for k, v in kv.items()) + '</map>\n'
sys.stdout.write(base64.b64encode(xml.encode()).decode())
print(len(done), file=sys.stderr)
