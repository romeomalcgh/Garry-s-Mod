GM.Name = "SCP Investigation"
GM.Author = "GMod Team"
GM.Version = "0.1.0"
GM.BaseClass = "sandbox"
DeriveGamemode("sandbox")
SCP = SCP or {}
SCP.Version = GM.Version
SCP.MaxPlayers = 3
SCP.EvidenceRequired = 3
SCP.ExtractionRadius = 180
SCP.AnomalyHealth = 100
SCP.StartMap = "gm_construct"
function SCP.IsInvestigator(ply) return IsValid(ply) and ply:IsPlayer() end
function SCP.GetState() return GAMEMODE.SCPState or "briefing" end
