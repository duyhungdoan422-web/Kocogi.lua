local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local ESP_COLOR = Color3.fromRGB(0, 255, 0)

local RAINBOW = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(255, 127, 0),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 170, 255),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(170, 0, 255)
}

local espObjects = {}

local statsGui = Instance.new("ScreenGui")
statsGui.Name = "ESPStats"
statsGui.ResetOnSpawn = false
statsGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.fromOffset(220, 35)
statsLabel.Position = UDim2.fromOffset(10, 10)
statsLabel.BackgroundTransparency = 1
statsLabel.TextColor3 = ESP_COLOR
statsLabel.TextStrokeTransparency = 0
statsLabel.TextSize = 20
statsLabel.Font = Enum.Font.SourceSansBold
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = statsGui

local vipLabel = Instance.new("TextLabel")
vipLabel.Name = "ESPVIP"
vipLabel.Size = UDim2.fromOffset(160, 30)
vipLabel.Position = UDim2.new(1, -170, 0, 10)
vipLabel.BackgroundTransparency = 1
vipLabel.Text = "ESP VIP"
vipLabel.TextSize = 22
vipLabel.Font = Enum.Font.SourceSansBold
vipLabel.TextStrokeTransparency = 0
vipLabel.TextXAlignment = Enum.TextXAlignment.Right
vipLabel.Parent = statsGui

task.spawn(function()
	local index = 1

	while vipLabel.Parent do
		vipLabel.TextColor3 = RAINBOW[index]
		index = index % #RAINBOW + 1
		task.wait(0.3)
	end
end)

local function updateStats()
	statsLabel.Text = "Players: " .. #Players:GetPlayers()
end

local function cleanup(player)
	local data = espObjects[player]

	if not data then
		return
	end

	if data.renderConnection then
		data.renderConnection:Disconnect()
	end

	if data.characterConnection then
		data.characterConnection:Disconnect()
	end

	if data.colorConnection then
		data.colorConnection:Disconnect()
	end

	for _, object in ipairs(data.objects or {}) do
		if object then
			object:Destroy()
		end
	end

	espObjects[player] = nil
end

local function setupCharacter(player, character)
	if player == LocalPlayer then
		return
	end

	local old = espObjects[player]

	if old then
		if old.renderConnection then
			old.renderConnection:Disconnect()
		end

		if old.colorConnection then
			old.colorConnection:Disconnect()
		end

		for _, object in ipairs(old.objects or {}) do
			if object then
				object:Destroy()
			end
		end
	end

	local humanoid = character:WaitForChild("Humanoid", 10)
	local root = character:WaitForChild("HumanoidRootPart", 10)

	if not humanoid or not root or not character.Parent then
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

	local nameLabel = Instance.new("BillboardGui")
	nameLabel.Name = "UsernameESP"
	nameLabel.Adornee = root
	nameLabel.Size = UDim2.fromOffset(180, 30)
	nameLabel.StudsOffset = Vector3.new(0, 3, 0)
	nameLabel.AlwaysOnTop = true
	nameLabel.Parent = character

	local nameText = Instance.new("TextLabel")
	nameText.Size = UDim2.fromScale(1, 1)
	nameText.BackgroundTransparency = 1
	nameText.Text = player.Name
	nameText.TextColor3 = RAINBOW[1]
	nameText.TextStrokeTransparency = 0
	nameText.TextSize = 16
	nameText.Font = Enum.Font.SourceSansBold
	nameText.Parent = nameLabel

	local colorConnection = nil

	colorConnection = task.spawn(function()
		local index = 1

		while nameText.Parent do
			nameText.TextColor3 = RAINBOW[index]
			index = index % #RAINBOW + 1
			task.wait(0.3)
		end
	end)

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

	local data = {
		objects = {
			box,
			nameLabel,
			beam,
			attachment,
			targetAttachment
		},
		renderConnection = nil,
		colorConnection = colorConnection
	}

	espObjects[player] = data

	data.renderConnection = RunService.RenderStepped:Connect(function()
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

		nameText.Text = player.Name

		box.Adornee = character
		box.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		box.OutlineTransparency = 0
	end)
end

local function createESP(player)
	if player == LocalPlayer then
		return
	end

	cleanup(player)

	local data = {
		objects = {},
		characterConnection = nil,
		renderConnection = nil,
		colorConnection = nil
	}

	espObjects[player] = data

	data.characterConnection = player.CharacterAdded:Connect(function(character)
		task.wait()
		setupCharacter(player, character)
	end)

	if player.Character then
		task.spawn(function()
			setupCharacter(player, player.Character)
		end)
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		createESP(player)
	end)
end

Players.PlayerAdded:Connect(function(player)
	createESP(player)
	updateStats()
end)

Players.PlayerRemoving:Connect(function(player)
	cleanup(player)
	updateStats()
end)

updateStats()
