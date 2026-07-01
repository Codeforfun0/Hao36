local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local function CreateESP(part, getText)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 250, 0, 40)
	gui.AlwaysOnTop = true
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.Adornee = part
	gui.Parent = part

	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0
	text.TextScaled = true
	text.Font = Enum.Font.SourceSansBold
	text.Parent = gui

	RunService.RenderStepped:Connect(function()
		local char = Player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp or not part.Parent then
			return
		end

		local dist = math.floor((hrp.Position - part.Position).Magnitude)
		text.Text = getText(dist)
	end)
end

-- Gates
for _, model in ipairs(workspace.Gates:GetChildren()) do
	if model.Name == "RedGate" or model.Name == "BlueGate" then
		local gate = model:FindFirstChild("Gate")
		local rank = gate and gate:FindFirstChild("Rank")

		if gate and rank then
			CreateESP(gate, function(dist)
				return string.format("%s(Rank: %s) | %dm", model.Name, rank.Value, dist)
			end)
		end
	end
end

-- CursedFinger
for _, obj in ipairs(workspace.Drops:GetChildren()) do
	if obj.Name == "CursedFinger" then
		local part = obj:FindFirstChildWhichIsA("BasePart", true)
		if part then
			CreateESP(part, function(dist)
				return string.format("CursedFinger | %dm", dist)
			end)
		end
	end
end