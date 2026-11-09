#!/usr/bin/env python3
"""Материалы для Google Play: скриншоты 1080x1920, значок 512x512 и
картинка для описания (feature graphic) 1024x500.

Композиция как у QuizExcellence и Budget (store/make_store.py там):
заголовок и подзаголовок сверху, кадр в тёмной рамке телефона, акцентная
черта. Палитра — из lib/ui/theme.dart: бирюзовое свечение на тёмном
камне, как у стола зачарования. Шрифт — Roboto, как в самом приложении.

Запуск:  python3 store/make_store.py
"""

import math
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STORE = os.path.join(ROOT, 'store')
RAW = os.path.join(STORE, 'raw')
SHOTS_OUT = os.path.join(STORE, 'screenshots')
ICON = os.path.join(STORE, 'source', 'app_icon_source.png')
FONT_TITLE = os.path.join(STORE, 'fonts', 'Roboto-Bold.ttf')
FONT_TEXT = os.path.join(STORE, 'fonts', 'Roboto-Regular.ttf')
FONT_NAME = os.path.join(STORE, 'fonts', 'RobotoCondensed-Bold.ttf')

PHONE = (1080, 1920)          # 9:16 — требование Google Play к скриншотам
FEATURE = (1024, 500)

# Палитра lib/ui/theme.dart.
ABYSS = (8, 18, 21)           # #081215 — фон приложения
GLOW_TOP = (18, 64, 59)       # #12403B — свечение сверху
GLOW_MID = (11, 34, 38)       # #0B2226
GLOW = (127, 230, 207)        # #7FE6CF — primary
ARCANE = (92, 184, 217)       # #5CB8D9 — secondary
TEXT = (217, 238, 234)        # #D9EEEA
MUTED = (143, 179, 173)       # #8FB3AD — onSurfaceVariant
OUTLINE = (47, 90, 87)        # #2F5A57

# Сырой кадр эмулятора (демо-прохождение, store/demo), заголовок, подзаголовок.
SHOTS = [
    ('01_home.png', 'Весь Скайрим в одном списке',
     'Квесты, секреты, навыки, чары и спутники'),
    ('02_quests.png', 'Сюжет, гильдии и DLC',
     'Dawnguard, Dragonborn и 200+ побочных заданий'),
    ('03_category.png', 'Отмечайте пройденное',
     'Прогресс по каждой ветке — с первого взгляда'),
    ('04_item.png', 'Справка без спойлеров',
     'Где взять, кто выдаёт, советы и развилки'),
    ('05_choices.png', 'Развилки и их последствия',
     'Что закроет ваш выбор — до того, как вы его сделаете'),
    ('06_missables.png', 'Не упустите навсегда',
     'Пункты, которые закрываются по ходу игры'),
    ('07_enchanting.png', 'Все зачарования',
     'Что изучать и что работает на спутнике'),
    ('08_followers.png', '70 спутников',
     'Где найти, на ком жениться и кто бессмертен'),
]

NAME = 'SKYLOG'
SLOGAN = 'Трекер прохождения Skyrim'
CHIPS = ['Квесты', 'Секреты', 'Чары', 'Спутники']

# Сглаживание скруглений: рисуем крупно и уменьшаем.
SS = 4


# ─── фон ──────────────────────────────────────────────────────────────

def scene(size, cy=-0.05, reach=1.15):
    """Фон приложения: тёмный камень с бирюзовым свечением сверху
    (_MagicBackground в lib/ui/theme.dart)."""
    w, h = size
    img = Image.new('RGB', (w, h), ABYSS)
    px = img.load()
    cx, cyy = w / 2, h * cy
    radius = math.hypot(w, h) * 0.5 * reach
    for y in range(h):
        for x in range(0, w, 2):
            t = min(math.hypot(x - cx, y - cyy) / radius, 1.0)
            if t < 0.45:
                k = t / 0.45
                c = tuple(int(GLOW_TOP[i] + (GLOW_MID[i] - GLOW_TOP[i]) * k)
                          for i in range(3))
            else:
                k = (t - 0.45) / 0.55
                c = tuple(int(GLOW_MID[i] + (ABYSS[i] - GLOW_MID[i]) * k)
                          for i in range(3))
            px[x, y] = c
            if x + 1 < w:
                px[x + 1, y] = c
    return img.convert('RGBA')


def sparks(img, seed, count, area=None):
    """Редкие бирюзовые искры, как частицы над столом зачарования."""
    import random
    rnd = random.Random(seed)
    w, h = img.size
    x0, y0, x1, y1 = area or (0, 0, w, h)
    layer = Image.new('RGBA', img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for _ in range(count):
        x, y = rnd.uniform(x0, x1), rnd.uniform(y0, y1)
        r = rnd.uniform(1.2, 3.0)
        d.ellipse([x - r, y - r, x + r, y + r],
                  fill=(*GLOW, int(rnd.uniform(40, 120))))
    return Image.alpha_composite(img, layer.filter(ImageFilter.GaussianBlur(0.8)))


# ─── текст ────────────────────────────────────────────────────────────

def fit(draw, text, max_w, start, path, floor=20):
    """Наибольший кегль, при котором строка влезает в ширину."""
    size = start
    while size > floor:
        font = ImageFont.truetype(path, size)
        if draw.textlength(text, font=font) <= max_w:
            return font
        size -= 2
    return ImageFont.truetype(path, floor)


def glow_text(img, xy, text, font, fill, glow, radius):
    """Текст со свечением — как заголовок в AppBar приложения."""
    layer = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).text(xy, text, font=font, fill=(*glow, 170))
    img = Image.alpha_composite(img, layer.filter(ImageFilter.GaussianBlur(radius)))
    ImageDraw.Draw(img).text(xy, text, font=font, fill=fill)
    return img


# ─── рамка устройства ─────────────────────────────────────────────────

def rounded_mask(w, h, radius):
    big = Image.new('L', (w * SS, h * SS), 0)
    ImageDraw.Draw(big).rounded_rectangle(
        [0, 0, w * SS - 1, h * SS - 1], radius=radius * SS, fill=255)
    return big.resize((w, h), Image.LANCZOS)


def framed(path, target_w, radius, bezel):
    """Скриншот в тёмном корпусе со скруглением, без растяжения."""
    shot = Image.open(path).convert('RGB')
    inner_w = target_w - bezel * 2
    inner_h = round(shot.height * inner_w / shot.width)
    shot = shot.resize((inner_w, inner_h), Image.LANCZOS)

    body_h = inner_h + bezel * 2
    big = Image.new('RGBA', (target_w * SS, body_h * SS), (0, 0, 0, 0))
    ImageDraw.Draw(big).rounded_rectangle(
        [0, 0, target_w * SS - 1, body_h * SS - 1],
        radius=(radius + bezel) * SS,
        fill=(5, 12, 14, 255), outline=(*GLOW, 70), width=2 * SS)
    body = big.resize((target_w, body_h), Image.LANCZOS)
    body.paste(shot, (bezel, bezel), rounded_mask(inner_w, inner_h, radius))
    return body


def make_shot(raw_name, title, subtitle, out_name):
    w, h = PHONE
    img = sparks(scene(PHONE), seed=len(out_name) * 7, count=60,
                 area=(0, 0, w, h * 0.22))
    draw = ImageDraw.Draw(img)

    margin = int(w * 0.07)
    max_w = w - margin * 2

    f_title = fit(draw, title, max_w, int(w * 0.075), FONT_TITLE)
    y = int(h * 0.05)
    tx = (w - draw.textlength(title, font=f_title)) / 2
    img = glow_text(img, (tx, y), title, f_title, TEXT, GLOW, 18)
    draw = ImageDraw.Draw(img)

    f_sub = fit(draw, subtitle, max_w, int(w * 0.037), FONT_TEXT)
    y2 = y + f_title.size + int(h * 0.016)
    draw.text(((w - draw.textlength(subtitle, font=f_sub)) / 2, y2),
              subtitle, font=f_sub, fill=MUTED)

    dash_y = y2 + f_sub.size + int(h * 0.022)
    dash = int(w * 0.042)
    draw.rounded_rectangle([w / 2 - dash, dash_y, w / 2 + dash, dash_y + 8],
                           radius=4, fill=GLOW)

    # Устройство: ширина такая, чтобы кадр целиком влез в остаток высоты.
    top = dash_y + int(h * 0.04)
    bezel = max(10, int(w * 0.013))
    radius = int(w * 0.03)
    src = Image.open(os.path.join(RAW, raw_name))
    avail_h = h - top - int(h * 0.03)
    body_w = min(int(w * 0.74),
                 int((avail_h - bezel * 2) * src.width / src.height) + bezel * 2)
    body = framed(os.path.join(RAW, raw_name), body_w, radius, bezel)
    bx = (w - body_w) // 2

    # Бирюзовый ореол за телефоном и тень под ним.
    halo = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(halo).rounded_rectangle(
        [bx - 10, top - 10, bx + body_w + 10, top + body.height + 10],
        radius=radius + bezel + 10, fill=(*GLOW, 40))
    img = Image.alpha_composite(img, halo.filter(ImageFilter.GaussianBlur(40)))
    shadow = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [bx, top + 18, bx + body_w, top + body.height + 18],
        radius=radius + bezel, fill=(0, 0, 0, 170))
    img = Image.alpha_composite(img, shadow.filter(ImageFilter.GaussianBlur(24)))

    img.alpha_composite(body, (bx, top))
    img.convert('RGB').save(os.path.join(SHOTS_OUT, out_name))
    print('   %-26s %dx%d' % (out_name, w, h))


# ─── значок и feature graphic ─────────────────────────────────────────

def make_icon():
    """Значок стора 512x512 из исходника 1254x1254 (полный квадрат —
    скругление Google Play накладывает сам)."""
    icon = Image.open(ICON).convert('RGB').resize((512, 512), Image.LANCZOS)
    icon.save(os.path.join(STORE, 'icon_512.png'))
    print('   %-26s 512x512' % 'icon_512.png')


def make_feature():
    w, h = FEATURE
    img = sparks(scene(FEATURE, cy=-0.3, reach=1.4), seed=21, count=70)

    size = 300
    ix, iy = 70, (h - size) // 2
    radius = 64

    halo = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(halo).rounded_rectangle(
        [ix - 16, iy - 16, ix + size + 16, iy + size + 16],
        radius=radius + 16, fill=(*GLOW, 80))
    img = Image.alpha_composite(img, halo.filter(ImageFilter.GaussianBlur(34)))

    icon = Image.open(ICON).convert('RGB').resize((size, size), Image.LANCZOS)
    img.paste(icon, (ix, iy), rounded_mask(size, size, radius))
    big = Image.new('RGBA', (size * SS, size * SS), (0, 0, 0, 0))
    ImageDraw.Draw(big).rounded_rectangle(
        [0, 0, size * SS - 1, size * SS - 1], radius=radius * SS,
        outline=(*GLOW, 90), width=3 * SS)
    img.alpha_composite(big.resize((size, size), Image.LANCZOS), (ix, iy))

    draw = ImageDraw.Draw(img)
    tx = ix + size + 56
    avail = w - tx - 50

    f_name = fit(draw, NAME, avail, 104, FONT_NAME)
    f_slog = fit(draw, SLOGAN, avail, 36, FONT_TEXT)
    f_chip = ImageFont.truetype(FONT_TEXT, 22)

    chip_h = 44
    block = f_name.size + 14 + f_slog.size + 30 + chip_h
    ty = (h - block) // 2 - 6

    img = glow_text(img, (tx, ty), NAME, f_name, GLOW, GLOW, 14)
    draw = ImageDraw.Draw(img)
    sy = ty + f_name.size + 14
    draw.text((tx, sy), SLOGAN, font=f_slog, fill=TEXT)

    cy = sy + f_slog.size + 30
    cx = tx
    for chip in CHIPS:
        cw = int(draw.textlength(chip, font=f_chip)) + 32
        if cx + cw > w - 30:
            break
        draw.rounded_rectangle([cx, cy, cx + cw, cy + chip_h], radius=12,
                               fill=(17, 35, 40), outline=OUTLINE, width=2)
        draw.text((cx + 16, cy + (chip_h - f_chip.size) / 2 - 2), chip,
                  font=f_chip, fill=MUTED)
        cx += cw + 10

    img.convert('RGB').save(os.path.join(STORE, 'feature_graphic.png'))
    print('   %-26s %dx%d' % ('feature_graphic.png', w, h))


if __name__ == '__main__':
    os.makedirs(SHOTS_OUT, exist_ok=True)
    print('Скриншоты:')
    for raw, title, sub in SHOTS:
        make_shot(raw, title, sub, raw)
    print('Графика:')
    make_icon()
    make_feature()
    print('Готово:', STORE)
