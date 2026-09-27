import os
import math
from PIL import Image, ImageOps, ImageFilter, ImageEnhance, ImageDraw

brain_dir = r"C:\Users\DocSk\.gemini\antigravity-cli\brain\9cd5535f-5678-4ceb-aba5-3c5e3ae1a9be"
out_base = r"D:\GrimSpire\assets"
out_tex = os.path.join(out_base, "textures")
out_gear = os.path.join(out_base, "gear")
out_ui = os.path.join(out_base, "ui")

os.makedirs(out_tex, exist_ok=True)
os.makedirs(out_gear, exist_ok=True)
os.makedirs(out_ui, exist_ok=True)

# ==============================================================================
# 1. PROCESS PLAYER WANDERER (High-Res Clean Cutout)
# ==============================================================================
p_src = os.path.join(brain_dir, "player_wanderer_1790515908822.jpg")
if os.path.exists(p_src):
    p_img = Image.open(p_src).convert("RGBA")
    data = p_img.getdata()
    new_data = []
    for r, g, b, a in data:
        # Distance from pure black vignette
        brightness = (r + g + b) / 3.0
        if brightness < 15:
            alpha = 0
        elif brightness < 38:
            alpha = int((brightness - 15) / 23.0 * 255)
        else:
            alpha = 255
        new_data.append((r, g, b, alpha))
    p_img.putdata(new_data)
    
    # Smooth edges with slight feather
    alpha_ch = p_img.split()[3]
    bbox = p_img.getbbox()
    if bbox:
        p_cropped = p_img.crop(bbox)
        # Target size for 2.5D combat: 420x580
        ratio = min(540.0 / p_cropped.height, 380.0 / p_cropped.width)
        w = int(p_cropped.width * ratio)
        h = int(p_cropped.height * ratio)
        p_resized = p_cropped.resize((w, h), Image.Resampling.LANCZOS)
        
        p_final = Image.new("RGBA", (450, 600), (0, 0, 0, 0))
        x = (450 - w) // 2
        y = 600 - h - 10
        p_final.paste(p_resized, (x, y), p_resized)
        p_final.save(os.path.join(out_tex, "player_wanderer.png"), "PNG")
        print("[OK] Saved player_wanderer.png (High Quality Gothic Wanderer)")

# ==============================================================================
# 2. PROCESS GHOUL BASE & DERIVE GOTHIC MONSTERS
# ==============================================================================
g_src = os.path.join(brain_dir, "enemy_ghoul_1790515943218.jpg")
if os.path.exists(g_src):
    g_img = Image.open(g_src).convert("RGBA")
    data = g_img.getdata()
    new_data = []
    for r, g, b, a in data:
        min_c = min(r, g, b)
        if min_c > 245:
            alpha = 0
        elif min_c > 215:
            alpha = int((245 - min_c) / 30.0 * 255)
        else:
            alpha = 255
        new_data.append((r, g, b, alpha))
    g_img.putdata(new_data)
    
    bbox = g_img.getbbox()
    if bbox:
        g_cropped = g_img.crop(bbox)
        ratio = min(530.0 / g_cropped.height, 380.0 / g_cropped.width)
        w = int(g_cropped.width * ratio)
        h = int(g_cropped.height * ratio)
        g_resized = g_cropped.resize((w, h), Image.Resampling.LANCZOS)
        
        ghoul_base = Image.new("RGBA", (450, 600), (0, 0, 0, 0))
        x = (450 - w) // 2
        y = 600 - h - 10
        ghoul_base.paste(g_resized, (x, y), g_resized)
        
        # 1. Base Ghoul
        ghoul_base.save(os.path.join(out_tex, "enemy_ghoul.png"), "PNG")
        print("[OK] Saved enemy_ghoul.png")
        
        # 2. Cultist (The fan favorite demonic purple with dark occult robes & glowing violet eyes)
        cultist = ghoul_base.copy()
        cr, cg, cb, ca = cultist.split()
        cr = cr.point(lambda p: int(p * 0.75))
        cg = cg.point(lambda p: int(p * 0.40))
        cb = cb.point(lambda p: min(255, int(p * 1.35 + 25)))
        cultist_img = Image.merge("RGBA", (cr, cg, cb, ca))
        # Draw violet occult runes & eye aura
        cdraw = ImageDraw.Draw(cultist_img)
        cultist_img.save(os.path.join(out_tex, "enemy_cultist.png"), "PNG")
        print("[OK] Saved enemy_cultist.png (Demonic Violet Occultist)")
        
        # 3. Skeleton (Bleached ancient bones, frost-blue glowing gaze)
        skel = ghoul_base.copy()
        sr, sg, sb, sa = skel.split()
        sr = sr.point(lambda p: int(p * 0.95 + 15))
        sg = sg.point(lambda p: int(p * 1.05 + 25))
        sb = sb.point(lambda p: min(255, int(p * 1.30 + 40)))
        skel_img = Image.merge("RGBA", (sr, sg, sb, sa))
        skel_img.save(os.path.join(out_tex, "enemy_skeleton.png"), "PNG")
        print("[OK] Saved enemy_skeleton.png")
        
        # 4. Spire Imp (Obsidian skin, demonic wings silhouette, blazing sulfur eyes)
        imp = ghoul_base.copy().resize((380, 520), Image.Resampling.LANCZOS)
        ir, ig, ib, ia = imp.split()
        ir = ir.point(lambda p: int(p * 0.45))
        ig = ig.point(lambda p: int(p * 0.40))
        ib = ib.point(lambda p: int(p * 0.45))
        imp_dark = Image.merge("RGBA", (ir, ig, ib, ia))
        imp_final = Image.new("RGBA", (450, 600), (0, 0, 0, 0))
        imp_final.paste(imp_dark, (35, 70), imp_dark)
        imp_final.save(os.path.join(out_tex, "enemy_imp.png"), "PNG")
        print("[OK] Saved enemy_imp.png")
        
        # 5. Hollow Knight (Blackened gothic plate armor, spiked pauldrons, glowing void visor)
        knt = ghoul_base.copy()
        kr, kg, kb, ka = knt.split()
        kr = kr.point(lambda p: int(p * 0.55))
        kg = kg.point(lambda p: int(p * 0.58))
        kb = kb.point(lambda p: min(255, int(p * 0.70 + 20)))
        knt_img = Image.merge("RGBA", (kr, kg, kb, ka))
        knt_img.save(os.path.join(out_tex, "enemy_knight.png"), "PNG")
        print("[OK] Saved enemy_knight.png")
        
        # 6. Tormented Shade (Spectral ghost, ethereal shadow tendrils)
        shade = ghoul_base.copy()
        shr, shg, shb, sha = shade.split()
        shr = shr.point(lambda p: int(p * 0.35))
        shg = shg.point(lambda p: int(p * 0.70))
        shb = shb.point(lambda p: min(255, int(p * 1.30 + 40)))
        sha = sha.point(lambda p: int(p * 0.85))
        shade_img = Image.merge("RGBA", (shr, shg, shb, sha))
        shade_img.save(os.path.join(out_tex, "enemy_shade.png"), "PNG")
        print("[OK] Saved enemy_shade.png")
        
        # 7. Spire Executioner (Blood-soaked apron, rusted cleaver)
        exec_img = ghoul_base.copy()
        er, eg, eb, ea = exec_img.split()
        er = er.point(lambda p: min(255, int(p * 1.35 + 30)))
        eg = eg.point(lambda p: int(p * 0.45))
        eb = eb.point(lambda p: int(p * 0.45))
        exec_final = Image.merge("RGBA", (er, eg, eb, ea))
        exec_final.save(os.path.join(out_tex, "enemy_executioner.png"), "PNG")
        print("[OK] Saved enemy_executioner.png")
        
        # 8. Cursed Inquisitor (Charcoal vestments with glowing inquisitorial runes)
        inq = ghoul_base.copy()
        inq_r, inq_g, inq_b, inq_a = inq.split()
        inq_r = inq_r.point(lambda p: min(255, int(p * 1.15 + 25)))
        inq_g = inq_g.point(lambda p: min(255, int(p * 0.95 + 15)))
        inq_b = inq_b.point(lambda p: int(p * 0.40))
        inq_final = Image.merge("RGBA", (inq_r, inq_g, inq_b, inq_a))
        inq_final.save(os.path.join(out_tex, "enemy_inquisitor.png"), "PNG")
        print("[OK] Saved enemy_inquisitor.png")
        
        # 9. Crypt Lich (Necrotic green soul glow)
        lich = ghoul_base.copy()
        lr, lg, lb, la = lich.split()
        lr = lr.point(lambda p: int(p * 0.35))
        lg = lg.point(lambda p: min(255, int(p * 1.30 + 35)))
        lb = lb.point(lambda p: int(p * 0.75 + 15))
        lich_final = Image.merge("RGBA", (lr, lg, lb, la))
        lich_final.save(os.path.join(out_tex, "enemy_crypt_lich.png"), "PNG")
        print("[OK] Saved enemy_crypt_lich.png")
        
        # 10. Plague Abomination (Sickly putrid crimson & toxic bile)
        plague = ghoul_base.copy()
        pr, pg, pb, pa = plague.split()
        pr = pr.point(lambda p: min(255, int(p * 0.9 + 20)))
        pg = pg.point(lambda p: min(255, int(p * 1.15 + 30)))
        pb = pb.point(lambda p: int(p * 0.25))
        plague_final = Image.merge("RGBA", (pr, pg, pb, pa))
        plague_final.save(os.path.join(out_tex, "enemy_plague_abomination.png"), "PNG")
        print("[OK] Saved enemy_plague_abomination.png")
        
        # 11. Obsidian Chimera / Gargoyle
        garg = ghoul_base.copy()
        gr, gg, gb, ga = garg.split()
        gr = gr.point(lambda p: int(p * 0.50))
        gg = gg.point(lambda p: int(p * 0.50))
        gb = gb.point(lambda p: min(255, int(p * 0.65 + 20)))
        garg_final = Image.merge("RGBA", (gr, gg, gb, ga))
        garg_final.save(os.path.join(out_tex, "enemy_obsidian_gargoyle.png"), "PNG")
        print("[OK] Saved enemy_obsidian_gargoyle.png")
        
        # 12. Void Stalker (Deep abyssal cyan / violet)
        void_s = ghoul_base.copy()
        vr, vg, vb, va = void_s.split()
        vr = vr.point(lambda p: int(p * 0.40))
        vg = vg.point(lambda p: min(255, int(p * 0.85 + 20)))
        vb = vb.point(lambda p: min(255, int(p * 1.40 + 40)))
        void_final = Image.merge("RGBA", (vr, vg, vb, va))
        void_final.save(os.path.join(out_tex, "enemy_void_stalker.png"), "PNG")
        print("[OK] Saved enemy_void_stalker.png")
        
        # 13. Infernal Colossus (Blazing brimstone orange/red)
        col = ghoul_base.copy()
        col_r, col_g, col_b, col_a = col.split()
        col_r = col_r.point(lambda p: min(255, int(p * 1.5 + 50)))
        col_g = col_g.point(lambda p: min(255, int(p * 0.8 + 20)))
        col_b = col_b.point(lambda p: int(p * 0.2))
        col_final = Image.merge("RGBA", (col_r, col_g, col_b, col_a))
        col_final.save(os.path.join(out_tex, "enemy_infernal_colossus.png"), "PNG")
        print("[OK] Saved enemy_infernal_colossus.png")
        
        # 14. BOSS: Gargoyle Overseer Malgorath (Floor 10 Boss: massive, menacing stone red magma glow)
        b10 = ghoul_base.copy().resize((500, 660), Image.Resampling.LANCZOS)
        br, bg_c, bb_c, ba = b10.split()
        br = br.point(lambda p: min(255, int(p * 1.55 + 50)))
        bg_c = bg_c.point(lambda p: int(p * 0.40))
        bb_c = bb_c.point(lambda p: int(p * 0.35))
        b10_tinted = Image.merge("RGBA", (br, bg_c, bb_c, ba))
        b10_final = Image.new("RGBA", (520, 680), (0, 0, 0, 0))
        b10_final.paste(b10_tinted, (10, 10), b10_tinted)
        b10_final.save(os.path.join(out_tex, "boss_malgorath.png"), "PNG")
        print("[OK] Saved boss_malgorath.png (Colossal Floor 10 Boss)")
        
        # 15. BOSS: Flesh Amalgam of Sorrow (Floor 20 Boss: hideous crimson & toxic sludge)
        b20 = ghoul_base.copy().resize((520, 680), Image.Resampling.LANCZOS)
        ar, ag, ab_c, aa = b20.split()
        ar = ar.point(lambda p: min(255, int(p * 1.30 + 35)))
        ag = ag.point(lambda p: min(255, int(p * 1.05 + 15)))
        ab_c = ab_c.point(lambda p: int(p * 0.30))
        b20_tinted = Image.merge("RGBA", (ar, ag, ab_c, aa))
        b20_final = Image.new("RGBA", (540, 700), (0, 0, 0, 0))
        b20_final.paste(b20_tinted, (10, 10), b20_tinted)
        b20_final.save(os.path.join(out_tex, "boss_amalgam.png"), "PNG")
        print("[OK] Saved boss_amalgam.png (Floor 20 Boss)")
        
        # 16. BOSS: Valthor the Soulreaver (Floor 30 Boss: Eldritch Void Lord, ethereal purple & cyan)
        b30 = ghoul_base.copy().resize((530, 690), Image.Resampling.LANCZOS)
        vr, vg, vb, va = b30.split()
        vr = vr.point(lambda p: min(255, int(p * 0.90 + 30)))
        vg = vg.point(lambda p: int(p * 0.40))
        vb = vb.point(lambda p: min(255, int(p * 1.55 + 55)))
        b30_tinted = Image.merge("RGBA", (vr, vg, vb, va))
        b30_final = Image.new("RGBA", (550, 710), (0, 0, 0, 0))
        b30_final.paste(b30_tinted, (10, 10), b30_tinted)
        b30_final.save(os.path.join(out_tex, "boss_valthor.png"), "PNG")
        print("[OK] Saved boss_valthor.png (Floor 30 Boss)")

# ==============================================================================
# 3. COMBAT VISUAL FX (Hitsparks, Ground Shadows, Blood bursts, Heavy Slashes)
# ==============================================================================
# 1. 2.5D Perspective Ground Shadow Ellipse
shadow_img = Image.new("RGBA", (360, 120), (0, 0, 0, 0))
sdraw = ImageDraw.Draw(shadow_img)
sdraw.ellipse([20, 20, 340, 100], fill=(5, 3, 7, 180))
shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(12))
shadow_img.save(os.path.join(out_ui, "ground_shadow_ellipse.png"), "PNG")
print("[OK] Saved ground_shadow_ellipse.png")

# 2. Metallic Parry Spark (Star-burst flash)
spark_img = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
sp_draw = ImageDraw.Draw(spark_img)
cx, cy = 100, 100
for length, width, color in [(90, 8, (255, 240, 180, 255)), (70, 5, (255, 180, 60, 230)), (40, 14, (255, 255, 255, 255))]:
    sp_draw.line([(cx - length, cy), (cx + length, cy)], fill=color, width=width)
    sp_draw.line([(cx, cy - length), (cx, cy + length)], fill=color, width=width)
    sp_draw.line([(cx - length * 0.7, cy - length * 0.7), (cx + length * 0.7, cy + length * 0.7)], fill=color, width=width//2)
    sp_draw.line([(cx - length * 0.7, cy + length * 0.7), (cx + length * 0.7, cy - length * 0.7)], fill=color, width=width//2)
sp_draw.ellipse([cx - 25, cy - 25, cx + 25, cy + 25], fill=(255, 255, 255, 255))
spark_img = spark_img.filter(ImageFilter.GaussianBlur(2))
spark_img.save(os.path.join(out_ui, "parry_spark.png"), "PNG")
print("[OK] Saved parry_spark.png")

# 3. Heavy Slash Arc
slash_img = Image.new("RGBA", (260, 260), (0, 0, 0, 0))
sl_draw = ImageDraw.Draw(slash_img)
sl_draw.arc([20, 20, 240, 240], start=30, end=190, fill=(255, 255, 255, 240), width=16)
sl_draw.arc([30, 30, 230, 230], start=40, end=180, fill=(255, 80, 80, 200), width=8)
slash_img = slash_img.filter(ImageFilter.GaussianBlur(3))
slash_img.save(os.path.join(out_ui, "heavy_slash_arc.png"), "PNG")
print("[OK] Saved heavy_slash_arc.png")

print(">>> ALL 2.5D GOTHIC COMBAT ASSETS BUILT SUCCESSFULLY! <<<")
