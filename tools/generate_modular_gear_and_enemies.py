"""
Generates high-quality stylized gothic 2D assets for GrimSpire:
- Modular equipment overlays (Weapons, Helmets, Armor, Shields, Accessories)
- Expanded enemy roster sprites
- Dungeon archway, treasure chests, particle effects
"""
import os
import math
import random
from PIL import Image, ImageDraw, ImageFilter

BASE_DIR = r"D:\GrimSpire\assets"
GEAR_DIR = os.path.join(BASE_DIR, "gear")
TEX_DIR = os.path.join(BASE_DIR, "textures")
UI_DIR = os.path.join(BASE_DIR, "ui")
ICONS_DIR = os.path.join(BASE_DIR, "icons")

os.makedirs(GEAR_DIR, exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)
os.makedirs(UI_DIR, exist_ok=True)
os.makedirs(ICONS_DIR, exist_ok=True)

def add_ink_outline(img, outline_color=(15, 12, 18, 255), thickness=3):
    """Adds a thick gothic ink outline around alpha silhouette."""
    alpha = img.split()[3]
    # Dilate alpha
    dilated = alpha.filter(ImageFilter.MaxFilter(thickness * 2 + 1))
    
    # Create outline image
    outline = Image.new("RGBA", img.size, outline_color)
    outline.putalpha(dilated)
    
    # Composite original on top of outline
    result = Image.alpha_composite(outline, img)
    return result

# ==============================================================================
# 1. WEAPONS (Size 180 x 260)
# ==============================================================================
def draw_cleaver():
    img = Image.new("RGBA", (200, 300), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Handle / Grip
    d.rectangle([92, 180, 108, 270], fill=(70, 50, 40, 255))
    for y in range(190, 260, 12):
        d.line([(90, y), (110, y + 4)], fill=(120, 95, 75, 255), width=2)
    # Pommel
    d.ellipse([88, 265, 112, 285], fill=(45, 42, 48, 255))
    # Crossguard
    d.rectangle([75, 172, 125, 184], fill=(55, 50, 60, 255))
    # Massive heavy blade (notched cleaver)
    blade_poly = [
        (85, 172), (80, 60), (145, 30), (150, 120), (130, 150), (115, 172)
    ]
    d.polygon(blade_poly, fill=(110, 105, 115, 255))
    # Sharp edge highlight
    d.line([(145, 30), (150, 120), (130, 150), (115, 172)], fill=(220, 215, 225, 255), width=4)
    # Rust and notches
    d.polygon([(147, 70), (135, 75), (148, 80)], fill=(0, 0, 0, 0))
    d.polygon([(149, 100), (138, 104), (147, 110)], fill=(0, 0, 0, 0))
    # Rust splotches
    d.ellipse([95, 80, 120, 120], fill=(125, 65, 35, 160))
    d.ellipse([100, 130, 118, 155], fill=(110, 55, 30, 140))
    return add_ink_outline(img)

def draw_axe():
    img = Image.new("RGBA", (220, 320), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Shaft
    d.rectangle([102, 40, 118, 300], fill=(65, 45, 35, 255))
    # Metal reinforcement bands
    for y in [60, 120, 200, 280]:
        d.rectangle([100, y, 120, y + 8], fill=(90, 85, 95, 255))
    # Crescent Executioner Blade
    # Right crescent
    crescent = [
        (115, 50), (170, 35), (200, 75), (205, 125), (180, 165), (115, 145)
    ]
    d.polygon(crescent, fill=(80, 75, 85, 255))
    d.line([(170, 35), (200, 75), (205, 125), (180, 165)], fill=(230, 225, 240, 255), width=5)
    # Left counter-spike
    spike = [(105, 80), (45, 95), (105, 115)]
    d.polygon(spike, fill=(90, 85, 95, 255))
    d.line([(105, 80), (45, 95), (105, 115)], fill=(210, 205, 220, 255), width=3)
    # Dark runes
    d.line([(135, 80), (160, 95), (145, 110)], fill=(180, 40, 60, 220), width=3)
    return add_ink_outline(img)

def draw_scythe():
    img = Image.new("RGBA", (260, 360), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Twisted obsidian staff
    for i in range(40, 340, 4):
        offset = int(math.sin(i * 0.03) * 6)
        d.line([(160 + offset, i), (172 + offset, i)], fill=(35, 30, 40, 255), width=3)
    # Scythe head mount
    d.ellipse([150, 30, 185, 65], fill=(80, 20, 30, 255))
    # Massive curved curved blade sweeping left
    blade_pts = [
        (170, 40), (130, 25), (70, 45), (25, 95), (15, 150), (18, 165),
        (35, 125), (80, 80), (130, 65), (165, 60)
    ]
    d.polygon(blade_pts, fill=(160, 25, 45, 255))
    # Glowing blood edge
    edge_pts = [(170, 40), (130, 25), (70, 45), (25, 95), (15, 150), (18, 165)]
    d.line(edge_pts, fill=(255, 90, 110, 255), width=4)
    # Blood drips
    d.ellipse([20, 170, 28, 182], fill=(220, 20, 40, 230))
    d.ellipse([60, 105, 66, 115], fill=(220, 20, 40, 200))
    return add_ink_outline(img)

def draw_greatsword():
    img = Image.new("RGBA", (200, 340), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Long hilt
    d.rectangle([94, 230, 106, 310], fill=(50, 40, 45, 255))
    # Runic Pommel
    d.ellipse([88, 305, 112, 328], fill=(180, 140, 50, 255))
    # Gothic crossguard with curved quillons
    guard_pts = [(50, 235), (90, 225), (100, 230), (110, 225), (150, 235), (145, 245), (100, 238), (55, 245)]
    d.polygon(guard_pts, fill=(190, 150, 60, 255))
    # Colossal blade with fuller
    blade_pts = [(84, 225), (86, 40), (100, 15), (114, 40), (116, 225)]
    d.polygon(blade_pts, fill=(130, 135, 145, 255))
    # Glowing central fuller
    d.line([(100, 220), (100, 45)], fill=(100, 200, 255, 240), width=4)
    # Razor edge
    d.line([(84, 225), (86, 40), (100, 15), (114, 40), (116, 225)], fill=(240, 245, 255, 255), width=3)
    return add_ink_outline(img)

def draw_dagger():
    img = Image.new("RGBA", (140, 220), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Hilt
    d.rectangle([66, 140, 74, 195], fill=(30, 25, 35, 255))
    d.ellipse([62, 190, 78, 205], fill=(120, 40, 140, 255))
    d.rectangle([52, 135, 88, 142], fill=(80, 60, 90, 255))
    # Curved assassin dagger
    blade_pts = [(65, 135), (63, 60), (70, 25), (77, 60), (75, 135)]
    d.polygon(blade_pts, fill=(50, 45, 55, 255))
    d.line([(63, 60), (70, 25), (77, 60)], fill=(160, 80, 240, 255), width=3)
    # Poison sheen
    d.line([(69, 130), (69, 35)], fill=(80, 230, 120, 220), width=2)
    return add_ink_outline(img)

# ==============================================================================
# 2. HELMETS (Size 180 x 180)
# ==============================================================================
def draw_helm_sallet():
    img = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Dome
    d.ellipse([55, 35, 145, 130], fill=(85, 80, 90, 255))
    # Neck guard swept back
    d.polygon([(55, 95), (35, 145), (70, 135)], fill=(75, 70, 80, 255))
    # Face visor
    d.polygon([(70, 85), (145, 85), (150, 130), (110, 145), (70, 125)], fill=(105, 100, 110, 255))
    # Eye slit (narrow terrifying glow)
    d.rectangle([85, 98, 140, 105], fill=(15, 10, 18, 255))
    d.line([(90, 101), (135, 101)], fill=(100, 220, 255, 240), width=2)
    # Highlights
    d.arc([60, 40, 140, 120], start=190, end=300, fill=(210, 205, 220, 255), width=3)
    return add_ink_outline(img)

def draw_crown_thorns():
    img = Image.new("RGBA", (200, 180), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Circlet base
    d.ellipse([50, 70, 150, 110], outline=(160, 120, 40, 255), width=8)
    # Sharp piercing thorns
    thorns = [
        ((65, 75), (55, 35), (75, 72)),
        ((85, 68), (80, 20), (95, 66)),
        ((105, 66), (105, 15), (115, 67)),
        ((125, 68), (130, 22), (135, 70)),
        ((142, 75), (152, 40), (146, 80)),
        # Downward thorns (piercing head!)
        ((75, 95), (73, 125), (82, 98)),
        ((115, 98), (118, 128), (124, 96))
    ]
    for p1, p2, p3 in thorns:
        d.polygon([p1, p2, p3], fill=(190, 150, 50, 255))
        d.line([p1, p2, p3], fill=(240, 210, 100, 255), width=2)
    # Blood drips on thorns
    d.ellipse([70, 125, 76, 133], fill=(220, 20, 30, 255))
    d.ellipse([116, 128, 122, 136], fill=(220, 20, 30, 255))
    return add_ink_outline(img)

def draw_helm_hood():
    img = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Dark cowl draped over head
    cowl_pts = [
        (100, 20), (145, 45), (160, 110), (145, 170), (55, 170), (40, 110), (55, 45)
    ]
    d.polygon(cowl_pts, fill=(30, 25, 38, 255))
    # Deep shadow inside hood
    shadow_pts = [(65, 65), (135, 65), (130, 135), (100, 150), (70, 135)]
    d.polygon(shadow_pts, fill=(8, 6, 12, 255))
    # Glowing predatory eyes in darkness
    d.ellipse([80, 95, 92, 103], fill=(240, 50, 70, 255))
    d.ellipse([108, 95, 120, 103], fill=(240, 50, 70, 255))
    return add_ink_outline(img)

# ==============================================================================
# 3. ARMOR OVERLAYS (Size 240 x 260)
# ==============================================================================
def draw_armor_carapace():
    img = Image.new("RGBA", (240, 260), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Stitched ribcage breastplate
    # Center sternum
    d.rectangle([112, 50, 128, 200], fill=(210, 200, 180, 255))
    # Left and right ribs
    for i, y in enumerate(range(70, 190, 24)):
        w = 55 - i * 4
        # Left rib
        d.arc([115 - w * 2, y - 10, 118, y + 25], start=270, end=90, fill=(225, 215, 195, 255), width=8)
        # Right rib
        d.arc([122, y - 10, 125 + w * 2, y + 25], start=90, end=270, fill=(225, 215, 195, 255), width=8)
    # Pauldrons (bone horned shoulders)
    d.polygon([(30, 50), (70, 40), (80, 85), (40, 95)], fill=(200, 190, 170, 255))
    d.polygon([(210, 50), (170, 40), (160, 85), (200, 95)], fill=(200, 190, 170, 255))
    # Spikes on pauldrons
    d.polygon([(25, 52), (10, 25), (45, 42)], fill=(220, 210, 190, 255))
    d.polygon([(215, 52), (230, 25), (195, 42)], fill=(220, 210, 190, 255))
    return add_ink_outline(img)

def draw_armor_cuirass():
    img = Image.new("RGBA", (240, 260), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Gothic steel breastplate
    plate_pts = [
        (75, 45), (165, 45), (185, 110), (160, 210), (120, 230), (80, 210), (55, 110)
    ]
    d.polygon(plate_pts, fill=(80, 75, 88, 255))
    # Golden heraldic crest
    d.line([(120, 50), (120, 220)], fill=(180, 140, 50, 255), width=4)
    # Heavy gothic pauldrons
    d.polygon([(35, 40), (80, 35), (90, 90), (45, 105)], fill=(95, 90, 105, 255))
    d.polygon([(205, 40), (160, 35), (150, 90), (195, 105)], fill=(95, 90, 105, 255))
    # Edge highlights
    d.line([(75, 45), (165, 45)], fill=(200, 195, 210, 255), width=4)
    d.line([(55, 110), (80, 210), (120, 230), (160, 210), (185, 110)], fill=(210, 205, 225, 255), width=3)
    return add_ink_outline(img)

# ==============================================================================
# 4. OFFHAND / SHIELDS (Size 180 x 240)
# ==============================================================================
def draw_shield_weeping():
    img = Image.new("RGBA", (200, 260), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Kite shield shape
    shield_pts = [
        (40, 40), (160, 40), (165, 120), (100, 240), (35, 120)
    ]
    d.polygon(shield_pts, fill=(55, 50, 65, 255))
    # Steel rim
    d.line([(40, 40), (160, 40), (165, 120), (100, 240), (35, 120), (40, 40)], fill=(160, 155, 170, 255), width=6)
    # Embossed sorrowful weeping face
    d.ellipse([75, 75, 125, 140], outline=(180, 140, 60, 255), width=4)
    # Weeping tears (glowing blue streams)
    d.line([(88, 105), (85, 180)], fill=(70, 180, 255, 230), width=4)
    d.line([(112, 105), (115, 180)], fill=(70, 180, 255, 230), width=4)
    return add_ink_outline(img)

def draw_offhand_grimoire():
    img = Image.new("RGBA", (180, 220), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Floating occult tome
    # Book covers
    d.polygon([(30, 50), (150, 35), (160, 170), (40, 185)], fill=(65, 20, 35, 255))
    # Pages
    d.polygon([(40, 55), (145, 42), (152, 162), (48, 175)], fill=(215, 200, 170, 255))
    # Eye of Agony on cover
    d.ellipse([70, 85, 120, 130], fill=(20, 10, 15, 255))
    d.ellipse([82, 95, 108, 120], fill=(240, 40, 60, 255))
    d.line([(95, 95), (95, 120)], fill=(10, 5, 10, 255), width=3)
    return add_ink_outline(img)

# ==============================================================================
# 5. EXPANDED ENEMIES (Size 400 x 600)
# ==============================================================================
def draw_enemy_shade():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Swirling shadow vapor
    for i in range(25):
        r = random.randint(60, 150)
        cx = random.randint(150, 250)
        cy = random.randint(180, 450)
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(25, 15, 35, 35))
    # Ghostly hood & ragged mantle
    torso_pts = [
        (200, 100), (280, 180), (310, 420), (280, 520), (200, 460), (120, 520), (90, 420), (120, 180)
    ]
    d.polygon(torso_pts, fill=(18, 12, 28, 220))
    # Long skeletal phantom claws
    d.line([(100, 280), (50, 360), (30, 420)], fill=(70, 50, 90, 255), width=7)
    d.line([(300, 280), (350, 360), (370, 420)], fill=(70, 50, 90, 255), width=7)
    for tip in [(25, 425), (32, 430), (20, 415), (375, 425), (368, 430), (380, 415)]:
        d.line([(tip[0] - 8, tip[1] - 12), tip], fill=(160, 120, 220, 255), width=4)
    # Piercing cyan spectral eyes
    d.ellipse([170, 190, 188, 204], fill=(80, 240, 255, 255))
    d.ellipse([212, 190, 230, 204], fill=(80, 240, 255, 255))
    return add_ink_outline(img)

def draw_enemy_executioner():
    img = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Colossal muscular brute in black leather executioner hood
    # Legs
    d.rectangle([130, 380, 180, 540], fill=(45, 35, 30, 255))
    d.rectangle([220, 380, 270, 540], fill=(45, 35, 30, 255))
    # Massive torso
    d.polygon([(100, 160), (300, 160), (280, 390), (120, 390)], fill=(70, 45, 40, 255))
    # Apron soaked in blood
    d.polygon([(130, 230), (270, 230), (260, 450), (140, 450)], fill=(120, 30, 35, 255))
    # Leather executioner hood with slit
    d.polygon([(150, 70), (250, 70), (260, 170), (140, 170)], fill=(25, 20, 25, 255))
    d.rectangle([180, 120, 220, 126], fill=(220, 50, 50, 255)) # Glowing eye slit
    # Colossal Cleaver in hand
    d.rectangle([290, 100, 310, 500], fill=(60, 55, 65, 255)) # Axe pole
    d.polygon([(305, 100), (385, 120), (395, 280), (305, 320)], fill=(100, 95, 105, 255))
    d.line([(385, 120), (395, 280)], fill=(240, 235, 245, 255), width=5)
    return add_ink_outline(img)

def draw_boss_valthor():
    img = Image.new("RGBA", (440, 640), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Valthor the Soul Extinguisher (Final Boss of Floor 30)
    # Crowned dark lord with 6 spectral wings
    # Wings
    for side in [-1, 1]:
        for ang in [-0.4, 0.0, 0.4]:
            pts = [
                (220, 240),
                (220 + side * 180, 200 + int(ang * 120)),
                (220 + side * 140, 320 + int(ang * 100))
            ]
            d.polygon(pts, fill=(45, 15, 60, 180))
            d.line(pts, fill=(160, 40, 180, 240), width=3)
    # Obsidian plate body
    d.polygon([(160, 140), (280, 140), (265, 440), (175, 440)], fill=(30, 25, 38, 255))
    # Ornate spires crown
    crown_pts = [
        (170, 120), (175, 40), (195, 90), (220, 20), (245, 90), (265, 40), (270, 120)
    ]
    d.polygon(crown_pts, fill=(210, 170, 60, 255))
    d.line(crown_pts, fill=(255, 220, 100, 255), width=3)
    # Void face
    d.polygon([(185, 95), (255, 95), (245, 145), (195, 145)], fill=(10, 5, 15, 255))
    d.ellipse([200, 110, 214, 122], fill=(220, 50, 255, 255))
    d.ellipse([226, 110, 240, 122], fill=(220, 50, 255, 255))
    # Soul Extinguisher Greatsword
    d.rectangle([110, 80, 124, 520], fill=(70, 60, 80, 255))
    d.polygon([(100, 80), (134, 80), (124, 20), (110, 20)], fill=(200, 80, 240, 255))
    d.line([(117, 80), (117, 500)], fill=(220, 120, 255, 255), width=4)
    return add_ink_outline(img)

# ==============================================================================
# 6. DUNGEON ARCHWAY & CHEST (Room Transitions & Loot Draft)
# ==============================================================================
def draw_dungeon_archway():
    img = Image.new("RGBA", (300, 480), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Gothic Stone Archway for room transitions
    # Pillars
    d.rectangle([30, 140, 70, 460], fill=(50, 45, 55, 255))
    d.rectangle([230, 140, 270, 460], fill=(50, 45, 55, 255))
    # Capital blocks
    d.rectangle([20, 130, 80, 150], fill=(70, 65, 78, 255))
    d.rectangle([220, 130, 280, 150], fill=(70, 65, 78, 255))
    # Pointed Gothic Arch
    d.arc([30, 40, 270, 240], start=180, end=360, fill=(75, 70, 85, 255), width=24)
    # Deep shadowy portal interior
    portal_pts = [(70, 150), (230, 150), (230, 460), (70, 460)]
    d.polygon(portal_pts, fill=(12, 8, 16, 255))
    d.arc([70, 60, 230, 220], start=180, end=360, fill=(12, 8, 16, 255), width=80)
    # Torch on archway
    d.ellipse([140, 80, 160, 100], fill=(255, 140, 30, 240))
    return add_ink_outline(img)

def draw_treasure_chest():
    img = Image.new("RGBA", (180, 150), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Dark gothic iron-banded chest
    # Base
    d.polygon([(25, 65), (155, 65), (145, 130), (35, 130)], fill=(65, 42, 30, 255))
    # Iron bands
    d.rectangle([45, 65, 58, 130], fill=(80, 75, 90, 255))
    d.rectangle([122, 65, 135, 130], fill=(80, 75, 90, 255))
    # Open lid glowing with gold inside!
    d.polygon([(20, 65), (160, 65), (170, 25), (30, 25)], fill=(85, 55, 38, 255))
    d.polygon([(30, 35), (150, 35), (145, 65), (35, 65)], fill=(255, 210, 60, 255)) # Gold glow!
    # Skull lock
    d.ellipse([82, 70, 98, 88], fill=(200, 190, 175, 255))
    return add_ink_outline(img)

def main():
    print(">>> Generating Modular Equipment Overlays...")
    draw_cleaver().save(os.path.join(GEAR_DIR, "weapon_cleaver.png"))
    draw_axe().save(os.path.join(GEAR_DIR, "weapon_axe.png"))
    draw_scythe().save(os.path.join(GEAR_DIR, "weapon_scythe.png"))
    draw_greatsword().save(os.path.join(GEAR_DIR, "weapon_greatsword.png"))
    draw_dagger().save(os.path.join(GEAR_DIR, "weapon_dagger.png"))
    
    draw_helm_sallet().save(os.path.join(GEAR_DIR, "helm_sallet.png"))
    draw_crown_thorns().save(os.path.join(GEAR_DIR, "helm_crown_thorns.png"))
    draw_helm_hood().save(os.path.join(GEAR_DIR, "helm_hood.png"))
    
    draw_armor_carapace().save(os.path.join(GEAR_DIR, "armor_carapace.png"))
    draw_armor_cuirass().save(os.path.join(GEAR_DIR, "armor_cuirass.png"))
    
    draw_shield_weeping().save(os.path.join(GEAR_DIR, "offhand_weeping.png"))
    draw_offhand_grimoire().save(os.path.join(GEAR_DIR, "offhand_grimoire.png"))
    
    print(">>> Generating Expanded Enemies...")
    draw_enemy_shade().save(os.path.join(TEX_DIR, "enemy_shade.png"))
    draw_enemy_executioner().save(os.path.join(TEX_DIR, "enemy_executioner.png"))
    draw_boss_valthor().save(os.path.join(TEX_DIR, "boss_valthor.png"))
    
    print(">>> Generating Dungeon Archway & Chest...")
    draw_dungeon_archway().save(os.path.join(UI_DIR, "dungeon_archway.png"))
    draw_treasure_chest().save(os.path.join(UI_DIR, "treasure_chest.png"))
    
    print(">>> ALL GRAPHICAL SPRITES GENERATED SUCCESSFULLY! <<<")

if __name__ == "__main__":
    main()
