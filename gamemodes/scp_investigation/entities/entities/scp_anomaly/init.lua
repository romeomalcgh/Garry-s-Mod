AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local function IsLookingAtSCP(ply, ent)
    if not IsValid(ply) or not ply:Alive() or not IsValid(ent) then return false end
    local toTarget = ent:WorldSpaceCenter() - ply:EyePos()
    local distance = toTarget:Length()
    if distance > 2200 then return false end
    local dot = ply:GetAimVector():Dot(toTarget:GetNormalized())
    if dot < 0.72 then return false end
    local tr = util.TraceLine({ start = ply:EyePos(), endpos = ent:WorldSpaceCenter(), filter = { ply, ent }, mask = MASK_VISIBLE })
    return not tr.Hit
end

function SCP.IsPlayerLookingAt173(ply, ent)
    return IsLookingAtSCP(ply, ent)
end

local function KillTarget(ply, ent)
    if not IsValid(ply) or not ply:Alive() then return end
    if ply:GetPos():DistToSqr(ent:GetPos()) <= 70 * 70 then
        ply:Kill()
        ent:EmitSound("physics/concrete/concrete_impact_hard3.wav", 75, 75)
    end
end

function ENT:Initialize()
    self:SetModel("models/props_lab/box01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionBounds(Vector(-18, -18, 0), Vector(18, 18, 72))
    self:SetUseType(SIMPLE_USE)
    self:SetObserved(false)
    self:SetContained(false)
    self:SetBehaviorState("searching")
    self:SetNoDraw(false)
    self.NextThinkAt = 0
    self.NextScrape = 0
end

function ENT:IsObserved()
    for _, ply in ipairs(player.GetAll()) do
        if SCP.IsPlayerLookingAt173(ply, self) then return true end
    end
    return false
end

function ENT:FindTarget()
    local best, bestDist
    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() then
            local d = ply:GetPos():DistToSqr(self:GetPos())
            if not bestDist or d < bestDist then best, bestDist = ply, d end
        end
    end
    return best
end

function ENT:Think()
    if self:GetContained() then return end
    local observed = self:IsObserved()
    self:SetObserved(observed)

    if observed then
        self:SetBehaviorState("observed")
        self:NextThink(CurTime() + 0.08)
        return true
    end

    local target = self:FindTarget()
    if not IsValid(target) then
        self:SetBehaviorState("idle")
        self:NextThink(CurTime() + 0.25)
        return true
    end

    self:SetBehaviorState("moving")
    local targetPos = target:GetPos()
    local direction = targetPos - self:GetPos()
    direction.z = 0
    local distance = direction:Length()

    if distance <= 70 then
        KillTarget(target, self)
    elseif distance > 0 then
        direction:Normalize()
        local step = math.min(distance, 42)
        local nextPos = self:GetPos() + direction * step
        local tr = util.TraceHull({ start = self:GetPos() + Vector(0,0,4), endpos = nextPos + Vector(0,0,4), mins = Vector(-14,-14,0), maxs = Vector(14,14,72), filter = self, mask = MASK_SOLID })
        if not tr.Hit then
            self:SetPos(nextPos)
        else
            local side = direction:Angle():Right()
            local sidestep = self:GetPos() + side * 36
            local sideTrace = util.TraceHull({ start = self:GetPos() + Vector(0,0,4), endpos = sidestep + Vector(0,0,4), mins = Vector(-14,-14,0), maxs = Vector(14,14,72), filter = self, mask = MASK_SOLID })
            if not sideTrace.Hit then self:SetPos(sidestep) end
        end
        if CurTime() >= self.NextScrape then
            self:EmitSound("physics/concrete/concrete_scrape_smooth_loop1.wav", 55, math.random(92, 105))
            self.NextScrape = CurTime() + 1.4
        end
    end

    self:NextThink(CurTime() + 0.08)
    return true
end

function ENT:OnTakeDamage(dmg)
    if GAMEMODE.SCPState ~= "containment" then return 0 end
    self:EmitSound("physics/concrete/concrete_impact_hard3.wav", 65, 90)
    return 0
end