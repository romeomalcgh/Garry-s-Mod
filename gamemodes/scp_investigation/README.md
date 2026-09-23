# SCP Investigation

First playable vertical slice for the SCP co-op investigation project.

## Current loop

1. Investigate three evidence objects.
2. Use the evidence signal to locate the nearest remaining evidence.
3. After all evidence is secured, the anomaly becomes the containment target.
4. Use the anomaly tracker to locate it.
5. Damage the anomaly until it is contained.
6. Return to extraction.

## HUD systems

- Evidence signal with pulse/heartbeat-style strength and direction.
- Evidence world beacons while investigating.
- Anomaly direction and distance tracker during containment.
- Anomaly world beacon.
- Bodycam toggle: F3.
- Thermal view toggle: F4.

## External weapons and content

The gamemode can use SWEPs supplied by other mounted GMod addons. Set the class names in gamemode/shared.lua:

    SCP.WeaponLoadout = {
        "weapon_crowbar",
        "weapon_pistol",
        -- "your_external_swep"
    }

The addon must be installed/mounted on the server. The gamemode checks that the SWEP exists before giving it to players.

Workshop content can be registered in SCP.Workshop.IDs. resource.AddWorkshop makes custom content downloadable to clients, but it does not install the addon on the server. For server-side use, the addon itself still needs to be installed/mounted.

Maps can be added to SCP.MapPool once they are installed. Mission map profiles will eventually define spawn points and objective locations per map instead of relying on fixed gm_construct coordinates.

## Source of truth

GitHub repository: romeomalcgh/Garry-s-Mod

The repository is the source of truth. The GMod installation on GKI is the test target.
