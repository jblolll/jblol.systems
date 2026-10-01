-- Remembers which NPCs a player has already met, so first-meeting dialogue plays once per account.
-- Saved in DataService as data.MetNPCs = { [npcName] = true } and mirrored to the client as
-- "Met<npcName>" attributes (e.g. MetJerren).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService = require(game:GetService("ServerScriptService").Modules.DataService)

-- only NPCs listed here can be marked as met
local FIRST_MEETINGS = {
	Jerren = true,
}

local events = ReplicatedStorage:WaitForChild("remotes"):WaitForChild("events")
local npcmet = events:FindFirstChild("npcmet")
if not npcmet then
	npcmet = Instance.new("RemoteEvent")
	npcmet.Name = "npcmet"
	npcmet.Parent = events
end

local function refresh(player)
	local data = DataService:Get(player)
	if not data then
		return
	end
	data.MetNPCs = data.MetNPCs or {}
	for name in FIRST_MEETINGS do
		player:SetAttribute("Met" .. name, data.MetNPCs[name] == true)
	end
end

DataService.Loaded:Connect(refresh)
for _, player in Players:GetPlayers() do
	refresh(player)
end

npcmet.OnServerEvent:Connect(function(player, name)
	if type(name) ~= "string" or not FIRST_MEETINGS[name] then
		return
	end
	local data = DataService:Get(player)
	if not data then
		return
	end
	data.MetNPCs = data.MetNPCs or {}
	if data.MetNPCs[name] then
		return
	end
	data.MetNPCs[name] = true
	player:SetAttribute("Met" .. name, true)
	-- the autosave picks this up within a minute; save now so a quick leave doesn't lose it
	task.spawn(DataService.Save, DataService, player)
end)
