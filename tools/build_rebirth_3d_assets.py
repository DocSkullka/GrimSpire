"""
GRIMSPIRE: REBIRTH - 3D ASSET & RIG PIPELINE
Generates 3D rigged skeletal characters, environment pieces, interactive chests,
and exports GLTF models with animations for Godot 4.7.
Compatible with Blender 5.2 LTS.
"""

import bpy
import math
import os

MODELS_DIR = r"D:\GrimSpire\assets\models"
TEX_DIR = r"D:\GrimSpire\assets\textures"

os.makedirs(MODELS_DIR, exist_ok=True)
os.makedirs(TEX_DIR, exist_ok=True)

def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def setup_render_settings(res_x=450, res_y=600):
    scene = bpy.context.scene
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

def create_mat(name, base_color, roughness=0.7, metallic=0.1, emission_color=None, emission_strength=1.0):
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

def setup_lighting(key_pos=(2.5, -3.5, 3.5), key_color=(1.0, 0.92, 0.85), key_energy=130.0,
                   rim_pos=(-3.0, 2.5, 2.5), rim_color=(0.25, 0.65, 1.0), rim_energy=110.0,
                   fill_pos=(0.0, -1.5, 0.3), fill_color=(0.7, 0.15, 0.15), fill_energy=40.0):
    bpy.ops.object.light_add(type='POINT', location=key_pos)
    k = bpy.context.active_object
    k.data.color = key_color
    k.data.energy = key_energy

    bpy.ops.object.light_add(type='POINT', location=rim_pos)
    r = bpy.context.active_object
    r.data.color = rim_color
    r.data.energy = rim_energy

    bpy.ops.object.light_add(type='POINT', location=fill_pos)
    f = bpy.context.active_object
    f.data.color = fill_color
    f.data.energy = fill_energy

def setup_camera(location=(0, -5.2, 1.7), rotation=(1.50, 0, 0)):
    bpy.ops.object.camera_add(location=location, rotation=rotation)
    cam = bpy.context.active_object
    bpy.context.scene.camera = cam
    return cam

def export_and_render(name, blend=True):
    gltf_file = os.path.join(MODELS_DIR, f"{name}.gltf")
    bpy.ops.export_scene.gltf(filepath=gltf_file, export_format='GLTF_SEPARATE', export_animations=True)
    if blend:
        blend_file = os.path.join(MODELS_DIR, f"{name}.blend")
        bpy.ops.wm.save_as_mainfile(filepath=blend_file)
    png_file = os.path.join(TEX_DIR, f"{name}.png")
    bpy.context.scene.render.filepath = png_file
    bpy.ops.render.render(write_still=True)
    print(f"[OK] Generated {name}: GLTF and render complete!")

# -----------------------------------------------------------------------------
# HELPER: RIG BUILDER WITH KEYFRAMED ACTIONS
# -----------------------------------------------------------------------------
def build_humanoid_rig(name="CharacterRig"):
    arm_data = bpy.data.armatures.new(name + "Data")
    arm_obj = bpy.data.objects.new(name, arm_data)
    bpy.context.scene.collection.objects.link(arm_obj)
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode='EDIT')

    # Root / Hips
    b_hips = arm_data.edit_bones.new("Hips")
    b_hips.head = (0, 0, 1.0)
    b_hips.tail = (0, 0, 1.4)

    # Spine & Chest
    b_chest = arm_data.edit_bones.new("Chest")
    b_chest.head = (0, 0, 1.4)
    b_chest.tail = (0, 0, 1.9)
    b_chest.parent = b_hips

    # Head
    b_head = arm_data.edit_bones.new("Head")
    b_head.head = (0, 0, 1.9)
    b_head.tail = (0, 0, 2.4)
    b_head.parent = b_chest

    # Left Arm
    b_arm_l = arm_data.edit_bones.new("Arm_L")
    b_arm_l.head = (0.35, 0, 1.8)
    b_arm_l.tail = (0.8, 0, 1.3)
    b_arm_l.parent = b_chest

    # Right Arm (Weapon Hand)
    b_arm_r = arm_data.edit_bones.new("Arm_R")
    b_arm_r.head = (-0.35, 0, 1.8)
    b_arm_r.tail = (-0.8, 0, 1.3)
    b_arm_r.parent = b_chest

    # Left Leg
    b_leg_l = arm_data.edit_bones.new("Leg_L")
    b_leg_l.head = (0.25, 0, 1.0)
    b_leg_l.tail = (0.25, 0, 0.0)
    b_leg_l.parent = b_hips

    # Right Leg
    b_leg_r = arm_data.edit_bones.new("Leg_R")
    b_leg_r.head = (-0.25, 0, 1.0)
    b_leg_r.tail = (-0.25, 0, 0.0)
    b_leg_r.parent = b_hips

    bpy.ops.object.mode_set(mode='OBJECT')
    return arm_obj

def add_standard_animations(arm_obj, weapon_side="R", is_tank=False, is_thief=False, is_cleric=False):
    """
    Creates distinct Action tracks (idle, walk, attack, hurt, death, block/cast)
    and saves them to the armature's animation data.
    """
    arm_obj.animation_data_create()

    # 1. IDLE ACTION
    act_idle = bpy.data.actions.new(name="idle")
    arm_obj.animation_data.action = act_idle
    p_chest = arm_obj.pose.bones.get("Chest")
    p_hips = arm_obj.pose.bones.get("Hips")
    p_arm_r = arm_obj.pose.bones.get("Arm_R")
    p_arm_l = arm_obj.pose.bones.get("Arm_L")

    for f, z in [(1, 0.0), (15, 0.04), (30, 0.0)]:
        p_chest.location = (0, 0, z)
        p_chest.keyframe_insert(data_path="location", frame=f)
        p_hips.location = (0, 0, z * 0.5)
        p_hips.keyframe_insert(data_path="location", frame=f)

    # 2. WALK ACTION
    act_walk = bpy.data.actions.new(name="walk")
    arm_obj.animation_data.action = act_walk
    p_leg_l = arm_obj.pose.bones.get("Leg_L")
    p_leg_r = arm_obj.pose.bones.get("Leg_R")

    for f, rot_l, rot_r in [(1, 0.35, -0.35), (10, 0.0, 0.0), (20, -0.35, 0.35), (30, 0.35, -0.35)]:
        p_leg_l.rotation_euler = (rot_l, 0, 0)
        p_leg_l.keyframe_insert(data_path="rotation_euler", frame=f)
        p_leg_r.rotation_euler = (rot_r, 0, 0)
        p_leg_r.keyframe_insert(data_path="rotation_euler", frame=f)
        p_arm_l.rotation_euler = (-rot_l * 0.8, 0, 0)
        p_arm_l.keyframe_insert(data_path="rotation_euler", frame=f)
        p_arm_r.rotation_euler = (-rot_r * 0.8, 0, 0)
        p_arm_r.keyframe_insert(data_path="rotation_euler", frame=f)

    # 3. ATTACK ACTION
    act_atk = bpy.data.actions.new(name="attack")
    arm_obj.animation_data.action = act_atk
    for f, rx, rz in [(1, 0.0, 0.0), (8, -0.8, -0.4), (14, 1.2, 0.6), (24, 0.0, 0.0)]:
        p_arm_r.rotation_euler = (rx, 0, rz)
        p_arm_r.keyframe_insert(data_path="rotation_euler", frame=f)
        if is_thief:
            p_arm_l.rotation_euler = (rx * 0.9, 0, -rz)
            p_arm_l.keyframe_insert(data_path="rotation_euler", frame=f)

    # 4. BLOCK / SPECIAL ACTION (Taunt / Shield Block / Cast / Pick)
    act_block = bpy.data.actions.new(name="block" if not is_cleric else "cast_heal")
    arm_obj.animation_data.action = act_block
    for f, val in [(1, 0.0), (8, 1.1), (22, 1.1), (30, 0.0)]:
        if is_tank:
            p_arm_l.rotation_euler = (val, 0, 0.5 * val) # Raise tower shield
            p_arm_l.keyframe_insert(data_path="rotation_euler", frame=f)
        elif is_cleric:
            p_arm_r.rotation_euler = (val, 0, 0)
            p_arm_r.keyframe_insert(data_path="rotation_euler", frame=f)
            p_arm_l.rotation_euler = (val, 0, 0)
            p_arm_l.keyframe_insert(data_path="rotation_euler", frame=f)
        else:
            p_arm_r.rotation_euler = (val * 0.6, 0, val * 0.4)
            p_arm_r.keyframe_insert(data_path="rotation_euler", frame=f)

    # 5. HURT ACTION
    act_hurt = bpy.data.actions.new(name="hurt")
    arm_obj.animation_data.action = act_hurt
    for f, y_rot, recoil in [(1, 0.0, 0.0), (6, -0.35, -0.15), (16, 0.0, 0.0)]:
        p_chest.rotation_euler = (y_rot, 0, 0)
        p_chest.location = (0, recoil, 0)
        p_chest.keyframe_insert(data_path="rotation_euler", frame=f)
        p_chest.keyframe_insert(data_path="location", frame=f)

    # 6. DEATH ACTION
    act_death = bpy.data.actions.new(name="death")
    arm_obj.animation_data.action = act_death
    for f, pitch, z_drop in [(1, 0.0, 0.0), (12, 0.6, -0.4), (25, 1.5, -0.9)]:
        p_hips.rotation_euler = (pitch, 0, 0)
        p_hips.location = (0, pitch * 0.4, z_drop)
        p_hips.keyframe_insert(data_path="rotation_euler", frame=f)
        p_hips.keyframe_insert(data_path="location", frame=f)

    # Reset default action to idle
    arm_obj.animation_data.action = act_idle

def attach_mesh_to_bone(mesh_obj, arm_obj, bone_name):
    mesh_obj.parent = arm_obj
    mesh_obj.parent_type = 'BONE'
    mesh_obj.parent_bone = bone_name

# =============================================================================
# 1. HERO: THE WANDERER (Проклятый Странник)
# =============================================================================
def build_hero():
    print(">>> Building Hero: The Wanderer...")
    clear_scene()
    setup_render_settings(450, 600)
    
    mat_armor = create_mat("WandererArmor", (0.15, 0.16, 0.20), roughness=0.6, metallic=0.7)
    mat_cloak = create_mat("TatteredCloak", (0.08, 0.07, 0.10), roughness=0.9)
    mat_cloth = create_mat("WandererCloth", (0.35, 0.12, 0.15), roughness=0.85)
    mat_steel = create_mat("CursedBlade", (0.7, 0.75, 0.82), roughness=0.3, metallic=0.9,
                           emission_color=(0.8, 0.2, 0.2), emission_strength=1.5)
    mat_eyes = create_mat("SoulGlow", (0.2, 0.85, 1.0), emission_color=(0.2, 0.85, 1.0), emission_strength=5.0)

    rig = build_humanoid_rig("HeroRig")

    # Torso Armor
    bpy.ops.mesh.primitive_cube_add(size=0.5, location=(0, 0, 1.6))
    torso = bpy.context.active_object
    torso.scale = (0.7, 0.45, 1.0)
    apply_mat(torso, mat_armor)
    attach_mesh_to_bone(torso, rig, "Chest")

    # Head & Helmet
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.25, location=(0, 0, 2.15))
    head = bpy.context.active_object
    apply_mat(head, mat_armor)
    attach_mesh_to_bone(head, rig, "Head")

    # Glowing eye visor slit
    bpy.ops.mesh.primitive_cube_add(size=0.1, location=(0, -0.22, 2.15))
    visor = bpy.context.active_object
    visor.scale = (1.5, 0.2, 0.3)
    apply_mat(visor, mat_eyes)
    attach_mesh_to_bone(visor, rig, "Head")

    # Tattered Cloak on back
    bpy.ops.mesh.primitive_plane_add(size=0.8, location=(0, 0.25, 1.4))
    cloak = bpy.context.active_object
    cloak.rotation_euler = (0.2, 0, 0)
    cloak.scale = (0.65, 1.3, 1.0)
    apply_mat(cloak, mat_cloak)
    attach_mesh_to_bone(cloak, rig, "Chest")

    # Left & Right Pauldrons
    for side, sign in [("Arm_L", 1), ("Arm_R", -1)]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.2, depth=0.35, location=(sign * 0.4, 0, 1.85))
        pauldron = bpy.context.active_object
        pauldron.rotation_euler = (0, sign * 0.4, 0)
        apply_mat(pauldron, mat_armor)
        attach_mesh_to_bone(pauldron, rig, side)

    # Greatsword (attached to Right Arm)
    bpy.ops.mesh.primitive_cube_add(size=0.1, location=(-0.8, -0.4, 1.5))
    blade = bpy.context.active_object
    blade.scale = (0.22, 0.04, 11.0)
    blade.rotation_euler = (0.2, 0.1, 0)
    apply_mat(blade, mat_steel)
    attach_mesh_to_bone(blade, rig, "Arm_R")

    # Crossguard & Hilt
    bpy.ops.mesh.primitive_cube_add(size=0.1, location=(-0.8, -0.4, 0.95))
    guard = bpy.context.active_object
    guard.scale = (1.8, 0.3, 0.3)
    apply_mat(guard, mat_armor)
    attach_mesh_to_bone(guard, rig, "Arm_R")

    # Greaves (Legs)
    for side, sign in [("Leg_L", 1), ("Leg_R", -1)]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.12, depth=0.8, location=(sign * 0.25, 0, 0.5))
        boot = bpy.context.active_object
        apply_mat(boot, mat_armor)
        attach_mesh_to_bone(boot, rig, side)

    add_standard_animations(rig, weapon_side="R")

    setup_lighting(key_pos=(2.2, -4.0, 3.2), key_color=(0.95, 0.9, 0.85), key_energy=130.0,
                   rim_pos=(-2.8, 2.8, 2.8), rim_color=(0.3, 0.7, 1.0), rim_energy=120.0)
    setup_camera(location=(0, -5.0, 1.6), rotation=(1.52, 0, 0))
    export_and_render("hero_wanderer")

# =============================================================================
# 2. TANK: THE BULWARK (Железный Бастион)
# =============================================================================
def build_tank():
    print(">>> Building Tank: The Bulwark...")
    clear_scene()
    setup_render_settings(450, 600)

    mat_plate = create_mat("HeavyPlate", (0.25, 0.24, 0.26), roughness=0.5, metallic=0.85)
    mat_gold_trim = create_mat("BulwarkGold", (0.75, 0.60, 0.20), roughness=0.4, metallic=0.9)
    mat_iron = create_mat("DarkIron", (0.15, 0.14, 0.16), roughness=0.6, metallic=0.7)
    mat_eyes = create_mat("VisorGlow", (1.0, 0.6, 0.1), emission_color=(1.0, 0.6, 0.1), emission_strength=4.0)

    rig = build_humanoid_rig("TankRig")

    # Massive Chest Plate
    bpy.ops.mesh.primitive_cube_add(size=0.65, location=(0, 0, 1.6))
    torso = bpy.context.active_object
    torso.scale = (0.95, 0.65, 0.95)
    apply_mat(torso, mat_plate)
    attach_mesh_to_bone(torso, rig, "Chest")

    # Heavy Greathelm
    bpy.ops.mesh.primitive_cylinder_add(radius=0.28, depth=0.5, location=(0, 0, 2.2))
    helm = bpy.context.active_object
    apply_mat(helm, mat_plate)
    attach_mesh_to_bone(helm, rig, "Head")

    # Helm Horns
    for side in [-0.25, 0.25]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.08, depth=0.35, location=(side, 0, 2.45))
        horn = bpy.context.active_object
        horn.rotation_euler = (0, side * 1.2, 0)
        apply_mat(horn, mat_gold_trim)
        attach_mesh_to_bone(horn, rig, "Head")

    # Massive Tower Shield (Attached to Left Arm)
    bpy.ops.mesh.primitive_cube_add(size=0.1, location=(0.7, -0.3, 1.4))
    shield = bpy.context.active_object
    shield.scale = (4.5, 0.5, 11.0) # Massive rectangular tower shield
    shield.rotation_euler = (0.1, -0.15, 0)
    apply_mat(shield, mat_plate)
    attach_mesh_to_bone(shield, rig, "Arm_L")

    # Shield Golden Cross / Spikes
    bpy.ops.mesh.primitive_cube_add(size=0.1, location=(0.7, -0.36, 1.4))
    cross = bpy.context.active_object
    cross.scale = (4.8, 0.2, 1.5)
    apply_mat(cross, mat_gold_trim)
    attach_mesh_to_bone(cross, rig, "Arm_L")

    # Flanged War Mace (Right Hand)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.04, depth=1.1, location=(-0.8, -0.2, 1.3))
    mace_shaft = bpy.context.active_object
    apply_mat(mace_shaft, mat_iron)
    attach_mesh_to_bone(mace_shaft, rig, "Arm_R")

    bpy.ops.mesh.primitive_ico_sphere_add(radius=0.18, location=(-0.8, -0.2, 1.85))
    mace_head = bpy.context.active_object
    apply_mat(mace_head, mat_gold_trim)
    attach_mesh_to_bone(mace_head, rig, "Arm_R")

    # Heavy Armored Legs
    for side, sign in [("Leg_L", 1), ("Leg_R", -1)]:
        bpy.ops.mesh.primitive_cube_add(size=0.3, location=(sign * 0.28, 0, 0.5))
        leg = bpy.context.active_object
        leg.scale = (0.9, 0.9, 2.5)
        apply_mat(leg, mat_plate)
        attach_mesh_to_bone(leg, rig, side)

    add_standard_animations(rig, weapon_side="R", is_tank=True)

    setup_lighting(key_pos=(3.0, -4.0, 3.5), key_color=(1.0, 0.95, 0.8), key_energy=140.0,
                   rim_pos=(-3.2, 2.5, 3.0), rim_color=(0.2, 0.6, 1.0), rim_energy=120.0)
    setup_camera(location=(0, -5.2, 1.6), rotation=(1.52, 0, 0))
    export_and_render("tank_bulwark")

# =============================================================================
# 3. THIEF: THE NIGHTSHADE (Ночная Тень)
# =============================================================================
def build_thief():
    print(">>> Building Thief: The Nightshade...")
    clear_scene()
    setup_render_settings(450, 600)

    mat_leather = create_mat("ShadowLeather", (0.10, 0.09, 0.12), roughness=0.75, metallic=0.2)
    mat_cowl = create_mat("VenomCowl", (0.05, 0.08, 0.07), roughness=0.9)
    mat_poison = create_mat("VenomEdge", (0.1, 0.9, 0.3), emission_color=(0.1, 0.9, 0.3), emission_strength=4.0)
    mat_steel = create_mat("DaggerSteel", (0.6, 0.65, 0.7), roughness=0.3, metallic=0.9)

    rig = build_humanoid_rig("ThiefRig")

    # Slender Torso
    bpy.ops.mesh.primitive_cube_add(size=0.45, location=(0, 0, 1.55))
    torso = bpy.context.active_object
    torso.scale = (0.65, 0.4, 0.9)
    apply_mat(torso, mat_leather)
    attach_mesh_to_bone(torso, rig, "Chest")

    # Deep Shadow Cowl / Hood
    bpy.ops.mesh.primitive_cone_add(radius1=0.32, depth=0.55, location=(0, 0, 2.15))
    hood = bpy.context.active_object
    hood.rotation_euler = (0.2, 0, 0)
    apply_mat(hood, mat_cowl)
    attach_mesh_to_bone(hood, rig, "Head")

    # Glowing eyes inside hood
    for side in [-0.1, 0.1]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.035, location=(side, -0.22, 2.1))
        apply_mat(bpy.context.active_object, mat_poison)
        attach_mesh_to_bone(bpy.context.active_object, rig, "Head")

    # Dual Venom Daggers (One on each arm)
    for side, sign in [("Arm_L", 1), ("Arm_R", -1)]:
        bpy.ops.mesh.primitive_cube_add(size=0.05, location=(sign * 0.7, -0.3, 1.2))
        blade = bpy.context.active_object
        blade.scale = (0.2, 0.05, 5.5)
        blade.rotation_euler = (-0.3, sign * 0.2, 0)
        apply_mat(blade, mat_poison)
        attach_mesh_to_bone(blade, rig, side)

    # Lockpick Tool Pouch on belt
    bpy.ops.mesh.primitive_cube_add(size=0.15, location=(0.28, -0.2, 1.05))
    pouch = bpy.context.active_object
    pouch.scale = (0.8, 0.4, 0.9)
    apply_mat(pouch, mat_leather)
    attach_mesh_to_bone(pouch, rig, "Hips")

    # Agile Legs & Boots
    for side, sign in [("Leg_L", 1), ("Leg_R", -1)]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.09, depth=0.85, location=(sign * 0.2, 0, 0.45))
        leg = bpy.context.active_object
        apply_mat(leg, mat_leather)
        attach_mesh_to_bone(leg, rig, side)

    add_standard_animations(rig, weapon_side="R", is_thief=True)

    setup_lighting(key_pos=(2.5, -4.0, 3.0), key_color=(0.85, 0.95, 0.85), key_energy=110.0,
                   rim_pos=(-2.5, 2.5, 2.5), rim_color=(0.1, 0.8, 0.4), rim_energy=110.0)
    setup_camera(location=(0, -4.8, 1.55), rotation=(1.52, 0, 0))
    export_and_render("thief_nightshade")

# =============================================================================
# 4. CLERIC: THE BLOODWEAVER (Плетунья Крови)
# =============================================================================
def build_cleric():
    print(">>> Building Cleric: The Bloodweaver...")
    clear_scene()
    setup_render_settings(450, 600)

    mat_robe = create_mat("OccultRobe", (0.18, 0.06, 0.08), roughness=0.85)
    mat_trim = create_mat("SanguineTrim", (0.6, 0.15, 0.18), roughness=0.6)
    mat_blood_orb = create_mat("BloodOrb", (0.9, 0.05, 0.05), emission_color=(1.0, 0.1, 0.1), emission_strength=6.0)
    mat_bone_staff = create_mat("BoneStaff", (0.75, 0.72, 0.65), roughness=0.8)

    rig = build_humanoid_rig("ClericRig")

    # Flowing Robes
    bpy.ops.mesh.primitive_cone_add(radius1=0.45, depth=1.4, location=(0, 0, 0.9))
    skirt = bpy.context.active_object
    apply_mat(skirt, mat_robe)
    attach_mesh_to_bone(skirt, rig, "Hips")

    # Torso with ceremonial mantle
    bpy.ops.mesh.primitive_cube_add(size=0.45, location=(0, 0, 1.55))
    torso = bpy.context.active_object
    torso.scale = (0.7, 0.45, 0.9)
    apply_mat(torso, mat_robe)
    attach_mesh_to_bone(torso, rig, "Chest")

    # Hooded Veil
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.26, location=(0, 0, 2.15))
    head = bpy.context.active_object
    apply_mat(head, mat_robe)
    attach_mesh_to_bone(head, rig, "Head")

    # Mystic Blood Staff (Left Arm)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=2.1, location=(0.75, -0.2, 1.4))
    staff = bpy.context.active_object
    apply_mat(staff, mat_bone_staff)
    attach_mesh_to_bone(staff, rig, "Arm_L")

    # Glowing Blood Lantern / Orb atop Staff
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.15, location=(0.75, -0.2, 2.45))
    orb = bpy.context.active_object
    apply_mat(orb, mat_blood_orb)
    attach_mesh_to_bone(orb, rig, "Arm_L")

    # Occult Grimoire on hip
    bpy.ops.mesh.primitive_cube_add(size=0.2, location=(-0.3, -0.15, 1.1))
    book = bpy.context.active_object
    book.scale = (0.35, 1.2, 0.9)
    apply_mat(book, mat_trim)
    attach_mesh_to_bone(book, rig, "Hips")

    add_standard_animations(rig, weapon_side="L", is_cleric=True)

    setup_lighting(key_pos=(2.5, -4.0, 3.2), key_color=(1.0, 0.85, 0.85), key_energy=120.0,
                   rim_pos=(-2.8, 2.5, 2.8), rim_color=(0.9, 0.1, 0.2), rim_energy=130.0)
    setup_camera(location=(0, -5.0, 1.6), rotation=(1.52, 0, 0))
    export_and_render("cleric_bloodweaver")

# =============================================================================
# 5. ENEMY: BLOOD CULTIST (Культист Скверны)
# =============================================================================
def build_cultist():
    print(">>> Building Enemy: Blood Cultist...")
    clear_scene()
    setup_render_settings(450, 600)

    mat_robe = create_mat("CultRobe", (0.12, 0.11, 0.14), roughness=0.9)
    mat_mask = create_mat("HornedMask", (0.8, 0.78, 0.7), roughness=0.8)
    mat_dagger = create_mat("RitualSteel", (0.4, 0.4, 0.45), roughness=0.4, metallic=0.8,
                            emission_color=(0.7, 0.1, 0.1), emission_strength=2.0)

    rig = build_humanoid_rig("CultistRig")

    # Robe base
    bpy.ops.mesh.primitive_cone_add(radius1=0.4, depth=1.3, location=(0, 0, 0.85))
    skirt = bpy.context.active_object
    apply_mat(skirt, mat_robe)
    attach_mesh_to_bone(skirt, rig, "Hips")

    # Chest
    bpy.ops.mesh.primitive_cube_add(size=0.45, location=(0, 0, 1.5))
    torso = bpy.context.active_object
    torso.scale = (0.7, 0.45, 0.9)
    apply_mat(torso, mat_robe)
    attach_mesh_to_bone(torso, rig, "Chest")

    # Mask Head
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.24, location=(0, 0, 2.1))
    head = bpy.context.active_object
    apply_mat(head, mat_mask)
    attach_mesh_to_bone(head, rig, "Head")

    # Horns
    for side in [-0.18, 0.18]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.06, depth=0.4, location=(side, -0.05, 2.35))
        horn = bpy.context.active_object
        horn.rotation_euler = (-0.3, side * 0.8, 0)
        apply_mat(horn, mat_mask)
        attach_mesh_to_bone(horn, rig, "Head")

    # Curved dagger in right hand
    bpy.ops.mesh.primitive_cube_add(size=0.08, location=(-0.75, -0.3, 1.25))
    blade = bpy.context.active_object
    blade.scale = (0.2, 0.05, 5.0)
    apply_mat(blade, mat_dagger)
    attach_mesh_to_bone(blade, rig, "Arm_R")

    add_standard_animations(rig, weapon_side="R")

    setup_lighting(key_pos=(2.2, -4.0, 3.0), key_color=(0.9, 0.8, 0.8), key_energy=110.0,
                   rim_pos=(-2.5, 2.5, 2.5), rim_color=(0.8, 0.1, 0.1), rim_energy=100.0)
    setup_camera(location=(0, -4.8, 1.55), rotation=(1.52, 0, 0))
    export_and_render("enemy_cultist")

# =============================================================================
# 5b. ENEMIES: SKELETON, IMP, HOLLOW KNIGHT, GARGOYLE, AMALGAM
# =============================================================================
def build_skeleton():
    print(">>> Building Enemy: Feeble Skeleton...")
    clear_scene()
    setup_render_settings(450, 600)

    mat_bone = create_mat("AncientBone", (0.82, 0.79, 0.72), roughness=0.85)
    mat_dark_bone = create_mat("DarkBone", (0.55, 0.52, 0.48), roughness=0.9)
    mat_rusty_iron = create_mat("RustyIron", (0.35, 0.28, 0.24), roughness=0.7, metallic=0.7)
    mat_eye_glow = create_mat("GhostEyeGlow", (0.4, 0.9, 1.0), roughness=0.3, emission_color=(0.3, 0.8, 1.0), emission_strength=4.0)

    rig = build_humanoid_rig("SkeletonRig")

    bpy.ops.mesh.primitive_cube_add(size=0.3, location=(0, 0, 0.95))
    pelvis = bpy.context.active_object
    pelvis.scale = (0.7, 0.4, 0.4)
    apply_mat(pelvis, mat_dark_bone)
    attach_mesh_to_bone(pelvis, rig, "Hips")

    for r in range(4):
        bpy.ops.mesh.primitive_torus_add(major_radius=0.18 - r * 0.015, minor_radius=0.03, location=(0, 0, 1.25 + r * 0.12))
        rib = bpy.context.active_object
        rib.scale = (1.0, 0.7, 0.6)
        apply_mat(rib, mat_bone)
        attach_mesh_to_bone(rib, rig, "Chest")

    bpy.ops.mesh.primitive_cylinder_add(radius=0.04, depth=0.6, location=(0, -0.02, 1.45))
    spine = bpy.context.active_object
    apply_mat(spine, mat_dark_bone)
    attach_mesh_to_bone(spine, rig, "Chest")

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.22, location=(0, 0, 2.1))
    skull = bpy.context.active_object
    apply_mat(skull, mat_bone)
    attach_mesh_to_bone(skull, rig, "Head")

    bpy.ops.mesh.primitive_cube_add(size=0.12, location=(0, -0.08, 1.95))
    jaw = bpy.context.active_object
    jaw.scale = (0.8, 1.2, 0.5)
    apply_mat(jaw, mat_bone)
    attach_mesh_to_bone(jaw, rig, "Head")

    for side in [-0.07, 0.07]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.04, location=(side, -0.18, 2.12))
        eye = bpy.context.active_object
        apply_mat(eye, mat_eye_glow)
        attach_mesh_to_bone(eye, rig, "Head")

    for side, sign in [("L", 1), ("R", -1)]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=0.6, location=(sign * 0.6, 0, 1.4))
        arm_mesh = bpy.context.active_object
        apply_mat(arm_mesh, mat_bone)
        attach_mesh_to_bone(arm_mesh, rig, f"Arm_{side}")

        bpy.ops.mesh.primitive_cylinder_add(radius=0.04, depth=0.7, location=(sign * 0.22, 0, 0.45))
        leg_mesh = bpy.context.active_object
        apply_mat(leg_mesh, mat_bone)
        attach_mesh_to_bone(leg_mesh, rig, f"Leg_{side}")

    bpy.ops.mesh.primitive_cube_add(size=0.08, location=(-0.75, -0.25, 1.3))
    blade = bpy.context.active_object
    blade.scale = (0.15, 0.04, 8.0)
    apply_mat(blade, mat_rusty_iron)
    attach_mesh_to_bone(blade, rig, "Arm_R")

    bpy.ops.mesh.primitive_cube_add(size=0.06, location=(-0.75, -0.25, 1.0))
    guard = bpy.context.active_object
    guard.scale = (2.2, 0.6, 0.6)
    apply_mat(guard, mat_rusty_iron)
    attach_mesh_to_bone(guard, rig, "Arm_R")

    add_standard_animations(rig, weapon_side="R")

    setup_lighting(key_pos=(2.2, -4.0, 3.0), key_color=(0.85, 0.9, 1.0), key_energy=110.0,
                   rim_pos=(-2.5, 2.5, 2.5), rim_color=(0.2, 0.6, 1.0), rim_energy=90.0)
    setup_camera(location=(0, -4.8, 1.55), rotation=(1.52, 0, 0))
    export_and_render("enemy_skeleton")

def build_imp():
    print(">>> Building Enemy: Spire Imp...")
    clear_scene()
    setup_render_settings(450, 600)

    mat_skin = create_mat("ImpFlesh", (0.55, 0.15, 0.12), roughness=0.75)
    mat_horn = create_mat("ImpDarkHorn", (0.15, 0.1, 0.12), roughness=0.6)
    mat_obsidian = create_mat("ImpObsidian", (0.1, 0.1, 0.12), roughness=0.3, metallic=0.6,
                              emission_color=(0.9, 0.2, 0.1), emission_strength=2.5)

    rig = build_humanoid_rig("ImpRig")

    bpy.ops.mesh.primitive_cube_add(size=0.35, location=(0, 0, 1.35))
    torso = bpy.context.active_object
    torso.scale = (0.75, 0.5, 0.8)
    apply_mat(torso, mat_skin)
    attach_mesh_to_bone(torso, rig, "Chest")

    for side in [-0.25, 0.25]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.25, depth=0.6, location=(side, 0.2, 1.45))
        wing = bpy.context.active_object
        wing.scale = (0.8, 0.1, 1.2)
        wing.rotation_euler = (0.4, side * 0.6, 0.8 * (-1 if side < 0 else 1))
        apply_mat(wing, mat_horn)
        attach_mesh_to_bone(wing, rig, "Chest")

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.2, location=(0, 0, 1.85))
    head = bpy.context.active_object
    apply_mat(head, mat_skin)
    attach_mesh_to_bone(head, rig, "Head")

    for side in [-0.14, 0.14]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.05, depth=0.35, location=(side, -0.04, 2.05))
        horn = bpy.context.active_object
        horn.rotation_euler = (-0.4, side * 0.6, 0)
        apply_mat(horn, mat_horn)
        attach_mesh_to_bone(horn, rig, "Head")

    for side in [-0.07, 0.07]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.035, location=(side, -0.16, 1.88))
        eye = bpy.context.active_object
        apply_mat(eye, mat_obsidian)
        attach_mesh_to_bone(eye, rig, "Head")

    bpy.ops.mesh.primitive_cube_add(size=0.07, location=(-0.75, -0.25, 1.15))
    blade = bpy.context.active_object
    blade.scale = (0.15, 0.04, 4.5)
    apply_mat(blade, mat_obsidian)
    attach_mesh_to_bone(blade, rig, "Arm_R")

    add_standard_animations(rig, weapon_side="R")

    setup_lighting(key_pos=(2.2, -4.0, 3.0), key_color=(1.0, 0.85, 0.8), key_energy=110.0,
                   rim_pos=(-2.5, 2.5, 2.5), rim_color=(0.9, 0.2, 0.1), rim_energy=100.0)
    setup_camera(location=(0, -4.8, 1.45), rotation=(1.52, 0, 0))
    export_and_render("enemy_imp")

def build_knight():
    print(">>> Building Enemy: Hollow Knight...")
    clear_scene()
    setup_render_settings(450, 600)

    mat_dark_plate = create_mat("CursedPlate", (0.16, 0.15, 0.18), roughness=0.45, metallic=0.9)
    mat_trim = create_mat("GoldRuinTrim", (0.6, 0.48, 0.25), roughness=0.5, metallic=0.85)
    mat_glow = create_mat("GhostVisorGlow", (0.2, 0.7, 0.9), roughness=0.3,
                          emission_color=(0.1, 0.6, 0.9), emission_strength=3.5)

    rig = build_humanoid_rig("KnightRig")

    bpy.ops.mesh.primitive_cube_add(size=0.48, location=(0, 0, 1.45))
    cuirass = bpy.context.active_object
    cuirass.scale = (0.85, 0.55, 1.0)
    apply_mat(cuirass, mat_dark_plate)
    attach_mesh_to_bone(cuirass, rig, "Chest")

    for side, sign in [("L", 1), ("R", -1)]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.18, depth=0.3, location=(sign * 0.55, 0, 1.75))
        pauldron = bpy.context.active_object
        pauldron.rotation_euler = (0, sign * 0.4, 0)
        apply_mat(pauldron, mat_trim)
        attach_mesh_to_bone(pauldron, rig, "Chest")

    bpy.ops.mesh.primitive_cylinder_add(radius=0.22, depth=0.4, location=(0, 0, 2.1))
    helm = bpy.context.active_object
    apply_mat(helm, mat_dark_plate)
    attach_mesh_to_bone(helm, rig, "Head")

    bpy.ops.mesh.primitive_cube_add(size=0.04, location=(0, -0.21, 2.12))
    visor = bpy.context.active_object
    visor.scale = (3.5, 0.2, 0.4)
    apply_mat(visor, mat_glow)
    attach_mesh_to_bone(visor, rig, "Head")

    for side in [-0.15, 0.15]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.05, depth=0.35, location=(side, 0.05, 2.38))
        crest = bpy.context.active_object
        crest.rotation_euler = (0.2, side * 0.5, 0)
        apply_mat(crest, mat_trim)
        attach_mesh_to_bone(crest, rig, "Head")

    bpy.ops.mesh.primitive_cube_add(size=0.09, location=(-0.75, -0.3, 1.35))
    blade = bpy.context.active_object
    blade.scale = (0.22, 0.05, 8.5)
    apply_mat(blade, mat_dark_plate)
    attach_mesh_to_bone(blade, rig, "Arm_R")

    bpy.ops.mesh.primitive_cube_add(size=0.06, location=(-0.75, -0.3, 1.0))
    guard = bpy.context.active_object
    guard.scale = (2.8, 0.8, 0.8)
    apply_mat(guard, mat_trim)
    attach_mesh_to_bone(guard, rig, "Arm_R")

    add_standard_animations(rig, weapon_side="R")

    setup_lighting(key_pos=(2.2, -4.0, 3.0), key_color=(0.85, 0.88, 1.0), key_energy=120.0,
                   rim_pos=(-2.5, 2.5, 2.5), rim_color=(0.2, 0.5, 0.8), rim_energy=100.0)
    setup_camera(location=(0, -5.0, 1.6), rotation=(1.52, 0, 0))
    export_and_render("enemy_knight")

def build_gargoyle():
    print(">>> Building Boss: Stone Gargoyle (Floor 10 Boss)...")
    clear_scene()
    setup_render_settings(450, 600)

    mat_stone = create_mat("GargoyleStone", (0.28, 0.28, 0.3), roughness=0.9)
    mat_moss = create_mat("GargoyleMoss", (0.18, 0.25, 0.16), roughness=0.95)
    mat_eye = create_mat("GargoyleAmberEye", (1.0, 0.6, 0.1), roughness=0.3,
                         emission_color=(1.0, 0.5, 0.0), emission_strength=3.5)

    rig = build_humanoid_rig("GargoyleRig")

    bpy.ops.mesh.primitive_cube_add(size=0.48, location=(0, 0, 1.45))
    torso = bpy.context.active_object
    torso.scale = (0.9, 0.65, 0.95)
    apply_mat(torso, mat_stone)
    attach_mesh_to_bone(torso, rig, "Chest")

    for side in [-0.35, 0.35]:
        bpy.ops.mesh.primitive_cube_add(size=0.1, location=(side, 0.3, 1.55))
        wing = bpy.context.active_object
        wing.scale = (2.2, 0.2, 4.0)
        wing.rotation_euler = (0.3, side * 0.4, 0.5 * (-1 if side < 0 else 1))
        apply_mat(wing, mat_stone)
        attach_mesh_to_bone(wing, rig, "Chest")

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.24, location=(0, 0, 2.05))
    head = bpy.context.active_object
    apply_mat(head, mat_moss)
    attach_mesh_to_bone(head, rig, "Head")

    for side in [-0.18, 0.18]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.07, depth=0.45, location=(side, -0.05, 2.32))
        horn = bpy.context.active_object
        horn.rotation_euler = (-0.5, side * 0.7, 0)
        apply_mat(horn, mat_stone)
        attach_mesh_to_bone(horn, rig, "Head")

    for side in [-0.09, 0.09]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.04, location=(side, -0.19, 2.08))
        eye = bpy.context.active_object
        apply_mat(eye, mat_eye)
        attach_mesh_to_bone(eye, rig, "Head")

    bpy.ops.mesh.primitive_cube_add(size=0.15, location=(-0.75, -0.25, 1.35))
    hammer = bpy.context.active_object
    hammer.scale = (0.7, 0.7, 4.5)
    apply_mat(hammer, mat_stone)
    attach_mesh_to_bone(hammer, rig, "Arm_R")

    add_standard_animations(rig, weapon_side="R")

    setup_lighting(key_pos=(2.2, -4.0, 3.0), key_color=(0.9, 0.9, 0.85), key_energy=120.0,
                   rim_pos=(-2.5, 2.5, 2.5), rim_color=(0.8, 0.5, 0.1), rim_energy=100.0)
    setup_camera(location=(0, -5.0, 1.6), rotation=(1.52, 0, 0))
    export_and_render("gargoyle_boss")

def build_amalgam():
    print(">>> Building Boss: Flesh Amalgam (Floor 20 Boss)...")
    clear_scene()
    setup_render_settings(450, 600)

    mat_flesh = create_mat("AmalgamFlesh", (0.35, 0.12, 0.15), roughness=0.6)
    mat_bone = create_mat("ProtrudingBone", (0.8, 0.75, 0.7), roughness=0.8)
    mat_cyst = create_mat("PulsingCyst", (0.85, 0.1, 0.1), roughness=0.4,
                          emission_color=(0.8, 0.05, 0.05), emission_strength=3.0)

    rig = build_humanoid_rig("AmalgamRig")

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.48, location=(0, 0, 1.5))
    torso = bpy.context.active_object
    torso.scale = (1.2, 0.9, 1.1)
    apply_mat(torso, mat_flesh)
    attach_mesh_to_bone(torso, rig, "Chest")

    for i in range(5):
        bpy.ops.mesh.primitive_cone_add(radius1=0.08, depth=0.5, location=((i-2)*0.15, 0.35, 1.4 + (i%2)*0.2))
        spike = bpy.context.active_object
        spike.rotation_euler = (0.6, (i-2)*0.2, 0)
        apply_mat(spike, mat_bone)
        attach_mesh_to_bone(spike, rig, "Chest")

    for side in [-0.22, 0.22]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.22, location=(side, -0.05, 2.15))
        head = bpy.context.active_object
        apply_mat(head, mat_flesh)
        attach_mesh_to_bone(head, rig, "Head")

        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.05, location=(side, -0.22, 2.18))
        cyst = bpy.context.active_object
        apply_mat(cyst, mat_cyst)
        attach_mesh_to_bone(cyst, rig, "Head")

    bpy.ops.mesh.primitive_cube_add(size=0.12, location=(-0.8, -0.3, 1.35))
    cleaver = bpy.context.active_object
    cleaver.scale = (0.28, 0.08, 9.0)
    apply_mat(cleaver, mat_bone)
    attach_mesh_to_bone(cleaver, rig, "Arm_R")

    add_standard_animations(rig, weapon_side="R")

    setup_lighting(key_pos=(2.2, -4.0, 3.0), key_color=(0.95, 0.8, 0.8), key_energy=130.0,
                   rim_pos=(-2.5, 2.5, 2.5), rim_color=(0.9, 0.1, 0.1), rim_energy=120.0)
    setup_camera(location=(0, -5.2, 1.65), rotation=(1.52, 0, 0))
    export_and_render("boss_amalgam")

# =============================================================================
# 6. BOSS: VALTHOR THE SOUL EXTINGUISHER (Валтор - Босс 30 этажа)
# =============================================================================
def build_valthor():
    print(">>> Building Boss: Valthor the Soul Extinguisher...")
    clear_scene()
    setup_render_settings(500, 650)

    mat_shadow = create_mat("WraithVoid", (0.04, 0.03, 0.06), roughness=0.9)
    mat_crown = create_mat("GothicCrown", (0.2, 0.18, 0.22), roughness=0.4, metallic=0.9)
    mat_soul = create_mat("SoulEthereal", (0.1, 0.8, 0.95), emission_color=(0.1, 0.85, 1.0), emission_strength=6.0)
    mat_scythe = create_mat("ReaperBlade", (0.3, 0.35, 0.4), roughness=0.3, metallic=0.9,
                            emission_color=(0.2, 0.9, 1.0), emission_strength=2.5)

    rig = build_humanoid_rig("ValthorRig")

    # Giant floating shadowy body
    bpy.ops.mesh.primitive_cone_add(radius1=0.7, depth=2.2, location=(0, 0, 1.2))
    robe = bpy.context.active_object
    robe.scale = (1.1, 0.8, 1.0)
    apply_mat(robe, mat_shadow)
    attach_mesh_to_bone(robe, rig, "Hips")

    # Glowing spectral ribcage / core
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.35, location=(0, -0.15, 1.8))
    core = bpy.context.active_object
    apply_mat(core, mat_soul)
    attach_mesh_to_bone(core, rig, "Chest")

    # Floating crowned skull
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.3, location=(0, 0, 2.5))
    skull = bpy.context.active_object
    skull.scale = (0.85, 0.95, 1.1)
    apply_mat(skull, mat_crown)
    attach_mesh_to_bone(skull, rig, "Head")

    # Jagged Crown
    for rot in [0, 0.8, 1.6, 2.4, 3.2, 4.0, 4.8, 5.6]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.05, depth=0.35, location=(0.22 * math.cos(rot), 0.22 * math.sin(rot), 2.8))
        spike = bpy.context.active_object
        apply_mat(spike, mat_crown)
        attach_mesh_to_bone(spike, rig, "Head")

    # Massive Reaper Scythe (Right Hand)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=3.0, location=(-1.1, -0.3, 1.8))
    pole = bpy.context.active_object
    apply_mat(pole, mat_crown)
    attach_mesh_to_bone(pole, rig, "Arm_R")

    # Curved Crescent Blade atop Scythe
    bpy.ops.mesh.primitive_torus_add(major_radius=0.6, minor_radius=0.06, location=(-1.4, -0.3, 3.1))
    blade = bpy.context.active_object
    blade.scale = (1.0, 0.3, 1.2)
    blade.rotation_euler = (0, 0.8, 0)
    apply_mat(blade, mat_scythe)
    attach_mesh_to_bone(blade, rig, "Arm_R")

    add_standard_animations(rig, weapon_side="R")

    setup_lighting(key_pos=(3.0, -4.5, 4.0), key_color=(0.8, 0.9, 1.0), key_energy=160.0,
                   rim_pos=(-3.5, 3.0, 3.0), rim_color=(0.1, 0.8, 1.0), rim_energy=150.0)
    setup_camera(location=(0, -5.8, 2.0), rotation=(1.52, 0, 0))
    export_and_render("boss_valthor")

# =============================================================================
# 7. INTERACTIVE CHEST (3D Запертый Сундук со взломом)
# =============================================================================
def build_chest():
    print(">>> Building Interactive 3D Chest...")
    clear_scene()
    setup_render_settings(450, 450)

    mat_wood = create_mat("DarkOakPlanks", (0.16, 0.10, 0.07), roughness=0.85)
    mat_iron = create_mat("ForgedIronBands", (0.2, 0.2, 0.22), roughness=0.6, metallic=0.8)
    mat_seal = create_mat("RunicSeal", (0.9, 0.7, 0.1), emission_color=(1.0, 0.7, 0.1), emission_strength=4.0)

    # Base container
    bpy.ops.mesh.primitive_cube_add(size=0.5, location=(0, 0, 0.25))
    base = bpy.context.active_object
    base.scale = (1.6, 1.0, 0.8)
    apply_mat(base, mat_wood)

    # Iron Corner Brackets on base
    for x in [-0.8, 0.8]:
        for y in [-0.5, 0.5]:
            bpy.ops.mesh.primitive_cube_add(size=0.08, location=(x, y, 0.25))
            bkt = bpy.context.active_object
            bkt.scale = (1.2, 1.2, 5.0)
            apply_mat(bkt, mat_iron)

    # Armature with Root and Lid Bone for opening animation
    arm_data = bpy.data.armatures.new("ChestRigData")
    arm_obj = bpy.data.objects.new("ChestRig", arm_data)
    bpy.context.scene.collection.objects.link(arm_obj)
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode='EDIT')

    b_root = arm_data.edit_bones.new("Root")
    b_root.head = (0, 0, 0)
    b_root.tail = (0, 0, 0.5)

    # Hinge is at back edge of chest (y = 0.5, z = 0.55)
    b_lid = arm_data.edit_bones.new("Lid")
    b_lid.head = (0, 0.5, 0.55)
    b_lid.tail = (0, -0.5, 0.55)
    b_lid.parent = b_root
    bpy.ops.object.mode_set(mode='OBJECT')

    # Hinged Curved Lid
    bpy.ops.mesh.primitive_cylinder_add(radius=0.5, depth=1.6, location=(0, 0, 0.55))
    lid = bpy.context.active_object
    lid.scale = (1.0, 1.0, 0.45)
    lid.rotation_euler = (0, math.pi / 2.0, 0)
    apply_mat(lid, mat_wood)
    attach_mesh_to_bone(lid, arm_obj, "Lid")

    # Front Demonic Lock Latch
    bpy.ops.mesh.primitive_cube_add(size=0.12, location=(0, -0.52, 0.55))
    latch = bpy.context.active_object
    apply_mat(latch, mat_seal)
    attach_mesh_to_bone(latch, arm_obj, "Lid")

    # Animations: idle and open
    arm_obj.animation_data_create()
    act_idle = bpy.data.actions.new("idle")
    arm_obj.animation_data.action = act_idle
    p_lid = arm_obj.pose.bones["Lid"]
    p_lid.rotation_euler = (0, 0, 0)
    p_lid.keyframe_insert(data_path="rotation_euler", frame=1)

    act_open = bpy.data.actions.new("open")
    arm_obj.animation_data.action = act_open
    p_lid.rotation_euler = (0, 0, 0)
    p_lid.keyframe_insert(data_path="rotation_euler", frame=1)
    p_lid.rotation_euler = (-1.8, 0, 0) # Swings wide open
    p_lid.keyframe_insert(data_path="rotation_euler", frame=20)

    arm_obj.animation_data.action = act_idle

    setup_lighting(key_pos=(1.8, -2.5, 2.5), key_color=(1.0, 0.9, 0.8), key_energy=120.0,
                   rim_pos=(-2.0, 2.0, 2.0), rim_color=(1.0, 0.8, 0.2), rim_energy=100.0)
    setup_camera(location=(0, -3.2, 1.8), rotation=(1.25, 0, 0))
    export_and_render("spire_chest")

# =============================================================================
# 8. ENVIRONMENT: CAMPFIRE (Подножие Шпиля - Лагерный Костер)
# =============================================================================
def build_campfire():
    print(">>> Building Modular Campfire...")
    clear_scene()
    setup_render_settings(450, 450)

    mat_stone = create_mat("CampStone", (0.3, 0.28, 0.28), roughness=0.9)
    mat_log = create_mat("CharredWood", (0.12, 0.08, 0.05), roughness=0.95)
    mat_embers = create_mat("GlowingEmbers", (1.0, 0.4, 0.05), emission_color=(1.0, 0.4, 0.05), emission_strength=7.0)

    # Stone Ring
    for i in range(10):
        angle = (i / 10.0) * math.pi * 2.0
        x = math.cos(angle) * 0.75
        y = math.sin(angle) * 0.75
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(x, y, 0.1))
        stone = bpy.context.active_object
        apply_mat(stone, mat_stone)

    # Embers Bed
    bpy.ops.mesh.primitive_cylinder_add(radius=0.6, depth=0.1, location=(0, 0, 0.08))
    bed = bpy.context.active_object
    apply_mat(bed, mat_embers)

    # Crisscrossed Charred Logs
    for rot in [0.3, 1.3, 2.4]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.09, depth=1.1, location=(0, 0, 0.2))
        log = bpy.context.active_object
        log.rotation_euler = (0.2, 0.15, rot)
        apply_mat(log, mat_log)

    setup_lighting(key_pos=(1.5, -2.0, 2.5), key_color=(1.0, 0.7, 0.3), key_energy=120.0)
    setup_camera(location=(0, -2.8, 1.8), rotation=(1.15, 0, 0))
    export_and_render("spire_campfire")

# =============================================================================
# 9. ENVIRONMENT: IRON GATE / PORTCULLIS (Врата Шпиля)
# =============================================================================
def build_iron_gate():
    print(">>> Building Gothic Iron Gate...")
    clear_scene()
    setup_render_settings(500, 600)

    mat_stone = create_mat("GothicStone", (0.22, 0.20, 0.24), roughness=0.85)
    mat_iron = create_mat("PortcullisIron", (0.15, 0.15, 0.18), roughness=0.6, metallic=0.85)
    mat_runes = create_mat("GateRunes", (0.2, 0.6, 1.0), emission_color=(0.2, 0.6, 1.0), emission_strength=3.0)

    # Two massive gothic side pillars
    for x in [-1.8, 1.8]:
        bpy.ops.mesh.primitive_cube_add(size=0.6, location=(x, 0, 1.8))
        pillar = bpy.context.active_object
        pillar.scale = (1.0, 1.0, 6.0)
        apply_mat(pillar, mat_stone)

    # Archway Beam across top
    bpy.ops.mesh.primitive_cube_add(size=0.6, location=(0, 0, 3.8))
    arch = bpy.context.active_object
    arch.scale = (6.5, 1.0, 0.9)
    apply_mat(arch, mat_stone)

    # Armature with Gate bone for opening (sliding up)
    arm_data = bpy.data.armatures.new("GateRigData")
    arm_obj = bpy.data.objects.new("GateRig", arm_data)
    bpy.context.scene.collection.objects.link(arm_obj)
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode='EDIT')

    b_root = arm_data.edit_bones.new("Root")
    b_root.head = (0, 0, 0)
    b_root.tail = (0, 0, 0.5)

    b_gate = arm_data.edit_bones.new("Portcullis")
    b_gate.head = (0, 0, 0.5)
    b_gate.tail = (0, 0, 3.0)
    b_gate.parent = b_root
    bpy.ops.object.mode_set(mode='OBJECT')

    # Vertical Spiked Iron Bars
    for i in range(-5, 6):
        x = i * 0.28
        bpy.ops.mesh.primitive_cylinder_add(radius=0.045, depth=3.2, location=(x, 0, 1.8))
        bar = bpy.context.active_object
        apply_mat(bar, mat_iron)
        attach_mesh_to_bone(bar, arm_obj, "Portcullis")

        # Bottom spike
        bpy.ops.mesh.primitive_cone_add(radius1=0.06, depth=0.3, location=(x, 0, 0.1))
        spike = bpy.context.active_object
        apply_mat(spike, mat_iron)
        attach_mesh_to_bone(spike, arm_obj, "Portcullis")

    # Horizontal Iron cross-ties
    for z in [0.8, 1.8, 2.8]:
        bpy.ops.mesh.primitive_cube_add(size=0.08, location=(0, 0, z))
        tie = bpy.context.active_object
        tie.scale = (38.0, 1.0, 1.0)
        apply_mat(tie, mat_iron)
        attach_mesh_to_bone(tie, arm_obj, "Portcullis")

    # Animation: gate lift
    arm_obj.animation_data_create()
    act_open = bpy.data.actions.new("open")
    arm_obj.animation_data.action = act_open
    p_gate = arm_obj.pose.bones["Portcullis"]
    p_gate.location = (0, 0, 0)
    p_gate.keyframe_insert(data_path="location", frame=1)
    p_gate.location = (0, 0, 2.5) # Rises up into stone arch
    p_gate.keyframe_insert(data_path="location", frame=25)

    act_closed = bpy.data.actions.new("idle")
    arm_obj.animation_data.action = act_closed
    p_gate.location = (0, 0, 0)
    p_gate.keyframe_insert(data_path="location", frame=1)

    setup_lighting(key_pos=(2.5, -4.0, 3.5), key_color=(0.9, 0.85, 0.8), key_energy=140.0,
                   rim_pos=(-3.0, 2.5, 3.0), rim_color=(0.3, 0.6, 1.0), rim_energy=120.0)
    setup_camera(location=(0, -6.0, 2.0), rotation=(1.52, 0, 0))
    export_and_render("spire_iron_gate")

# =============================================================================
# 10. ENVIRONMENT: STONE CORRIDOR PILLAR (Каменный Коридор)
# =============================================================================
def build_corridor_pillar():
    print(">>> Building Spire Corridor Pillar...")
    clear_scene()
    setup_render_settings(350, 600)

    mat_stone = create_mat("PillarStone", (0.26, 0.24, 0.28), roughness=0.8)
    mat_torch = create_mat("TorchFlame", (1.0, 0.5, 0.05), emission_color=(1.0, 0.5, 0.05), emission_strength=5.0)

    # Base Pedestal
    bpy.ops.mesh.primitive_cube_add(size=0.6, location=(0, 0, 0.3))
    base = bpy.context.active_object
    base.scale = (1.2, 1.2, 1.0)
    apply_mat(base, mat_stone)

    # Column Shaft
    bpy.ops.mesh.primitive_cylinder_add(radius=0.28, depth=3.8, location=(0, 0, 2.2))
    col = bpy.context.active_object
    apply_mat(col, mat_stone)

    # Capital at Top
    bpy.ops.mesh.primitive_cube_add(size=0.6, location=(0, 0, 4.2))
    cap = bpy.context.active_object
    cap.scale = (1.3, 1.3, 0.8)
    apply_mat(cap, mat_stone)

    # Wall Torch Sconce
    bpy.ops.mesh.primitive_cylinder_add(radius=0.06, depth=0.35, location=(0, -0.35, 2.2))
    sconce = bpy.context.active_object
    sconce.rotation_euler = (0.4, 0, 0)
    apply_mat(sconce, mat_stone)

    bpy.ops.mesh.primitive_ico_sphere_add(radius=0.12, location=(0, -0.42, 2.4))
    flame = bpy.context.active_object
    apply_mat(flame, mat_torch)

    setup_lighting(key_pos=(1.8, -3.0, 2.5), key_color=(1.0, 0.8, 0.6), key_energy=110.0)
    setup_camera(location=(0, -4.5, 2.2), rotation=(1.52, 0, 0))
    export_and_render("spire_corridor_pillar")

# =============================================================================
# 11. ENVIRONMENT: ELEVATOR PLATFORM (Платформа Лифта)
# =============================================================================
def build_elevator():
    print(">>> Building Spire Elevator Platform...")
    clear_scene()
    setup_render_settings(500, 400)

    mat_stone = create_mat("ElevatorStone", (0.24, 0.22, 0.26), roughness=0.85)
    mat_runes = create_mat("ElevatorRunes", (0.9, 0.2, 0.1), emission_color=(1.0, 0.2, 0.1), emission_strength=5.0)

    # Hexagonal / Round Runic Platform
    bpy.ops.mesh.primitive_cylinder_add(radius=1.8, depth=0.3, vertices=8, location=(0, 0, 0.15))
    plat = bpy.context.active_object
    apply_mat(plat, mat_stone)

    # Inlaid Runic Ring
    bpy.ops.mesh.primitive_torus_add(major_radius=1.3, minor_radius=0.08, location=(0, 0, 0.31))
    ring = bpy.context.active_object
    apply_mat(ring, mat_runes)

    # Central Core Rune
    bpy.ops.mesh.primitive_cylinder_add(radius=0.4, depth=0.05, location=(0, 0, 0.32))
    core = bpy.context.active_object
    apply_mat(core, mat_runes)

    setup_lighting(key_pos=(2.0, -3.0, 2.5), key_color=(0.9, 0.7, 0.7), key_energy=110.0)
    setup_camera(location=(0, -3.5, 2.2), rotation=(1.15, 0, 0))
    export_and_render("spire_elevator_platform")

# =============================================================================
# MAIN PIPELINE EXECUTION
# =============================================================================
def main():
    print("==================================================================")
    print("   GRIMSPIRE: REBIRTH - 3D SKELETAL RIG & ENVIRONMENT PIPELINE   ")
    print("==================================================================")
    build_hero()
    build_tank()
    build_thief()
    build_cleric()
    build_cultist()
    build_skeleton()
    build_imp()
    build_knight()
    build_gargoyle()
    build_amalgam()
    build_valthor()
    build_chest()
    build_campfire()
    build_iron_gate()
    build_corridor_pillar()
    build_elevator()
    print("==================================================================")
    print("   ALL 16 3D MODELS AND SKELETAL RIGS GENERATED SUCCESSFULLY!    ")
    print("==================================================================")

if __name__ == "__main__":
    main()
