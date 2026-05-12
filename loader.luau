local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ UI 초기화 및 잔상 제거 ]]
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "AXIS_HUB" or v.Name == "AXIS_MENU_BTN" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"
ScreenGui.DisplayOrder = 999

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

-- [[ 1. MENU 버튼 및 토글 시스템 ]]
local MenuBtn = Instance.new("TextButton", CoreGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 50, 0, 50)
MenuBtn.Position = UDim2.new(0, 15, 0.5, -25)
MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MenuBtn.Text = "AXIS"
MenuBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.TextSize = 12
MenuBtn.ZIndex = 1000
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)
local BtnStroke = Instance.new("UIStroke", MenuBtn)
BtnStroke.Color = Color3.fromRGB(0, 150, 255)
BtnStroke.Thickness = 2

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 350)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(40, 40, 40)

-- [ 토글 함수: 버튼 클릭 및 LeftShift 키 ]
local function ToggleUI()
    MainFrame.Visible = not MainFrame.Visible
end

MenuBtn.MouseButton1Click:Connect(ToggleUI)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.LeftShift then
        ToggleUI()
    end
end)

-- [[ 2. 탭 및 섹션 레이아웃 ]]
local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1, 0, 0, 40)
TabFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
local TabList = Instance.new("UIListLayout", TabFrame)
TabList.FillDirection = Enum.FillDirection.Horizontal

local Pages = Instance.new("Frame", MainFrame)
Pages.Size = UDim2.new(1, -20, 1, -60)
Pages.Position = UDim2.new(0, 10, 0, 50)
Pages.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", TabFrame)
    btn.Size = UDim2.new(0.333, 0, 1, 0)
    btn.Text = name:upper()
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    
    local pg = Instance.new("ScrollingFrame", Pages)
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.Visible = false
    pg.BackgroundTransparency = 1
    pg.ScrollBarThickness = 2
    Instance.new("UIListLayout", pg).Padding = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(Tabs) do v.Visible = false end
        pg.Visible = true
    end)
    Tabs[name] = pg
    return pg
end

local MainTab = CreateTab("Main")
local VisualsTab = CreateTab("Visuals")
local MiscTab = CreateTab("Misc")
MainTab.Visible = true

local function AddToggle(parent, text, var)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 35); f.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 18, 0, 18); b.Position = UDim2.new(0, 5, 0.5, -9)
    b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -40, 1, 0); l.Position = UDim2.new(0, 35, 0, 0); l.Text = text; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"; l.Font = "Gotham"
    
    b.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    end)
end

-- 버튼 배치
AddToggle(MainTab, "Auto Farm (Top)", "AutoFarm")
AddToggle(MainTab, "Aimbot (Lock On)", "Aimbot")
AddToggle(MainTab, "Auto Shoot (On Target)", "AutoShoot")
AddToggle(MainTab, "Fly (Stable / Directional)", "Fly")
AddToggle(MainTab, "Noclip", "Noclip")
AddToggle(MainTab, "Infinite Jump", "InfJump")
AddToggle(VisualsTab, "Player ESP", "ESP")

-- Misc: 스킨 체인저 복구
local SkinBtn = Instance.new("TextButton", MiscTab)
SkinBtn.Size = UDim2.new(1, 0, 0, 40); SkinBtn.Text = "Unlock All Skins"; SkinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); SkinBtn.TextColor3 = Color3.fromRGB(255, 150, 0); SkinBtn.Font = "GothamBold"
SkinBtn.MouseButton1Click:Connect(function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))() end)
end)

-- [[ 3. 고성능 로직 (Aimbot & Fly 고침) ]] --

local function GetNearest()
    local target, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local d = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then target = v; dist = d end
        end
    end
    return target
end

-- Fly 로직 (완전 고침)
local flying = false
local function ToggleFly()
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    flying = true
    local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.zero
    local bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

    task.spawn(function()
        while _G.Config.Fly and char and char.Parent do
            RunService.RenderStepped:Wait()
            local moveDir = char.Humanoid.MoveDirection
            bg.CFrame = Camera.CFrame
            if moveDir.Magnitude > 0 then
                bv.Velocity = (Camera.CFrame.LookVector * moveDir.Z + Camera.CFrame.RightVector * moveDir.X).Unit * _G.Config.FlySpeed
            else
                bv.Velocity = Vector3.new(0, 0.1, 0)
            end
            char.Humanoid.PlatformStand = true
        end
        bv:Destroy(); bg:Destroy(); char.Humanoid.PlatformStand = false; flying = false
    end)
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local target = GetNearest()

    if _G.Config.Fly and not flying then ToggleFly() end
    
    -- Aimbot 고침 (부드러운 조준)
    if _G.Config.Aimbot and target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
    end
    
    -- Auto Shoot
    if _G.Config.AutoShoot and target then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end

    -- Farm & Noclip
    if _G.Config.AutoFarm and target then
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0)
        char.HumanoidRootPart.Velocity = Vector3.zero
    end
    if _G.Config.Noclip or _G.Config.AutoFarm then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- ESP 
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

-- 무한 점프
UserInputService.JumpRequest:Connect(function()
    if _G.Config.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB | V", Text = "Shift 키로 메뉴를 켜고 끌 수 있습니다.", Duration = 4})
