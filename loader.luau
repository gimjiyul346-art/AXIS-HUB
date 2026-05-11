local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ UI 초기화 ]]
if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end
if CoreGui:FindFirstChild("AXIS_MENU_BTN") then CoreGui.AXIS_MENU_BTN:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

_G.Config = {
    Aimbot = false,
    AutoShoot = false,
    AutoFarm = false,
    Wallbang = false,
    WalkSpeed = 16,
    Fly = false,
    Noclip = false,
    ESP = false
}

-- [ 1. MENU 버튼 ]
local MenuBtn = Instance.new("TextButton", CoreGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 60, 0, 60)
MenuBtn.Position = UDim2.new(0, 15, 0.45, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = "GothamBold"
MenuBtn.TextSize = 12
MenuBtn.ZIndex = 10
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)

-- [ 2. 메인 프레임 ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Size = UDim2.new(0, 480, 0, 420)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -210)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [ 3. 탭 시스템 ]
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 45)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UIListLayout", TabBar).FillDirection = "Horizontal"

local Pages = Instance.new("Frame", MainFrame)
Pages.Position = UDim2.new(0, 10, 0, 55)
Pages.Size = UDim2.new(1, -20, 1, -65)
Pages.BackgroundTransparency = 1

local TabPages = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.Text = name:upper()
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = "GothamBold"
    
    local pg = Instance.new("ScrollingFrame", Pages)
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.Visible = false
    pg.BackgroundTransparency = 1
    pg.ScrollBarThickness = 0
    Instance.new("UIListLayout", pg).Padding = UDim.new(0, 8)
    TabPages[name] = pg
    
    btn.MouseButton1Click:Connect(function()
        for n, p in pairs(TabPages) do p.Visible = (n == name) end
    end)
    return pg
end

local combat_pg = CreateTab("Combat")
local visuals_pg = CreateTab("Visuals")
local misc_pg = CreateTab("Misc")
TabPages["Combat"].Visible = true

-- [ 4. 공용 토글 컴포넌트 ]
local function AddToggle(parent, name, var)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Frame)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = "Left"
    Label.Font = "Gotham"

    local Box = Instance.new("TextButton", Frame)
    Box.Size = UDim2.new(0, 24, 0, 24)
    Box.Position = UDim2.new(1, -40, 0.5, -12)
    Box.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 50, 50)
    Box.Text = ""
    Instance.new("UICorner", Box)

    Box.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        Box.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 50, 50)
    end)
end

-- [[ 5. 모바일 통합 엔진 ]] --

local function GetTarget()
    local target, dist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local pos, vis = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if vis or _G.Config.AutoFarm or _G.Config.Wallbang then
                local mDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mDist < dist then
                    target = v
                    dist = mDist
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    -- 1. Auto Farm (상대 발밑 텔포)
    if _G.Config.AutoFarm then
        local t = GetTarget()
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
            if _G.Config.AutoShoot then char:FindFirstChildOfClass("Tool"):Activate() end
        end
    end

    -- 2. Mobile Aimbot (부드러운 조준 고정)
    if _G.Config.Aimbot and not _G.Config.AutoFarm then
        local t = GetTarget()
        if t and t.Character:FindFirstChild("Head") then
            local goal = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, 0.2) -- 0.2 값으로 부드러움 조절
            if _G.Config.AutoShoot then 
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end 
            end
        end
    end

    -- 3. Misc & Movement
    if _G.Config.WalkSpeed > 16 and char.Humanoid.MoveDirection.Magnitude > 0 then
        root.CFrame = root.CFrame + (char.Humanoid.MoveDirection * (_G.Config.WalkSpeed / 300))
    end
    if _G.Config.Fly then root.Velocity = Vector3.new(0, 3, 0) end
    if _G.Config.Noclip or _G.Config.AutoFarm then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- [[ 6. 탭 구성 및 버튼 연결 ]] --

-- Combat 탭
AddToggle(combat_pg, "Mobile Aimbot", "Aimbot")
AddToggle(combat_pg, "Auto Shoot", "AutoShoot")
AddToggle(combat_pg, "Auto Farm (TP Under)", "AutoFarm")
AddToggle(combat_pg, "Wallbang Mode", "Wallbang")

-- Visuals 탭
AddToggle(visuals_pg, "Highlight ESP", "ESP")
RunService.Heartbeat:Connect(function()
    if _G.Config.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("AxisESP") then
                local h = Instance.new("Highlight", p.Character); h.Name = "AxisESP"
                h.FillColor = Color3.fromRGB(0, 150, 255)
            end
        end
    end
end)

-- Misc 탭
local SpeedBtn = Instance.new("TextButton", misc_pg)
SpeedBtn.Size = UDim2.new(1, 0, 0, 45); SpeedBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); SpeedBtn.Text = "WalkSpeed: ".._G.Config.WalkSpeed; SpeedBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SpeedBtn)
SpeedBtn.MouseButton1Click:Connect(function()
    _G.Config.WalkSpeed = (_G.Config.WalkSpeed >= 200) and 16 or _G.Config.WalkSpeed + 20
    SpeedBtn.Text = "WalkSpeed: ".._G.Config.WalkSpeed
end)

AddToggle(misc_pg, "Fly Mode", "Fly")
AddToggle(misc_pg, "Noclip", "Noclip")

local SkinBtn = Instance.new("TextButton", misc_pg)
SkinBtn.Size = UDim2.new(1, 0, 0, 45); SkinBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255); SkinBtn.Text = "Execute Skin Changer"
SkinBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SkinBtn)
SkinBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))() end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V10", Text = "All Systems Rebooted", Duration = 5})
