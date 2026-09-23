AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/box01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetInvestigated(false)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local colors = {
        [1] = Color(190, 205, 215),
        [2] = Color(205, 195, 160),
        [3] = Color(185, 210, 195)
    }

    self:SetColor(colors[self:GetEvidenceId()] or Color(220, 220, 220))
end

function ENT:Investigate(ply)
    if self:GetInvestigated() then return end

    self:SetInvestigated(true)
    GAMEMODE.EvidenceFound = GAMEMODE.EvidenceFound + 1

    ply:SetNWInt("SCP_Evidence", ply:GetNWInt("SCP_Evidence", 0) + 1)
    SetGlobalInt("SCP_Evidence", GAMEMODE.EvidenceFound)

    self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self:SetColor(Color(255, 255, 255, 90))

    PrintMessage(
        HUD_PRINTTALK,
        ply:Nick() .. " secured evidence " .. self:GetEvidenceId()
    )

    if GAMEMODE.EvidenceFound >= GAMEMODE.EvidenceRequired then
        GAMEMODE.SCPState = "containment"
        SetGlobalInt("SCP_State", 2)
        PrintMessage(
            HUD_PRINTCENTER,
            "EVIDENCE COMPLETE - LOCATE AND CONTAIN THE ANOMALY"
        )
    end
end
