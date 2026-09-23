include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local base = self:GetPos() + Vector(0, 0, 34)
    local pulse = 0.8 + math.sin(CurTime() * 3) * 0.2
    local hp = self:GetAnomalyHealth()

    render.SetColorMaterial()

    for i = 1, 3 do
        local radius = 18 + i * 7 + math.sin(CurTime() * 2 + i) * 3
        render.DrawWireframeSphere(
            base,
            radius,
            24,
            12,
            Color(180, 35, 35, math.max(30, 130 - i * 25))
        )
    end

    render.DrawSprite(
        base,
        55 * pulse,
        55 * pulse,
        Color(235, 55, 45, 180)
    )

    cam.Start3D2D(
        self:GetPos() + Vector(0, 0, 92),
        Angle(0, LocalPlayer():EyeAngles().y - 90, 90),
        0.1
    )
        draw.SimpleText(
            "ANOMALOUS CORE",
            "DermaDefaultBold",
            0,
            0,
            Color(255, 210, 205),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )

        draw.SimpleText(
            "THREAT " .. math.max(0, hp) .. "%",
            "DermaDefault",
            0,
            16,
            Color(220, 185, 180),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    cam.End3D2D()
end
