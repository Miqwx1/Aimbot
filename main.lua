-- FPS BOOST + AIM ASSIST COMPACTO
local P=game:GetService("Players");local R=game:GetService("RunService");local W=workspace;local LP=P.LocalPlayer;local C=W.CurrentCamera

-- Gráficos leves
pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
local L=game:GetService("Lighting");L.GlobalShadows=false;L.FogEnd=1e9;L.Brightness=0;L.EnvironmentDiffuseScale=0;L.EnvironmentSpecularScale=0;L.OutdoorAmbient=Color3.new(0,0,0)
for _,v in ipairs(L:GetChildren()) do if v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end end

-- Otimizar mapa (remove só decos)
local nomesDeco={"tree","arvore","plant","bush","folha","leaf","palm","rock","pedra","decor","prop"}
local function isDeco(o) for _,n in ipairs(nomesDeco) do if o.Name:lower():find(n) then return true end end return false end
local function opt(o) if o:IsDescendantOf(LP.Character) then return end
if o:IsA("BasePart") then o.Material=Enum.Material.Plastic;o.Reflectance=0;o.CastShadow=false;if isDeco(o) then o:Destroy() end
elseif o:IsA("Decal") or o:IsA("Texture") then o:Destroy()
elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then o.Enabled=false;o:Destroy()
elseif (o:IsA("Model") or o:IsA("Folder")) and isDeco(o) then o:Destroy() end end
for _,v in ipairs(W:GetDescendants()) do opt(v) end
W.DescendantAdded:Connect(function(v) task.wait();opt(v) end)

-- Limpar roupas/acessórios
local function cleanChar(c) if c==LP.Character then return end;for _,v in ipairs(c:GetDescendants()) do if v:IsA("Accessory") or v:IsA("Clothing") then v:Destroy() end end end
for _,p in ipairs(P:GetPlayers()) do if p.Character then cleanChar(p.Character) end end
P.PlayerAdded:Connect(function(p)p.CharacterAdded:Connect(cleanChar)end)

-- Painel FPS
local gui=Instance.new("ScreenGui",LP.PlayerGui);gui.ResetOnSpawn=false
local lbl=Instance.new("TextLabel",gui);lbl.Size=UDim2.fromScale(0.1,0.05);lbl.Position=UDim2.new(0,10,0,10);lbl.BackgroundTransparency=1;lbl.TextColor3=Color3.fromRGB(0,255,0);lbl.Font=Enum.Font.SourceSansBold;lbl.TextSize=18
local c,lt=0,tick()
R.RenderStepped:Connect(function() c=c+1;if tick()-lt>=1 then lbl.Text="FPS: "..c;c=0;lt=tick() end end)

-- AIM ASSIST Head Aim
local FOV=10;local assist=0.1;local headOffset=Vector3.new(0,1.5,0)
R.RenderStepped:Connect(function()
if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
local closest=FOV; local target
for _,p in ipairs(P:GetPlayers()) do
if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
local head=p.Character:FindFirstChild("Head")
if head then
local pos,onscreen=C:WorldToViewportPoint(head.Position)
if onscreen then
local center=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y/2)
local dist=(Vector2.new(pos.X,pos.Y)-center).magnitude
if dist<closest then closest=dist; target=head.Position end
end
end
end
end
if target then
local dir=(target-C.CFrame.Position).Unit
C.CFrame=CFrame.new(C.CFrame.Position,C.CFrame.Position+dir:Lerp(dir,assist))
end
end)

--------------------------------------------------
-- ESP FIXADO (BOX NÃO GIGANTE)
--------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local function createESP(player)

    if player == LP then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255,0,0)
    box.Filled = false
    box.Visible = false

    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Color = Color3.fromRGB(255,0,0)
    line.Visible = false

    local name = Drawing.new("Text")
    name.Size = 16
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255,255,255)
    name.Visible = false

    RunService.RenderStepped:Connect(function()

        local char = player.Character
        if not char then
            box.Visible = false
            line.Visible = false
            name.Visible = false
            return
        end

        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local humanoid = char:FindFirstChild("Humanoid")

        if not root or not head or not humanoid or humanoid.Health <= 0 then
            box.Visible = false
            line.Visible = false
            name.Visible = false
            return
        end

        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)

        if not onScreen then
            box.Visible = false
            line.Visible = false
            name.Visible = false
            return
        end

        -- 🔥 CÁLCULO PROFISSIONAL DA BOX
        local headPos = Camera:WorldToViewportPoint(head.Position)

        local height = math.abs(headPos.Y - rootPos.Y)
        local width = height / 2

        -- LIMITADORES (impede caixa gigante)
        height = math.clamp(height, 20, 300)
        width = math.clamp(width, 10, 150)

        -- BOX
        box.Size = Vector2.new(width, height)
        box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height)
        box.Visible = true

        -- LINE
        line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        line.To = Vector2.new(rootPos.X, rootPos.Y)
        line.Visible = true

        -- NAME
        name.Text = player.Name
        name.Position = Vector2.new(rootPos.X, rootPos.Y - height - 15)
        name.Visible = true
    end)
end

-- jogadores atuais
for _,p in ipairs(Players:GetPlayers()) do
    createESP(p)
end

-- novos jogadores
Players.PlayerAdded:Connect(createESP)
