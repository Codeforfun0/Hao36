local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local notified = {}

local function Notify(id,text)
	if notified[id] then return end
	notified[id] = true

	pcall(function()
		StarterGui:SetCore("SendNotification",{
			Title="ESP",
			Text=text,
			Duration=5
		})
	end)
end

local function getRoot(obj)
	if obj:IsA("BasePart") then
		return obj
	end
	return obj:FindFirstChildWhichIsA("BasePart",true)
end

local ESP = {}

local function CreateESP(obj,color,box)
	if ESP[obj] then return end

	local square = Drawing.new("Square")
	square.Thickness = 2
	square.Filled = false
	square.Color = color

	local text = Drawing.new("Text")
	text.Size = 16
	text.Center = true
	text.Outline = true
	text.Color = color

	ESP[obj] = {
		Square=square,
		Text=text,
		Box=box
	}
end

local function RemoveESP(obj)
	if not ESP[obj] then return end
	ESP[obj].Square:Remove()
	ESP[obj].Text:Remove()
	ESP[obj]=nil
end

for _,v in ipairs(workspace.Items:GetChildren()) do
	if tonumber(v.Name) and tonumber(v.Name)>9 then
		CreateESP(v,Color3.new(1,1,0),false)
	end
end

workspace.Items.ChildAdded:Connect(function(v)
	if tonumber(v.Name) and tonumber(v.Name)>9 then
		CreateESP(v,Color3.new(1,1,0),false)
	end
end)

local InMap=workspace.Map:WaitForChild("InMapItems")

for _,v in ipairs(InMap:GetChildren()) do
	CreateESP(v,Color3.new(0,1,1),false)
end

InMap.ChildAdded:Connect(function(v)
	CreateESP(v,Color3.new(0,1,1),false)
end)

CreateESP(workspace.Ghost,Color3.new(1,0,0),true)

workspace.Handprints.ChildAdded:Connect(function(c)
	Notify(c:GetDebugId(),"Handprints: "..c.Name)
end)

workspace.ScratchText.ChildAdded:Connect(function(c)
	Notify(c:GetDebugId(),"ScratchText: "..c.Name)
end)

task.spawn(function()
	while task.wait(.5) do
		local orb=workspace:FindFirstChild("GhostOrb")
		if orb then
			Notify("GhostOrb","GhostOrb Found!")
		end
	end
end)

task.spawn(function()
	while task.wait(.2) do
		local g=workspace:FindFirstChild("Ghost")
		if g and g:IsA("BasePart") then
			if g.Transparency>0.8 and g.Transparency<1 then
				Notify("Laser","Laser Found!")
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()

	for obj,data in pairs(ESP) do

		if not obj.Parent then
			RemoveESP(obj)
			continue
		end

		local part=getRoot(obj)

		if not part then
			data.Square.Visible=false
			data.Text.Visible=false
			continue
		end

		local pos,onScreen=cam:WorldToViewportPoint(part.Position)

		if not onScreen then
			data.Square.Visible=false
			data.Text.Visible=false
			continue
		end

		local dist=(cam.CFrame.Position-part.Position).Magnitude

		data.Text.Text=math.floor(dist).."m"
		data.Text.Position=Vector2.new(pos.X,pos.Y-35)
		data.Text.Visible=true

		if data.Box then
			local s=120/dist*8
			s=math.clamp(s,20,200)

			data.Square.Size=Vector2.new(s,s*2)
			data.Square.Position=Vector2.new(pos.X-s/2,pos.Y-s)
		else
			local s=80/dist*8
			s=math.clamp(s,15,80)

			data.Square.Size=Vector2.new(s,s)
			data.Square.Position=Vector2.new(pos.X-s/2,pos.Y-s/2)
		end

		data.Square.Visible=true
	end

end)