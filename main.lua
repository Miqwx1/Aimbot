local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--------------------------------------------------
-- FPS BOOST (leve e seguro)
--------------------------------------------------

pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

Lighting.GlobalShadows = false
Lighting.FogEnd = 1e9
Lighting.Brightness = 1
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0

for _,v in ipairs(Lighting:GetChildren()) do
    if v:IsA("PostEffect") or v:IsA("Atmosphere") then
        v.Enabled = false -- melhor que destruir
    end
end

--------------------------------------------------
-- OTIMIZAR PARTES PESADAS
--------------------------------------------------

local function optimizePart(obj)

    if obj:IsDescendantOf(LP.Character or nil) then
        return
    end

    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.CastShadow = false
        obj.Reflectance = 0

    elseif obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Smoke")
        or obj:IsA("Fire")
        or obj:IsA("Sparkles") then
        
        obj.Enabled = false -- não destruir = menos lag de limpeza
    end
end

-- roda UMA vez
for _,obj in ipairs(Workspace:GetDescendants()) do
    optimizePart(obj)
end

-- otimiza só novos objetos
Workspace.DescendantAdded:Connect(optimizePart)

--------------------------------------------------
-- FPS COUNTER (mais leve)
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.fromOffset(120,40)
label.Position = UDim2.fromOffset(10,10)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(0,255,0)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 20
label.Parent = gui

local frames = 0
local last = tick()

RunService.Heartbeat:Connect(function(dt) -- melhor que RenderStepped pra isso
    frames += 1
    
    if tick() - last >= 1 then
        label.Text = "FPS: "..frames
        frames = 0
        last = tick()
    end
end)

--------------------------------------------------
-- AIM SUAVE (lado técnico)
--------------------------------------------------

local FOV = 15
local Smoothness = 0.5

RunService.RenderStepped:Connect(function()

    if not LP.Character then return end

    local closestDist = FOV
    local targetHead = nil

    local center = Vector2.new(
        Camera.ViewportSize.X/2,
        Camera.ViewportSize.Y/2
    )

    for _,player in ipairs(Players:GetPlayers()) do

        if player ~= LP and player.Character then
            
            local head = player.Character:FindFirstChild("Head")

            if head then
                
                local pos, visible = Camera:WorldToViewportPoint(head.Position)

                if visible then
                    
                    local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude

                    if dist < closestDist then
                        closestDist = dist
                        targetHead = head.Position
                    end
                end
            end
        end
    end

    if targetHead then
        
        local direction = (targetHead - Camera.CFrame.Position).Unit
        
        local newLook = Camera.CFrame.LookVector:Lerp(direction, Smoothness)

        Camera.CFrame = CFrame.new(
            Camera.CFrame.Position,
            Camera.CFrame.Position + newLook
        )
    end
end)
