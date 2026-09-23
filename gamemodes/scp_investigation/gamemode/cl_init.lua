include("shared.lua")
hook.Add("HUDPaint","SCP_InvestigationHUD",function()
    local state=SCP.GetState()
    local evidence=GetGlobalInt("SCP_Evidence",0)
    draw.SimpleText(string.format("SCP INVESTIGATION  |  %s  |  Evidence %d/%d",string.upper(state),evidence,SCP.EvidenceRequired),"DermaDefaultBold",24,24,Color(235,235,235))
    local ply=LocalPlayer() if not IsValid(ply) then return end
    local cam=ply:GetNWBool("SCP_Bodycam",true) and "BODYCAM" or "BODYCAM OFF"
    local thermal=ply:GetNWBool("SCP_Thermal",false) and "THERMAL" or "NORMAL"
    draw.SimpleText(cam.."  |  "..thermal,"DermaDefault",24,44,Color(190,190,190))
end)
hook.Add("RenderScreenspaceEffects","SCP_ThermalFX",function()
    local ply=LocalPlayer() if not IsValid(ply) or not ply:GetNWBool("SCP_Thermal",false) then return end
    DrawColorModify({["$pp_colour_addr"]=0.05,["$pp_colour_addg"]=0.12,["$pp_colour_addb"]=0.12,["$pp_colour_brightness"]=0.03,["$pp_colour_contrast"]=1.15,["$pp_colour_colour"]=0.25,["$pp_colour_mulr"]=0.05,["$pp_colour_mulg"]=0.15,["$pp_colour_mulb"]=0.15})
end)
hook.Add("PlayerButtonDown","SCP_InvestigationKeys",function(ply,button)
    if ply~=LocalPlayer() then return end
    if button==KEY_F3 then net.Start("SCP_ToggleBodycam") net.SendToServer() elseif button==KEY_F4 then net.Start("SCP_ToggleThermal") net.SendToServer() end
end)
