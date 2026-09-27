"""
Premium Gothic Asset Generator for GrimSpire
Renders rich, shaded, cross-hatched gothic ink sprites for:
1. All 16 distinct enemies
2. Clean modular equipment overlays (weapons, helms, armors, offhands)
3. Dungeon props (Gothic archway, closed & open treasure chests)
"""
import os
import math
import random
from PIL import Image, ImageDraw, ImageFilter, ImageOps, ImageEnhance

BASE_DIR = r"D:\GrimSpire\assets"
GEAR_DIR = os.path.join(BASE_DIR, "gear")
TEX_DIR = os.path.join(BASE_DIR, "textures")
UI_DIR = os.path.join(BASE_DIR, "ui")

os.makedirs(GEAR_DIR, exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)
os.makedirs(UI_DIR, exist_ok=True)

def add_ink_outline(img, outline_color=(18, 14, 22, 255), thickness=4):
    alpha = img.split()[3]
    dilated = alpha.filter(ImageFilter.MaxFilter(thickness * 2 + 1))
    outline = Image.new("RGBA", img.size, outline_color)
    outline.putalpha(dilated)
    result = Image.alpha_composite(outline, img)
    
    # Sharp ink finish
    enhancer = ImageEnhance.Sharpness(result)
    return enhancer.enhance(1.4)

def draw_hatch(draw, x1, y1, x2, y2, color=(25, 20, 30, 180), spacing=8, width=2):
    """Draws gothic ink crosshatching lines for rich texture."""
    dx = x2 - x1
    dy = y2 - y1
    for offset in range(-dx, dy + dx, spacing):
        sx = x1 + offset
        sy = y1
        ex = sx + 25
        ey = sy + 25
        draw.line([(sx, sy), (ex, ey)], fill=color, width=width)

# ==============================================================================
# 1. ALL 16 ENEMIES (Rich shaded gothic dark fantasy art)
# ==============================================================================

# 1. Feeble Skeleton (Tier 1, Floor 1)
def draw_enemy_skeleton():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Tattered rags on shoulders & hips
    d.polygon([(150, 190), (250, 190), (270, 340), (130, 340)], fill=(45, 38, 45, 255))
    d.polygon([(140, 330), (260, 330), (240, 420), (160, 420)], fill=(35, 30, 35, 255))
    # Legs (weathered bones with shading)
    d.line([(175, 380), (165, 470), (155, 550)], fill=(175, 165, 150, 255), width=12)
    d.line([(173, 380), (163, 470), (153, 550)], fill=(215, 205, 190, 255), width=6)
    d.line([(225, 380), (235, 470), (245, 550)], fill=(175, 165, 150, 255), width=12)
    d.line([(227, 380), (237, 470), (247, 550)], fill=(215, 205, 190, 255), width=6)
    # Spine & Ribcage
    d.line([(200, 190), (200, 370)], fill=(160, 150, 135, 255), width=16)
    for i, y in enumerate(range(210, 340, 22)):
        w = 38 - i * 3
        d.arc([200 - w, y, 200 + w, y + 24], start=0, end=180, fill=(210, 200, 185, 255), width=7)
        d.arc([200 - w + 2, y + 2, 200 + w - 2, y + 22], start=0, end=180, fill=(140, 130, 115, 255), width=3)
    # Left Arm with rusted iron buckler
    d.line([(160, 200), (120, 270), (110, 340)], fill=(180, 170, 155, 255), width=9)
    d.ellipse([70, 280, 150, 360], fill=(70, 60, 55, 255))
    d.ellipse([85, 295, 135, 345], fill=(130, 100, 70, 255))
    d.ellipse([100, 310, 120, 330], fill=(40, 35, 35, 255))
    # Right Arm with notched rusted blade
    d.line([(240, 200), (275, 260), (290, 320)], fill=(180, 170, 155, 255), width=9)
    # Rusted notched sword
    d.line([(290, 320), (345, 160)], fill=(130, 125, 135, 255), width=9)
    d.line([(292, 320), (347, 160)], fill=(210, 205, 215, 255), width=4)
    d.line([(275, 305), (305, 298)], fill=(170, 130, 60, 255), width=6)
    # Skull with broken iron helmet
    d.ellipse([170, 110, 230, 180], fill=(215, 205, 190, 255))
    d.polygon([(185, 170), (215, 170), (210, 195), (190, 195)], fill=(190, 180, 165, 255)) # Jaw
    # Broken iron helmet rim
    d.arc([165, 100, 235, 150], start=180, end=360, fill=(75, 65, 60, 255), width=14)
    d.polygon([(165, 120), (235, 120), (230, 135), (170, 135)], fill=(60, 52, 50, 255))
    # Hollow eye sockets with pale cyan ghost lights
    d.ellipse([180, 138, 194, 154], fill=(20, 15, 25, 255))
    d.ellipse([206, 138, 220, 154], fill=(20, 15, 25, 255))
    d.ellipse([185, 143, 189, 149], fill=(120, 240, 255, 255))
    d.ellipse([211, 143, 215, 149], fill=(120, 240, 255, 255))
    return add_ink_outline(img)

# 2. Spire Imp (Tier 1, Floors 2-3)
def draw_enemy_imp():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Demonic bat wings with crimson webbing & veins
    for side in [-1, 1]:
        w_poly = [
            (200, 240),
            (200 + side * 180, 140),
            (200 + side * 195, 230),
            (200 + side * 155, 330),
            (200 + side * 115, 380),
            (200, 310)
        ]
        d.polygon(w_poly, fill=(55, 25, 35, 255))
        d.line(w_poly, fill=(190, 45, 65, 255), width=5)
        # Wing rib bones
        d.line([(200, 240), (200 + side * 180, 140)], fill=(90, 35, 45, 255), width=6)
        d.line([(200, 240), (200 + side * 195, 230)], fill=(90, 35, 45, 255), width=5)
        d.line([(200, 240), (200 + side * 155, 330)], fill=(90, 35, 45, 255), width=5)
    # Crouched demonic body
    d.ellipse([155, 230, 245, 360], fill=(105, 35, 45, 255))
    d.ellipse([165, 240, 235, 350], fill=(135, 45, 55, 255)) # Chest highlight
    # Muscular legs with sharp curved talons
    d.polygon([(170, 330), (145, 410), (130, 490), (160, 495), (180, 420)], fill=(85, 28, 38, 255))
    d.polygon([(230, 330), (255, 410), (270, 490), (240, 495), (220, 420)], fill=(85, 28, 38, 255))
    for tx in [130, 270]:
        d.polygon([(tx, 490), (tx - 18, 510), (tx + 18, 510)], fill=(20, 15, 22, 255))
    # Claws ready to slash
    d.line([(160, 250), (110, 280), (85, 320)], fill=(95, 32, 42, 255), width=10)
    d.line([(240, 250), (290, 280), (315, 320)], fill=(95, 32, 42, 255), width=10)
    for cx in [(80, 325), (85, 332), (90, 325), (310, 325), (315, 332), (320, 325)]:
        d.line([cx, (cx[0], cx[1] + 16)], fill=(20, 15, 22, 255), width=4)
    # Head & Horns
    d.ellipse([165, 140, 235, 230], fill=(115, 38, 48, 255))
    # Curved Obsidian Horns
    d.line([(175, 160), (135, 90), (120, 105)], fill=(30, 20, 25, 255), width=9)
    d.line([(225, 160), (265, 90), (280, 105)], fill=(30, 20, 25, 255), width=9)
    # Glowing sulfur yellow eyes & vicious fanged grin
    d.ellipse([180, 175, 194, 189], fill=(255, 215, 40, 255))
    d.ellipse([206, 175, 220, 189], fill=(255, 215, 40, 255))
    d.ellipse([185, 180, 189, 184], fill=(180, 40, 20, 255))
    d.ellipse([211, 180, 215, 184], fill=(180, 40, 20, 255))
    d.polygon([(185, 205), (215, 205), (200, 218)], fill=(245, 240, 230, 255))
    return add_ink_outline(img)

# 3. Crypt Ghoul (Tier 1, Floors 3-4)
def draw_enemy_ghoul():
    # Use high quality conversion from original ghoul image with transparency
    ghoul_jpg = os.path.join(r"C:\Users\DocSk\.gemini\antigravity-cli\brain\9cd5535f-5678-4ceb-aba5-3c5e3ae1a9be", "enemy_ghoul_1790515943218.jpg")
    if os.path.exists(ghoul_jpg):
        raw = Image.open(ghoul_jpg).convert("RGBA")
        data = raw.getdata()
        new_data = []
        for item in data:
            brightness = (item[0] + item[1] + item[2]) / 3.0
            if brightness > 240:
                alpha = 0
            elif brightness > 220:
                alpha = int((240 - brightness) / 20.0 * 255)
            else:
                alpha = 255
            new_data.append((item[0], item[1], item[2], alpha))
        raw.putdata(new_data)
        bbox = raw.getbbox()
        if bbox:
            cropped = raw.crop(bbox)
            res = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
            scale = min(380.0 / cropped.width, 560.0 / cropped.height)
            nw = int(cropped.width * scale)
            nh = int(cropped.height * scale)
            resized = cropped.resize((nw, nh), Image.Resampling.LANCZOS)
            res.paste(resized, ((400 - nw) // 2, 600 - nh - 10), resized)
            return add_ink_outline(res)
    # Fallback procedural ghoul
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([140, 180, 260, 390], fill=(85, 80, 68, 255))
    return add_ink_outline(img)

# 4. Tormented Shade (Tier 1, Floor 4)
def draw_enemy_shade():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Dark swirling ether mist
    for i in range(25):
        r = random.randint(45, 110)
        cx = random.randint(155, 245)
        cy = random.randint(160, 480)
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(28, 18, 42, 50))
    # Tattered ethereal mantle
    shroud = [
        (200, 80), (275, 160), (320, 380), (280, 520), (240, 470),
        (200, 510), (160, 470), (120, 520), (80, 380), (125, 160)
    ]
    d.polygon(shroud, fill=(35, 22, 50, 250))
    # Inner dark core
    d.polygon([(150, 140), (250, 140), (260, 420), (140, 420)], fill=(18, 10, 28, 255))
    # Ethereal spectral claws
    d.line([(110, 260), (60, 350), (40, 440)], fill=(85, 65, 125, 255), width=10)
    d.line([(290, 260), (340, 350), (360, 440)], fill=(85, 65, 125, 255), width=10)
    for tip in [(35, 445), (42, 452), (28, 435), (365, 445), (358, 452), (372, 435)]:
        d.line([(tip[0] - 8, tip[1] - 16), tip], fill=(130, 230, 255, 255), width=5)
    # Piercing cyan spectral eyes
    d.ellipse([172, 175, 190, 191], fill=(90, 245, 255, 255))
    d.ellipse([210, 175, 228, 191], fill=(90, 245, 255, 255))
    d.ellipse([178, 181, 184, 185], fill=(255, 255, 255, 255))
    d.ellipse([216, 181, 222, 185], fill=(255, 255, 255, 255))
    return add_ink_outline(img)

# 5. Hollow Knight (Tier 2, Floors 5-7)
def draw_enemy_knight():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Gothic steel plate greaves
    d.polygon([(160, 360), (145, 480), (135, 555), (175, 555), (185, 480), (195, 360)], fill=(55, 48, 54, 255))
    d.polygon([(205, 360), (215, 480), (225, 555), (265, 555), (255, 480), (240, 360)], fill=(50, 44, 50, 255))
    # Knee cops
    d.polygon([(140, 440), (180, 440), (175, 465), (145, 465)], fill=(75, 68, 75, 255))
    d.polygon([(220, 440), (260, 440), (255, 465), (225, 465)], fill=(75, 68, 75, 255))
    # Breastplate & Tassets
    d.polygon([(135, 185), (265, 185), (255, 370), (145, 370)], fill=(70, 62, 70, 255))
    d.line([(200, 185), (200, 370)], fill=(120, 110, 120, 255), width=4) # Ridge
    # Spiked gothic pauldrons
    d.polygon([(100, 160), (150, 175), (135, 240), (85, 210)], fill=(90, 80, 90, 255))
    d.polygon([(300, 160), (250, 175), (265, 240), (315, 210)], fill=(85, 75, 85, 255))
    # Pauldron Spikes
    d.polygon([(100, 160), (80, 125), (125, 150)], fill=(140, 130, 140, 255))
    d.polygon([(300, 160), (320, 125), (275, 150)], fill=(140, 130, 140, 255))
    # Arms holding broadsword
    d.line([(130, 210), (110, 290), (125, 350)], fill=(65, 58, 65, 255), width=18)
    d.line([(270, 210), (290, 290), (275, 350)], fill=(65, 58, 65, 255), width=18)
    # Heavy two-handed greatsword
    d.rectangle([272, 90, 286, 490], fill=(145, 140, 152, 255))
    d.line([(279, 90), (279, 480)], fill=(235, 230, 245, 255), width=4)
    d.polygon([(260, 320), (298, 320), (279, 340)], fill=(180, 140, 60, 255)) # Crossguard
    # Horned Greathelm
    d.polygon([(155, 95), (245, 95), (240, 180), (160, 180)], fill=(80, 72, 80, 255))
    # Horned crest
    d.polygon([(160, 95), (135, 45), (185, 85)], fill=(115, 105, 115, 255))
    d.polygon([(240, 95), (265, 45), (215, 85)], fill=(115, 105, 115, 255))
    # Sinister crimson eye slit
    d.rectangle([170, 134, 230, 144], fill=(15, 10, 18, 255))
    d.rectangle([178, 136, 222, 142], fill=(255, 35, 50, 255))
    return add_ink_outline(img)

# 6. Blood Cultist Zealot (Tier 2, Floors 6-8)
def draw_enemy_cultist():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Flowing crimson ritual vestments
    d.polygon([(155, 170), (245, 170), (295, 545), (105, 545)], fill=(95, 18, 28, 255))
    # Dark occult lining
    d.polygon([(170, 170), (230, 170), (240, 545), (160, 545)], fill=(55, 12, 18, 255))
    # Gold embroidered blood sigils down front
    d.line([(200, 170), (200, 545)], fill=(225, 175, 55, 255), width=5)
    d.line([(105, 535), (295, 535)], fill=(225, 175, 55, 255), width=6)
    for y in [240, 310, 380, 450]:
        d.line([(185, y), (215, y)], fill=(225, 175, 55, 255), width=4)
        d.polygon([(200, y - 8), (192, y + 8), (208, y + 8)], fill=(240, 40, 60, 255))
    # Deep hooded cowl
    d.polygon([(145, 95), (255, 95), (245, 190), (200, 215), (155, 190)], fill=(50, 12, 18, 255))
    d.polygon([(165, 120), (235, 120), (225, 180), (175, 180)], fill=(15, 5, 10, 255))
    # Glowing blood eyes
    d.ellipse([180, 140, 194, 154], fill=(255, 30, 50, 255))
    d.ellipse([206, 140, 220, 154], fill=(255, 30, 50, 255))
    # Left hand channels pulsing Blood Orb
    d.line([(155, 195), (115, 260), (95, 315)], fill=(75, 15, 25, 255), width=14)
    for r in range(40, 12, -6):
        d.ellipse([95 - r, 315 - r, 95 + r, 315 + r], fill=(230, 25, 45, 50))
    d.ellipse([80, 300, 110, 330], fill=(255, 60, 80, 255))
    d.ellipse([88, 308, 102, 322], fill=(255, 220, 220, 255))
    # Right hand wields wavy ritual sacrificial dagger
    d.line([(245, 195), (275, 260), (295, 320)], fill=(75, 15, 25, 255), width=14)
    d.line([(295, 320), (350, 210)], fill=(35, 22, 38, 255), width=8)
    d.line([(295, 320), (350, 210)], fill=(255, 40, 65, 255), width=3)
    return add_ink_outline(img)

# 7. Obsidian Sentry Gargoyle (Tier 2, Floors 8-9)
def draw_enemy_obsidian_gargoyle():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Living volcanic stone wings
    for side in [-1, 1]:
        w = [
            (200, 230),
            (200 + side * 185, 110),
            (200 + side * 195, 210),
            (200 + side * 165, 320),
            (200 + side * 120, 390),
            (200, 320)
        ]
        d.polygon(w, fill=(45, 42, 50, 255))
        d.line(w, fill=(120, 115, 130, 255), width=5)
        # Glowing magma cracks in stone wings
        d.line([(200 + side * 90, 220), (200 + side * 150, 190)], fill=(255, 140, 30, 220), width=3)
        d.line([(200 + side * 110, 290), (200 + side * 140, 330)], fill=(255, 140, 30, 220), width=3)
    # Muscular stone torso
    d.polygon([(145, 190), (255, 190), (245, 370), (155, 370)], fill=(60, 58, 68, 255))
    # Stone chest pectorals
    d.arc([155, 205, 200, 255], start=0, end=180, fill=(35, 32, 40, 255), width=4)
    d.arc([200, 205, 245, 255], start=0, end=180, fill=(35, 32, 40, 255), width=4)
    # Hind legs perched on stone ledge
    d.polygon([(155, 370), (125, 470), (110, 545), (155, 545), (175, 470)], fill=(50, 48, 58, 255))
    d.polygon([(245, 370), (275, 470), (290, 545), (245, 545), (225, 470)], fill=(50, 48, 58, 255))
    # Stone talons
    d.line([(145, 210), (95, 280), (85, 370)], fill=(52, 48, 58, 255), width=16)
    d.line([(255, 210), (305, 280), (315, 370)], fill=(52, 48, 58, 255), width=16)
    for tx in [(80, 380), (88, 388), (96, 380), (304, 380), (312, 388), (320, 380)]:
        d.polygon([(tx[0], 365), (tx[0] - 6, 395), (tx[0] + 6, 395)], fill=(20, 18, 24, 255))
    # Gargoyle head with horned brow
    d.polygon([(160, 110), (240, 110), (230, 195), (170, 195)], fill=(75, 72, 82, 255))
    # Curved stone horns
    d.line([(170, 120), (125, 50), (105, 65)], fill=(32, 28, 38, 255), width=11)
    d.line([(230, 120), (275, 50), (295, 65)], fill=(32, 28, 38, 255), width=11)
    # Glowing amber stone eyes
    d.ellipse([176, 140, 190, 154], fill=(255, 180, 30, 255))
    d.ellipse([210, 140, 224, 154], fill=(255, 180, 30, 255))
    return add_ink_outline(img)

# 8. Rotting Plague Abomination (Miniboss Floor 9)
def draw_enemy_plague_abomination():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Swollen decaying flesh (sickly olive green)
    d.polygon([(125, 390), (105, 545), (175, 555), (185, 420)], fill=(55, 70, 50, 255))
    d.polygon([(215, 420), (225, 555), (295, 545), (275, 390)], fill=(50, 65, 45, 255))
    # Massive bloated belly
    d.ellipse([90, 170, 310, 445], fill=(70, 90, 60, 255))
    # Toxic glowing green boils & pustules
    boils = [(135, 220, 20), (255, 250, 24), (180, 375, 22), (245, 385, 18), (155, 335, 16)]
    for (bx, by, br) in boils:
        d.ellipse([bx - br, by - br, bx + br, by + br], fill=(130, 235, 35, 230))
        d.ellipse([bx - br//2, by - br//2, bx, by], fill=(235, 255, 110, 255))
    # Coarse crude stitches
    d.line([(135, 275), (265, 335)], fill=(20, 30, 18, 255), width=5)
    for i in range(8):
        px = 140 + i * 16
        py = 277 + i * 8
        d.line([(px - 7, py + 9), (px + 7, py - 9)], fill=(200, 190, 160, 255), width=4)
    # Massive club arm (left)
    d.line([(125, 210), (65, 310), (45, 435)], fill=(62, 78, 52, 255), width=26)
    # Bone mallet arm (right)
    d.line([(275, 210), (335, 300), (355, 415)], fill=(62, 78, 52, 255), width=22)
    d.ellipse([330, 385, 385, 460], fill=(175, 165, 145, 255))
    # Cyclopean deformed head with giant festering eye
    d.ellipse([155, 90, 245, 185], fill=(75, 95, 65, 255))
    d.ellipse([180, 115, 220, 155], fill=(245, 235, 45, 255))
    d.ellipse([192, 127, 208, 143], fill=(45, 18, 18, 255))
    # Snapping fanged jaw
    d.polygon([(165, 160), (235, 160), (215, 195), (185, 195)], fill=(30, 22, 26, 255))
    for tx in range(175, 225, 8):
        d.line([(tx, 160), (tx + 2, 172)], fill=(235, 230, 215, 255), width=3)
    return add_ink_outline(img)

# 9. Boss Floor 10: Gargoyle Overseer Malgorath (450x650)
def draw_boss_malgorath():
    # Use existing high quality render if present, else procedural
    path = os.path.join(TEX_DIR, "boss_malgorath.png")
    if os.path.exists(path) and os.path.getsize(path) > 50000:
        return Image.open(path)
    img = Image.new("RGBA", (450, 650), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Colossal Wings
    for side in [-1, 1]:
        w = [
            (225, 250), (225 + side * 215, 100), (225 + side * 225, 230),
            (225 + side * 185, 370), (225 + side * 135, 450), (225, 360)
        ]
        d.polygon(w, fill=(48, 26, 32, 255))
        d.line(w, fill=(180, 40, 52, 255), width=6)
    d.polygon([(160, 200), (290, 200), (280, 410), (170, 410)], fill=(65, 48, 55, 255))
    d.polygon([(175, 110), (275, 110), (265, 210), (185, 210)], fill=(80, 58, 68, 255))
    # Massive Horns
    d.line([(185, 120), (120, 40), (90, 55)], fill=(28, 18, 24, 255), width=16)
    d.line([(265, 120), (330, 40), (360, 55)], fill=(28, 18, 24, 255), width=16)
    d.ellipse([(195, 145), (213, 163)], fill=(255, 45, 55, 255))
    d.ellipse([(237, 145), (255, 163)], fill=(255, 45, 55, 255))
    return add_ink_outline(img, thickness=5)

# 10. Cursed Inquisitor (Tier 3, Floors 11-13)
def draw_enemy_inquisitor():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Dark fanatical templar in blackened plate & sacred vestments
    d.polygon([(140, 180), (260, 180), (285, 550), (115, 550)], fill=(38, 32, 44, 255))
    # Ragged ivory tabard with desecrated black iron cross
    d.polygon([(160, 180), (240, 180), (250, 525), (150, 525)], fill=(185, 180, 175, 255))
    d.rectangle([192, 220, 208, 430], fill=(22, 14, 25, 255))
    d.rectangle([165, 275, 235, 291], fill=(22, 14, 25, 255))
    # Spiked Iron Halo Crown radiating behind head
    for a in range(0, 180, 15):
        rad = math.radians(a + 180)
        hx = 200 + int(math.cos(rad) * 70)
        hy = 135 + int(math.sin(rad) * 70)
        d.line([(200, 135), (hx, hy)], fill=(215, 165, 45, 255), width=4)
        d.polygon([(hx - 4, hy - 4), (hx + 4, hy - 4), (hx, hy - 12)], fill=(245, 210, 70, 255))
    # Greathelm with cross slit visor
    d.polygon([(165, 100), (235, 100), (230, 180), (170, 180)], fill=(70, 65, 75, 255))
    d.line([(200, 120), (200, 165)], fill=(255, 205, 50, 255), width=4)
    d.line([(180, 138), (220, 138)], fill=(255, 205, 50, 255), width=4)
    # Right arm swinging chained burning censer
    d.line([(245, 190), (280, 255), (295, 310)], fill=(55, 48, 60, 255), width=14)
    d.line([(295, 310), (335, 385)], fill=(190, 155, 65, 255), width=4)
    # Brazier
    d.polygon([(320, 385), (350, 385), (345, 425), (325, 425)], fill=(100, 80, 50, 255))
    # Blackened unholy fire erupting from censer
    d.ellipse([310, 360, 360, 400], fill=(255, 95, 30, 230))
    d.ellipse([322, 368, 348, 392], fill=(255, 230, 70, 255))
    return add_ink_outline(img)

# 11. Spire Headsman (Tier 3, Floors 14-16)
def draw_enemy_executioner():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([130, 390, 180, 555], fill=(45, 35, 30, 255))
    d.rectangle([220, 390, 270, 555], fill=(45, 35, 30, 255))
    d.polygon([(95, 155), (305, 155), (285, 405), (115, 405)], fill=(75, 48, 42, 255))
    d.polygon([(125, 225), (275, 225), (265, 465), (135, 465)], fill=(125, 25, 35, 255))
    # Leather executioner hood with slit
    d.polygon([(145, 65), (255, 65), (265, 165), (135, 165)], fill=(25, 20, 25, 255))
    d.rectangle([175, 115, 225, 123], fill=(225, 45, 50, 255))
    # Colossal Guillotine Axe
    d.rectangle([290, 70, 312, 530], fill=(65, 60, 70, 255))
    d.polygon([(308, 70), (398, 100), (398, 300), (308, 335)], fill=(105, 100, 110, 255))
    d.line([(398, 100), (398, 300)], fill=(245, 240, 250, 255), width=6)
    d.line([(335, 215), (398, 255)], fill=(190, 20, 30, 255), width=5)
    return add_ink_outline(img)

# 12. Crypt Arch-Lich (Tier 3, Floors 17-19)
def draw_enemy_crypt_lich():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Levitation silhouette in rich imperial purple
    d.polygon([(145, 170), (255, 170), (315, 535), (200, 480), (85, 535)], fill=(45, 15, 62, 255))
    # Gold & dark runes
    d.line([(200, 170), (200, 480)], fill=(220, 175, 55, 255), width=5)
    # Skeletal hands
    d.line([(145, 200), (105, 275), (85, 335)], fill=(190, 180, 165, 255), width=9)
    d.line([(255, 200), (285, 265), (300, 325)], fill=(190, 180, 165, 255), width=9)
    # Necrotic Bone Staff in hand
    d.line([(85, 80), (85, 490)], fill=(70, 50, 40, 255), width=7)
    d.ellipse([70, 55, 100, 85], fill=(210, 200, 185, 255))
    d.ellipse([76, 65, 84, 73], fill=(80, 245, 120, 255)) # Necrotic orb
    # Lich Skull
    d.ellipse([170, 100, 230, 170], fill=(220, 210, 195, 255))
    d.polygon([(182, 155), (218, 155), (212, 185), (188, 185)], fill=(205, 195, 180, 255))
    # Glowing violet soul gaze
    d.ellipse([180, 125, 194, 141], fill=(190, 50, 255, 255))
    d.ellipse([206, 125, 220, 141], fill=(190, 50, 255, 255))
    # Floating ornate crown
    crown_pts = [(160, 95), (170, 45), (188, 75), (200, 35), (212, 75), (230, 45), (240, 95)]
    d.polygon(crown_pts, fill=(230, 180, 50, 255))
    return add_ink_outline(img)

# 13. Boss Floor 20: The Flesh Amalgam of Sorrow (480x650)
def draw_boss_amalgam():
    path = os.path.join(TEX_DIR, "boss_amalgam.png")
    if os.path.exists(path) and os.path.getsize(path) > 50000:
        return Image.open(path)
    img = Image.new("RGBA", (480, 650), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([70, 150, 410, 530], fill=(75, 42, 52, 255))
    for (sx, sy, ex, ey) in [(110, 240, 30, 170), (90, 350, 20, 410), (370, 240, 450, 170), (380, 360, 460, 420)]:
        d.line([(sx, sy), (ex, ey)], fill=(65, 38, 48, 255), width=18)
        d.ellipse([ex - 12, ey - 12, ex + 12, ey + 12], fill=(190, 170, 150, 255))
    faces = [(175, 235, 30), (285, 215, 34), (230, 320, 38), (155, 380, 28), (315, 370, 32)]
    for (fx, fy, fr) in faces:
        d.ellipse([fx - fr, fy - fr, fx + fr, fy + fr], fill=(180, 165, 155, 255))
        d.ellipse([fx - fr//2, fy - 7, fx - fr//4, fy + 4], fill=(20, 10, 15, 255))
        d.ellipse([fx + fr//4, fy - 7, fx + fr//2, fy + 4], fill=(20, 10, 15, 255))
        d.line([(fx - fr//3, fy), (fx - fr//3, fy + fr)], fill=(15, 10, 15, 255), width=2)
        d.line([(fx + fr//3, fy), (fx + fr//3, fy + fr)], fill=(15, 10, 15, 255), width=2)
    return add_ink_outline(img, thickness=5)

# 14. Eldritch Void Stalker (Tier 4, Floors 21-25)
def draw_enemy_void_stalker():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Cosmic void horror core
    d.ellipse([135, 175, 265, 365], fill=(20, 12, 32, 255))
    # Writhing alien tentacles
    for a in range(0, 360, 25):
        rad = math.radians(a)
        tx = 200 + int(math.cos(rad) * 145)
        ty = 270 + int(math.sin(rad) * 165)
        d.line([(200, 270), (tx, ty)], fill=(50, 22, 75, 255), width=11)
        d.ellipse([tx - 9, ty - 9, tx + 9, ty + 9], fill=(175, 45, 235, 255))
    # 5 Glowing cosmic violet eyes
    eyes = [(200, 215, 18), (165, 265, 14), (235, 265, 14), (180, 310, 11), (220, 310, 11)]
    for (ex, ey, er) in eyes:
        d.ellipse([ex - er, ey - er, ex + er, ey + er], fill=(195, 55, 255, 255))
        d.ellipse([ex - er//2, ey - er//2, ex + er//2, ey + er//2], fill=(255, 235, 255, 255))
        d.line([(ex, ey - er), (ex, ey + er)], fill=(25, 8, 38, 255), width=3)
    return add_ink_outline(img)

# 15. Infernal Dreadnought (Tier 4, Floors 26-29)
def draw_enemy_infernal_colossus():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Heavy blackened iron automaton
    d.polygon([(125, 375), (105, 545), (185, 550), (195, 415)], fill=(38, 34, 38, 255))
    d.polygon([(205, 415), (215, 550), (295, 545), (275, 375)], fill=(34, 30, 34, 255))
    # Molten lava cracks
    d.line([(140, 415), (145, 520)], fill=(255, 125, 25, 255), width=5)
    d.line([(260, 415), (255, 520)], fill=(255, 125, 25, 255), width=5)
    # Heavy iron torso with central molten furnace core
    d.polygon([(115, 160), (285, 160), (265, 395), (135, 395)], fill=(48, 42, 48, 255))
    # Furnace grate in chest
    d.rectangle([165, 230, 235, 305], fill=(22, 16, 22, 255))
    d.rectangle([170, 235, 230, 300], fill=(255, 95, 25, 255))
    d.ellipse([182, 250, 218, 285], fill=(255, 235, 95, 255))
    for gy in [250, 275]:
        d.line([(165, gy), (235, gy)], fill=(42, 38, 42, 255), width=5)
    # Spiked heavy shoulders
    d.polygon([(85, 140), (130, 165), (115, 225), (75, 195)], fill=(58, 52, 58, 255))
    d.polygon([(315, 140), (270, 165), (285, 225), (325, 195)], fill=(52, 48, 52, 255))
    d.polygon([(85, 140), (60, 100), (110, 125)], fill=(145, 85, 35, 255))
    d.polygon([(315, 140), (340, 100), (290, 125)], fill=(145, 85, 35, 255))
    # Iron head with glowing horizontal furnace eye slit
    d.polygon([(155, 85), (245, 85), (235, 160), (165, 160)], fill=(52, 48, 52, 255))
    d.rectangle([170, 120, 230, 132], fill=(255, 145, 35, 255))
    return add_ink_outline(img)

# 16. Boss Floor 30: Valthor the Soul Extinguisher (440x640)
def draw_boss_valthor():
    img = Image.new("RGBA", (440, 640), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # 6 Spectral wings of void flame
    for side in [-1, 1]:
        for ang in [-0.45, 0.0, 0.45]:
            pts = [
                (220, 240),
                (220 + side * 190, 200 + int(ang * 130)),
                (220 + side * 145, 330 + int(ang * 110))
            ]
            d.polygon(pts, fill=(52, 16, 68, 200))
            d.line(pts, fill=(195, 55, 225, 240), width=4)
    # Obsidian plate body
    d.polygon([(155, 140), (285, 140), (270, 450), (170, 450)], fill=(30, 24, 38, 255))
    # Spired crown of the Spire Architect
    crown = [(165, 120), (170, 35), (190, 85), (220, 15), (250, 85), (270, 35), (275, 120)]
    d.polygon(crown, fill=(230, 185, 65, 255))
    d.line(crown, fill=(255, 240, 130, 255), width=4)
    # Void face
    d.polygon([(180, 90), (260, 90), (250, 145), (190, 145)], fill=(14, 8, 20, 255))
    d.ellipse([195, 105, 212, 120], fill=(245, 65, 255, 255))
    d.ellipse([228, 105, 245, 120], fill=(245, 65, 255, 255))
    # Colossal Soul Extinguisher Greatsword
    d.rectangle([(105, 70), (120, 530)], fill=(78, 68, 88, 255))
    d.polygon([(95, 70), (130, 70), (120, 15), (105, 15)], fill=(225, 95, 255, 255))
    d.line([(112, 70), (112, 510)], fill=(245, 145, 255, 255), width=5)
    return add_ink_outline(img, thickness=5)

# ==============================================================================
# 2. PROPS (Gothic Archway, Closed & Open Chests)
# ==============================================================================
def draw_dungeon_archway():
    img = Image.new("RGBA", (320, 520), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Stone pillars with masonry blocks
    d.rectangle([25, 130, 75, 510], fill=(42, 38, 48, 255))
    d.rectangle([245, 130, 295, 510], fill=(42, 38, 48, 255))
    for y in range(150, 500, 45):
        d.line([(25, y), (75, y)], fill=(65, 60, 72, 255), width=3)
        d.line([(245, y), (295, y)], fill=(65, 60, 72, 255), width=3)
    # Capital blocks
    d.rectangle([15, 120, 85, 140], fill=(68, 62, 75, 255))
    d.rectangle([235, 120, 305, 140], fill=(68, 62, 75, 255))
    # Deep shadowy portal doorway (black depth into darkness)
    d.polygon([(75, 140), (245, 140), (245, 510), (75, 510)], fill=(8, 5, 12, 255))
    d.arc([75, 40, 245, 240], start=180, end=360, fill=(8, 5, 12, 255), width=90)
    # Pointed Gothic Arch stone molding
    d.arc([25, 20, 295, 260], start=180, end=360, fill=(75, 70, 85, 255), width=30)
    # Torch bracket & torch flame
    d.rectangle([152, 85, 168, 115], fill=(85, 65, 50, 255))
    d.polygon([(160, 50), (142, 90), (178, 90)], fill=(255, 135, 25, 255))
    d.polygon([(160, 60), (150, 90), (170, 90)], fill=(255, 225, 70, 255))
    return add_ink_outline(img)

def draw_treasure_chest_closed():
    img = Image.new("RGBA", (200, 160), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Body
    d.polygon([(30, 65), (170, 65), (160, 145), (40, 145)], fill=(68, 44, 32, 255))
    # Iron bands
    d.rectangle([50, 65, 66, 145], fill=(78, 72, 88, 255))
    d.rectangle([134, 65, 150, 145], fill=(78, 72, 88, 255))
    # Curved Lid closed
    d.polygon([(25, 65), (175, 65), (165, 25), (35, 25)], fill=(82, 54, 40, 255))
    # Skull lock
    d.ellipse([88, 65, 112, 88], fill=(215, 205, 190, 255))
    return add_ink_outline(img)

def draw_treasure_chest_open():
    img = Image.new("RGBA", (200, 160), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Base
    d.polygon([(30, 70), (170, 70), (160, 145), (40, 145)], fill=(68, 44, 32, 255))
    # Iron bands
    d.rectangle([50, 70, 66, 145], fill=(78, 72, 88, 255))
    d.rectangle([134, 70, 150, 145], fill=(78, 72, 88, 255))
    # Open lid tilted backward
    d.polygon([(25, 70), (175, 70), (185, 20), (35, 20)], fill=(88, 58, 42, 255))
    # Golden glow inside chest!
    d.polygon([(35, 40), (165, 40), (155, 70), (45, 70)], fill=(255, 215, 55, 255))
    d.ellipse([55, 42, 145, 68], fill=(255, 250, 185, 255))
    return add_ink_outline(img)

def main():
    print(">>> Generating ALL 16 Enemies with Premium Gothic Inking...")
    draw_enemy_skeleton().save(os.path.join(TEX_DIR, "enemy_skeleton.png"))
    draw_enemy_imp().save(os.path.join(TEX_DIR, "enemy_imp.png"))
    draw_enemy_ghoul().save(os.path.join(TEX_DIR, "enemy_ghoul.png"))
    draw_enemy_shade().save(os.path.join(TEX_DIR, "enemy_shade.png"))
    draw_enemy_knight().save(os.path.join(TEX_DIR, "enemy_knight.png"))
    draw_enemy_cultist().save(os.path.join(TEX_DIR, "enemy_cultist.png"))
    draw_enemy_obsidian_gargoyle().save(os.path.join(TEX_DIR, "enemy_obsidian_gargoyle.png"))
    draw_enemy_plague_abomination().save(os.path.join(TEX_DIR, "enemy_plague_abomination.png"))
    draw_boss_malgorath().save(os.path.join(TEX_DIR, "boss_malgorath.png"))
    draw_enemy_inquisitor().save(os.path.join(TEX_DIR, "enemy_inquisitor.png"))
    draw_enemy_executioner().save(os.path.join(TEX_DIR, "enemy_executioner.png"))
    draw_enemy_crypt_lich().save(os.path.join(TEX_DIR, "enemy_crypt_lich.png"))
    draw_boss_amalgam().save(os.path.join(TEX_DIR, "boss_amalgam.png"))
    draw_enemy_void_stalker().save(os.path.join(TEX_DIR, "enemy_void_stalker.png"))
    draw_enemy_infernal_colossus().save(os.path.join(TEX_DIR, "enemy_infernal_colossus.png"))
    draw_boss_valthor().save(os.path.join(TEX_DIR, "boss_valthor.png"))
    
    print(">>> Generating Dungeon Props...")
    draw_dungeon_archway().save(os.path.join(UI_DIR, "dungeon_archway.png"))
    draw_treasure_chest_closed().save(os.path.join(UI_DIR, "treasure_chest.png"))
    draw_treasure_chest_open().save(os.path.join(UI_DIR, "treasure_chest_open.png"))
    
    print(">>> ALL PREMIUM ASSETS SAVED SUCCESSFULLY! <<<")

if __name__ == "__main__":
    main()
