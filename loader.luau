local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 확실한 초기화 ]]
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "AXIS_HUB" or v.Name == "AXIS_MENU_BTN" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"
ScreenGui.DisplayOrder = 999 -- 다른 UI보다 위에 표시

_G.Config = {
    Aimbot = false,
    AutoShoot = false,
    AutoFarm = false,
    Fly = false,
    FlySpeed = 50,
    ESP = false,
    Noclip = false,
    InfJump = false
}

-- [[ 1. MENU 버튼 복구 (최상단 고정) ]]
local MenuBtn = Instance.new("TextButton", CoreGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 55, 0, 55)
MenuBtn.Position = UDim2.new(0, 15, 0.5, -27)
MenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuBtn.Text = "AXIS"
MenuBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.TextSize = 14
MenuBtn.ZIndex = 1000 -- 가장 위에 표시되도록 설정

local MenuStroke = Instance.new("UIStroke", MenuBtn)
MenuStroke.Color = Color3.fromRGB(0, 150, 255)
MenuStroke.Thickness = 2
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)

-- [[ 2. 메인 UI 구조 ]]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(50, 50, 50)

MenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 탭 버튼 생성 함수
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
local TabList = Instance.new("UIListLayout", TabContainer)
TabList.FillDirection = "Horizontal"

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -20, 1, -50)
PageContainer.Position = UDim2.new(0, 10, 0, 45)
PageContainer.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local b = Instance.new("TextButton", TabContainer)
    b.Size = UDim2.new(0.333, 0, 1, 0)
    b.Text = name:upper()
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    b.Font = "GothamBold"
    b.BorderSizePixel = 0
    
    local p = Instance.new("ScrollingFrame", PageContainer)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.Visible = false
    p.BackgroundTransparency = 1
    p.ScrollBarThickness = 2
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 5)
    
    b.MouseButton1Click:Connect(function()
        for _, v in pairs(Tabs) do v.Visible = false end
        p.Visible = true
    end)
    Tabs[name] = p
    return p
end

local MainTab = CreateTab("Main")
local VisualsTab = CreateTab("Visuals")
local MiscTab = CreateTab("Misc")
MainTab.Visible = true

local function AddToggle(parent, text, var)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 35); f.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 20, 0, 20); b.Position = UDim2.new(0, 5, 0.5, -10)
    b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 45)
    b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -40, 1, 0); l.Position = UDim2.new(0, 35, 0, 0); l.Text = text; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"; l.Font = "Gotham"
    
    b.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 45)
    end)
end

AddToggle(MainTab, "Auto Farm (Stick Top)", "AutoFarm")
AddToggle(MainTab, "Aimbot", "Aimbot")
AddToggle(MainTab, "Auto Shoot", "AutoShoot")
AddToggle(MainTab, "Fly (Zero Drift)", "Fly")
AddToggle(MainTab, "Noclip", "Noclip")
AddToggle(VisualsTab, "Blue ESP Highlight", "ESP")

-- [[ 3. 개선된 Fly 로직 (1인칭 완벽 지원) ]] --
local flySpeed = 50
local bv, bg

local function StartFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bg = Instance.new("BodyGyro", char.HumanoidRootPart)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    
    task.spawn(function()
        while _G.Config.Fly do
            RunService.RenderStepped:Wait()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then break end
            
            hum.PlatformStand = true
            bg.CFrame = Camera.CFrame
            
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                -- 1인칭과 3인칭 모두 대응하는 카메라 기준 좌표계 이동
                local look = Camera.CFrame.LookVector
                local right = Camera.CFrame.RightVector
                bv.Velocity = (look * moveDir.Z + right * moveDir.X).Unit * _G.Config.FlySpeed
            else
                bv.Velocity = Vector3.new(0, 0.1, 0) -- 멈추면 전진 안 함
            end
        end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        if char:FindFirstChildOfClass("Humanoid") then char.Humanoid.PlatformStand = false end
    end)
end

-- [[ 4. 루프 및 기타 기능 ]] --
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    if _G.Config.Fly and (not bv or not bv.Parent) then StartFly() end
    
    -- Farm & Noclip
    if _G.Config.AutoFarm or _G.Config.Noclip then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    
    if _G.Config.AutoFarm then
        local target, dist = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                local d = (p.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if d < dist then target = p; dist = d end
            end
        end
        if target then char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0) end
    end
end)

-- ESP (Highlight 방식)
task.spawn(function()
    while task.wait(1) do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("AXIS_ESP")
                if _G.Config.ESP then
                    if not h then
                        local highlight = Instance.new("Highlight", p.Character)
                        highlight.Name = "AXIS_ESP"
                        highlight.FillColor = Color3.fromRGB(0, 150, 255)
                    end
                elseif h then h:Destroy() end
            end
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB | V", Text = "긴급 패치 완료 (V12)", Duration = 3})
