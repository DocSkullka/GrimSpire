import os
from PIL import Image, ImageOps, ImageFilter, ImageEnhance, ImageDraw

TEX_DIR = r"D:\GrimSpire\assets\textures"

def apply_dont_starve_styling(path):
    if not os.path.exists(path):
        print("Not found:", path)
        return
    img = Image.open(path).convert("RGBA")
    r, g, b, a = img.split()
    rgb = Image.merge("RGB", (r, g, b))
    
    # 1. High contrast to get strong gothic ink silhouettes
    enhancer = ImageEnhance.Contrast(rgb)
    rgb_c = enhancer.enhance(1.3)
    
    # 2. Extract edge lines (black ink outlines)
    edges = rgb_c.filter(ImageFilter.FIND_EDGES).convert("L")
    # Enhance edge lines
    edges = ImageOps.invert(edges)
    edges = edges.point(lambda p: 255 if p > 220 else int(p * 0.75))
    
    # Composite with dark charcoal ink line color
    ink_color = Image.new("RGB", rgb.size, (18, 14, 22))
    inked_rgb = Image.composite(rgb_c, ink_color, edges)
    
    # 3. Stylized sharpness
    sharpener = ImageEnhance.Sharpness(inked_rgb)
    final_rgb = sharpener.enhance(1.5)
    
    fr, fg, fb = final_rgb.split()
    final_img = Image.merge("RGBA", (fr, fg, fb, a))
    final_img.save(path, "PNG")
    print(f"[OK] Inked & styled {path}")

# Style all 6 rendered assets
assets = [
    "enemy_skeleton.png",
    "enemy_imp.png",
    "enemy_knight.png",
    "boss_malgorath.png",
    "boss_amalgam.png",
    "camp_altar.png"
]

for a in assets:
    apply_dont_starve_styling(os.path.join(TEX_DIR, a))

print("All textures post-processed in authentic Don't Starve ink style!")
