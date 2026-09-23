AddCSLuaFile("shared.lua") include("shared.lua")
function ENT:Initialize()
    self:SetModel("models/props_combine/combine_barricade_short01a.mdl") self:PhysicsInit(SOLID_VPHYSICS) self:SetMoveType(MOVETYPE_NONE) self:SetSolid(SOLID_VPHYSICS) self:SetHealth(SCP.AnomalyHealth) self:SetAnomalyHealth(SCP.AnomalyHealth)
end
function ENT:OnTakeDamage(dmg)
    if GAMEMODE.SCPState~="containment" then return 0 end
    local hp=math.max(0,self:Health()-dmg:GetDamage()) self:SetHealth(hp) self:SetAnomalyHealth(hp)
    if hp<=0 then GAMEMODE.SCPState="extraction" SetGlobalInt("SCP_State",3) PrintMessage(HUD_PRINTCENTER,"ANOMALY CONTAINED - RETURN TO EXTRACTION") self:EmitSound("buttons/button14.wav") end
    return dmg:GetDamage()
end
