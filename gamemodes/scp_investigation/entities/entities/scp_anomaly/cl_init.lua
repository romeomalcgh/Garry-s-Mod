include("shared.lua")
function ENT:Draw()
    self:DrawModel() local pos=self:GetPos()+Vector(0,0,45) local ang=LocalPlayer():EyeAngles()
    cam.Start3D2D(pos,Angle(0,ang.y,90),0.1) draw.SimpleText("ANOMALY","DermaDefaultBold",0,0,Color(235,80,80),TEXT_ALIGN_CENTER) draw.SimpleText("Containment target","DermaDefault",0,18,Color(210,210,210),TEXT_ALIGN_CENTER) cam.End3D2D()
end
