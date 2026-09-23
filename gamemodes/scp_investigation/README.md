# SCP Investigation

First playable vertical slice for the SCP co-op investigation project.

## Current incident

The first implemented SCP is **SCP-173**, the Euclid-class Sculpture.

The official SCP-173 entry describes it as an animate, hostile concrete-and-rebar object that cannot move while directly observed. Its containment procedure requires multiple personnel and continuous direct observation while the chamber is entered. This gamemode turns those properties into the core co-op mechanic.

## Current loop

1. Investigate three SCP-173 evidence sources.
2. Follow the evidence locator to find each source.
3. Evidence reveals the incident and unlocks containment.
4. Locate SCP-173.
5. SCP-173 moves only while no living investigator has direct line of sight to it.
6. Keep SCP-173 observed while a player reaches the containment control.
7. The control requires two living observers when two or more players are alive. Solo testing uses one observer.
8. SCP-173 becomes contained.
9. Return to extraction.

## SCP-173 behavior

- Direct line of sight freezes SCP-173.
- If unobserved, SCP-173 moves toward the nearest living investigator.
- It attacks at close range.
- It uses scraping concrete audio while moving.
- Its state is networked as observed, moving, or contained.
- The visual is currently a procedural concrete statue so the entity does not depend on a broken/missing model.

## HUD

- Evidence locator with distance and direction.
- SCP-173 locator after evidence is complete.
- Objective text for containment and extraction.
- Bodycam toggle: F3.
- Thermal toggle: F4.
- World-space evidence and SCP markers.

## External content

Workshop IDs can be registered through SCP.Workshop.IDs. resource.AddWorkshop only makes content downloadable to clients. The addon must still be installed/mounted server-side before its assets can be used.

## Source of truth

GitHub repository: romeomalcgh/Garry-s-Mod

The repository is the source of truth. The GMod installation on GKI is the test target.
