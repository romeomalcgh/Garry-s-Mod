local gamemode = GM

gamemode.Name = "SCP Investigation"
gamemode.Author = "GMod Team"
gamemode.Version = "0.2.0"

SCP = SCP or {}
SCP.Version = gamemode.Version
SCP.MaxPlayers = 3
SCP.EvidenceRequired = 3
SCP.ExtractionRadius = 180
SCP.AnomalyHealth = 100
SCP.StartMap = "gm_construct"

SCP.Workshop = SCP.Workshop or {
    IDs = {}
}

SCP.WeaponLoadout = SCP.WeaponLoadout or {
    "weapon_crowbar",
    "weapon_pistol"
}

SCP.MapPool = SCP.MapPool or {
    "gm_construct"
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
            start = pos + Vector(0, 0, 1024),
            endpos = pos - Vector(0, 0, 2048),
            mask = MASK_SOLID_BRUSHONLY
        })
        return tr.Hit and (tr.HitPos + Vector(0, 0, 1)) or pos
    end

    local function PlaceOnGround(ent, pos)
        if not IsValid(ent) then return end
        local ground = GroundPosition(pos)
        local mins = ent:OBBMins()
        ent:SetPos(ground - Vector(0, 0, mins.z))
    end

    local function SpawnMission()
        gamemode.ExtractionOrigin = ents.Create("info_target")
        gamemode.ExtractionOrigin:SetName("scp_extraction")
        gamemode.ExtractionOrigin:SetPos(GroundPosition(Vector(0, 0, 40)))
        gamemode.ExtractionOrigin:Spawn()

        for i, pos in ipairs({
            Vector(500, 0, 40),
            Vector(0, 500, 40),
            Vector(-500, 0, 40)
        }) do
            local e = ents.Create("scp_evidence")
            e:SetEvidenceId(i)
            e:Spawn()
            PlaceOnGround(e, pos)
        end

        gamemode.Anomaly = ents.Create("scp_anomaly")
        gamemode.Anomaly:Spawn()
        PlaceOnGround(gamemode.Anomaly, Vector(0, 900, 40))
        print("[SCP] Mission spawned")
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
