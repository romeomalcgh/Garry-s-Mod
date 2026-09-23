function GM:CheckExtraction(ply)
    if self.SCPState~="extraction" or not IsValid(self.Anomaly) or self.Anomaly:Health()>0 then return false end
    if IsValid(self.ExtractionOrigin) and ply:GetPos():DistToSqr(self.ExtractionOrigin:GetPos())<=SCP.ExtractionRadius^2 then
        self.SCPState="complete" SetGlobalInt("SCP_State",4) PrintMessage(HUD_PRINTCENTER,"INCIDENT COMPLETE - TEAM EXTRACTED") return true
    end
    return false
end
hook.Add("Think","SCP_InvestigationMissionThink",function()
    if not GAMEMODE or GAMEMODE.SCPState~="extraction" then return end
    for _,ply in ipairs(player.GetAll()) do if GAMEMODE:CheckExtraction(ply) then break end end
end)
