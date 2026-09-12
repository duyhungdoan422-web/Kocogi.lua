local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local ESP_COLOR = Color3.fromRGB(0, 255, 0)

local espObjects = {}

local function cleanup(player)
	local data = espObjects[player]
	if not data then
		return
	end

	if data.connection then
		data.connection:Disconnect()
	end

	if data.box then
		data.box:Destroy()
	end

	if data.beam then
		data.beam:Destroy()
	end

	if data.attachment then
		data.attachment:Destroy()
	end

	if data.targetAttachment then
		data.targetAttachment:Destroy()
	end

	espObjects[player] = nil
end

local function createESP(player)
	if player == LocalPlayer then
		return
	end

	cleanup(player)

	local function setupCharacter(character)
		cleanup(player)

		local humanoid = character:WaitForChild("Humanoid", 5)
		local root = character:WaitForChild("HumanoidRootPart", 5)

		if not humanoid or not root then
			return
		end

		local box = Instance.new("Highlight")
		box.Name = "GreenESP"
		box.Adornee = character
		box.FillTransparency = 1
		box.OutlineColor = ESP_COLOR
		box.OutlineTransparency = 0
		box.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		box.Parent = character

		local myCharacter = LocalPlayer.Character
		local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")

		local attachment

		if myRoot then
			attachment = Instance.new("Attachment")
			attachment.Name = "ESPOrigin"
			attachment.Position = Vector3.new(0, -3, 0)
			attachment.Parent = myRoot
		end

		local targetAttachment = Instance.new("Attachment")
		targetAttachment.Name = "ESPTarget"
		targetAttachment.Position = Vector3.new(0, -3, 0)
		targetAttachment.Parent = root

		local beam

		if attachment then
			beam = Instance.new("Beam")
			beam.Name = "ESPLaser"
			beam.Attachment0 = attachment
			beam.Attachment1 = targetAttachment
			beam.Color = ColorSequence.new(ESP_COLOR)
			beam.Width0 = 0.04
			beam.Width1 = 0.04
			beam.FaceCamera = true
			beam.LightEmission = 1
			beam.Transparency = NumberSequence.new(0.15)
			beam.Parent = root
		end

		local connection

		connection = RunService.RenderStepped:Connect(function()
			if not player.Parent
				or not character.Parent
				or humanoid.Health <= 0 then

				cleanup(player)
				return
			end

			local currentCharacter = LocalPlayer.Character
			local currentRoot = currentCharacter
				and currentCharacter:FindFirstChild("HumanoidRootPart")

			if attachment and currentRoot
				and attachment.Parent ~= currentRoot then
				attachment.Parent = currentRoot
			end

			if humanoid.Health <= 0 and beam then
				beam:Destroy()
				beam = nil
			end
		end)

		espObjects[player] = {
			connection = connection,
			box = box,
			beam = beam,
			attachment = attachment,
			targetAttachment = targetAttachment
		}
	end

	if player.Character then
		setupCharacter(player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		setupCharacter(character)
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	createESP(player)
end

Players.PlayerAdded:Connect(function(player)
	createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
	cleanup(player)
end)
