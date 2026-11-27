# Build a make.fun game contest entry

## Put the standing rules in the builder brief

- Write the standing game rules into the builder brief before any builder starts, because a rule missing from the brief is built wrong and paid for with a rebuild.

- List hand-written WebGL2 as the renderer in the brief, with a real depth buffer and per-fragment lighting and smooth normals and exponential fog.

- List the fallback chain in the brief as WebGL2 first, then WebGL1, then 2D only as insurance, and never use the canvas 2D painter as the main engine.

- Forbid external 3D libraries in the brief, because Three.js fails the authorship gate, and require the WebGL engine to be hand-authored in session.

- List the rank one system density pattern in the brief, with a HUD on every edge and a mission card and stage pips and a full systems page such as a route manifest or flight records page.

- List high-poly high-detail models in the brief, with smooth curved surfaces and dense geometry on heroes, and reject low-poly stylized models.

- List dynamic internal render resolution up to 4K with adaptive step down for frame rate, plus consistent sun and shadows and atmospheric perspective and warm grading and a vignette and procedural texture grain, so no hero surface reads as flat fill.

- List the ultra-HD treatment in the brief, with rich layered realistic art and no flat fills on hero elements and dense living scenes and glossy HD style UI.

- List the realistic build rule in the brief, so realism is a build requirement and not a polish note.

- Add every contest specific rule the user set in the loop into the brief as well, such as a plane that must fly visibly high or rings that must sit close together.

- Check the brief against this list before the builder starts, and fix the brief when a rule is missing instead of fixing the built game later.

## Check the game from its screenshots

- Open every graded screenshot yourself and verify each named system is actually visible in it before you call a version good.

- Name each defect you see before you fix anything, because a fix with no named defect is a guess.

- Verify each placed model part sits on the right axis and points the right way, because axis swaps have turned beaks and aprons and doors sideways and left objects floating with no ground contact.

- Verify each model part against its reference shape before you call it good, and name the part and the wrong axis when a part reads as a different object.

- Show the screenshots to the user before you submit a new game version, because the screenshots are what the judge sees first.

- Submit to save the round only when a blind round cutoff is imminent and the user has not replied, and show the screenshots immediately after that submit.

- Follow the makefun playbook for quota order and authorship and bundle and submit verification, and follow makefun finisher recovery when a builder stops on a security flag.

## Polish from named defects and stop on time

- Start each polish round from a named defect list taken from user feedback or from your own screenshot check.

- Treat a vague request to improve the game as a request for a defect list, not as a round, and ask the user to name the worst defect or name it yourself from the screenshots.

- Cap polish at three rounds per version, because returns shrink after that and the cutoff does not move.

- Rebuild from zero when the user orders a stop to patching, and do not keep patching a version the user told you to abandon.

- Decide submit or stop before the round cutoff, with enough time left to submit and verify the entry, and never let a polish round run past that point.

- Report the decision with the version and the remaining defects and the time left, so the user sees why the entry went in as it stands or why it stopped.

## Available connectors

- Use `muse.connector_search` to find other connectors and `muse.skill_search` to find related skills.

- If nothing here fits, look on the web for a maintained API or MCP server and set it up with [Custom Connectors and MCPs](/opt/muse/skills/custom-connector-setup/SKILL.md), or build a custom connector.

## Websites

- [make.fun](https://make.fun/) for reading the contest status and the round cutoff and the submission stage after you bundle and submit.

## Alternatives for better results

- Ask the user to name the single worst defect when they ask for another polish round, so the round has one clear target.

- Reuse a proven game pattern from an earlier entry only by re-implementing it from a behavioural spec, and never by reading the earlier entry code.
