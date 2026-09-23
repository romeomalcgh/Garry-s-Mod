include("shared.lua")

local evidenceNames = {
    [1] = "SECURITY FOOTAGE",
    [2] = "CONTAINMENT REPORT",
    [3] = "CONCRETE TRACE"
}

function ENT:Draw()
    if self:GetInvestigated() then return end

    self:DrawModel()

    local pos = self:GetPos() + Vector(0, 0, 28)
    local pulse = 0.7 + math.sin(CurTime() * 4) * 0.3

    render.SetColorMaterial()
    render.DrawSphere(pos, 5 + pulse * 2, 12, 8, Color(220, 230, 235, 210))

    cam.Start3D2D(
        self:GetPos() + Vector(0, 0, 36),
        Angle(0, LocalPlayer():EyeAngles().y - 90, 90),
        0.08
    )
        draw.SimpleText(
            "EVIDENCE " .. self:GetEvidenceId(),
            "DermaDefaultBold",
            0,
            0,
            Color(230, 235, 235),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )

        draw.SimpleText(
            evidenceNames[self:GetEvidenceId()] or "UNKNOWN",
            "DermaDefault",
            0,
            14,
            Color(190, 200, 205),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    cam.End3D2D()
end
