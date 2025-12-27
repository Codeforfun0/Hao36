--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local UnitsFolder = workspace:WaitForChild("Units")

--// REMOTES
local SelectCardEvent = ReplicatedStorage.Assets.RemoteEvents.SelectCardEvent
local ToolDamageEvent = ReplicatedStorage.Assets.RemoteEvents.ToolDamageEvent

--// GUI
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "HackMenu"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 320)
Main.Position = UDim2.new(0, 30, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Active = true
Main.Draggable = true

local UIList = Instance.new("UIListLayout", Main)
UIList.Padding = UDim.new(0, 8)

--// TITLE
local Title = Instance.new("TextLabel", Main)
Title.Text = "🔥 MENU"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22

--// BUTTON MAKER
local function createButton(text)
	local btn = Instance.new("TextButton", Main)
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.Position = UDim2.new(0, 5, 0, 0)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	return btn
end

--// TOGGLE MAKER
local function createToggle(text)
	local toggle = createButton(text.." : OFF")
	local state = false
	return toggle, function()
		state = not state
		toggle.Text = text.." : "..(state and "ON" or "OFF")
		toggle.BackgroundColor3 = state and Color3.fromRGB(0,120,0) or Color3.fromRGB(40,40,40)
		return state
	end
end

--====================================================
-- 🎴 SELECT CARD
--====================================================
local SelectBtn = createButton("Select Cards")
SelectBtn.MouseButton1Click:Connect(function()
	local cards = {
		"Gifted",
		"Break your Limits",
		"Last breath",
		"Strength of Will",
		"Fate manipulation"
	}
	for _, card in ipairs(cards) do
		SelectCardEvent:FireServer(card)
		task.wait(0.5)
	end
end)

--====================================================
-- 💀 KILL ALL (CLICK)
--====================================================
local KillBtn = createButton("Kill All Units")
KillBtn.MouseButton1Click:Connect(function()
	local Baton = player.Backpack:FindFirstChild("Baton")
	if not Baton then return end
	local AttackAnim = Baton.Animations.AttackAnimations.Attack2

	for _, unit in ipairs(UnitsFolder:GetChildren()) do
		if unit:IsA("Model") and unit.Name ~= "Clerk" and not Players:FindFirstChild(unit.Name) then
			ToolDamageEvent:FireServer(
				unit,
				999999,
				Baton,
				AttackAnim,
				[10] = {}
			)
		end
	end
end)

--====================================================
-- ⚔️ GOD WEAPON TOGGLE
--====================================================
local GodBtn, GodToggle = createToggle("God Weapon")

local function fixWeapon(tool)
	if tool:FindFirstChild("SettingValues") then
		local s = tool.SettingValues
		if s:FindFirstChild("MaxDamageValue") then
			s.MaxDamageValue.Value = 99999999
			s.MinDamageValue.Value = 9999999
		end
	end
end

local function applyGod()
	for _, tool in ipairs(player.Backpack:GetChildren()) do
		fixWeapon(tool)
	end

	local unit = UnitsFolder:FindFirstChild(player.Name)
	if unit and unit:FindFirstChild("CharStats") then
		unit.CharStats.AttackSpeed.Value = 10
	end
end

task.spawn(function()
	while task.wait(2) do
		if GodToggle() then
			applyGod()
		end
	end
end)

GodBtn.MouseButton1Click:Connect(GodToggle)

--====================================================
-- 👁️ ESP TOGGLE
--====================================================
local ESPBtn, ESPToggle = createToggle("ESP Units")
local ESPs = {}

local function createESP(target)
	if ESPs[target] then return end
	if not target:FindFirstChild("Head") then return end

	local bb = Instance.new("BillboardGui", target)
	bb.Name = "ESP"
	bb.Adornee = target.Head
	bb.AlwaysOnTop = true
	bb.Size = UDim2.new(0,150,0,30)
	bb.StudsOffset = Vector3.new(0,3,0)

	local txt = Instance.new("TextLabel", bb)
	txt.Size = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.fromRGB(255,0,0)
	txt.TextScaled = true
	txt.Font = Enum.Font.SourceSansBold

	ESPs[target] = bb

	task.spawn(function()
		while bb.Parent and ESPToggle() do
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local dist = (char.HumanoidRootPart.Position - target.Head.Position).Magnitude
				txt.Text = target.Name.." ["..math.floor(dist).."]"
			end
			task.wait(0.2)
		end
		if bb then bb:Destroy() end
		ESPs[target] = nil
	end)
end

ESPBtn.MouseButton1Click:Connect(ESPToggle)

UnitsFolder.ChildAdded:Connect(function(u)
	if ESPToggle() and not Players:FindFirstChild(u.Name) then
		task.wait(0.2)
		createESP(u)
	end
end)