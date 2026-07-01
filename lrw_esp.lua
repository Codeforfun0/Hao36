local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local function getRoot()
	local char = Player.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
end

local ESPs = {}

local function createESP(model, textFunc)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP"
	billboard.Size = UDim2.new(0, 250, 0, 40)
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, 4, 0)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1,1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = billboard

	local adornee = model:IsA("Model") and model.PrimaryPart or model
	if not adornee then
		adornee = model:FindFirstChildWhichIsA("BasePart", true)
	end

	if adornee then
		billboard.Adornee = adornee
		billboard.Parent = adornee
	end

	table.insert(ESPs,{
		Model = model,
		Label = label,
		Update = textFunc
	})
end

-- Drops
local dropsFolder = workspace:WaitForChild("Drops")

for _,v in ipairs(dropsFolder:GetChildren()) do
	if v.Name == "CursedFinger" then
		createESP(v,function(model,dist)
			return string.format("CursedFinger | %.0fm",dist)
		end)
	end
end

-- Gates
local gatesFolder = workspace:WaitForChild("Gates")

for _,gate in ipairs(gatesFolder:GetChildren()) do
	if gate.Name == "RedGate" or gate.Name == "BlueGate" then
		createESP(gate,function(model,dist)
			local rank = "?"
			local gatePart = model:FindFirstChild("Gate")
			if gatePart then
				local rankValue = gatePart:FindFirstChild("Rank")
				if rankValue then
					rank = rankValue.Value
				end
			end

			return string.format("%s(Rank: %s) | %.0fm",model.Name,rank,dist)
		end)
	end
end

RunService.RenderStepped:Connect(function()
	local root = getRoot()
	if not root then return end

	for _,esp in ipairs(ESPs) do
		local obj = esp.Model
		if obj and obj.Parent then
			local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
			if part then
				local dist = (root.Position - part.Position).Magnitude
				esp.Label.Text = esp.Update(obj,dist)
			end
		end
	end
end)