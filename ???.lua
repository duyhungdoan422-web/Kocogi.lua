local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local Workspace=game:GetService("Workspace")

Lighting.GlobalShadows=false
Lighting.EnvironmentDiffuseScale=0
Lighting.EnvironmentSpecularScale=0
Lighting.Brightness=1

for _,v in ipairs(Lighting:GetChildren()) do
	if v:IsA("PostEffect") then
		v.Enabled=false
	end
end

local terrain=Workspace:FindFirstChildOfClass("Terrain")
if terrain then
	terrain.Decoration=false
end

local function removeEffects(v)
	if v:IsA("ParticleEmitter")
	or v:IsA("Trail")
	or v:IsA("Beam")
	or v:IsA("Smoke")
	or v:IsA("Fire")
	or v:IsA("Sparkles") then
		v.Enabled=false
	end

	if v:IsA("BasePart") then
		v.CastShadow=false
	end
end

for _,v in ipairs(Workspace:GetDescendants()) do
	removeEffects(v)
end

Workspace.DescendantAdded:Connect(function(v)
	task.defer(function()
		if v.Parent then
			removeEffects(v)
		end
	end)
end)

local function potatoCharacter(character)
	for _,v in ipairs(character:GetChildren()) do
		if v:IsA("Accessory")
		or v:IsA("Shirt")
		or v:IsA("Pants")
		or v:IsA("ShirtGraphic") then
			v:Destroy()
		end
	end

	for _,v in ipairs(character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CastShadow=false
			v.Material=Enum.Material.SmoothPlastic
		elseif v:IsA("Decal") or v:IsA("Texture") then
			v.Transparency=1
		end
	end
end

local function setupPlayer(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(0.2)
		potatoCharacter(character)
	end)

	if player.Character then
		potatoCharacter(player.Character)
	end
end

for _,player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
