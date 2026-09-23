include("shared.lua")

local pulse = 0
local pulseStart = 0

surface.CreateFont("SCP_HUD_Title", {font="Tahoma", size=20, weight=800, antialias=true})
surface.CreateFont("SCP_HUD_Body", {font="Tahoma", size=16, weight=600, antialias=true})
surface.CreateFont("SCP_HUD_Small", {font="Tahoma", size=13, weight=500, antialias=true})

local function FormatDistance(units)
    if units < 100 then return string.format("%dm", units * 0.01905) end
    return string.format("%dm", math.floor(units * 0.01905))
end

local function GetEvidenceInfo(ply)
    local nearest, nearestDist
    for _, ent in ipairs(ents.FindByClass("scp_evidence")) do
        if not IsValid(ent) or ent:GetInvestigated() then continue end
        local d = ply:GetPos():Distance(ent:GetPos())
        if not nearestDist or d < nearestDist then
            nearest, nearestDist = ent, d
        end
    end
    return nearest, nearestDist
end

local function DrawPanel(x, y, w, h, alpha)
    surface.SetDrawColor(8, 12, 15, alpha or 210)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(100, 110, 115, 100)
    surface.DrawOutlinedRect(x, y, w, h, 1)
end

hook.Add("HUDPaint", "SCP_InvestigationHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local state = SCP.GetState()
    local evidence = GetGlobalInt("SCP_Evidence", 0)
    local anomaly = ents.FindByClass("scp_anomaly")[1]
    local evidenceEnt, evidenceDist = GetEvidenceInfo(ply)

    DrawPanel(20, 20, 370, 118)
    draw.SimpleText("SCP INVESTIGATION", "SCP_HUD_Title", 34, 32, Color(235,235,235))
    draw.SimpleText(string.upper(state) .. "  |  EVIDENCE " .. evidence .. "/" .. SCP.EvidenceRequired,
        "SCP_HUD_Body", 34, 60, Color(195,205,205))

    if state == "investigation" and IsValid(evidenceEnt) then
        local targetPos = evidenceEnt:GetPos() + Vector(0,0,12)
        local dir = (targetPos - ply:GetShootPos()):GetNormalized()
        local dot = math.Clamp(ply:EyeAngles():Forward():Dot(dir), -1, 1)
        local angle = math.deg(math.acos(dot))
        local side = ply:EyeAngles():Right():Dot(dir)
        local arrow = side >= 0 and ">" or "<"

        local rate = math.Clamp(2.8 - evidenceDist / 600, 0.55, 2.8)
        pulse = math.sin((CurTime() - pulseStart) * math.pi * 2 * rate)
        local bars = math.Clamp(math.floor((pulse + 1) * 3), 1, 6)

        draw.SimpleText("EVIDENCE SIGNAL", "SCP_HUD_Small", 34, 88, Color(150,160,160))
        draw.SimpleText(arrow .. "  " .. FormatDistance(evidenceDist) .. "  " .. string.rep("|", bars),
            "SCP_HUD_Body", 150, 84, Color(215,225,225))
        draw.SimpleText(angle < 20 and "TARGET AHEAD" or "FOLLOW SIGNAL",
            "SCP_HUD_Small", 34, 108, Color(170,180,180))
    elseif state == "containment" and IsValid(anomaly) then
        local targetPos = anomaly:GetPos()
        local dir = (targetPos - ply:GetShootPos()):GetNormalized()
        local side = ply:EyeAngles():Right():Dot(dir)
        local arrow = math.abs(side) < 0.18 and "^" or (side > 0 and ">" or "<")
        draw.SimpleText("ANOMALY", "SCP_HUD_Small", 34, 88, Color(160,160,160))
        draw.SimpleText(arrow .. "  " .. FormatDistance(ply:GetPos():Distance(targetPos)),
            "SCP_HUD_Body", 150, 84, Color(225,210,180))
        draw.SimpleText("CONTAINMENT TARGET", "SCP_HUD_Small", 34, 108, Color(180,175,165))
    elseif state == "extraction" then
        draw.SimpleText("EXTRACTION", "SCP_HUD_Small", 34, 88, Color(160,160,160))
        draw.SimpleText("RETURN TO BASE", "SCP_HUD_Body", 150, 84, Color(215,225,225))
    end

    local cam = ply:GetNWBool("SCP_Bodycam", true) and "BODYCAM" or "BODYCAM OFF"
    local thermal = ply:GetNWBool("SCP_Thermal", false) and "THERMAL" or "NORMAL"
    draw.SimpleText(cam .. "  |  " .. thermal, "SCP_HUD_Small", 34, 125, Color(135,145,145))
end)

hook.Add("RenderScreenspaceEffects", "SCP_ThermalFX", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:GetNWBool("SCP_Thermal", false) then return end
    DrawColorModify({
        ["$pp_colour_addr"]=0.05, ["$pp_colour_addg"]=0.12, ["$pp_colour_addb"]=0.12,
        ["$pp_colour_brightness"]=0.03, ["$pp_colour_contrast"]=1.15,
        ["$pp_colour_colour"]=0.25, ["$pp_colour_mulr"]=0.05,
        ["$pp_colour_mulg"]=0.15, ["$pp_colour_mulb"]=0.15
    })
end)

hook.Add("PostDrawTranslucentRenderables", "SCP_ObjectiveBeacons", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    if SCP.GetState() == "investigation" then
        for _, ent in ipairs(ents.FindByClass("scp_evidence")) do
            if not IsValid(ent) or ent:GetInvestigated() then continue end
            local d = ply:GetPos():Distance(ent:GetPos())
            if d > 1600 then continue end
            local pos = ent:GetPos() + Vector(0,0,24)
            render.SetColorMaterial()
            render.DrawSprite(pos, 18, 18, Color(210, 220, 220, math.Clamp(255 - d * 0.12, 40, 220)))
        end
    elseif SCP.GetState() == "containment" then
        local ent = ents.FindByClass("scp_anomaly")[1]
        if IsValid(ent) then
            local d = ply:GetPos():Distance(ent:GetPos())
            if d < 3000 then
                render.SetColorMaterial()
                render.DrawSprite(ent:GetPos() + Vector(0,0,60), 34, 34, Color(220, 180, 100, math.Clamp(255 - d * 0.05, 50, 230)))
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
