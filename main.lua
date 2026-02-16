-- ALL-IN-ONE REWORK (FPS BOOST + AIM ASSIST + ESP)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ========== CONFIG ==========
local FPS_BOOST = true
local AIM_ENABLED = true
local AIM_FOV = 120       -- pixels
local AIM_SMOOTH = 0.08  -- 0.05~0.15
local ESP_ENABLED = true
local SHOW_BOX = true
local SHOW_NAME = true
local SHOW_DISTANCE = true
-- ============================

-- ========== FPS BOOST ==========
if FPS_BOOST then
	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	end)

	Lighting.GlobalShadows = false
	Lighting.FogEnd = 1e9
	Lighting.Brightness = 1
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.OutdoorAmbient = Color3.new(0,0,0)

	for _,v in ipairs(Lighting:GetChildren()) do
		if v:IsA("PostEffect") or v:IsA("Atmosphere") then
			v:Destroy()
		end
	end

	local decoNames = {"tree","arvore","plant","bush","folha","leaf","palm","rock","pedra","decor","prop"}
	local function isDecor(obj)
		for _,n in ipairs(decoNames) do
			if obj.Name:lower():find(n) then return true end
		end
		return false
	end

	local function optimize(obj)
		if obj:IsDescendantOf(LocalPlayer.Character or Instance.new("Folder")) then return end
		if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
			obj.Enabled = false
		elseif obj:IsA("BasePart") then
			obj.Material = Enum.Material.Plastic
			obj.Reflectance = 0
			obj.CastShadow = false
		elseif (obj:IsA("Model") or obj:IsA("Folder")) and isDecor(obj) then
			pcall(function() obj:Destroy() end)
		end
	end

	for _,v in ipairs(Workspace:GetDescendants()) do
		pcall(function() optimize(v) end)
	end

	Workspace.DescendantAdded:Connect(function(v)
		task.wait(0.1)
		pcall(function() optimize(v) end)
	end)
end

-- ========== AIM ASSIST ==========
local function getClosestTarget()
	local closest = AIM_FOV
	local targetPos

	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
			if p.Character.Humanoid.Health > 0 then
				local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
				if onScreen then
					local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
					local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude
					if dist < closest then
						closest = dist
						targetPos = p.Character.Head.Position
					end
				end
			end
		end
	end

	return targetPos
end

RunService.RenderStepped:Connect(function()
	if not AIM_ENABLED then return end
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

	local target = getClosestTarget()
	if target then
		local camPos = Camera.CFrame.Position
		local desired = CFrame.new(camPos, target)
		Camera.CFrame = Camera.CFrame:Lerp(desired, AIM_SMOOTH)
	end
end)

-- ========== ESP ==========
local drawings = {}

local function createESP(player)
	if player == LocalPlayer then return end

	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Transparency = 1
	box.Color = Color3.fromRGB(255, 0, 0)
	box.Filled = false

	local text = Drawing.new("Text")
	text.Size = 14
	text.Center = true
	text.Outline = true
	text.Color = Color3.fromRGB(255,255,255)

	drawings[player] = {box = box, text = text}
end

local function removeESP(player)
	if drawings[player] then
		drawings[player].box:Remove()
		drawings[player].text:Remove()
		drawings[player] = nil
	end
end

for _,p in ipairs(Players:GetPlayers()) do
	createESP(p)
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
	if not ESP_ENABLED then
		for _,d in pairs(drawings) do
			d.box.Visible = false
			d.text.Visible = false
		end
		return
	end

	for player,esp in pairs(drawings) do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if hrp and hum and hum.Health > 0 then
			local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			if onScreen then
				local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
				local scale = math.clamp(1 / (distance / 25), 0.6, 2)
				local size = Vector2.new(35, 50) * scale

				esp.box.Size = size
				esp.box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
				esp.box.Visible = SHOW_BOX

				local label = player.Name
				if SHOW_DISTANCE then
					label = label .. string.format(" [%.0fm]", distance)
				end

				esp.text.Text = label
				esp.text.Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 14)
				esp.text.Visible = SHOW_NAME
			else
				esp.box.Visible = false
				esp.text.Visible = false
			end
		else
			esp.box.Visible = false
			esp.text.Visible = false
		end
	end
end)

print("ALL-IN-ONE rework carregado.")
