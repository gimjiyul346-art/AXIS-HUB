local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ UI 초기화 ]]
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "AXIS_HUB" or v.Name == "AXIS_MENU_BTN" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"
ScreenGui.DisplayOrder = 999

_G.Config = {
    SilentAim = false,
    Wallbang = false,
    RageBot = false,
    Aimbot = false,
    AutoShoot = false,
    Fly = false,
    FlySpeed = 50,
    ESP = false,
    Noclip = false,
    InfJump = false
}

-- [[ 1. UI 디자인 & 토글 (Shift 키 포함) ]]
local MenuBtn = Instance.new("TextButton", CoreGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 50, 0, 50)
MenuBtn.Position = UDim2.new(0, 15, 0.5, -25)
MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MenuBtn.Text = "AXIS"
MenuBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.ZIndex = 1000
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", MenuBtn).Color = Color3.fromRGB(0, 150, 255)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 380)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(40, 40, 40)

local function ToggleUI() MainFrame.Visible = not MainFrame.Visible end
MenuBtn.MouseButton1Click:Connect(ToggleUI)
UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.LeftShift then ToggleUI() end end)

local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1, 0, 0, 40)
TabFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UIListLayout", TabFrame).FillDirection = "Horizontal"

local Pages = Instance.new("Frame", MainFrame)
Pages.Size = UDim2.new(1, -20, 1, -60)
Pages.Position = UDim2.new(0, 10, 0, 50)
Pages.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local b = Instance.new("TextButton", TabFrame)
    b.Size = UDim2.new(0.333, 0, 1, 0)
    b.Text = name:upper()
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    b.TextColor3 = Color3.fromRGB(200, 200, 200)
    b.Font = "GothamBold"
    b.BorderSizePixel = 0
    local p = Instance.new("ScrollingFrame", Pages)
    p.Size = UDim2.new(1, 0, 1, 0); p.Visible = false; p.BackgroundTransparency = 1; p.ScrollBarThickness = 2
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 5)
    b.MouseButton1Click:Connect(function() for _, v in pairs(Tabs) do v.Visible = false end p.Visible = true end)
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
AddToggle(MainTab, "Silent Aim (Target Hit)", "SilentAim")
AddToggle(MainTab, "Wallbang (Shoot Through)", "Wallbang")
AddToggle(MainTab, "Aimbot Lock", "Aimbot")
AddToggle(MainTab, "Fly (Improved)", "Fly")
AddToggle(VisualsTab, "Player ESP", "ESP")
AddToggle(MiscTab, "RAGE BOT (Full Aggressive)", "RageBot")

local SkinBtn = Instance.new("TextButton", MiscTab)
SkinBtn.Size = UDim2.new(1, 0, 0, 40); SkinBtn.Text = "Unlock All Skins"; SkinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); SkinBtn.TextColor3 = Color3.fromRGB(255, 150, 0); SkinBtn.Font = "GothamBold"
SkinBtn.MouseButton1Click:Connect(function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))() end) end)

-- [[ 2. 핵심 통합 로직 ]] --

local function GetNearest()
    local target, dist = nil, 2000
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local d = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then target = v; dist = d end
        end
    end
    return target
end

-- Wallbang & Silent Aim 후킹 로직
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if _G.Config.SilentAim and Method == "FindPartOnRayWithIgnoreList" then
        local T = GetNearest()
        if T then
            Args[1] = Ray.new(Args[1].Origin, (T.Character.HumanoidRootPart.Position - Args[1].Origin).Unit * 1000)
            return OldNamecall(Self, unpack(Args))
        end
    end
    
    if _G.Config.Wallbang and Method == "Raycast" then
        return nil -- 레이캐스트 결과를 무효화하여 벽 무시
    end
    
    return OldNamecall(Self, ...)
end)

-- Rage Bot & Fly 로직
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local target = GetNearest()

    -- Rage Bot: 초고속 추적 및 자동 사격
    if _G.Config.RageBot and target then
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        char.HumanoidRootPart.Velocity = Vector3.zero
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end

    -- Fly 로직 (기존 성공 버전 유지)
    if _G.Config.Fly then
        local hrp = char.HumanoidRootPart
        if not hrp:FindFirstChild("AxisV") then
            local bv = Instance.new("BodyVelocity", hrp); bv.Name = "AxisV"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            local bg = Instance.new("BodyGyro", hrp); bg.Name = "AxisG"; bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        end
        local hum = char.Humanoid
        hum.PlatformStand = true
        hrp.BodyGyro.CFrame = Camera.CFrame
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            hrp.BodyVelocity.Velocity = (Camera.CFrame.LookVector * moveDir.Z + Camera.CFrame.RightVector * moveDir.X).Unit * _G.Config.FlySpeed
        else
            hrp.BodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
        end
    else
        if char.HumanoidRootPart:FindFirstChild("AxisV") then 
            char.HumanoidRootPart.AxisV:Destroy() 
            char.HumanoidRootPart.AxisG:Destroy()
            char.Humanoid.PlatformStand = false
        end
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

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB | V", Text = "Rage & Wallbang 기능 통합 완료", Duration = 4})
