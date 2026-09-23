include("shared.lua")

local function DrawStatue(base, alpha)
    render.SetColorMaterial()
    local concrete = Color(165, 165, 158, alpha)
    local dark = Color(45, 45, 43, alpha)

    render.DrawBox(base + Vector(0, 0, 38), Angle(0, 0, 0), Vector(-16,-12,-34), Vector(16,12,34), concrete)
    render.DrawBox(base + Vector(0, 0, 76), Angle(0, 0, 0), Vector(-13,-11,-13), Vector(13,11,13), concrete)
    render.DrawBox(base + Vector(-25, 0, 40), Angle(0, 0, -8), Vector(-9,-8,-30), Vector(9,8,25), concrete)
    render.DrawBox(base + Vector(25, 0, 40), Angle(0, 0, 8), Vector(-9,-8,-30), Vector(9,8,25), concrete)
    render.DrawBox(base + Vector(-10, 0, 5), Angle(0, 0, -5), Vector(-9,-9,-35), Vector(0,9,0), concrete)
    render.DrawBox(base + Vector(10, 0, 5), Angle(0, 0, 5), Vector(0,-9,-35), Vector(9,9,0), concrete)

    render.DrawSphere(base + Vector(-6,-10,80), 3.2, 12, 8, dark)
    render.DrawSphere(base + Vector(6,-10,80), 3.2, 12, 8, dark)
end

function ENT:Draw()
    local base = self:GetPos()
    local observed = self:GetObserved()
    local contained = self:GetContained()
    local alpha = contained and 55 or 255
    self:SetNoDraw(true)
    DrawStatue(base, alpha)

    if not contained then
        local pulse = 0.5 + math.sin(CurTime() * 5) * 0.5
        render.DrawSprite(base + Vector(0, 0, 92), 16 + pulse * 8, 16 + pulse * 8, Color(210, 205, 190, 40 + pulse * 50))
    end

    cam.Start3D2D(base + Vector(0, 0, 108), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.08)
        local title = contained and "SCP-173  /  CONTAINED" or "SCP-173"
        local state = contained and "SECURED" or (observed and "OBSERVED  /  IMMOBILE" or "UNOBSERVED  /  MOVING")
        draw.SimpleText(title, "DermaDefaultBold", 0, 0, Color(235,235,228,alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(state, "DermaDefault", 0, 18, Color(205,205,195,alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end