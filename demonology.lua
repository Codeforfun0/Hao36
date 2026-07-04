local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local notified = {}

local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5
        })
    end)
end

local function ESP(obj, color)
    if not obj or obj:FindFirstChild("ESP") then return end

    local hl = Instance.new("Highlight")
    hl.Name = "ESP"
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.FillColor = color
    hl.OutlineColor = color
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = obj
    hl.Parent = obj
end

-- Items >9
local items = workspace:WaitForChild("Items")

local function checkItem(item)
    local num = tonumber(item.Name)
    if num and num > 9 then
        ESP(item, Color3.fromRGB(255,255,0))
    end
end

for _,v in ipairs(items:GetChildren()) do
    checkItem(v)
end

items.ChildAdded:Connect(checkItem)

-- InMapItems ESP
local mapItems = workspace:WaitForChild("Map"):WaitForChild("InMapItems")

local function addMapESP(obj)
    ESP(obj, Color3.fromRGB(0,255,255))
end

for _,v in ipairs(mapItems:GetChildren()) do
    addMapESP(v)
end

mapItems.ChildAdded:Connect(addMapESP)

-- Ghost ESP
local function setupGhost(g)
    ESP(g, Color3.fromRGB(255,0,0))

    local laserNotified = false

    local function check()
        if g:IsA("BasePart") then
            if g.Transparency > 0.8 and g.Transparency < 1 and not laserNotified then
                laserNotified = true
                Notify("Ghost","Laser Found!")
            end
        end
    end

    check()

    if g:IsA("BasePart") then
        g:GetPropertyChangedSignal("Transparency"):Connect(check)
    end
end

if workspace:FindFirstChild("Ghost") then
    setupGhost(workspace.Ghost)
end

workspace.ChildAdded:Connect(function(obj)
    if obj.Name=="Ghost" then
        setupGhost(obj)
    elseif obj.Name=="GhostOrb" and not notified[obj] then
        notified[obj]=true
        Notify("GhostOrb","GhostOrb Found!")
    end
end)

if workspace:FindFirstChild("GhostOrb") then
    notified[workspace.GhostOrb]=true
    Notify("GhostOrb","GhostOrb Found!")
end

-- Handprints
local hp = workspace:WaitForChild("Handprints")

hp.ChildAdded:Connect(function(obj)
    if notified[obj] then return end
    notified[obj]=true
    Notify("Handprints",obj:GetFullName())
end)

-- ScratchText
local st = workspace:WaitForChild("ScratchText")

st.ChildAdded:Connect(function(obj)
    if notified[obj] then return end
    notified[obj]=true
    Notify("ScratchText",obj:GetFullName())
end)