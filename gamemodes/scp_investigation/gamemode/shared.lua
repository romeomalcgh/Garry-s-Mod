local gamemode = GM

gamemode.Name = "SCP Investigation"
gamemode.Author = "GMod Team"
gamemode.Version = "0.3.0"

SCP = SCP or {}
SCP.Version = gamemode.Version
SCP.MaxPlayers = 3
SCP.EvidenceRequired = 3
SCP.ExtractionRadius = 180
SCP.AnomalyHealth = 100
SCP.StartMap = "gm_boreas"
SCP.MissionMinSeparation = 2200
SCP.MissionMaxCandidates = 5000

SCP.Workshop = SCP.Workshop or {
    IDs = { "1572373847" }
}

SCP.WeaponLoadout = SCP.WeaponLoadout or {
    "weapon_crowbar",
    "weapon_pistol"
}

SCP.MapPool = SCP.MapPool or {
    "gm_boreas",
    "gm_fork"
}

function SCP.IsInvestigator(ply)
    return IsValid(ply) and ply:IsPlayer()
end

function SCP.GetState()
    return GAMEMODE and GAMEMODE.SCPState or "briefing"
end

if SERVER then
    util.AddNetworkString("SCP_ToggleBodycam")
    util.AddNetworkString("SCP_ToggleThermal")

    for _, workshopId in ipairs(SCP.Workshop.IDs) do
        if tostring(workshopId):match("^%d+$") then
            resource.AddWorkshop(tostring(workshopId))
        end
    end

    gamemode.SCPState = "investigation"
    gamemode.EvidenceFound = 0
    gamemode.EvidenceRequired = SCP.EvidenceRequired
    gamemode.Anomaly = nil
    gamemode.ExtractionOrigin = nil

    local function GroundPosition(pos)
        local tr = util.TraceLine({
            start = pos + Vector(0, 0, 256),
            endpos = pos - Vector(0, 0, 512),
            mask = MASK_SOLID_BRUSHONLY
        })
        if tr.Hit then
            return tr.HitPos + Vector(0, 0, 2)
        end
        return pos
    end

    local function PlaceOnGround(ent, pos)
        if not IsValid(ent) then return end
        local ground = GroundPosition(pos)
        local mins = ent:OBBMins()
        ent:SetPos(ground - Vector(0, 0, mins.z))
        ent:DropToFloor()
        ent:SetPos(ent:GetPos() + Vector(0, 0, 2))
    end

    local function GetSpawnOrigin()
        local classes = {
            "info_player_start",
            "info_player_deathmatch",
            "gmod_player_start"
        }

        for _, class in ipairs(classes) do
            for _, spawn in ipairs(ents.FindByClass(class)) do
                if IsValid(spawn) then
                    return spawn:GetPos()
                end
            end
        end

        return Vector(0, 0, 64)
    end

    local function GetMissionCandidates(origin)
        if game.GetMap() == "gm_construct" then
            return {
                GroundPosition(origin + Vector(700, 0, 0)),
                GroundPosition(origin + Vector(-700, 0, 0)),
                GroundPosition(origin + Vector(0, 700, 0)),
                GroundPosition(origin + Vector(0, -700, 0)),
                GroundPosition(origin + Vector(1100, 900, 0)),
                GroundPosition(origin + Vector(-1100, -900, 0))
            }
        end

        local candidates = {}
        local areas = navmesh.GetAllNavAreas()

        for _, area in ipairs(areas) do
            if #candidates >= SCP.MissionMaxCandidates then break end
            if IsValid(area) and not area:IsBlocked() and not area:IsUnderwater() then
                local p = area:GetCenter()
                local ground = navmesh.GetGroundHeight(p)

                if ground
                    and math.abs(ground - p.z) < 256
                    and util.IsInWorld(Vector(p.x, p.y, ground))
                    and p:DistToSqr(origin) > 90000 then
                    candidates[#candidates + 1] = Vector(p.x, p.y, ground + 4)
                end
            end
        end

        return candidates
    end

    local function PickFarthest(candidates, used)
        local best, bestScore

        for _, p in ipairs(candidates) do
            local score = math.huge

            for _, u in ipairs(used) do
                score = math.min(score, p:Distance(u))
            end

            if score >= SCP.MissionMinSeparation and (not bestScore or score > bestScore) then
                best = p
                bestScore = score
            end
        end

        return best
    end

    local function BuildMissionLayout()
        local extraction = GetSpawnOrigin()
        local candidates = GetMissionCandidates(extraction)

        if #candidates < 4 then
            candidates = {
                extraction + Vector(3000, 0, 0),
                extraction + Vector(-3000, 0, 0),
                extraction + Vector(0, 3000, 0),
                extraction + Vector(0, -3000, 0),
                extraction + Vector(4500, 4500, 0)
            }
        end

        local points = {}
        local used = { extraction }

        for i = 1, 4 do
            local p = PickFarthest(candidates, used)

            if not p then
                p = candidates[((i - 1) % #candidates) + 1]
            end

            points[i] = p
            used[#used + 1] = p
        end

        return extraction, points
    end

    local function SpawnMission()
        local extractionPos, points = BuildMissionLayout()

        gamemode.ExtractionOrigin = ents.Create("info_target")
        gamemode.ExtractionOrigin:SetName("scp_extraction")
        gamemode.ExtractionOrigin:SetPos(GroundPosition(extractionPos))
        gamemode.ExtractionOrigin:Spawn()

        local evidenceModels = {
            "models/props_lab/box01a.mdl",
            "models/props_lab/box01a.mdl",
            "models/props_lab/box01a.mdl"
        }

        for i = 1, 3 do
            local e = ents.Create("scp_evidence")
            e:SetEvidenceId(i)
            e:SetModel(evidenceModels[i])
            e:Spawn()
            PlaceOnGround(e, points[i])
        end

        gamemode.Anomaly = ents.Create("scp_anomaly")
        gamemode.Anomaly:Spawn()
        PlaceOnGround(gamemode.Anomaly, points[4])

        print(string.format(
            "[SCP] Mission spawned on %s | navmesh=%d | extraction=%s | evidence=%s / %s / %s | anomaly=%s",
            game.GetMap(),
            #navmesh.GetAllNavAreas(),
            tostring(extractionPos),
            tostring(points[1]),
            tostring(points[2]),
            tostring(points[3]),
            tostring(points[4])
        ))
    end

    function gamemode:Initialize()
        SetGlobalInt("SCP_Evidence", 0)
        SetGlobalInt("SCP_State", 1)
        timer.Simple(1, SpawnMission)
    end

    function gamemode:PlayerInitialSpawn(ply)
        ply:SetTeam(1)
        ply:SetNWBool("SCP_Bodycam", true)
        ply:SetNWBool("SCP_Thermal", false)
        ply:SetNWInt("SCP_Evidence", 0)
    end

    function gamemode:PlayerSpawn(ply)
        player_manager.SetPlayerClass(ply, "player_sandbox")
        player_manager.OnPlayerSpawn(ply)

        timer.Simple(0, function()
            if not IsValid(ply) then return end

            for _, class in ipairs(SCP.WeaponLoadout) do
                if weapons.Get(class) then
                    ply:Give(class)
                else
                    print("[SCP] Loadout weapon unavailable: " .. tostring(class))
                end
            end

            ply:SetWalkSpeed(160)
            ply:SetRunSpeed(260)
        end)
    end

    function gamemode:CheckExtraction(ply)
        if self.SCPState ~= "extraction" then return false end
        if not IsValid(self.Anomaly) or self.Anomaly:Health() > 0 then return false end

        if IsValid(self.ExtractionOrigin)
            and ply:GetPos():DistToSqr(self.ExtractionOrigin:GetPos()) <= SCP.ExtractionRadius ^ 2 then
            self.SCPState = "complete"
            SetGlobalInt("SCP_State", 4)
            PrintMessage(HUD_PRINTCENTER, "INCIDENT COMPLETE - TEAM EXTRACTED")
            return true
        end

        return false
    end

    hook.Add("PlayerUse", "SCP_InvestigationUse", function(ply, ent)
        if IsValid(ent) and ent:GetClass() == "scp_evidence" then
            ent:Investigate(ply)
            return false
        end
    end)

    hook.Add("Think", "SCP_InvestigationMissionThink", function()
        if not GAMEMODE or GAMEMODE.SCPState ~= "extraction" then return end

        for _, ply in ipairs(player.GetAll()) do
            if GAMEMODE:CheckExtraction(ply) then break end
        end
    end)

    net.Receive("SCP_ToggleBodycam", function(_, ply)
        ply:SetNWBool("SCP_Bodycam", not ply:GetNWBool("SCP_Bodycam", true))
    end)

    net.Receive("SCP_ToggleThermal", function(_, ply)
        ply:SetNWBool("SCP_Thermal", not ply:GetNWBool("SCP_Thermal", false))
    end)

    hook.Add("PlayerDeath", "SCP_InvestigationDeath", function(ply)
        ply:SetNWBool("SCP_Bodycam", true)
        ply:SetNWBool("SCP_Thermal", false)
    end)
end

DeriveGamemode("sandbox")
