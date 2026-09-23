include("shared.lua")
function ENT:Draw()
    self:DrawModel() if self:GetInvestigated() then return end
    local pos=self:GetPos()+Vector(0,0,18) local ang=LocalPlayer():EyeAngles()
    cam.Start3D2D(pos,Angle(0,ang.y,90),0.08) draw.SimpleText("EVIDENCE","DermaDefaultBold",0,0,Color(230,230,230),TEXT_ALIGN_CENTER) draw.SimpleText("Press E to investigate","DermaDefault",0,18,Color(180,180,180),TEXT_ALIGN_CENTER) cam.End3D2D()
end
