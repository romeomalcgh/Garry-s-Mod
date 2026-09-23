include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    local base = self:GetPos() + Vector(0,0,28)
    render.SetColorMaterial()
    render.DrawWireframeBox(base, self:GetAngles(), Vector(-18,-18,-8), Vector(18,18,8), Color(210,210,190,150), true)
    cam.Start3D2D(self:GetPos() + Vector(0,0,42), Angle(0,LocalPlayer():EyeAngles().y - 90,90), 0.08)
        draw.SimpleText("CONTAINMENT CONTROL", "DermaDefaultBold", 0, 0, Color(230,230,220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("E  /  LOCK SCP-173", "DermaDefault", 0, 18, Color(200,200,190), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end