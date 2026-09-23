ENT.Type="anim"
ENT.Base="base_anim"
ENT.PrintName="Investigation Evidence"
ENT.Spawnable=false
function ENT:SetupDataTables()
    self:NetworkVar("Int",0,"EvidenceId") self:NetworkVar("Bool",0,"Investigated")
end
