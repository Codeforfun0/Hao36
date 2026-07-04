local P,R,S=game:GetService("Players"),game:GetService("RunService"),game:GetService("StarterGui")
local C=workspace.CurrentCamera
local N,E={},{}
local function Notify(i,t)
	if N[i] then return end
	N[i]=1
	task.spawn(function()
		repeat
			local ok=pcall(function()
				S:SetCore("SendNotification",{Title="ESP",Text=t,Duration=5})
			end)
			if ok then break end
			task.wait(1)
		until false
	end)
end

local function Root(o)return o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart",true)end
local function ESP(o,c,b)
	if E[o] then return end
	local s=Drawing.new("Square") s.Filled=false s.Thickness=2 s.Color=c
	local t=Drawing.new("Text") t.Center=true t.Outline=true t.Size=16 t.Color=c
	E[o]={S=s,T=t,B=b}
end

local function Watch(parent,msg)
	for _,v in ipairs(parent:GetChildren())do
		Notify(msg..v:GetDebugId(),msg)
	end
	parent.ChildAdded:Connect(function(v)
		Notify(msg..v:GetDebugId(),msg)
	end)
end

-- Items >9
for _,v in ipairs(workspace.Items:GetChildren())do
	if tonumber(v.Name)and tonumber(v.Name)>9 then ESP(v,Color3.new(1,1,0))end

	for _,n in ipairs({"LeftPage","RightPage"})do
		local p=v:FindFirstChild(n)
		if p then
			if p:FindFirstChild("Decal")then
				Notify("Book"..p:GetDebugId(),"Book Writing!")
			end
			p.ChildAdded:Connect(function(c)
				if c.Name=="Decal"then
					Notify("Book"..p:GetDebugId(),"Book Writing!")
				end
			end)
		end
	end
end

workspace.Items.ChildAdded:Connect(function(v)
	if tonumber(v.Name)and tonumber(v.Name)>9 then ESP(v,Color3.new(1,1,0))end
end)

-- InMapItems
for _,v in ipairs(workspace.Map.InMapItems:GetChildren())do
	ESP(v,Color3.new(0,1,1))
end
workspace.Map.InMapItems.ChildAdded:Connect(function(v)
	ESP(v,Color3.new(0,1,1))
end)

-- Ghost
if workspace:FindFirstChild("Ghost")then
	ESP(workspace.Ghost,Color3.new(1,0,0),true)
end

Watch(workspace.Handprints,"Handprints Found!")
Watch(workspace.ScratchText,"Scratch Found!")

-- GhostOrb
for _,v in ipairs(workspace:GetDescendants())do
	if v.Name=="GhostOrb"then Notify("Orb","GhostOrb Found!")end
end
workspace.DescendantAdded:Connect(function(v)
	if v.Name=="GhostOrb"then Notify("Orb","GhostOrb Found!")end
end)

-- Laser
task.spawn(function()
	while task.wait(.2)do
		local g=workspace:FindFirstChild("Ghost")
		if g and g.Transparency>.8 and g.Transparency<1 then
			Notify("Laser","Laser Found!")
		end
	end
end)

R.RenderStepped:Connect(function()
	for o,d in pairs(E)do
		if not o.Parent then
			d.S:Remove()d.T:Remove()E[o]=nil
		else
			local p=Root(o)
			if p then
				local v,on=C:WorldToViewportPoint(p.Position)
				if on then
					local dis=(C.CFrame.Position-p.Position).Magnitude
					local sz=math.clamp((d.B and 120 or 80)/dis*8,d.B and 20 or 15,d.B and 200 or 80)
					d.S.Size=Vector2.new(sz,d.B and sz*2 or sz)
					d.S.Position=Vector2.new(v.X-sz/2,v.Y-(d.B and sz or sz/2))
					d.S.Visible=true
					d.T.Text=math.floor(dis).."m"
					d.T.Position=Vector2.new(v.X,v.Y-35)
					d.T.Visible=true
				else
					d.S.Visible=false d.T.Visible=false
				end
			end
		end
	end
end)