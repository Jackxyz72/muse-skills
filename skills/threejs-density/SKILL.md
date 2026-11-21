---
name: threejs-density
description: Pack more visible world into three.js browser-game frames without killing frame rate — instancing, merged static geometry, shared materials/atlases, cheap lighting. Use when a judged game needs dense streets (traffic, crowds, props) that still run in an unknown sandbox.
---

# Three.js Density — more world per frame, same frame rate

Goal: the densest readable scene a mid-range laptop GPU can hold at a stable frame rate, because judged browser games are graded on how much world is visible in the frame (see `game-cinematography`) and the judge sandbox's hardware is unknown and throttled.

## The budget mindset

- Draw calls are the first budget. A street scene with 300 individually-meshed props is 300+ calls before cars and people. Target: **< 150 draw calls** for a full city frame; check with `renderer.info.render.calls` in the capture harness, not by guessing.
- Triangles are the second budget and rarely the binding one at low-poly densities. A 500k-tri frame is fine; 500k draw-call-bound frames are not.
- Per-frame CPU allocations are the silent killer on throttled CPUs: no `new Vector3()` inside loops, reuse scratch objects, no array churn in the update path.

## Instancing (the big lever)

- `InstancedMesh` for anything repeated: traffic cars (per colour via instance colour), pedestrians, palm trees, streetlights, barriers, trash props, windows. One call per model type instead of per object.
- Per-instance variation sells density: scale jitter, rotation jitter, colour jitter within a palette. Identical clones read as fake at a glance.
- Animate instances by updating matrices only for the ones that move (traffic, crowd); static instances are set once.
- Shadows: let only hero objects cast. Instanced crowds/props receive, not cast — shadow-casting instanced meshes multiply cost.

## Merged static geometry

- Buildings, kerbs, road furniture that never move: merge into a handful of big `BufferGeometry` chunks (BufferGeometryUtils.mergeGeometries), one per material. A whole district can be 3–5 draw calls.
- Use vertex colours on merged geometry instead of per-building materials — one material for the whole city shell.
- Chunk by district so frustum culling still drops off-screen chunks; one city-wide mesh defeats culling.

## Materials and textures

- Shared materials everywhere; a new material per mesh is a new program/state cost. Palette-driven flat materials (MeshLambertMaterial or MeshStandardMaterial with low roughness variance) read well at golden hour.
- One texture atlas for signs/shopfronts/labels instead of many small textures — fewer binds, and signage density is cheap score in stills.
- Avoid per-frame material property changes that force program switches in the hot path.

## Lighting that stays cheap

- One directional key light (the sun) + one hemisphere fill. That is the whole rig for a dense scene.
- One shadow map, tight frustum around the play area, 2048 max. Moving the shadow camera with the player is fine; adding a second shadow light is not.
- Fake the rest: emissive windows/signage, lightmap-ish vertex darkening in corners, fog for depth. Fog is nearly free and adds a background layer to every frame.

## Distance discipline

- Three LOD rings: near = full models, mid = low-poly versions, far = billboards/impostor planes or fog-faded silhouettes. The far ring exists to fill the background layer of the frame, not to be inspected.
- Hard despawn radius for dynamic actors (traffic/peds) with pooled reuse — never create/destroy meshes during play.
- Skyline: a ring of dark silhouette boxes/planes against the sky gradient. Cheapest possible background, always in frame, always reads as "city".

## Sandbox-proofing (the judge's machine is not yours)

- Assume a throttled shared vCPU and an integrated GPU: test captures with the CPU throttled (headless `--run-all-compositor-stages-before-draw` style flags or DevTools 4× throttle) and confirm frames still compose.
- Cap pixel ratio at 1.5 for gameplay; captures for the dossier may render at full 1280×800.
- Deterministic staging (`?demo=` scenes) must place the same density every run — seeded RNG for traffic/crowd scatter, verified by byte-identical dossier output across two runs.

## Density targets per graded frame (gta6-01 pattern)

- Play frame: ≥ 8 vehicles, ≥ 10 pedestrians, ≥ 3 readable signs, skyline ring visible, all inside the draw-call budget.
- Chase frame: player car + ≥ 3 police + ≥ 4 traffic cars parting, props (barriers, palms) in the foreground layer.
- If a target misses, add instances — do not add new mesh types until the instancing budget for existing types is used up.
