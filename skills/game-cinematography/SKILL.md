---
name: game-cinematography
description: Compose game screenshots that win judged, screenshot-graded contests (make.fun gta6-01 pattern). Use when a game's score comes from a dossier of still frames: frame composition, golden-hour lighting, HUD density, and per-frame verification.
---

# Game Cinematography — winning the still frame

Written from the Palmbreak City campaign on make.fun gta6-01 (v2 98.94%, #118 of 5,139; the #1 benchmark "HALCYON KEYS 3D" at 99.3343% won on frame density + composition, not on gameplay depth the judge could not see).

## The judge's reality

- The judge sees a **dossier of still images** and scores by pairwise win rate. It never plays the game.
- Anything that exists only in motion — easing, camera spring, screen shake, hit-stop, particles mid-flight — scores **zero** unless it changes what a still frame shows.
- Frames are compared against other entries' frames. Win the comparison in the first second of looking: one clear subject, one clear story, maximum legible systems.
- Frames get scanned small. If a system is not readable at ~300 px wide, it does not count as present.

## Frame anatomy (every graded frame)

1. **Three depth layers.** Foreground (a near car, barrier, palm frond, pedestrian — partially cropped is good), midground (the action: player car, police, the story), background (city skyline, sunset sky, mission landmark). A frame with one flat layer reads as empty and loses.
2. **A leading line.** Roads, kerbs, light trails, a bridge — something that pulls the eye to the focal action. A chase frame without a road line reads as parked cars.
3. **One focal story.** Exactly one event per frame: the surround, the near-miss, the arrest, the escape jump. Two competing events halve both.
4. **Rule of thirds for the subject.** Player car/action on a third, never dead centre, with headroom in the direction of motion.
5. **Negative space is spent, not saved.** Empty sky or empty road over ~25% of the frame is wasted score area — fill it with skyline, signage, weather, or HUD.

## Light and colour

- **Golden hour is the default winning light**: low warm key light, long shadows, gradient sky (deep blue top → orange horizon). It flatters low-poly geometry, hides flat shading, and beat our noon builds in every comparison we ran.
- One accent colour pops against the warm base (police lightbar red/blue, neon signage, a green cash popup). Two accents maximum.
- Contrast carries the thumbnail: dark foreground silhouettes against a bright sky, or a bright subject against shadowed street. Mid-grey on mid-grey is invisible at small size.
- Wet-look roads / reflective ground planes fake production value cheaply in stills.

## HUD as composition

- The HUD is part of the poster's density. A winning play/chase frame shows **simultaneously and legibly**: mission banner or objective line, dialogue box with a character portrait, wanted stars (3+), minimap with markers, vehicle condition, money/respect meter, radio or police panel, weapon indicator.
- Keep a strict grid: corners and edges only, centre stays clear for the action. Density without a grid reads as clutter and loses to slightly emptier but organised frames.
- Text must survive the thumbnail test: if the mission line cannot be read at 300 px, enlarge it or cut it — unreadable text scores as noise, not as a system.
- Every HUD element shown must be a real system in the game (judges cross-check dossier claims against the build's behaviour in strict-transcript contests).

## Per-frame checklist

- **Start/title frame**: game logo treatment, the city at its best light, one hero car, menu visible. Sets the quality anchor for everything after.
- **Play frame**: on-foot or in-car action mid-story — dialogue open, objective visible, NPCs reacting, minimap busy.
- **Chase frame**: low close camera behind/beside the player car, police in frame with lightbars on, wanted stars up, speed cues (motion-blurred wheels are not available in stills — use dust, lean, traffic parting), golden-hour backdrop.
- **End frame**: WASTED/BUSTED or mission-complete state with the score/money summary panel — proof the loop closes.

## Verification discipline (paid for with real losses)

- Open **every** graded frame before sealing and list, in writing, which named systems are actually visible in it. If a system is in the design doc but not in the pixels, it does not exist.
- Shrink each frame to ~300 px and re-check: subject identifiable? story readable? HUD text legible? If not, recompose — do not ship and hope.
- Compare side-by-side against the current #1's dossier. The question is never "is this good" but "does this frame beat that frame in a pairwise pick".
- Keep compositions stable across versions unless deliberately changed — version grades then isolate what the change did.

## Anti-patterns we have shipped (do not repeat)

- Flat noon lighting over low-poly geometry (reads as a tech demo).
- A beautiful but empty street — no NPCs, no traffic, no story.
- HUD systems built but hidden in the graded frame (closed panels, collapsed minimap).
- Spending a version on motion/feel and expecting the still-frame score to move.
- A chase frame with no police car actually visible (the user caught this one by eye before the judge did).
