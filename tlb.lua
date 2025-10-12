local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TuantusLobotomyBranches"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Create main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 300)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Create logo button (toggle GUI visibility)
local logoButton = Instance.new("TextButton")
logoButton.Size = UDim2.new(0, 40, 0, 40)
logoButton.Position = UDim2.new(0, 10, 0, 10)
logoButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
logoButton.Text = "T"
logoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
logoButton.TextScaled = true
logoButton.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "Tuantu's Lobotomy Branches"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Parent = mainFrame

-- Button 1: Select Cards
local button1 = Instance.new("TextButton")
button1.Size = UDim2.new(0.9, 0, 0, 40)
button1.Position = UDim2.new(0.05, 0, 0.15, 0)
button1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button1.Text = "Select Cards"
button1.TextColor3 = Color3.fromRGB(255, 255, 255)
button1.TextScaled = true
button1.Parent = mainFrame

-- Button 2: Tool Damage
local button2 = Instance.new("TextButton")
button2.Size = UDim2.new(0.9, 0, 0, 40)
button2.Position = UDim2.new(0.05, 0, 0.3, 0)
button2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button2.Text = "Tool Damage"
button2.TextColor3 = Color3.fromRGB(255, 255, 255)
button2.TextScaled = true
button2.Parent = mainFrame

-- Damage Input Box
local damageBox = Instance.new("TextBox")
damageBox.Size = UDim2.new(0.9, 0, 0, 40)
damageBox.Position = UDim2.new(0.05, 0, 0.45, 0)
damageBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
damageBox.Text = "999999"
damageBox.TextColor3 = Color3.fromRGB(255, 255, 255)
damageBox.TextScaled = true
damageBox.Parent = mainFrame

-- Toggle 1: Weapon & Attack Speed
local toggle1 = Instance.new("TextButton")
toggle1.Size = UDim2.new(0.9, 0, 0, 40)
toggle1.Position = UDim2.new(0.05, 0, 0.6, 0)
toggle1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggle1.Text = "Weapon & Attack Speed: OFF"
toggle1.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle1.TextScaled = true
toggle1.Parent = mainFrame

-- Toggle 2: ESP
local toggle2 = Instance.new("TextButton")
toggle2.Size = UDim2.new(0.9, 0, 0, 40)
toggle2.Position = UDim2.new(0.05, 0, 0.75, 0)
toggle2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggle2.Text = "ESP: OFF"
toggle2.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle2.TextScaled = true
toggle2.Parent = mainFrame

-- Toggle GUI visibility
local guiVisible = true
logoButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
end)

-- Button 1: Select Cards
button1.MouseButton1Click:Connect(function()
    local cards = {
        "Gifted",
        "Break your Limits",
        "Last breath",
        "Strength of Will",
        "Fate manipulation"
    }
    for _, card in ipairs(cards) do
        game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("RemoteEvents"):WaitForChild("SelectCardEvent"):FireServer(card)
        task.wait(0.5)
    end
end)

-- Button 2: Tool Damage
button2.MouseButton1Click:Connect(function()
    local ToolDamageEvent = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("RemoteEvents"):WaitForChild("ToolDamageEvent")
    local UnitsFolder = workspace:WaitForChild("Units")
    local Baton = player.Backpack:WaitForChild("Baton")
    local AttackAnim = Baton.Animations.AttackAnimations.Attack2
    local damage = tonumber(damageBox.Text) or 999999

    for _, unit in ipairs(UnitsFolder:GetChildren()) do
        if unit:IsA("Model") and unit.Name ~= "Clerk" and not Players:FindFirstChild(unit.Name) then
            local args = {
                unit,
                damage,
                Baton,
                AttackAnim,
                [10] = {}
            }
            ToolDamageEvent:FireServer(unpack(args))
        end
    end
end)

-- Toggle 1: Weapon & Attack Speed
local weaponToggleActive = false
local weaponConnection
toggle1.MouseButton1Click:Connect(function()
    weaponToggleActive = not weaponToggleActive
    toggle1.Text = "Weapon & Attack Speed: " .. (weaponToggleActive and "ON" or "OFF")
    toggle1.BackgroundColor3 = weaponToggleActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)

    if weaponToggleActive then
        local function fixWeapon(tool)
            if tool:FindFirstChild("SettingValues") then
                local settings = tool.SettingValues
                local maxDamage = settings:FindFirstChild("MaxDamageValue")
                local minDamage = settings:FindFirstChild("MinDamageValue")
                if maxDamage and minDamage then
                    maxDamage.Value = 99999999
                    minDamage.Value = 9999999
                end
            end
        end

        local function setAllWeaponsDamage()
            local backpack = player:FindFirstChild("Backpack")
            if not backpack then return end
            for _, tool in ipairs(backpack:GetChildren()) do
                fixWeapon(tool)
            end
        end

        local function setAttackSpeed()
            local units = workspace:FindFirstChild("Units")
            if not units then return end
            local playerUnit = units:FindFirstChild(player.Name)
            if not playerUnit then return end
            local charStats = playerUnit:FindFirstChild("CharStats")
            if not charStats then return end
            local attackSpeed = charStats:FindFirstChild("AttackSpeed")
            if attackSpeed then
                attackSpeed.Value = 10
            end
        end

        player.CharacterAdded:Connect(function()
            task.wait(1)
            setAllWeaponsDamage()
            setAttackSpeed()
        end)

        if player.Character then
            task.wait(1)
            setAllWeaponsDamage()
            setAttackSpeed()
        end

        player.Backpack.ChildAdded:Connect(function(tool)
            task.wait(0.5)
            fixWeapon(tool)
        end)

        workspace.Units:WaitForChild(player.Name).ChildAdded:Connect(function(child)
            if child.Name == "CharStats" then
                child:WaitForChild("AttackSpeed").Value = 10
            end
        end)

        weaponConnection = task.spawn(function()
            while weaponToggleActive do
                setAllWeaponsDamage()
                setAttackSpeed()
                task.wait(2)
            end
        end)
    else
        if weaponConnection then
            task.cancel(weaponConnection)
        end
    end
end)

-- Toggle 2: ESP
local espToggleActive = false
local espConnections = {}
toggle2.MouseButton1Click:Connect(function()
    espToggleActive = not espToggleActive
    toggle2.Text = "ESP: " .. (espToggleActive and "ON" or "OFF")
    toggle2.BackgroundColor3 = espToggleActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)

    local UnitsFolder = workspace:WaitForChild("Units")

    local function createESP(target)
        if target:FindFirstChild("Head") and not target:FindFirstChild("ESP") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP"
            billboard.Adornee = target.Head
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 150, 0, 25)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Parent = target

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 0, 0)
            label.TextScaled = true
            label.Font = Enum.Font.SourceSansBold
            label.Text = target.Name
            label.Parent = billboard

            local espUpdate
            espUpdate = task.spawn(function()
                while billboard.Parent and espToggleActive do
                    local char = player.Character
                    local hum = target:FindFirstChildOfClass("Humanoid")
                    if not hum or hum.Health <= 0 then
                        billboard:Destroy()
                        break
                    end
                    if char and char:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Head") then
                        local distance = (char.HumanoidRootPart.Position - target.Head.Position).Magnitude
                        label.Text = string.format("%s\n[%.0f]", target.Name, distance)
                    end
                    task.wait(0.2)
                end
            end)
            table.insert(espConnections, espUpdate)
        end
    end

    local function isAbno(model)
        return not Players:FindFirstChild(model.Name)
    end

    local function onUnitAdded(unit)
        if unit:IsA("Model") and isAbno(unit) then
            unit:WaitForChild("Head", 5)
            if unit:FindFirstChild("Head") then
                createESP(unit)
            end
        end
    end

    if espToggleActive then
        UnitsFolder.ChildAdded:Connect(onUnitAdded)
        for _, unit in ipairs(UnitsFolder:GetChildren()) do
            onUnitAdded(unit)
        end
    else
        for _, connection in ipairs(espConnections) do
            task.cancel(connection)
        end
        espConnections = {}
        for _, unit in ipairs(UnitsFolder:GetChildren()) do
            if unit:FindFirstChild("ESP") then
                unit.ESP:Destroy()
            end
        end
    end
end)

-- Draggable for mobile
local dragging
local dragInput
local dragStart
local startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and dragging then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
