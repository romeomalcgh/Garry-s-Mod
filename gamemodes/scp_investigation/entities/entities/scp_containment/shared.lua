ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "SCP-173 Containment Control"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Active")
end