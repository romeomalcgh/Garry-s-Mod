include("shared.lua")

surface.CreateFont("SCP_HUD_Title", {
    font = "Tahoma",
    size = 20,
    weight = 800,
    antialias = true
})

surface.CreateFont("SCP_HUD_Body", {
    font = "Tahoma",
    size = 17,
    weight = 700,
    antialias = true
})

surface.CreateFont("SCP_HUD_Small", {
    font = "Tahoma",
    size = 13,
    weight = 600,
    antialias = true
})

surface.CreateFont("SCP_HUD_Locator", {
    font = "Tahoma",
    size = 25,
    weight = 900,
    antialias = true
})

local function FormatDistance(units)
    return string.format("%dm", math.max(0, math.floor(units * 0.01905)))
end

local function GetNearestEvidence(ply)
    local nearest
    local nearestDist

    for _, ent in ipairs(ents.FindByClass("scp_evidence")) do
        if not IsValid(ent) or ent:GetInvestigated() then continue end

        local dist = ply:GetPos():Distance(ent:GetPos())
        if not nearestDist or dist < nearestDist then
            nearest = ent
            nearestDist = dist
        end
    end

    return nearest, nearestDist
end

local function DrawPanel(x, y, w, h)
    surface.SetDrawColor(8, 11, 13, 225)
    surface.DrawRect(x, y, w, h)

    surface.SetDrawColor(110, 120, 125, 130)
    surface.DrawOutlinedRect(x, y, w, h, 1)
end

local function DrawLocator(ply, target, label, color)
    if not IsValid(target) then return end

    local targetPos = target:GetPos() + Vector(0, 0, 28)
    local toTarget = targetPos - ply:GetShootPos()
    local distance = toTarget:Length()
    local direction = toTarget:GetNormalized()
    local forward = ply:EyeAngles():Forward()
    local right = ply:EyeAngles():Right()

    local dot = math.Clamp(forward:Dot(direction), -1, 1)
    local angle = math.deg(math.acos(dot))
    local side = right:Dot(direction)

    local arrow
    if angle < 12 then
        arrow = "TARGET"
    elseif side > 0 then
        arrow = ">"
    else
        arrow = "<"
    end

    local x = ScrW() * 0.5
    local y = ScrH() - 115

    surface.SetDrawColor(8, 11, 13, 235)
    surface.DrawRect(x - 135, y - 34, 270, 72)

    surface.SetDrawColor(color.r, color.g, color.b, 180)
    surface.DrawOutlinedRect(x - 135, y - 34, 270, 72, 1)

    draw.SimpleText(
        label,
        "SCP_HUD_Small",
        x,
        y - 23,
        color,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    draw.SimpleText(
        arrow .. "  " .. FormatDistance(distance),
        "SCP_HUD_Locator",
        x,
        y + 5,
        color,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )
end

hook.Add("HUDPaint", "SCP_InvestigationHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local state = SCP.GetState()
    local evidence = GetGlobalInt("SCP_Evidence", 0)
    local evidenceEnt = GetNearestEvidence(ply)

    DrawPanel(20, 20, 390, 126)

    draw.SimpleText(
        "SCP INVESTIGATION",
        "SCP_HUD_Title",
        34,
        32,
        Color(235, 235, 235)
    )

    draw.SimpleText(
        string.upper(state) .. "  |  EVIDENCE " .. evidence .. "/" .. SCP.EvidenceRequired,
        "SCP_HUD_Body",
        34,
        60,
        Color(195, 205, 205)
    )

    if state == "investigation" and IsValid(evidenceEnt) then
        local dist = ply:GetPos():Distance(evidenceEnt:GetPos())
        local pulse = 0.5 + math.sin(CurTime() * math.Clamp(4 - dist / 900, 0.7, 4)) * 0.5

        draw.SimpleText(
            "EVIDENCE LOCATOR",
            "SCP_HUD_Small",
            34,
            91,
            Color(165, 175, 180)
        )

        draw.SimpleText(
            FormatDistance(dist) .. "  " .. string.rep("|", math.Clamp(math.floor(pulse * 6), 1, 6)),
            "SCP_HUD_Body",
            175,
            87,
            Color(220, 230, 235)
        )

        draw.SimpleText(
            "Follow the locator at the bottom of the screen",
            "SCP_HUD_Small",
            34,
            114,
            Color(150, 160, 165)
        )

        DrawLocator(ply, evidenceEnt, "NEXT EVIDENCE", Color(220, 230, 235))
    elseif state == "containment" then
        local anomaly = ents.FindByClass("scp_anomaly")[1]
        local control = ents.FindByClass("scp_containment")[1]

        draw.SimpleText(
            "OBJECTIVE",
            "SCP_HUD_Small",
            34,
            91,
            Color(165, 175, 180)
        )

        draw.SimpleText(
            "CONTAIN SCP-173",
            "SCP_HUD_Body",
            120,
            87,
            Color(235, 205, 195)
        )

        DrawLocator(ply, anomaly, "SCP-173", Color(235, 95, 85))
        if IsValid(control) then
            draw.SimpleText("Use the containment control while the team keeps SCP-173 in sight", "SCP_HUD_Small", 34, 111, Color(175, 165, 160))
        end
    elseif state == "extraction" then
        local extraction = ents.FindByName("scp_extraction")[1]

        draw.SimpleText(
            "OBJECTIVE",
            "SCP_HUD_Small",
            34,
            91,
            Color(165, 175, 180)
        )

        draw.SimpleText(
            "RETURN TO EXTRACTION",
            "SCP_HUD_Body",
            120,
            87,
            Color(220, 230, 235)
        )

        DrawLocator(ply, extraction, "EXTRACTION", Color(220, 230, 235))
    end

    local bodycam = ply:GetNWBool("SCP_Bodycam", true) and "BODYCAM" or "BODYCAM OFF"
    local thermal = ply:GetNWBool("SCP_Thermal", false) and "THERMAL" or "NORMAL"

    draw.SimpleText(
        bodycam .. "  |  " .. thermal,
        "SCP_HUD_Small",
        34,
        130,
        Color(135, 145, 150)
    )
end)

hook.Add("RenderScreenspaceEffects", "SCP_ThermalFX", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:GetNWBool("SCP_Thermal", false) then return end

    DrawColorModify({
        ["$pp_colour_addr"] = 0.05,
        ["$pp_colour_addg"] = 0.12,
        ["$pp_colour_addb"] = 0.12,
        ["$pp_colour_brightness"] = 0.03,
        ["$pp_colour_contrast"] = 1.15,
        ["$pp_colour_colour"] = 0.25,
        ["$pp_colour_mulr"] = 0.05,
        ["$pp_colour_mulg"] = 0.15,
        ["$pp_colour_mulb"] = 0.15
    })
end)

hook.Add("PostDrawTranslucentRenderables", "SCP_ObjectiveBeacons", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local state = SCP.GetState()

    if state == "investigation" then
        for _, ent in ipairs(ents.FindByClass("scp_evidence")) do
            if not IsValid(ent) or ent:GetInvestigated() then continue end

            local distance = ply:GetPos():Distance(ent:GetPos())
            if distance > 3000 then continue end

            render.SetColorMaterial()
            render.DrawSprite(
                ent:GetPos() + Vector(0, 0, 46),
                20,
                20,
                Color(220, 230, 235, math.Clamp(255 - distance * 0.06, 40, 220))
            )
        end
    elseif state == "containment" then
        local ent = ents.FindByClass("scp_anomaly")[1]

        if IsValid(ent) then
            local distance = ply:GetPos():Distance(ent:GetPos())

            if distance < 4000 then
                render.SetColorMaterial()
                render.DrawSprite(
                    ent:GetPos() + Vector(0, 0, 110),
                    38,
                    38,
                    Color(235, 70, 55, math.Clamp(255 - distance * 0.04, 50, 230))
                )
            end
        end
    end
end)

hook.Add("PlayerButtonDown", "SCP_InvestigationKeys", function(ply, button)
    if ply ~= LocalPlayer() then return end

    if button == KEY_F3 then
        net.Start("SCP_ToggleBodycam")
        net.SendToServer()
    elseif button == KEY_F4 then
        net.Start("SCP_ToggleThermal")
        net.SendToServer()
    end
end)
