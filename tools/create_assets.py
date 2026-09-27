import os
import math
from PIL import Image, ImageOps, ImageFilter, ImageDraw, ImageEnhance

brain_dir = r"C:\Users\DocSk\.gemini\antigravity-cli\brain\9cd5535f-5678-4ceb-aba5-3c5e3ae1a9be"
out_tex = r"D:\GrimSpire\assets\textures"
out_icons = r"D:\GrimSpire\assets\icons"
out_ui = r"D:\GrimSpire\assets\ui"

os.makedirs(out_tex, exist_ok=True)
os.makedirs(out_icons, exist_ok=True)
os.makedirs(out_ui, exist_ok=True)

# 1. Background
bg_path = os.path.join(brain_dir, "spire_interior_bg_1790515893844.jpg")
if os.path.exists(bg_path):
    bg = Image.open(bg_path).convert("RGBA")
    # Resize to standard 1280x720 keeping high quality
    bg_resized = bg.resize((1280, 720), Image.Resampling.LANCZOS)
    bg_resized.save(os.path.join(out_tex, "spire_interior.png"), "PNG")
    print("Saved spire_interior.png")

    # Also create camp_altar background from the same gothic cathedral with moody reddish tint
    camp = bg_resized.copy()
    r, g, b, a = camp.split()
    r = r.point(lambda p: min(255, int(p * 1.15)))
    g = g.point(lambda p: int(p * 0.8))
    b = b.point(lambda p: int(p * 0.75))
    camp_altar = Image.merge("RGBA", (r, g, b, a))
    camp_altar.save(os.path.join(out_tex, "camp_altar.png"), "PNG")
    print("Saved camp_altar.png")

# 2. Player Wanderer (Black background removal)
pw_path = os.path.join(brain_dir, "player_wanderer_1790515908822.jpg")
if os.path.exists(pw_path):
    pw = Image.open(pw_path).convert("RGBA")
    data = pw.getdata()
    new_data = []
    for item in data:
        # Distance from pure black
        brightness = (item[0] + item[1] + item[2]) / 3.0
        if brightness < 18:
            alpha = 0
        elif brightness < 38:
            alpha = int((brightness - 18) / 20.0 * 255)
        else:
            alpha = 255
        new_data.append((item[0], item[1], item[2], alpha))
    pw.putdata(new_data)
    # Find bounding box of non-transparent pixels
    bbox = pw.getbbox()
    if bbox:
        pw_cropped = pw.crop(bbox)
        # Pad to make it a neat sprite (width ~ 320, height ~ 500)
        pw_final = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
        # paste centered horizontally, aligned to bottom
        x = (400 - pw_cropped.width) // 2
        y = 600 - pw_cropped.height - 20
        # If cropped is too large, scale down
        if pw_cropped.height > 550 or pw_cropped.width > 380:
            ratio = min(550.0 / pw_cropped.height, 380.0 / pw_cropped.width)
            pw_cropped = pw_cropped.resize((int(pw_cropped.width * ratio), int(pw_cropped.height * ratio)), Image.Resampling.LANCZOS)
            x = (400 - pw_cropped.width) // 2
            y = 600 - pw_cropped.height - 20
        pw_final.paste(pw_cropped, (x, y), pw_cropped)
        pw_final.save(os.path.join(out_tex, "player_wanderer.png"), "PNG")
        print("Saved player_wanderer.png")

# 3. Enemy Ghoul (White background removal)
eg_path = os.path.join(brain_dir, "enemy_ghoul_1790515943218.jpg")
if os.path.exists(eg_path):
    eg = Image.open(eg_path).convert("RGBA")
    data = eg.getdata()
    new_data = []
    for item in data:
        # Distance from pure white
        # If r, g, b are all high
        min_c = min(item[0], item[1], item[2])
        if min_c > 245:
            alpha = 0
        elif min_c > 220:
            alpha = int((245 - min_c) / 25.0 * 255)
        else:
            alpha = 255
        new_data.append((item[0], item[1], item[2], alpha))
    eg.putdata(new_data)
    bbox = eg.getbbox()
    if bbox:
        eg_cropped = eg.crop(bbox)
        # Scale to match ~ 400x550
        ratio = min(520.0 / eg_cropped.height, 360.0 / eg_cropped.width)
        eg_cropped = eg_cropped.resize((int(eg_cropped.width * ratio), int(eg_cropped.height * ratio)), Image.Resampling.LANCZOS)
        eg_final = Image.new("RGBA", (400, 600), (0, 0, 0, 0))
        x = (400 - eg_cropped.width) // 2
        y = 600 - eg_cropped.height - 20
        eg_final.paste(eg_cropped, (x, y), eg_cropped)
        eg_final.save(os.path.join(out_tex, "enemy_ghoul.png"), "PNG")
        print("Saved enemy_ghoul.png")

        # 4. Create Enemy Cultist (dark purple tint, shadow aura)
        cultist = eg_final.copy()
        cr, cg, cb, ca = cultist.split()
        cr = cr.point(lambda p: int(p * 0.7))
        cg = cg.point(lambda p: int(p * 0.4))
        cb = cb.point(lambda p: min(255, int(p * 1.3 + 20)))
        cultist_tinted = Image.merge("RGBA", (cr, cg, cb, ca))
        cultist_tinted.save(os.path.join(out_tex, "enemy_cultist.png"), "PNG")
        print("Saved enemy_cultist.png")

        # 5. Create Boss Malgorath (Gargoyle boss: massive, menacing stone red glow)
        # Scaled up 1.3x with demonic red/stone cracks
        boss_base = eg_final.copy()
        br, bg_c, bb_c, ba = boss_base.split()
        br = br.point(lambda p: min(255, int(p * 1.5 + 40)))
        bg_c = bg_c.point(lambda p: int(p * 0.45))
        bb_c = bb_c.point(lambda p: int(p * 0.4))
        boss_img = Image.merge("RGBA", (br, bg_c, bb_c, ba))
        boss_img.save(os.path.join(out_tex, "boss_malgorath.png"), "PNG")
        print("Saved boss_malgorath.png")

        # 6. Create Boss Flesh Amalgam (sickly crimson / necrotic green abomination)
        amalgam = eg_final.copy()
        ar, ag, ab_c, aa = amalgam.split()
        ar = ar.point(lambda p: min(255, int(p * 1.2 + 30)))
        ag = ag.point(lambda p: min(255, int(p * 1.1 + 10)))
        ab_c = ab_c.point(lambda p: int(p * 0.3))
        amalgam_img = Image.merge("RGBA", (ar, ag, ab_c, aa))
        amalgam_img.save(os.path.join(out_tex, "boss_amalgam.png"), "PNG")
        print("Saved boss_amalgam.png")

# 7. Generate Equipment Icons in authentic Don't Starve Gothic Ink Style (128x128)
def create_gothic_icon(name, icon_type, color_accent):
    size = (128, 128)
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Dark parchment card base
    draw.rounded_rectangle([6, 6, 122, 122], radius=10, fill=(24, 21, 28, 240), outline=(55, 45, 60, 255), width=3)
    draw.rounded_rectangle([12, 12, 116, 116], radius=7, fill=(16, 14, 20, 240), outline=(color_accent[0]//2, color_accent[1]//2, color_accent[2]//2, 200), width=1)

    if icon_type == "weapon":
        # Gothic jagged broadsword
        # Blade
        blade_pts = [(64, 20), (54, 35), (58, 50), (52, 65), (56, 80), (64, 82), (72, 80), (76, 65), (70, 50), (74, 35)]
        draw.polygon(blade_pts, fill=(180, 190, 200, 255), outline=(20, 20, 25, 255))
        # Fuller / runes
        draw.line([(64, 26), (64, 78)], fill=(120, 30, 30, 255), width=2)
        # Crossguard
        draw.polygon([(40, 80), (88, 80), (85, 87), (43, 87)], fill=(80, 70, 60, 255), outline=(15, 15, 15, 255))
        # Hilt & Pommel
        draw.line([(64, 87), (64, 102)], fill=(60, 45, 30, 255), width=4)
        draw.ellipse([58, 101, 70, 113], fill=(130, 100, 40, 255), outline=(20, 15, 10, 255))

    elif icon_type == "armor":
        # Spiked dark gothic cuirass
        pts = [(44, 32), (64, 28), (84, 32), (94, 50), (84, 98), (64, 106), (44, 98), (34, 50)]
        draw.polygon(pts, fill=(70, 68, 76, 255), outline=(15, 15, 20, 255))
        # Shoulder spikes
        draw.polygon([(34, 50), (24, 38), (42, 42)], fill=(90, 88, 98, 255), outline=(10, 10, 10, 255))
        draw.polygon([(94, 50), (104, 38), (86, 42)], fill=(90, 88, 98, 255), outline=(10, 10, 10, 255))
        # Rib plating lines
        draw.line([(48, 60), (80, 60)], fill=(30, 28, 35, 255), width=2)
        draw.line([(50, 75), (78, 75)], fill=(30, 28, 35, 255), width=2)
        draw.line([(54, 90), (74, 90)], fill=(30, 28, 35, 255), width=2)
        draw.ellipse([60, 45, 68, 53], fill=(150, 20, 20, 255))

    elif icon_type == "helm":
        # Horned executioner helm
        draw.polygon([(46, 42), (64, 26), (82, 42), (86, 88), (64, 98), (42, 88)], fill=(85, 80, 90, 255), outline=(15, 15, 20, 255))
        # Horns
        draw.polygon([(46, 44), (28, 26), (36, 52)], fill=(50, 45, 40, 255), outline=(10, 10, 10, 255))
        draw.polygon([(82, 44), (100, 26), (92, 52)], fill=(50, 45, 40, 255), outline=(10, 10, 10, 255))
        # Glowing eye slits
        draw.polygon([(50, 56), (60, 56), (58, 62), (52, 62)], fill=(240, 220, 90, 255), outline=(10, 10, 10, 255))
        draw.polygon([(68, 56), (78, 56), (76, 62), (70, 62)], fill=(240, 220, 90, 255), outline=(10, 10, 10, 255))

    elif icon_type == "shield":
        # Kite shield with skull insignia
        pts = [(40, 30), (88, 30), (92, 65), (64, 108), (36, 65)]
        draw.polygon(pts, fill=(65, 60, 70, 255), outline=(15, 15, 20, 255))
        # Rim
        draw.polygon([(45, 36), (83, 36), (86, 63), (64, 100), (42, 63)], fill=(45, 40, 50, 255), outline=(100, 90, 70, 255))
        # Center boss / skull
        draw.ellipse([54, 52, 74, 72], fill=(200, 195, 185, 255), outline=(20, 20, 20, 255))
        draw.ellipse([58, 58, 63, 64], fill=(20, 20, 20, 255))
        draw.ellipse([65, 58, 70, 64], fill=(20, 20, 20, 255))

    elif icon_type == "amulet":
        # Bloodstone talisman amulet
        # Chain
        draw.arc([36, 26, 92, 68], 0, 180, fill=(160, 130, 50, 255), width=3)
        # Gem setting
        draw.polygon([(64, 48), (86, 68), (64, 106), (42, 68)], fill=(180, 20, 35, 255), outline=(180, 140, 40, 255), width=2)
        # Facet highlight
        draw.polygon([(64, 54), (80, 68), (64, 98), (48, 68)], fill=(230, 50, 60, 255))
        draw.polygon([(64, 58), (74, 68), (64, 88), (54, 68)], fill=(255, 120, 120, 255))

    img.save(os.path.join(out_icons, f"{name}.png"), "PNG")
    print(f"Saved {name}.png")

create_gothic_icon("icon_weapon", "weapon", (210, 60, 60))
create_gothic_icon("icon_armor", "armor", (80, 140, 210))
create_gothic_icon("icon_helm", "helm", (210, 180, 60))
create_gothic_icon("icon_shield", "shield", (130, 200, 120))
create_gothic_icon("icon_amulet", "amulet", (200, 50, 160))

# 8. Create UI textures
# Gold coin icon
gold_img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
gd = ImageDraw.Draw(gold_img)
gd.ellipse([6, 6, 58, 58], fill=(220, 175, 45, 255), outline=(90, 65, 10, 255), width=3)
gd.ellipse([14, 14, 50, 50], fill=(245, 205, 70, 255), outline=(180, 140, 30, 255), width=2)
gd.polygon([(32, 20), (38, 28), (46, 28), (40, 36), (43, 44), (32, 40), (21, 44), (24, 36), (18, 28), (26, 28)], fill=(160, 110, 20, 255))
gold_img.save(os.path.join(out_ui, "gold_coin.png"), "PNG")
print("Saved gold_coin.png")

# Blood drop icon
blood_img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
bd = ImageDraw.Draw(blood_img)
bd.polygon([(32, 8), (48, 36), (46, 48), (32, 58), (18, 48), (16, 36)], fill=(190, 20, 25, 255), outline=(70, 5, 10, 255), width=2)
bd.ellipse([22, 28, 30, 42], fill=(240, 80, 85, 255))
blood_img.save(os.path.join(out_ui, "blood_drop.png"), "PNG")
print("Saved blood_drop.png")

# Card Frame (for 3-item draft modal) 260x360
card_img = Image.new("RGBA", (260, 360), (0, 0, 0, 0))
cd = ImageDraw.Draw(card_img)
# Outer dark parchment
cd.rounded_rectangle([4, 4, 256, 356], radius=14, fill=(20, 18, 24, 248), outline=(70, 58, 75, 255), width=4)
# Inner ornate line
cd.rounded_rectangle([12, 12, 248, 348], radius=10, fill=(14, 12, 18, 245), outline=(40, 35, 48, 255), width=2)
# Corner accents
for (cx, cy) in [(18, 18), (242, 18), (18, 342), (242, 342)]:
    cd.rectangle([cx-4, cy-4, cx+4, cy+4], fill=(180, 140, 60, 255))
card_img.save(os.path.join(out_ui, "card_frame.png"), "PNG")
print("Saved card_frame.png")

# Slash particle / effect 128x128
slash_img = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
sd = ImageDraw.Draw(slash_img)
# Curved white/cyan crescent slash
sd.polygon([(20, 100), (60, 60), (108, 20), (85, 45), (45, 85)], fill=(240, 245, 255, 255))
sd.polygon([(24, 96), (62, 58), (104, 24), (80, 48), (48, 82)], fill=(120, 200, 255, 255))
slash_img.save(os.path.join(out_ui, "slash_effect.png"), "PNG")
print("Saved slash_effect.png")

# Blood splatter particle 64x64
splat_img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
spd = ImageDraw.Draw(splat_img)
spd.ellipse([20, 20, 44, 44], fill=(160, 15, 20, 240))
for pt, r in [((12, 14), 5), ((52, 16), 4), ((10, 42), 6), ((48, 50), 5), ((32, 54), 4)]:
    spd.ellipse([pt[0]-r, pt[1]-r, pt[0]+r, pt[1]+r], fill=(140, 10, 15, 220))
splat_img.save(os.path.join(out_ui, "blood_splatter.png"), "PNG")
print("Saved blood_splatter.png")

print("All visual assets processed and generated successfully!")
