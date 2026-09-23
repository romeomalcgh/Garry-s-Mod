ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Anomalous Core"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "AnomalyHealth")
end
