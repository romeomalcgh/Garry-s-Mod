AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
GM.SCPState = "investigation"
GM.EvidenceFound = 0
GM.EvidenceRequired = SCP.EvidenceRequired
GM.Anomaly = nil
GM.ExtractionOrigin = nil
include("core/player.lua")
include("core/mission.lua")
local function SpawnMission()
    GM.ExtractionOrigin = ents.Create("info_target")
    GM.ExtractionOrigin:SetName("scp_extraction")
    GM.ExtractionOrigin:SetPos(Vector(0, 0, 40))
    GM.ExtractionOrigin:Spawn()
    for i, pos in ipairs({Vector(500,0,40),Vector(0,500,40),Vector(-500,0,40)}) do
        local e = ents.Create("scp_evidence")
        e:SetPos(pos) e:SetEvidenceId(i) e:Spawn()
    end
    GM.Anomaly = ents.Create("scp_anomaly")
    GM.Anomaly:SetPos(Vector(0,900,40)) GM.Anomaly:Spawn()
end
function GM:Initialize()
    SetGlobalInt("SCP_Evidence", 0) SetGlobalInt("SCP_State", 1)
    timer.Simple(1, SpawnMission)
end
function GM:PlayerInitialSpawn(ply)
    ply:SetTeam(1) ply:SetNWBool("SCP_Bodycam", true) ply:SetNWBool("SCP_Thermal", false) ply:SetNWInt("SCP_Evidence", 0)
end
function GM:PlayerSpawn(ply)
    player_manager.SetPlayerClass(ply, "player_sandbox") player_manager.OnPlayerSpawn(ply)
    ply:Give("weapon_crowbar") ply:Give("weapon_pistol") ply:SetWalkSpeed(160) ply:SetRunSpeed(260)
end
hook.Add("PlayerUse","SCP_InvestigationUse",function(ply,ent)
    if IsValid(ent) and ent:GetClass()=="scp_evidence" then ent:Investigate(ply) return false end
end)
