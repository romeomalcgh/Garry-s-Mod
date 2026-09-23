AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/reciever01b.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetActive(true)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if GAMEMODE.SCPState ~= "containment" then
        ply:ChatPrint("Containment control is locked. Investigate SCP-173 first.")
        return
    end
    local scp = GAMEMODE.Anomaly
    if not IsValid(scp) or scp:GetContained() then return end
    if ply:GetPos():DistToSqr(scp:GetPos()) > 260 * 260 then
        ply:ChatPrint("SCP-173 is too far from the containment chamber.")
        return
    end
    local observers = 0
    local alivePlayers = 0
    for _, candidate in ipairs(player.GetAll()) do
        if candidate:Alive() then
            alivePlayers = alivePlayers + 1
            if SCP.IsPlayerLookingAt173(candidate, scp) then observers = observers + 1 end
        end
    end
    local required = alivePlayers >= 2 and 2 or 1
    if observers < required then
        ply:ChatPrint("Containment requires "..required.." observer(s) maintaining direct sight of SCP-173.")
        return
    end
    scp:SetContained(true)
    scp:SetObserved(true)
    scp:SetBehaviorState("contained")
    GAMEMODE.SCPState = "extraction"
    SetGlobalInt("SCP_State", 3)
    PrintMessage(HUD_PRINTCENTER, "SCP-173 CONTAINED - RETURN TO EXTRACTION")
    self:EmitSound("buttons/button14.wav", 75, 100)
end