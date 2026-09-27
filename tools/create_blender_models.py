import bpy
import os

out_dir = r"D:\GrimSpire\assets\models"
os.makedirs(out_dir, exist_ok=True)

# Function to clear scene
def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

# 1. Create Gothic Blood Altar Model
clear_scene()

# Base pedestal
bpy.ops.mesh.primitive_cube_add(size=2, location=(0, 0, 0.5))
pedestal = bpy.context.active_object
pedestal.name = "AltarPedestal"
pedestal.scale = (1.5, 1.0, 0.5)

# Altar top slab
bpy.ops.mesh.primitive_cube_add(size=2, location=(0, 0, 1.2))
slab = bpy.context.active_object
slab.name = "AltarTopSlab"
slab.scale = (1.7, 1.2, 0.2)

# Blood Basin on top
bpy.ops.mesh.primitive_cylinder_add(radius=0.7, depth=0.3, location=(0, 0, 1.5))
basin = bpy.context.active_object
basin.name = "BloodBasin"

# Gothic Pillars / Corner spikes
for x, y in [(-1.5, -0.9), (1.5, -0.9), (-1.5, 0.9), (1.5, 0.9)]:
    bpy.ops.mesh.primitive_cone_add(radius1=0.2, radius2=0.02, depth=1.8, location=(x, y, 1.1))
    spike = bpy.context.active_object
    spike.name = f"Spike_{x}_{y}"

# Create dark stone material
mat_stone = bpy.data.materials.new(name="DarkGothicStone")
mat_stone.use_nodes = True
bsdf = mat_stone.node_tree.nodes.get("Principled BSDF")
if bsdf:
    bsdf.inputs["Base Color"].default_value = (0.08, 0.07, 0.09, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.85

pedestal.data.materials.append(mat_stone)
slab.data.materials.append(mat_stone)

# Blood material
mat_blood = bpy.data.materials.new(name="CursedBlood")
mat_blood.use_nodes = True
bsdf_blood = mat_blood.node_tree.nodes.get("Principled BSDF")
if bsdf_blood:
    bsdf_blood.inputs["Base Color"].default_value = (0.7, 0.02, 0.05, 1.0)
    bsdf_blood.inputs["Roughness"].default_value = 0.15

basin.data.materials.append(mat_blood)

# Save .blend
blend_path = os.path.join(out_dir, "blood_altar.blend")
bpy.ops.wm.save_as_mainfile(filepath=blend_path)
print(f"Saved {blend_path}")

# Export glTF
gltf_path = os.path.join(out_dir, "blood_altar.gltf")
bpy.ops.export_scene.gltf(filepath=gltf_path, export_format='GLTF_SEPARATE')
print(f"Exported {gltf_path}")

# 2. Create Gargoyle Boss Monolith
clear_scene()

# Monolith body
bpy.ops.mesh.primitive_cube_add(size=2, location=(0, 0, 2.0))
boss_body = bpy.context.active_object
boss_body.name = "GargoyleBody"
boss_body.scale = (1.2, 0.8, 2.0)

# Demon Wings
for side in [-1, 1]:
    bpy.ops.mesh.primitive_cone_add(radius1=1.5, radius2=0.1, depth=3.0, location=(side * 2.2, 0.5, 2.5), rotation=(0, side * 0.4, 0))
    wing = bpy.context.active_object
    wing.name = f"Wing_{side}"

# Horns
for side in [-1, 1]:
    bpy.ops.mesh.primitive_cone_add(radius1=0.25, radius2=0.05, depth=1.2, location=(side * 0.6, 0.2, 4.3), rotation=(side * 0.3, 0, 0))
    horn = bpy.context.active_object
    horn.name = f"Horn_{side}"

boss_blend_path = os.path.join(out_dir, "gargoyle_boss.blend")
bpy.ops.wm.save_as_mainfile(filepath=boss_blend_path)
print(f"Saved {boss_blend_path}")

boss_gltf_path = os.path.join(out_dir, "gargoyle_boss.gltf")
bpy.ops.export_scene.gltf(filepath=boss_gltf_path, export_format='GLTF_SEPARATE')
print(f"Exported {boss_gltf_path}")

print("Blender 3D models generated and exported successfully!")
