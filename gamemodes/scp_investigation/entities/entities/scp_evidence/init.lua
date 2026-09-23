AddCSLuaFile("shared.lua") include("shared.lua")
function ENT:Initialize()
    self:SetModel("models/props_lab/box01a.mdl") self:PhysicsInit(SOLID_VPHYSICS) self:SetMoveType(MOVETYPE_NONE) self:SetSolid(SOLID_VPHYSICS) self:SetUseType(SIMPLE_USE) self:SetInvestigated(false)
end
function ENT:Investigate(ply)
    if self:GetInvestigated() then return end
    self:SetInvestigated(true) GAMEMODE.EvidenceFound=GAMEMODE.EvidenceFound+1
    ply:SetNWInt("SCP_Evidence",ply:GetNWInt("SCP_Evidence",0)+1) SetGlobalInt("SCP_Evidence",GAMEMODE.EvidenceFound)
    PrintMessage(HUD_PRINTTALK,ply:Nick().." secured evidence "..self:GetEvidenceId())
    if GAMEMODE.EvidenceFound>=GAMEMODE.EvidenceRequired then GAMEMODE.SCPState="containment" SetGlobalInt("SCP_State",2) PrintMessage(HUD_PRINTCENTER,"EVIDENCE COMPLETE - LOCATE AND CONTAIN THE ANOMALY") end
end
