local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Units = workspace:WaitForChild("Units")

local SelectCardEvent = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("RemoteEvents"):WaitForChild("SelectCardEvent")
local ToolDamageEvent = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("RemoteEvents"):WaitForChild("ToolDamageEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "Menu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,300,0,420)
main.Position = UDim2.new(0,40,0.5,-210)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local layout = Instance.new("UIListLayout", main)
layout.Padding = UDim.new(0,8)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "MENU"
title.TextColor3 = Color3.fromRGB(255,80,80)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22

local function button(text)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(1,-20,0,38)
	b.Position = UDim2.new(0,10,0,0)
	b.Text = text
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 15
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

button("Select Cards").MouseButton1Click:Connect(function()
	for _, v in ipairs({
   "Fate manipulation",
		"Gifted",
		"Break your Limits",
		"Last breath",
		"Strength of Will"
	}) do
		SelectCardEvent:FireServer(v)
		task.wait(0.5)
	end
end)

local selectedTool = nil
local toolButtons = {}

local selectLabel = Instance.new("TextLabel", main)
selectLabel.Size = UDim2.new(1,-20,0,28)
selectLabel.Position = UDim2.new(0,10,0,0)
selectLabel.BackgroundTransparency = 1
selectLabel.Text = "Selected Weapon: NONE"
selectLabel.TextColor3 = Color3.fromRGB(200,200,200)
selectLabel.Font = Enum.Font.SourceSans
selectLabel.TextSize = 14

local function clearToolButtons()
	for _, b in ipairs(toolButtons) do
		b:Destroy()
	end
	toolButtons = {}
end

local function loadTools()
	clearToolButtons()
	selectedTool = nil
	selectLabel.Text = "Selected Weapon: NONE"

	for _, tool in ipairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			local b = Instance.new("TextButton", main)
			b.Size = UDim2.new(1,-20,0,34)
			b.Position = UDim2.new(0,10,0,0)
			b.Text = tool.Name
			b.Font = Enum.Font.SourceSansBold
			b.TextSize = 14
			b.TextColor3 = Color3.new(1,1,1)
			b.BackgroundColor3 = Color3.fromRGB(55,55,55)
			Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

			b.MouseButton1Click:Connect(function()
				selectedTool = tool
				selectLabel.Text = "Selected Weapon: "..tool.Name
				for _, x in ipairs(toolButtons) do
					x.BackgroundColor3 = Color3.fromRGB(55,55,55)
				end
				b.BackgroundColor3 = Color3.fromRGB(0,120,0)
			end)

			table.insert(toolButtons, b)
		end
	end
end

local refreshBtn = button("Refresh Weapons")
refreshBtn.MouseButton1Click:Connect(loadTools)

local killBtn = button("Kill All (Selected Weapon)")
killBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)

killBtn.MouseButton1Click:Connect(function()
	if not selectedTool then return end
	if not selectedTool:FindFirstChild("Animations") then return end
	local animFolder = selectedTool.Animations:FindFirstChild("AttackAnimations")
	if not animFolder then return end
	local anim = animFolder:GetChildren()[1]
	if not anim then return end

	for _, unit in ipairs(Units:GetChildren()) do
		if unit:IsA("Model") and unit.Name ~= "Clerk" and not Players:FindFirstChild(unit.Name) then
			ToolDamageEvent:FireServer(unit,999999,selectedTool,anim,[10]={})
		end
	end
end)

loadTools()

local godOn = false
local godBtn = button("God Weapon : OFF")

godBtn.MouseButton1Click:Connect(function()
	godOn = not godOn
	godBtn.Text = "God Weapon : "..(godOn and "ON" or "OFF")
	godBtn.BackgroundColor3 = godOn and Color3.fromRGB(0,120,0) or Color3.fromRGB(45,45,45)
end)

task.spawn(function()
	while task.wait(2) do
		if godOn then
			for _, tool in ipairs(player.Backpack:GetChildren()) do
				if tool:FindFirstChild("SettingValues") then
					local s = tool.SettingValues
					if s:FindFirstChild("MaxDamageValue") then
						s.MaxDamageValue.Value = 99999999
						s.MinDamageValue.Value = 9999999
					end
				end
			end
			local unit = Units:FindFirstChild(player.Name)
			if unit and unit:FindFirstChild("CharStats") then
				unit.CharStats.AttackSpeed.Value = 10
			end
		end
	end
end)

local espOn = false
local espBtn = button("ESP : OFF")
local espCache = {}

espBtn.MouseButton1Click:Connect(function()
	espOn = not espOn
	espBtn.Text = "ESP : "..(espOn and "ON" or "OFF")
	espBtn.BackgroundColor3 = espOn and Color3.fromRGB(0,120,0) or Color3.fromRGB(45,45,45)
	if not espOn then
		for _, e in pairs(espCache) do
			e:Destroy()
		end
		espCache = {}
	end
end)

task.spawn(function()
	while task.wait(0.5) do
		if espOn then
			for _, unit in ipairs(Units:GetChildren()) do
				if unit:IsA("Model") and not Players:FindFirstChild(unit.Name) and unit:FindFirstChild("Head") and not espCache[unit] then
					local bb = Instance.new("BillboardGui", unit)
					bb.Adornee = unit.Head
					bb.AlwaysOnTop = true
					bb.Size = UDim2.new(0,150,0,30)
					bb.StudsOffset = Vector3.new(0,3,0)

					local txt = Instance.new("TextLabel", bb)
					txt.Size = UDim2.new(1,0,1,0)
					txt.BackgroundTransparency = 1
					txt.TextColor3 = Color3.fromRGB(255,0,0)
					txt.TextScaled = true
					txt.Font = Enum.Font.SourceSansBold
					txt.Text = unit.Name

					espCache[unit] = bb
				end
			end
		end
	end
end)

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0,60,0,60)
toggleBtn.Position = UDim2.new(1,-70,0.5,-30)
toggleBtn.Text = "≡"
toggleBtn.TextSize = 28
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
toggleBtn.Draggable = true
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)

local menuOn = true
toggleBtn.MouseButton1Click:Connect(function()
	menuOn = not menuOn
	main.Visible = menuOn
end)