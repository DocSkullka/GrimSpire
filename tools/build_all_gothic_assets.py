import bpy
import math
import os

MODELS_DIR = r"D:\GrimSpire\assets\models"
TEX_DIR = r"D:\GrimSpire\assets\textures"

os.makedirs(MODELS_DIR, exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)

def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def setup_render_settings(res_x=400, res_y=600):
    scene = bpy.context.scene
    # In Blender 5.2, BLENDER_EEVEE_NEXT or BLENDER_EEVEE
    for eng in ['BLENDER_EEVEE_NEXT', 'BLENDER_EEVEE', 'CYCLES']:
        try:
            scene.render.engine = eng
            break
        except Exception:
            pass
    scene.render.film_transparent = True
    scene.render.resolution_x = res_x
    scene.render.resolution_y = res_y
    scene.render.resolution_percentage = 100

def create_mat(name, base_color, roughness=0.8, metallic=0.0, emission_color=None, emission_strength=1.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        if "Base Color" in bsdf.inputs:
            bsdf.inputs["Base Color"].default_value = (base_color[0], base_color[1], base_color[2], 1.0)
        if "Roughness" in bsdf.inputs:
            bsdf.inputs["Roughness"].default_value = roughness
        if "Metallic" in bsdf.inputs:
            bsdf.inputs["Metallic"].default_value = metallic
        if emission_color:
            if "Emission Color" in bsdf.inputs:
                bsdf.inputs["Emission Color"].default_value = (emission_color[0], emission_color[1], emission_color[2], 1.0)
            if "Emission Strength" in bsdf.inputs:
                bsdf.inputs["Emission Strength"].default_value = emission_strength
            elif "Emission" in bsdf.inputs:
                bsdf.inputs["Emission"].default_value = (emission_color[0], emission_color[1], emission_color[2], 1.0)
    return mat

def apply_mat(obj, mat):
    if obj.data.materials:
        obj.data.materials[0] = mat
    else:
        obj.data.materials.append(mat)

def setup_lighting(key_color=(1.0, 0.9, 0.8), key_energy=100.0, rim_color=(0.4, 0.6, 1.0), rim_energy=80.0):
    # Key light
    bpy.ops.object.light_add(type='POINT', location=(2.5, -3.0, 3.5))
    key = bpy.context.active_object
    key.data.color = key_color
    key.data.energy = key_energy
    
    # Fill / Rim light (cool gothic rim)
    bpy.ops.object.light_add(type='POINT', location=(-3.0, 2.5, 2.0))
    rim = bpy.context.active_object
    rim.data.color = rim_color
    rim.data.energy = rim_energy

    # Low ambient bottom light
    bpy.ops.object.light_add(type='POINT', location=(0.0, -1.0, 0.2))
    bottom = bpy.context.active_object
    bottom.data.color = (0.6, 0.1, 0.1)
    bottom.data.energy = 30.0

def setup_camera(location=(0, -5.2, 1.8), rotation=(1.45, 0, 0), ortho_scale=None):
    bpy.ops.object.camera_add(location=location, rotation=rotation)
    cam = bpy.context.active_object
    bpy.context.scene.camera = cam
    if ortho_scale:
        cam.data.type = 'ORTHO'
        cam.data.ortho_scale = ortho_scale
    return cam

# ==============================================================================
# 1. MODEL & RENDER: FEEBLE SKELETON (Floor 1)
# ==============================================================================
def build_skeleton():
    print(">>> Building Feeble Skeleton...")
    clear_scene()
    setup_render_settings(400, 600)
    
    mat_bone = create_mat("AncientBone", (0.85, 0.82, 0.75), roughness=0.9)
    mat_iron = create_mat("RustyIron", (0.35, 0.3, 0.28), roughness=0.7, metallic=0.5)
    mat_eyes = create_mat("EyeGlow", (0.1, 0.9, 0.8), emission_color=(0.1, 0.9, 0.8), emission_strength=4.0)

    # Skull
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.35, location=(0, 0, 2.6))
    skull = bpy.context.active_object
    skull.scale = (0.85, 0.95, 1.0)
    apply_mat(skull, mat_bone)

    # Jaw
    bpy.ops.mesh.primitive_cube_add(size=0.25, location=(0, -0.15, 2.3))
    jaw = bpy.context.active_object
    jaw.scale = (0.7, 0.8, 0.6)
    apply_mat(jaw, mat_bone)

    # Glowing eye sockets
    for side in [-0.12, 0.12]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.06, location=(side, -0.32, 2.62))
        eye = bpy.context.active_object
        apply_mat(eye, mat_eyes)

    # Spine
    for i in range(5):
        bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=0.15, location=(0, 0, 1.5 + i * 0.16))
        vert = bpy.context.active_object
        apply_mat(vert, mat_bone)

    # Ribs
    for i in range(4):
        bpy.ops.mesh.primitive_torus_add(major_radius=0.32 - i*0.02, minor_radius=0.04, location=(0, 0, 1.7 + i * 0.16))
        rib = bpy.context.active_object
        rib.scale = (1.0, 0.7, 0.8)
        apply_mat(rib, mat_bone)

    # Pelvis
    bpy.ops.mesh.primitive_cone_add(radius1=0.32, radius2=0.15, depth=0.25, location=(0, 0, 1.35))
    pelvis = bpy.context.active_object
    apply_mat(pelvis, mat_bone)

    # Legs
    for side in [-0.2, 0.2]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.06, depth=0.6, location=(side, 0, 0.95))
        femur = bpy.context.active_object
        femur.rotation_euler = (0, side * 0.1, 0)
        apply_mat(femur, mat_bone)
        bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=0.65, location=(side * 1.1, 0, 0.35))
        tibia = bpy.context.active_object
        apply_mat(tibia, mat_bone)

    # Arms
    bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=0.6, location=(-0.45, 0, 1.8))
    apply_mat(bpy.context.active_object, mat_bone)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=0.6, location=(0.45, -0.2, 1.8))
    r_arm = bpy.context.active_object
    r_arm.rotation_euler = (0.5, 0, -0.4)
    apply_mat(r_arm, mat_bone)

    # Rusty Sword
    bpy.ops.mesh.primitive_cube_add(size=0.1, location=(0.7, -0.4, 1.8))
    sword_blade = bpy.context.active_object
    sword_blade.scale = (0.2, 0.05, 9.0)
    sword_blade.rotation_euler = (0.4, 0.2, -0.3)
    apply_mat(sword_blade, mat_iron)

    setup_lighting(key_color=(0.9, 0.85, 0.8), key_energy=120.0, rim_color=(0.2, 0.8, 0.9), rim_energy=90.0)
    setup_camera(location=(0, -4.5, 1.5), rotation=(1.52, 0, 0))

    blend_file = os.path.join(MODELS_DIR, "enemy_skeleton.blend")
    bpy.ops.wm.save_as_mainfile(filepath=blend_file)
    gltf_file = os.path.join(MODELS_DIR, "enemy_skeleton.gltf")
    bpy.ops.export_scene.gltf(filepath=gltf_file, export_format='GLTF_SEPARATE')

    png_file = os.path.join(TEX_DIR, "enemy_skeleton.png")
    bpy.context.scene.render.filepath = png_file
    bpy.ops.render.render(write_still=True)
    print("Feeble Skeleton finished!")

# ==============================================================================
# 2. MODEL & RENDER: SPIRE IMP (Floors 2-4)
# ==============================================================================
def build_imp():
    print(">>> Building Spire Imp...")
    clear_scene()
    setup_render_settings(400, 600)

    mat_obsidian = create_mat("ObsidianFlesh", (0.12, 0.10, 0.15), roughness=0.6)
    mat_horns = create_mat("JaggedHorn", (0.28, 0.18, 0.15), roughness=0.85)
    mat_eyes = create_mat("SulfurEyes", (1.0, 0.85, 0.1), emission_color=(1.0, 0.85, 0.1), emission_strength=5.0)
    mat_wings = create_mat("LeatheryWing", (0.22, 0.14, 0.22), roughness=0.9)

    # Hunched demonic torso
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.45, location=(0, 0, 1.4))
    torso = bpy.context.active_object
    torso.scale = (0.9, 0.75, 1.1)
    apply_mat(torso, mat_obsidian)

    # Head
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.32, location=(0, -0.2, 1.95))
    head = bpy.context.active_object
    head.scale = (1.0, 1.1, 0.9)
    apply_mat(head, mat_obsidian)

    # Glowing eyes
    for side in [-0.14, 0.14]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.07, location=(side, -0.48, 1.95))
        apply_mat(bpy.context.active_object, mat_eyes)

    # Curved Horns
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.1, radius2=0.01, depth=0.6, location=(side * 0.22, -0.1, 2.3))
        horn = bpy.context.active_object
        horn.rotation_euler = (-0.3, side * 0.5, 0)
        apply_mat(horn, mat_horns)

    # Bat Wings
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.8, radius2=0.05, depth=1.4, location=(side * 0.85, 0.3, 1.7))
        wing = bpy.context.active_object
        wing.scale = (1.0, 0.08, 1.2)
        wing.rotation_euler = (0.2, side * 0.7, side * 0.3)
        apply_mat(wing, mat_wings)

    # Barbed tail
    bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=0.8, location=(0, 0.45, 1.1))
    tail = bpy.context.active_object
    tail.rotation_euler = (-0.8, 0, 0)
    apply_mat(tail, mat_obsidian)
    bpy.ops.mesh.primitive_cone_add(radius1=0.12, radius2=0.01, depth=0.25, location=(0, 0.8, 0.8))
    apply_mat(bpy.context.active_object, mat_horns)

    # Clawed limbs
    for side in [-0.3, 0.3]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=0.7, location=(side * 1.3, -0.1, 1.1))
        arm = bpy.context.active_object
        arm.rotation_euler = (0.6, side * 0.4, 0)
        apply_mat(arm, mat_obsidian)

    setup_lighting(key_color=(1.0, 0.6, 0.2), key_energy=130.0, rim_color=(0.7, 0.2, 0.9), rim_energy=100.0)
    setup_camera(location=(0, -4.2, 1.6), rotation=(1.50, 0, 0))

    blend_file = os.path.join(MODELS_DIR, "enemy_imp.blend")
    bpy.ops.wm.save_as_mainfile(filepath=blend_file)
    gltf_file = os.path.join(MODELS_DIR, "enemy_imp.gltf")
    bpy.ops.export_scene.gltf(filepath=gltf_file, export_format='GLTF_SEPARATE')

    png_file = os.path.join(TEX_DIR, "enemy_imp.png")
    bpy.context.scene.render.filepath = png_file
    bpy.ops.render.render(write_still=True)
    print("Spire Imp finished!")

# ==============================================================================
# 3. MODEL & RENDER: HOLLOW KNIGHT (Floors 5-9)
# ==============================================================================
def build_knight():
    print(">>> Building Hollow Knight...")
    clear_scene()
    setup_render_settings(400, 600)

    mat_armor = create_mat("GothicPlate", (0.20, 0.22, 0.25), roughness=0.5, metallic=0.7)
    mat_trim = create_mat("CursedBronze", (0.35, 0.28, 0.18), roughness=0.6, metallic=0.8)
    mat_void = create_mat("VoidGlow", (0.7, 0.1, 0.9), emission_color=(0.7, 0.1, 0.9), emission_strength=5.0)

    # Imposing breastplate
    bpy.ops.mesh.primitive_cube_add(size=0.8, location=(0, 0, 1.8))
    plate = bpy.context.active_object
    plate.scale = (0.9, 0.6, 1.1)
    apply_mat(plate, mat_armor)

    # Greathelm
    bpy.ops.mesh.primitive_cube_add(size=0.45, location=(0, 0, 2.55))
    helm = bpy.context.active_object
    helm.scale = (0.85, 0.95, 1.1)
    apply_mat(helm, mat_armor)

    # Void visor glow
    bpy.ops.mesh.primitive_cube_add(size=0.1, location=(0, -0.23, 2.58))
    slit = bpy.context.active_object
    slit.scale = (2.2, 0.2, 0.3)
    apply_mat(slit, mat_void)

    # Spiked Pauldrons
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.3, radius2=0.05, depth=0.6, location=(side * 0.65, 0, 2.15))
        pauldron = bpy.context.active_object
        pauldron.rotation_euler = (0, side * 0.6, 0)
        apply_mat(pauldron, mat_trim)

    # Legs
    for side in [-0.25, 0.25]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.14, depth=1.2, location=(side, 0, 0.7))
        apply_mat(bpy.context.active_object, mat_armor)

    # Greatsword
    bpy.ops.mesh.primitive_cube_add(size=0.1, location=(0.6, -0.3, 1.4))
    blade = bpy.context.active_object
    blade.scale = (0.4, 0.08, 14.0)
    apply_mat(blade, mat_armor)
    bpy.ops.mesh.primitive_cube_add(size=0.1, location=(0.6, -0.3, 2.1))
    guard = bpy.context.active_object
    guard.scale = (3.5, 0.5, 0.5)
    apply_mat(guard, mat_trim)

    setup_lighting(key_color=(0.8, 0.85, 1.0), key_energy=140.0, rim_color=(0.8, 0.2, 0.95), rim_energy=110.0)
    setup_camera(location=(0, -4.8, 1.6), rotation=(1.51, 0, 0))

    blend_file = os.path.join(MODELS_DIR, "enemy_knight.blend")
    bpy.ops.wm.save_as_mainfile(filepath=blend_file)
    gltf_file = os.path.join(MODELS_DIR, "enemy_knight.gltf")
    bpy.ops.export_scene.gltf(filepath=gltf_file, export_format='GLTF_SEPARATE')

    png_file = os.path.join(TEX_DIR, "enemy_knight.png")
    bpy.context.scene.render.filepath = png_file
    bpy.ops.render.render(write_still=True)
    print("Hollow Knight finished!")

# ==============================================================================
# 4. MODEL & RENDER: GARGOYLE OVERSEER MALGORATH (Floor 10 Boss)
# ==============================================================================
def build_gargoyle_boss():
    print(">>> Building Gargoyle Overseer Malgorath...")
    clear_scene()
    setup_render_settings(450, 650)

    mat_stone = create_mat("DemonicStone", (0.14, 0.13, 0.16), roughness=0.85)
    mat_glow = create_mat("CrimsonFissure", (1.0, 0.08, 0.1), emission_color=(1.0, 0.08, 0.1), emission_strength=6.0)

    # Massive torso
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 1.8))
    body = bpy.context.active_object
    body.scale = (1.3, 0.9, 1.4)
    apply_mat(body, mat_stone)

    # Glowing fissures
    for y_offset in [1.6, 1.8, 2.0]:
        bpy.ops.mesh.primitive_cube_add(size=0.1, location=(0, -0.47, y_offset))
        fissure = bpy.context.active_object
        fissure.scale = (2.2, 0.1, 0.3)
        apply_mat(fissure, mat_glow)

    # Horned head
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.45, location=(0, -0.2, 2.7))
    head = bpy.context.active_object
    apply_mat(head, mat_stone)

    # Demon horns
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.16, radius2=0.02, depth=1.1, location=(side * 0.45, -0.1, 3.2))
        horn = bpy.context.active_object
        horn.rotation_euler = (-0.3, side * 0.6, 0)
        apply_mat(horn, mat_stone)

    # Glowing eyes
    for side in [-0.18, 0.18]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.08, location=(side, -0.62, 2.75))
        apply_mat(bpy.context.active_object, mat_glow)

    # Demon wings
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cone_add(radius1=1.4, radius2=0.1, depth=2.4, location=(side * 1.5, 0.5, 2.2))
        wing = bpy.context.active_object
        wing.scale = (1.2, 0.08, 1.3)
        wing.rotation_euler = (0.2, side * 0.5, side * 0.2)
        apply_mat(wing, mat_stone)

    # Stone arms
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.22, depth=1.3, location=(side * 1.0, -0.3, 1.5))
        arm = bpy.context.active_object
        arm.rotation_euler = (0.5, side * 0.3, 0)
        apply_mat(arm, mat_stone)

    setup_lighting(key_color=(1.0, 0.3, 0.2), key_energy=180.0, rim_color=(0.9, 0.1, 0.1), rim_energy=150.0)
    setup_camera(location=(0, -5.2, 1.9), rotation=(1.48, 0, 0))

    blend_file = os.path.join(MODELS_DIR, "gargoyle_boss.blend")
    bpy.ops.wm.save_as_mainfile(filepath=blend_file)
    gltf_file = os.path.join(MODELS_DIR, "gargoyle_boss.gltf")
    bpy.ops.export_scene.gltf(filepath=gltf_file, export_format='GLTF_SEPARATE')

    png_file = os.path.join(TEX_DIR, "boss_malgorath.png")
    bpy.context.scene.render.filepath = png_file
    bpy.ops.render.render(write_still=True)
    print("Gargoyle Boss Malgorath finished!")

# ==============================================================================
# 5. MODEL & RENDER: FLESH AMALGAM OF SORROW (Floor 20 Boss)
# ==============================================================================
def build_flesh_amalgam():
    print(">>> Building Flesh Amalgam of Sorrow...")
    clear_scene()
    setup_render_settings(480, 650)

    mat_flesh = create_mat("RottenFlesh", (0.28, 0.12, 0.15), roughness=0.6)
    mat_skull = create_mat("PaleSkull", (0.75, 0.72, 0.65), roughness=0.9)
    mat_toxic = create_mat("ToxicPustule", (0.2, 0.8, 0.2), emission_color=(0.2, 0.8, 0.2), emission_strength=5.0)

    # Grotesque undulating mass
    bpy.ops.mesh.primitive_uv_sphere_add(radius=1.1, location=(0, 0, 1.5))
    torso = bpy.context.active_object
    torso.scale = (1.3, 0.9, 1.2)
    apply_mat(torso, mat_flesh)

    # Skulls
    skull_locs = [
        (0.0, -0.7, 2.1, 0.35),
        (-0.5, -0.6, 1.6, 0.28),
        (0.5, -0.6, 1.7, 0.30),
        (-0.3, -0.5, 0.9, 0.25),
        (0.4, -0.5, 1.0, 0.26)
    ]
    for (x, y, z, r) in skull_locs:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=r, location=(x, y, z))
        sk = bpy.context.active_object
        sk.scale = (0.85, 0.9, 1.1)
        apply_mat(sk, mat_skull)

    # Toxic sores
    for (px, py, pz) in [(-0.6, -0.4, 2.2), (0.7, -0.3, 1.3), (0.1, -0.8, 1.3), (0.0, 0.4, 2.2)]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.14, location=(px, py, pz))
        apply_mat(bpy.context.active_object, mat_toxic)

    # Tendrils
    for side in [-1, 1]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.12, depth=1.6, location=(side * 1.3, -0.2, 0.9))
        tent = bpy.context.active_object
        tent.rotation_euler = (0.4, side * 0.7, 0)
        apply_mat(tent, mat_flesh)

    setup_lighting(key_color=(0.9, 0.2, 0.3), key_energy=180.0, rim_color=(0.2, 0.9, 0.3), rim_energy=120.0)
    setup_camera(location=(0, -5.2, 1.6), rotation=(1.50, 0, 0))

    blend_file = os.path.join(MODELS_DIR, "boss_amalgam.blend")
    bpy.ops.wm.save_as_mainfile(filepath=blend_file)
    gltf_file = os.path.join(MODELS_DIR, "boss_amalgam.gltf")
    bpy.ops.export_scene.gltf(filepath=gltf_file, export_format='GLTF_SEPARATE')

    png_file = os.path.join(TEX_DIR, "boss_amalgam.png")
    bpy.context.scene.render.filepath = png_file
    bpy.ops.render.render(write_still=True)
    print("Flesh Amalgam finished!")

# ==============================================================================
# 6. MODEL & RENDER: GOTHIC BLOOD ALTAR SANCTUARY (Camp Background)
# ==============================================================================
def build_camp_altar():
    print(">>> Building Gothic Blood Altar Sanctuary...")
    clear_scene()
    setup_render_settings(1280, 720)

    mat_stone = create_mat("AltarDarkStone", (0.09, 0.08, 0.11), roughness=0.9)
    mat_blood = create_mat("GlowingBlood", (0.85, 0.02, 0.06), roughness=0.2, emission_color=(0.85, 0.02, 0.06), emission_strength=4.5)
    mat_torch = create_mat("TorchFire", (1.0, 0.6, 0.1), emission_color=(1.0, 0.6, 0.1), emission_strength=8.0)

    # Dais
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.2))
    base1 = bpy.context.active_object
    base1.scale = (4.5, 2.5, 0.4)
    apply_mat(base1, mat_stone)

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.6))
    base2 = bpy.context.active_object
    base2.scale = (3.5, 2.0, 0.4)
    apply_mat(base2, mat_stone)

    # Basin
    bpy.ops.mesh.primitive_cylinder_add(radius=1.2, depth=0.5, location=(0, 0, 1.0))
    basin = bpy.context.active_object
    apply_mat(basin, mat_stone)

    # Blood Pool
    bpy.ops.mesh.primitive_cylinder_add(radius=1.1, depth=0.1, location=(0, 0, 1.22))
    blood_pool = bpy.context.active_object
    apply_mat(blood_pool, mat_blood)

    # Spiked Pillars
    for x, y in [(-2.2, -1.2), (2.2, -1.2), (-2.2, 1.2), (2.2, 1.2)]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.25, radius2=0.02, depth=3.0, location=(x, y, 1.8))
        apply_mat(bpy.context.active_object, mat_stone)

    # Skull Braziers
    for side in [-2.6, 2.6]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.3, depth=1.5, location=(side, -0.4, 0.9))
        apply_mat(bpy.context.active_object, mat_stone)
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.22, location=(side, -0.4, 1.85))
        apply_mat(bpy.context.active_object, mat_torch)

    # Pillars
    for ax in [-4.0, 4.0]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(ax, 2.5, 2.5))
        col = bpy.context.active_object
        col.scale = (0.8, 0.8, 5.0)
        apply_mat(col, mat_stone)

    setup_lighting(key_color=(1.0, 0.5, 0.1), key_energy=220.0, rim_color=(0.3, 0.1, 0.6), rim_energy=90.0)
    setup_camera(location=(0, -6.5, 2.4), rotation=(1.38, 0, 0))

    blend_file = os.path.join(MODELS_DIR, "blood_altar.blend")
    bpy.ops.wm.save_as_mainfile(filepath=blend_file)
    gltf_file = os.path.join(MODELS_DIR, "blood_altar.gltf")
    bpy.ops.export_scene.gltf(filepath=gltf_file, export_format='GLTF_SEPARATE')

    png_file = os.path.join(TEX_DIR, "camp_altar.png")
    bpy.context.scene.render.filepath = png_file
    bpy.ops.render.render(write_still=True)
    print("Camp Blood Altar finished!")

if __name__ == "__main__":
    build_skeleton()
    build_imp()
    build_knight()
    build_gargoyle_boss()
    build_flesh_amalgam()
    build_camp_altar()
    print(">>> ALL 6 GOTHIC 3D BLENDER ASSETS BUILT & RENDERED SUCCESSFULLY! <<<")
