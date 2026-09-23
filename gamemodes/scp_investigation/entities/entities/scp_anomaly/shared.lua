ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "SCP-173"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Observed")
    self:NetworkVar("Bool", 1, "Contained")
    self:NetworkVar("String", 0, "BehaviorState")
end