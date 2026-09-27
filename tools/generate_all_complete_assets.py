"""
Complete Gothic Asset Generator for GrimSpire
Generates:
1. All 16 unique enemies (13 regular + 3 bosses)
2. Player base body (clean ready stance, unbaked weapons/helms)
3. Modular equipment overlays (Weapons, Helmets, Armors, Offhands)
4. Traversal dungeon props (Archway, Closed & Open Chests)
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

def add_ink_outline(img, outline_color=(15, 12, 18, 255), thickness=3):
    alpha = img.split()[3]
    dilated = alpha.filter(ImageFilter.MaxFilter(thickness * 2 + 1))
    outline = Image.new("RGBA", img.size, outline_color)
    outline.putalpha(dilated)
    return Image.alpha_composite(outline, img)

# ==============================================================================
# 1. PLAYER BASE CHARACTER (Clean stance, 400x600)
# ==============================================================================
def draw_player_base():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Flowing dark tattered traveler's cloak (back layer)
    cloak_back = [
        (160, 220), (120, 360), (90, 520), (130, 500), (160, 530),
        (220, 510), (270, 535), (290, 480), (250, 340), (240, 220)
    ]
    d.polygon(cloak_back, fill=(28, 22, 32, 255))
    
    # Legs in dark leather boots & cloth wraps
    # Left leg
    d.polygon([(170, 360), (150, 480), (140, 550), (165, 555), (185, 480), (195, 360)], fill=(45, 38, 42, 255))
    # Right leg
    d.polygon([(205, 360), (215, 480), (230, 550), (255, 550), (240, 480), (230, 360)], fill=(40, 34, 38, 255))
    # Boot wraps
    for y in [490, 510, 530]:
        d.line([(145, y), (175, y + 4)], fill=(80, 70, 65, 255), width=3)
        d.line([(220, y), (250, y + 4)], fill=(80, 70, 65, 255), width=3)
    
    # Torso: Tattered dark gambeson / tunic with cross-straps
    d.polygon([(160, 200), (240, 200), (250, 370), (150, 370)], fill=(55, 45, 52, 255))
    # Leather belt with iron buckle
    d.rectangle([150, 350, 250, 368], fill=(35, 25, 22, 255))
    d.rectangle([190, 348, 210, 370], fill=(130, 110, 70, 255))
    # Chest straps
    d.line([(165, 210), (235, 340)], fill=(32, 24, 20, 255), width=6)
    d.line([(235, 210), (165, 340)], fill=(32, 24, 20, 255), width=6)
    
    # Left Arm & Hand (Offhand position: holds shield or ready stance)
    # Shoulder to elbow
    d.line([(160, 215), (130, 290)], fill=(50, 40, 48, 255), width=18)
    # Forearm to wrist
    d.line([(130, 290), (145, 335)], fill=(45, 36, 42, 255), width=16)
    # Left fist / grip
    d.ellipse([135, 325, 155, 345], fill=(75, 60, 55, 255))
    
    # Right Arm & Hand (Weapon hand: ready forward grip)
    # Shoulder to elbow
    d.line([(240, 215), (275, 285)], fill=(50, 40, 48, 255), width=18)
    # Forearm to wrist
    d.line([(275, 285), (260, 340)], fill=(45, 36, 42, 255), width=16)
    # Right fist / grip
    d.ellipse([250, 330, 272, 352], fill=(75, 60, 55, 255))
    
    # Neck & Shadowed Head
    d.polygon([(185, 170), (215, 170), (220, 210), (180, 210)], fill=(40, 32, 35, 255))
    # Head cowl base (shadowed face)
    d.ellipse([175, 110, 225, 175], fill=(22, 16, 26, 255))
    # Glowing ethereal cyan eyes piercing through the shadow
    d.ellipse([187, 138, 195, 146], fill=(100, 240, 255, 255))
    d.ellipse([205, 138, 213, 146], fill=(100, 240, 255, 255))
    
    # Front cloak collar & tattered cloth cowl
    cowl_pts = [(165, 185), (200, 225), (235, 185), (225, 170), (175, 170)]
    d.polygon(cowl_pts, fill=(35, 26, 40, 255))
    
    return add_ink_outline(img)

# ==============================================================================
# 2. ALL 16 ENEMIES (Authentic stylized gothic ink monsters)
# ==============================================================================

# 1. Feeble Skeleton (Tier 1, Floor 1)
def draw_enemy_skeleton():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Legs (fragile bones)
    d.line([(175, 360), (165, 470), (155, 550)], fill=(195, 185, 170, 255), width=10)
    d.line([(225, 360), (235, 470), (245, 550)], fill=(195, 185, 170, 255), width=10)
    # Ribcage & Spine
    d.line([(200, 200), (200, 360)], fill=(180, 170, 155, 255), width=14)
    for y in range(220, 340, 20):
        d.arc([160, y, 240, y + 25], start=0, end=180, fill=(210, 200, 185, 255), width=6)
    # Broken iron rusted hip
    d.polygon([(165, 350), (235, 350), (220, 375), (180, 375)], fill=(75, 55, 45, 255))
    # Arms
    d.line([(165, 210), (130, 280), (120, 350)], fill=(190, 180, 165, 255), width=8)
    d.line([(235, 210), (270, 270), (290, 330)], fill=(190, 180, 165, 255), width=8)
    # Cracked iron sword in right hand
    d.line([(290, 330), (330, 180)], fill=(110, 105, 115, 255), width=7)
    d.line([(280, 310), (300, 305)], fill=(160, 130, 60, 255), width=5)
    # Skull
    d.ellipse([175, 120, 225, 185], fill=(215, 205, 190, 255))
    d.polygon([(185, 175), (215, 175), (210, 200), (190, 200)], fill=(200, 190, 175, 255)) # Jaw
    # Hollow eye sockets
    d.ellipse([183, 142, 195, 158], fill=(20, 15, 25, 255))
    d.ellipse([205, 142, 217, 158], fill=(20, 15, 25, 255))
    # Pale yellow ghost light in sockets
    d.ellipse([187, 148, 191, 152], fill=(255, 240, 120, 255))
    d.ellipse([209, 148, 213, 152], fill=(255, 240, 120, 255))
    return add_ink_outline(img)

# 2. Spire Imp (Tier 1, Floors 2-3)
def draw_enemy_imp():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Obsidian bat wings
    for side in [-1, 1]:
        w_pts = [
            (200, 250),
            (200 + side * 170, 160),
            (200 + side * 190, 240),
            (200 + side * 150, 330),
            (200 + side * 110, 370),
            (200, 320)
        ]
        d.polygon(w_pts, fill=(45, 25, 35, 255))
        d.line(w_pts, fill=(180, 50, 70, 255), width=4)
    # Leaping hunched body
    d.ellipse([160, 240, 240, 360], fill=(85, 30, 40, 255))
    # Spindly legs with sharp talons
    d.line([(175, 340), (150, 420), (135, 480)], fill=(65, 25, 35, 255), width=8)
    d.line([(225, 340), (250, 420), (265, 480)], fill=(65, 25, 35, 255), width=8)
    for tx in [135, 265]:
        d.polygon([(tx, 480), (tx - 15, 495), (tx + 15, 495)], fill=(20, 15, 20, 255))
    # Claws outstretched
    d.line([(165, 260), (115, 280), (90, 310)], fill=(75, 25, 35, 255), width=7)
    d.line([(235, 260), (285, 280), (310, 310)], fill=(75, 25, 35, 255), width=7)
    # Horned head
    d.ellipse([170, 160, 230, 240], fill=(95, 35, 45, 255))
    # Obsidian curved horns
    d.line([(180, 175), (145, 120), (130, 130)], fill=(25, 18, 25, 255), width=7)
    d.line([(220, 175), (255, 120), (270, 130)], fill=(25, 18, 25, 255), width=7)
    # Glowing amber devilish eyes & fanged grin
    d.ellipse([182, 190, 194, 202], fill=(255, 200, 30, 255))
    d.ellipse([206, 190, 218, 202], fill=(255, 200, 30, 255))
    d.polygon([(185, 220), (215, 220), (200, 232)], fill=(240, 230, 220, 255))
    return add_ink_outline(img)

# 3. Crypt Ghoul (Tier 1, Floors 3-4)
def draw_enemy_ghoul():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Feral hunchbacked ghoul in earthy olive-grey flesh
    # Legs crouched
    d.polygon([(150, 380), (110, 460), (90, 540), (130, 545), (145, 460), (180, 380)], fill=(65, 60, 50, 255))
    d.polygon([(210, 380), (240, 460), (260, 540), (295, 545), (275, 460), (240, 380)], fill=(60, 55, 45, 255))
    # Hunched spine & necrotic ribs
    d.ellipse([130, 180, 270, 390], fill=(85, 80, 68, 255))
    # Exposed vertebrae along spine
    for y in range(190, 350, 22):
        d.rectangle([135, y, 155, y + 10], fill=(180, 175, 155, 255))
    # Ragged tattered loincloth
    d.polygon([(140, 360), (260, 360), (250, 440), (200, 420), (150, 450)], fill=(35, 30, 25, 255))
    # Forearms with long feral claws
    d.line([(150, 240), (80, 320), (60, 430)], fill=(75, 70, 58, 255), width=12)
    d.line([(250, 240), (320, 320), (340, 430)], fill=(75, 70, 58, 255), width=12)
    for cx in [(55, 435), (65, 440), (75, 435), (335, 435), (345, 440), (355, 435)]:
        d.line([(cx[0], 430), (cx[0], 455)], fill=(20, 18, 15, 255), width=4)
    # Sunken feral head
    d.ellipse([175, 120, 255, 210], fill=(90, 85, 72, 255))
    # Yellow predator eyes
    d.ellipse([215, 145, 227, 157], fill=(230, 240, 40, 255))
    d.ellipse([235, 148, 247, 160], fill=(230, 240, 40, 255))
    # Snarling open maw with needle fangs
    maw = [(200, 175), (250, 175), (240, 205), (205, 200)]
    d.polygon(maw, fill=(25, 15, 18, 255))
    for fx in range(205, 245, 6):
        d.line([(fx, 175), (fx + 2, 184)], fill=(240, 235, 220, 255), width=2)
        d.line([(fx, 202), (fx + 2, 193)], fill=(240, 235, 220, 255), width=2)
    return add_ink_outline(img)

# 4. Tormented Shade (Tier 1, Floor 4)
def draw_enemy_shade():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Swirling dark vapor
    for i in range(20):
        r = random.randint(50, 120)
        cx = random.randint(160, 240)
        cy = random.randint(180, 460)
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(22, 15, 35, 40))
    # Phantom robe & mantle
    torso_pts = [
        (200, 90), (280, 170), (320, 420), (280, 530), (200, 460), (120, 530), (80, 420), (120, 170)
    ]
    d.polygon(torso_pts, fill=(25, 18, 38, 240))
    # Ghostly spectral talons
    d.line([(100, 280), (50, 360), (30, 430)], fill=(80, 60, 110, 255), width=8)
    d.line([(300, 280), (350, 360), (370, 430)], fill=(80, 60, 110, 255), width=8)
    for tip in [(25, 435), (32, 440), (20, 425), (375, 435), (368, 440), (380, 425)]:
        d.line([(tip[0] - 8, tip[1] - 14), tip], fill=(120, 220, 255, 255), width=4)
    # Piercing cyan spectral eyes
    d.ellipse([170, 180, 188, 196], fill=(80, 245, 255, 255))
    d.ellipse([212, 180, 230, 196], fill=(80, 245, 255, 255))
    return add_ink_outline(img)

# 5. Hollow Knight (Tier 2, Floors 5-7)
def draw_enemy_knight():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Rusted gothic full plate armor
    # Legs (greaves)
    d.polygon([(160, 360), (145, 480), (135, 555), (175, 555), (185, 480), (195, 360)], fill=(55, 48, 52, 255))
    d.polygon([(205, 360), (215, 480), (225, 555), (265, 555), (255, 480), (240, 360)], fill=(50, 44, 48, 255))
    # Torso (steel breastplate with rust & crest)
    d.polygon([(140, 190), (260, 190), (250, 370), (150, 370)], fill=(65, 58, 64, 255))
    # Gothic belt & faulds
    d.polygon([(145, 365), (255, 365), (245, 410), (155, 410)], fill=(40, 35, 38, 255))
    # Massive spiked pauldrons
    d.polygon([(110, 170), (155, 185), (140, 240), (95, 210)], fill=(80, 72, 78, 255))
    d.polygon([(290, 170), (245, 185), (260, 240), (305, 210)], fill=(75, 68, 74, 255))
    # Spikes on pauldrons
    d.polygon([(110, 170), (95, 140), (130, 160)], fill=(120, 110, 118, 255))
    d.polygon([(290, 170), (305, 140), (270, 160)], fill=(120, 110, 118, 255))
    # Arms holding broadsword
    d.line([(135, 220), (115, 300), (130, 360)], fill=(60, 52, 58, 255), width=16)
    d.line([(265, 220), (285, 300), (270, 360)], fill=(60, 52, 58, 255), width=16)
    # Gothic iron broadsword held vertical
    d.rectangle([270, 120, 282, 480], fill=(130, 125, 135, 255))
    d.line([(276, 120), (276, 470)], fill=(220, 215, 230, 255), width=3)
    d.polygon([(260, 330), (292, 330), (276, 345)], fill=(160, 120, 50, 255))
    # Greathelm with horned crest
    d.polygon([(160, 105), (240, 105), (235, 185), (165, 185)], fill=(70, 62, 68, 255))
    # Horned crest
    d.polygon([(165, 105), (145, 60), (185, 95)], fill=(100, 90, 98, 255))
    d.polygon([(235, 105), (255, 60), (215, 95)], fill=(100, 90, 98, 255))
    # Menacing horizontal red eye slit
    d.rectangle([175, 142, 225, 150], fill=(15, 10, 18, 255))
    d.rectangle([182, 144, 218, 148], fill=(255, 30, 45, 255))
    return add_ink_outline(img)

# 6. Blood Cultist Zealot (Tier 2, Floors 6-8)
def draw_enemy_cultist():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Long flowing crimson & obsidian ritual robes
    d.polygon([(160, 180), (240, 180), (290, 540), (110, 540)], fill=(85, 18, 28, 255))
    # Gold occult embroidery along hem & front
    d.line([(200, 180), (200, 540)], fill=(210, 160, 50, 255), width=4)
    d.line([(110, 530), (290, 530)], fill=(210, 160, 50, 255), width=6)
    # Deep hood casting face into blackness
    d.polygon([(150, 110), (250, 110), (240, 195), (200, 215), (160, 195)], fill=(45, 12, 18, 255))
    # Glowing blood runes inside hood
    d.ellipse([185, 148, 195, 158], fill=(255, 40, 60, 255))
    d.ellipse([205, 148, 215, 158], fill=(255, 40, 60, 255))
    # Left hand holds glowing Blood Orb
    d.line([(160, 210), (120, 270), (100, 320)], fill=(70, 15, 25, 255), width=12)
    # Floating Blood Orb with outer glow
    for r in range(35, 15, -5):
        d.ellipse([100 - r, 320 - r, 100 + r, 320 + r], fill=(220, 20, 40, 45))
    d.ellipse([85, 305, 115, 335], fill=(255, 50, 70, 255))
    # Right hand holds wavy sacrificial obsidian dagger
    d.line([(240, 210), (270, 270), (290, 330)], fill=(70, 15, 25, 255), width=12)
    d.line([(290, 330), (340, 230)], fill=(30, 20, 35, 255), width=7)
    d.line([(290, 330), (340, 230)], fill=(240, 30, 50, 255), width=3)
    return add_ink_outline(img)

# 7. Obsidian Sentry Gargoyle (Tier 2, Floors 8-9)
def draw_enemy_obsidian_gargoyle():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Massive stone bat-wings with cracked rock veins
    for side in [-1, 1]:
        w = [
            (200, 230),
            (200 + side * 185, 120),
            (200 + side * 195, 220),
            (200 + side * 165, 320),
            (200 + side * 120, 390),
            (200, 320)
        ]
        d.polygon(w, fill=(50, 48, 55, 255))
        d.line(w, fill=(110, 105, 120, 255), width=4)
        # Cracked stone texture
        d.line([(200 + side * 100, 240), (200 + side * 150, 220)], fill=(30, 28, 35, 255), width=3)
    # Muscular gargoyle torso
    d.polygon([(150, 200), (250, 200), (240, 370), (160, 370)], fill=(65, 62, 70, 255))
    # Living rock claws
    d.line([(150, 220), (105, 290), (95, 380)], fill=(55, 52, 60, 255), width=14)
    d.line([(250, 220), (295, 290), (305, 380)], fill=(55, 52, 60, 255), width=14)
    for cx in [(90, 390), (95, 395), (100, 390), (300, 390), (305, 395), (310, 390)]:
        d.polygon([(cx[0], 375), (cx[0] - 5, 400), (cx[0] + 5, 400)], fill=(20, 18, 22, 255))
    # Crouched stone hind legs
    d.polygon([(160, 370), (130, 470), (120, 545), (160, 545), (180, 470)], fill=(55, 52, 60, 255))
    d.polygon([(240, 370), (270, 470), (280, 545), (240, 545), (220, 470)], fill=(50, 48, 55, 255))
    # Horned gargoyle head
    d.polygon([(165, 120), (235, 120), (225, 200), (175, 200)], fill=(75, 72, 80, 255))
    # Massive obsidian curved horns
    d.line([(175, 130), (135, 65), (115, 80)], fill=(30, 28, 35, 255), width=9)
    d.line([(225, 130), (265, 65), (285, 80)], fill=(30, 28, 35, 255), width=9)
    # Glowing amber stone eyes
    d.ellipse([180, 150, 192, 162], fill=(255, 170, 30, 255))
    d.ellipse([208, 150, 220, 162], fill=(255, 170, 30, 255))
    return add_ink_outline(img)

# 8. Rotting Plague Abomination (Miniboss Floor 9)
def draw_enemy_plague_abomination():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Bloated grotesque necrotic juggernaut
    # Massive trunk legs
    d.polygon([(130, 390), (110, 540), (170, 550), (180, 420)], fill=(60, 75, 55, 255))
    d.polygon([(220, 420), (230, 550), (290, 540), (270, 390)], fill=(55, 70, 50, 255))
    # Enormous bloated belly dripping bile
    d.ellipse([100, 180, 300, 440], fill=(75, 95, 65, 255))
    # Stitches across belly
    d.line([(140, 280), (260, 340)], fill=(25, 35, 20, 255), width=4)
    for i in range(7):
        px = 145 + i * 16
        py = 282 + i * 8
        d.line([(px - 6, py + 8), (px + 6, py - 8)], fill=(190, 180, 150, 255), width=3)
    # Toxic glowing green pustules
    pustules = [(140, 230, 16), (250, 260, 20), (180, 370, 18), (240, 380, 14), (160, 330, 12)]
    for (px, py, pr) in pustules:
        d.ellipse([px - pr, py - pr, px + pr, py + pr], fill=(140, 240, 40, 220))
        d.ellipse([px - pr//2, py - pr//2, px, py], fill=(220, 255, 120, 255))
    # Massive club arm (left)
    d.line([(130, 220), (70, 320), (50, 440)], fill=(65, 80, 55, 255), width=24)
    # Rotting bone club (right)
    d.line([(270, 220), (330, 310), (350, 420)], fill=(65, 80, 55, 255), width=20)
    d.ellipse([335, 390, 380, 460], fill=(160, 150, 130, 255)) # Bone mallet
    # Cyclopean deformed head
    d.ellipse([160, 100, 240, 190], fill=(80, 100, 70, 255))
    # Single giant sickly yellow eye
    d.ellipse([185, 125, 215, 155], fill=(240, 230, 40, 255))
    d.ellipse([195, 135, 205, 145], fill=(40, 15, 15, 255))
    # Gaping toothy lower jaw
    d.polygon([(170, 165), (230, 165), (215, 195), (185, 195)], fill=(30, 20, 25, 255))
    return add_ink_outline(img)

# 9. Boss Floor 10: Gargoyle Overseer Malgorath (450x650)
def draw_boss_malgorath():
    img = Image.new("RGBA", (450, 650), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Colossal gothic stone demon boss
    # Colossal spread wings
    for side in [-1, 1]:
        w_pts = [
            (225, 260),
            (225 + side * 215, 110),
            (225 + side * 225, 240),
            (225 + side * 185, 380),
            (225 + side * 135, 460),
            (225, 370)
        ]
        d.polygon(w_pts, fill=(45, 25, 30, 255))
        d.line(w_pts, fill=(160, 35, 45, 255), width=6)
    # Massive stony body
    d.polygon([(160, 210), (290, 210), (280, 420), (170, 420)], fill=(60, 45, 52, 255))
    # Colossal legs
    d.polygon([(160, 410), (130, 520), (115, 605), (175, 605), (195, 510)], fill=(50, 38, 44, 255))
    d.polygon([(265, 510), (285, 605), (345, 605), (330, 520), (290, 410)], fill=(45, 34, 40, 255))
    # Huge obsidian talons
    d.line([(160, 230), (100, 330), (80, 440)], fill=(55, 40, 48, 255), width=22)
    d.line([(290, 230), (350, 330), (370, 440)], fill=(55, 40, 48, 255), width=22)
    for cx in [(75, 450), (85, 460), (95, 450), (365, 450), (375, 460), (385, 450)]:
        d.polygon([(cx[0], 435), (cx[0] - 6, 465), (cx[0] + 6, 465)], fill=(18, 12, 16, 255))
    # Horned demonic head
    d.polygon([(175, 120), (275, 120), (265, 220), (185, 220)], fill=(75, 55, 65, 255))
    # Massive sweeping demonic horns
    d.line([(185, 130), (120, 50), (90, 65)], fill=(25, 15, 20, 255), width=14)
    d.line([(265, 130), (330, 50), (360, 65)], fill=(25, 15, 20, 255), width=14)
    # Burning crimson hellfire eyes
    d.ellipse([(195, 155), (213, 173)], fill=(255, 40, 50, 255))
    d.ellipse([(237, 155), (255, 173)], fill=(255, 40, 50, 255))
    return add_ink_outline(img, thickness=4)

# 10. Cursed Inquisitor (Tier 3, Floors 11-13)
def draw_enemy_inquisitor():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Dark fanatical templar in blackened plate & corrupted sacred vestments
    d.polygon([(145, 190), (255, 190), (280, 545), (120, 545)], fill=(35, 30, 40, 255))
    # White tattered tabard with blackened cross
    d.polygon([(165, 190), (235, 190), (245, 520), (155, 520)], fill=(180, 175, 170, 255))
    # Corrupted black cross on tabard
    d.rectangle([193, 230, 207, 430], fill=(25, 15, 25, 255))
    d.rectangle([170, 280, 230, 294], fill=(25, 15, 25, 255))
    # Spiked Iron Halo Crown behind head
    halo_pts = []
    for a in range(0, 180, 15):
        rad = math.radians(a + 180)
        hx = 200 + int(math.cos(rad) * 65)
        hy = 140 + int(math.sin(rad) * 65)
        d.line([(200, 140), (hx, hy)], fill=(210, 160, 40, 255), width=3)
    # Greathelm with cross slit visor
    d.polygon([(170, 110), (230, 110), (225, 185), (175, 185)], fill=(65, 60, 70, 255))
    d.line([(200, 130), (200, 170)], fill=(255, 200, 50, 255), width=3)
    d.line([(185, 145), (215, 145)], fill=(255, 200, 50, 255), width=3)
    # Right arm swings chained burning censer
    d.line([(240, 200), (275, 260), (290, 310)], fill=(50, 45, 55, 255), width=12)
    # Chain & flaming censer
    d.line([(290, 310), (330, 380)], fill=(180, 150, 60, 255), width=3)
    d.polygon([(320, 380), (345, 380), (340, 415), (325, 415)], fill=(90, 75, 45, 255))
    # Unholy fire erupting from censer
    d.ellipse([315, 360, 355, 395], fill=(255, 90, 30, 220))
    d.ellipse([325, 365, 345, 385], fill=(255, 220, 60, 255))
    return add_ink_outline(img)

# 11. Spire Headsman (Tier 3, Floors 14-16)
def draw_enemy_executioner():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Massive muscular executioner brute
    d.rectangle([130, 390, 180, 550], fill=(45, 35, 30, 255))
    d.rectangle([220, 390, 270, 550], fill=(45, 35, 30, 255))
    # Massive broad torso
    d.polygon([(100, 160), (300, 160), (280, 400), (120, 400)], fill=(70, 45, 40, 255))
    # Apron soaked in dark blood
    d.polygon([(130, 230), (270, 230), (260, 460), (140, 460)], fill=(120, 25, 35, 255))
    # Leather executioner hood with slit
    d.polygon([(150, 70), (250, 70), (260, 170), (140, 170)], fill=(25, 20, 25, 255))
    d.rectangle([180, 120, 220, 126], fill=(220, 50, 50, 255))
    # Colossal Guillotine Axe
    d.rectangle([290, 80, 310, 520], fill=(60, 55, 65, 255))
    d.polygon([(305, 80), (395, 110), (395, 300), (305, 330)], fill=(95, 90, 100, 255))
    d.line([(395, 110), (395, 300)], fill=(240, 235, 245, 255), width=6)
    # Blood drips on blade
    d.line([(340, 220), (395, 260)], fill=(180, 20, 30, 255), width=4)
    return add_ink_outline(img)

# 12. Crypt Arch-Lich (Tier 3, Floors 17-19)
def draw_enemy_crypt_lich():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Floating undead sorcerer in tattered amethyst robes
    d.polygon([(150, 180), (250, 180), (310, 530), (200, 480), (90, 530)], fill=(40, 15, 55, 255))
    # Gold & dark runes along robes
    d.line([(200, 180), (200, 480)], fill=(210, 170, 50, 255), width=4)
    # Floating skeletal hands
    d.line([(150, 210), (110, 280), (90, 340)], fill=(180, 170, 150, 255), width=8)
    d.line([(250, 210), (280, 270), (295, 330)], fill=(180, 170, 150, 255), width=8)
    # Left hand holds floating Necrotic Staff
    d.line([(90, 100), (90, 480)], fill=(65, 45, 35, 255), width=6)
    # Bone skull on top of staff
    d.ellipse([75, 75, 105, 105], fill=(200, 190, 175, 255))
    d.ellipse([80, 85, 88, 93], fill=(80, 240, 120, 255)) # Green eye in staff
    # Skull Head of Lich
    d.ellipse([175, 110, 225, 175], fill=(215, 205, 185, 255))
    d.polygon([(185, 165), (215, 165), (210, 190), (190, 190)], fill=(200, 190, 175, 255))
    # Glowing violet soul fires in sockets
    d.ellipse([183, 132, 195, 148], fill=(180, 40, 255, 255))
    d.ellipse([205, 132, 217, 148], fill=(180, 40, 255, 255))
    # Floating ornate spired crown
    crown_pts = [(165, 105), (175, 55), (190, 85), (200, 45), (210, 85), (225, 55), (235, 105)]
    d.polygon(crown_pts, fill=(220, 175, 50, 255))
    return add_ink_outline(img)

# 13. Boss Floor 20: The Flesh Amalgam of Sorrow (480x650)
def draw_boss_amalgam():
    img = Image.new("RGBA", (480, 650), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Lovecraftian mass of fused bodies & weeping faces
    d.ellipse([80, 160, 400, 520], fill=(70, 40, 50, 255))
    # Multiple fused limbs reaching outward
    for (sx, sy, ex, ey) in [(120, 250, 40, 180), (100, 360, 30, 420), (360, 250, 440, 180), (370, 370, 450, 430)]:
        d.line([(sx, sy), (ex, ey)], fill=(60, 35, 45, 255), width=16)
        d.ellipse([ex - 10, ey - 10, ex + 10, ey + 10], fill=(180, 160, 140, 255))
    # Fused weeping faces in flesh
    faces = [(180, 240, 28), (280, 220, 32), (230, 320, 35), (160, 380, 26), (310, 370, 30)]
    for (fx, fy, fr) in faces:
        d.ellipse([fx - fr, fy - fr, fx + fr, fy + fr], fill=(170, 155, 145, 255))
        # Sunken eyes
        d.ellipse([fx - fr//2, fy - 6, fx - fr//4, fy + 4], fill=(20, 10, 15, 255))
        d.ellipse([fx + fr//4, fy - 6, fx + fr//2, fy + 4], fill=(20, 10, 15, 255))
        # Weeping black tears
        d.line([(fx - fr//3, fy), (fx - fr//3, fy + fr)], fill=(15, 10, 15, 255), width=2)
        d.line([(fx + fr//3, fy), (fx + fr//3, fy + fr)], fill=(15, 10, 15, 255), width=2)
        # Screaming open mouth
        d.ellipse([fx - 8, fy + 8, fx + 8, fy + fr - 4], fill=(15, 10, 15, 255))
    return add_ink_outline(img, thickness=4)

# 14. Eldritch Void Stalker (Tier 4, Floors 21-25)
def draw_enemy_void_stalker():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Cosmic shadow horror with writhing tendrils
    # Void body core
    d.ellipse([140, 180, 260, 360], fill=(18, 12, 30, 255))
    # Writhing tentacles
    for a in range(0, 360, 30):
        rad = math.radians(a)
        tx = 200 + int(math.cos(rad) * 140)
        ty = 270 + int(math.sin(rad) * 160)
        d.line([(200, 270), (tx, ty)], fill=(45, 20, 65, 255), width=10)
        d.ellipse([tx - 8, ty - 8, tx + 8, ty + 8], fill=(160, 40, 220, 255))
    # Multiple floating purple void eyes
    eye_pos = [(200, 220, 16), (170, 270, 12), (230, 270, 12), (185, 310, 10), (215, 310, 10)]
    for (ex, ey, er) in eye_pos:
        d.ellipse([ex - er, ey - er, ex + er, ey + er], fill=(180, 50, 255, 255))
        d.ellipse([ex - er//2, ey - er//2, ex + er//2, ey + er//2], fill=(255, 220, 255, 255))
        d.line([(ex, ey - er), (ex, ey + er)], fill=(20, 5, 30, 255), width=2)
    return add_ink_outline(img)

# 15. Infernal Dreadnought (Tier 4, Floors 26-29)
def draw_enemy_infernal_colossus():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Black iron golem fortress with molten lava cracks
    # Piston legs
    d.polygon([(130, 380), (110, 545), (180, 550), (190, 420)], fill=(35, 30, 35, 255))
    d.polygon([(210, 420), (220, 550), (290, 545), (270, 380)], fill=(30, 26, 30, 255))
    # Molten lava cracks in legs
    d.line([(145, 420), (150, 520)], fill=(255, 120, 20, 255), width=4)
    d.line([(255, 420), (250, 520)], fill=(255, 120, 20, 255), width=4)
    # Heavy iron torso with central molten furnace core
    d.polygon([(120, 170), (280, 170), (260, 400), (140, 400)], fill=(45, 40, 45, 255))
    # Furnace grate in chest
    d.rectangle([170, 240, 230, 310], fill=(20, 15, 20, 255))
    d.rectangle([174, 244, 226, 306], fill=(255, 90, 20, 255))
    # Blazing core
    d.ellipse([185, 260, 215, 290], fill=(255, 230, 90, 255))
    for gy in [260, 280]:
        d.line([(170, gy), (230, gy)], fill=(40, 35, 40, 255), width=4)
    # Iron spiked shoulders
    d.polygon([(90, 150), (135, 170), (120, 230), (80, 200)], fill=(55, 50, 55, 255))
    d.polygon([(310, 150), (265, 170), (280, 230), (320, 200)], fill=(50, 46, 50, 255))
    # Spikes
    d.polygon([(90, 150), (65, 110), (115, 135)], fill=(140, 80, 30, 255))
    d.polygon([(310, 150), (335, 110), (285, 135)], fill=(140, 80, 30, 255))
    # Heavy iron head with single glowing horizontal furnace slit
    d.polygon([(160, 90), (240, 90), (230, 165), (170, 165)], fill=(50, 45, 50, 255))
    d.rectangle([175, 125, 225, 135], fill=(255, 140, 30, 255))
    return add_ink_outline(img)

# 16. Boss Floor 30: Valthor the Soul Extinguisher (440x640)
def draw_boss_valthor():
    img = Image.new("RGBA", (440, 640), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Crowned dark lord with 6 spectral wings
    for side in [-1, 1]:
        for ang in [-0.45, 0.0, 0.45]:
            pts = [
                (220, 240),
                (220 + side * 190, 200 + int(ang * 130)),
                (220 + side * 145, 330 + int(ang * 110))
            ]
            d.polygon(pts, fill=(50, 15, 65, 190))
            d.line(pts, fill=(180, 50, 210, 240), width=4)
    # Obsidian plate body
    d.polygon([(155, 140), (285, 140), (270, 450), (170, 450)], fill=(28, 22, 35, 255))
    # Ornate spires crown
    crown_pts = [
        (165, 120), (170, 35), (190, 85), (220, 15), (250, 85), (270, 35), (275, 120)
    ]
    d.polygon(crown_pts, fill=(225, 180, 60, 255))
    d.line(crown_pts, fill=(255, 235, 120, 255), width=4)
    # Void face with magenta soul gaze
    d.polygon([(180, 90), (260, 90), (250, 145), (190, 145)], fill=(12, 6, 18, 255))
    d.ellipse([195, 105, 212, 120], fill=(240, 60, 255, 255))
    d.ellipse([228, 105, 245, 120], fill=(240, 60, 255, 255))
    # Soul Extinguisher Greatsword
    d.rectangle([(105, 70), (120, 530)], fill=(75, 65, 85, 255))
    d.polygon([(95, 70), (130, 70), (120, 15), (105, 15)], fill=(220, 90, 255, 255))
    d.line([(112, 70), (112, 510)], fill=(240, 140, 255, 255), width=5)
    return add_ink_outline(img, thickness=4)

# ==============================================================================
# 3. MODULAR EQUIPMENT OVERLAYS (Aligns with Player Base)
# ==============================================================================

# WEAPONS
def draw_weapon_cleaver():
    img = Image.new("RGBA", (200, 300), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([92, 170, 108, 270], fill=(70, 50, 40, 255))
    d.rectangle([75, 162, 125, 174], fill=(55, 50, 60, 255))
    blade = [(85, 162), (80, 50), (150, 20), (155, 110), (130, 145), (115, 162)]
    d.polygon(blade, fill=(120, 115, 125, 255))
    d.line([(150, 20), (155, 110), (130, 145), (115, 162)], fill=(230, 225, 235, 255), width=4)
    return add_ink_outline(img)

def draw_weapon_axe():
    img = Image.new("RGBA", (220, 320), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([104, 30, 116, 290], fill=(65, 45, 35, 255))
    crescent = [(115, 40), (180, 25), (210, 70), (215, 120), (185, 160), (115, 140)]
    d.polygon(crescent, fill=(85, 80, 90, 255))
    d.line([(180, 25), (210, 70), (215, 120), (185, 160)], fill=(240, 235, 250, 255), width=5)
    d.polygon([(105, 70), (45, 85), (105, 105)], fill=(95, 90, 100, 255))
    return add_ink_outline(img)

def draw_weapon_scythe():
    img = Image.new("RGBA", (260, 360), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([160, 30, 172, 330], fill=(40, 35, 45, 255))
    blade = [
        (170, 35), (130, 20), (70, 40), (25, 90), (15, 145), (18, 160),
        (35, 120), (80, 75), (130, 60), (165, 55)
    ]
    d.polygon(blade, fill=(180, 25, 45, 255))
    d.line([(170, 35), (130, 20), (70, 40), (25, 90), (15, 145)], fill=(255, 100, 120, 255), width=4)
    return add_ink_outline(img)

def draw_weapon_greatsword():
    img = Image.new("RGBA", (200, 340), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([94, 220, 106, 300], fill=(50, 40, 45, 255))
    guard = [(50, 225), (150, 225), (145, 235), (55, 235)]
    d.polygon(guard, fill=(190, 150, 60, 255))
    blade = [(84, 215), (86, 35), (100, 10), (114, 35), (116, 215)]
    d.polygon(blade, fill=(135, 140, 150, 255))
    d.line([(100, 210), (100, 40)], fill=(120, 210, 255, 240), width=4)
    return add_ink_outline(img)

def draw_weapon_dagger():
    img = Image.new("RGBA", (140, 220), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([66, 130, 74, 185], fill=(30, 25, 35, 255))
    d.rectangle([52, 125, 88, 132], fill=(80, 60, 90, 255))
    blade = [(65, 125), (63, 50), (70, 20), (77, 50), (75, 125)]
    d.polygon(blade, fill=(55, 50, 60, 255))
    d.line([(63, 50), (70, 20), (77, 50)], fill=(180, 90, 255, 255), width=3)
    return add_ink_outline(img)

def draw_weapon_mace():
    img = Image.new("RGBA", (200, 300), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle([94, 120, 106, 280], fill=(55, 45, 40, 255))
    # Flanged head
    d.polygon([(80, 50), (120, 50), (135, 80), (120, 115), (80, 115), (65, 80)], fill=(100, 95, 105, 255))
    # Spikes
    for sp in [(100, 30), (50, 80), (150, 80), (100, 130)]:
        d.polygon([(95, 75), sp, (105, 75)], fill=(150, 145, 155, 255))
    return add_ink_outline(img)

# HELMETS
def draw_helm_sallet():
    img = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pts = [(45, 90), (60, 45), (100, 25), (140, 45), (155, 90), (150, 140), (100, 155), (50, 140)]
    d.polygon(pts, fill=(90, 85, 95, 255))
    d.rectangle([65, 85, 135, 95], fill=(15, 12, 18, 255))
    d.line([(70, 88), (130, 88)], fill=(160, 220, 255, 255), width=2)
    return add_ink_outline(img)

def draw_helm_crown_thorns():
    img = Image.new("RGBA", (200, 180), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([45, 80, 155, 115], fill=(0, 0, 0, 0))
    d.arc([45, 80, 155, 115], start=0, end=360, fill=(180, 140, 50, 255), width=8)
    spikes = [(55, 75), (70, 40), (100, 30), (130, 40), (145, 75)]
    for sp in spikes:
        d.polygon([(sp[0] - 8, sp[1] + 25), sp, (sp[0] + 8, sp[1] + 25)], fill=(225, 180, 60, 255))
    return add_ink_outline(img)

def draw_helm_hood():
    img = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pts = [(40, 160), (55, 70), (100, 30), (145, 70), (160, 160), (135, 175), (65, 175)]
    d.polygon(pts, fill=(35, 25, 38, 255))
    d.polygon([(65, 85), (135, 85), (125, 155), (75, 155)], fill=(12, 8, 15, 255))
    return add_ink_outline(img)

def draw_helm_inquisitor():
    img = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.polygon([(50, 40), (150, 40), (145, 155), (55, 155)], fill=(65, 60, 70, 255))
    d.line([(100, 70), (100, 130)], fill=(240, 180, 40, 255), width=4)
    d.line([(75, 95), (125, 95)], fill=(240, 180, 40, 255), width=4)
    return add_ink_outline(img)

# ARMORS
def draw_armor_carapace():
    img = Image.new("RGBA", (240, 260), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.polygon([(50, 50), (190, 50), (180, 220), (60, 220)], fill=(50, 40, 35, 255))
    for y in range(70, 200, 25):
        d.arc([60, y, 180, y + 25], start=0, end=180, fill=(210, 200, 180, 255), width=7)
    d.polygon([(50, 45), (30, 25), (70, 35)], fill=(200, 190, 170, 255))
    d.polygon([(190, 45), (210, 25), (170, 35)], fill=(200, 190, 170, 255))
    return add_ink_outline(img)

def draw_armor_cuirass():
    img = Image.new("RGBA", (240, 260), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pts = [(55, 45), (185, 45), (180, 230), (120, 245), (60, 230)]
    d.polygon(pts, fill=(90, 85, 95, 255))
    d.line([(120, 45), (120, 240)], fill=(160, 155, 170, 255), width=4)
    d.arc([70, 70, 170, 160], start=0, end=180, fill=(130, 125, 140, 255), width=4)
    return add_ink_outline(img)

def draw_armor_robes():
    img = Image.new("RGBA", (240, 260), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.polygon([(60, 45), (180, 45), (200, 240), (40, 240)], fill=(45, 18, 30, 255))
    d.line([(120, 45), (120, 240)], fill=(210, 165, 45, 255), width=4)
    return add_ink_outline(img)

# SHIELDS / OFFHANDS
def draw_shield_weeping():
    img = Image.new("RGBA", (200, 260), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    kite = [(35, 40), (165, 40), (155, 170), (100, 240), (45, 170)]
    d.polygon(kite, fill=(75, 70, 80, 255))
    d.ellipse([70, 90, 130, 150], fill=(50, 45, 55, 255))
    d.ellipse([80, 105, 92, 117], fill=(130, 210, 255, 255))
    d.ellipse([108, 105, 120, 117], fill=(130, 210, 255, 255))
    d.line([(86, 117), (86, 140)], fill=(120, 200, 255, 255), width=2)
    d.line([(114, 117), (114, 140)], fill=(120, 200, 255, 255), width=2)
    return add_ink_outline(img)

def draw_offhand_grimoire():
    img = Image.new("RGBA", (180, 220), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.polygon([(40, 40), (145, 25), (150, 185), (45, 200)], fill=(75, 20, 35, 255))
    d.polygon([(45, 45), (140, 32), (145, 180), (50, 192)], fill=(190, 175, 145, 255))
    d.ellipse([80, 90, 110, 120], fill=(220, 40, 60, 255))
    return add_ink_outline(img)

def draw_offhand_buckler():
    img = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([30, 30, 170, 170], fill=(85, 80, 90, 255))
    d.ellipse([70, 70, 130, 130], fill=(160, 155, 165, 255))
    d.ellipse([90, 90, 110, 110], fill=(40, 35, 45, 255))
    return add_ink_outline(img)

# ==============================================================================
# 4. DUNGEON PROPS (Gothic Archway, Closed & Open Chests)
# ==============================================================================
def draw_dungeon_archway():
    img = Image.new("RGBA", (320, 520), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Outer stone pillars
    d.rectangle([30, 140, 75, 500], fill=(45, 40, 50, 255))
    d.rectangle([245, 140, 290, 500], fill=(45, 40, 50, 255))
    # Capital blocks
    d.rectangle([20, 130, 85, 150], fill=(65, 60, 72, 255))
    d.rectangle([235, 130, 300, 150], fill=(65, 60, 72, 255))
    # Deep shadowy portal doorway (black depth into darkness)
    d.polygon([(75, 150), (245, 150), (245, 500), (75, 500)], fill=(10, 6, 14, 255))
    d.arc([75, 50, 245, 250], start=180, end=360, fill=(10, 6, 14, 255), width=85)
    # Pointed Gothic Arch stone molding
    d.arc([30, 30, 290, 270], start=180, end=360, fill=(70, 65, 80, 255), width=28)
    # Torch with flame
    d.rectangle([152, 90, 168, 120], fill=(80, 60, 45, 255))
    d.polygon([(160, 60), (145, 95), (175, 95)], fill=(255, 140, 25, 255))
    d.polygon([(160, 70), (152, 95), (168, 95)], fill=(255, 230, 75, 255))
    return add_ink_outline(img)

def draw_treasure_chest_closed():
    img = Image.new("RGBA", (200, 160), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Body
    d.polygon([(30, 70), (170, 70), (160, 145), (40, 145)], fill=(65, 42, 30, 255))
    # Iron bands
    d.rectangle([50, 70, 65, 145], fill=(75, 70, 85, 255))
    d.rectangle([135, 70, 150, 145], fill=(75, 70, 85, 255))
    # Curved Lid closed
    d.polygon([(25, 70), (175, 70), (165, 30), (35, 30)], fill=(80, 52, 38, 255))
    # Skull lock
    d.ellipse([90, 70, 110, 92], fill=(210, 200, 185, 255))
    return add_ink_outline(img)

def draw_treasure_chest_open():
    img = Image.new("RGBA", (200, 160), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Base
    d.polygon([(30, 75), (170, 75), (160, 145), (40, 145)], fill=(65, 42, 30, 255))
    # Iron bands
    d.rectangle([50, 75, 65, 145], fill=(75, 70, 85, 255))
    d.rectangle([135, 75, 150, 145], fill=(75, 70, 85, 255))
    # Open lid tilted backward
    d.polygon([(25, 75), (175, 75), (185, 25), (35, 25)], fill=(85, 55, 40, 255))
    # Golden glow inside chest!
    d.polygon([(35, 45), (165, 45), (155, 75), (45, 75)], fill=(255, 215, 60, 255))
    d.ellipse([60, 48, 140, 72], fill=(255, 250, 180, 255))
    return add_ink_outline(img)

def main():
    print(">>> 1. Generating Player Base Body...")
    draw_player_base().save(os.path.join(TEX_DIR, "player_wanderer.png"))
    
    print(">>> 2. Generating ALL 16 Unique Enemies...")
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
    
    print(">>> 3. Generating Modular Equipment Overlays...")
    draw_weapon_cleaver().save(os.path.join(GEAR_DIR, "weapon_cleaver.png"))
    draw_weapon_axe().save(os.path.join(GEAR_DIR, "weapon_axe.png"))
    draw_weapon_scythe().save(os.path.join(GEAR_DIR, "weapon_scythe.png"))
    draw_weapon_greatsword().save(os.path.join(GEAR_DIR, "weapon_greatsword.png"))
    draw_weapon_dagger().save(os.path.join(GEAR_DIR, "weapon_dagger.png"))
    draw_weapon_mace().save(os.path.join(GEAR_DIR, "weapon_mace.png"))
    
    draw_helm_sallet().save(os.path.join(GEAR_DIR, "helm_sallet.png"))
    draw_helm_crown_thorns().save(os.path.join(GEAR_DIR, "helm_crown_thorns.png"))
    draw_helm_hood().save(os.path.join(GEAR_DIR, "helm_hood.png"))
    draw_helm_inquisitor().save(os.path.join(GEAR_DIR, "helm_inquisitor.png"))
    
    draw_armor_carapace().save(os.path.join(GEAR_DIR, "armor_carapace.png"))
    draw_armor_cuirass().save(os.path.join(GEAR_DIR, "armor_cuirass.png"))
    draw_armor_robes().save(os.path.join(GEAR_DIR, "armor_robes.png"))
    
    draw_shield_weeping().save(os.path.join(GEAR_DIR, "offhand_weeping.png"))
    draw_offhand_grimoire().save(os.path.join(GEAR_DIR, "offhand_grimoire.png"))
    draw_offhand_buckler().save(os.path.join(GEAR_DIR, "offhand_buckler.png"))
    
    print(">>> 4. Generating Dungeon Props...")
    draw_dungeon_archway().save(os.path.join(UI_DIR, "dungeon_archway.png"))
    draw_treasure_chest_closed().save(os.path.join(UI_DIR, "treasure_chest.png"))
    draw_treasure_chest_open().save(os.path.join(UI_DIR, "treasure_chest_open.png"))
    
    print(">>> ALL 26 COMPLETE GOTHIC ASSETS GENERATED SUCCESSFULLY! <<<")

if __name__ == "__main__":
    main()
