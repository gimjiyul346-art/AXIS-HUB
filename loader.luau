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
    AttackSpeed = 1,
    ESP = false,
    Fly = false,
    InfJump = false,
    Noclip = false,
    FlySpeed = 50
}

-- [ 1. 고정 MENU 버튼 ]
local MenuBtn = Instance.new("TextButton", CoreGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 50, 0, 50)
MenuBtn.Position = UDim2.new(0, 10, 0.5, -25)
MenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuBtn.BorderSizePixel = 2
MenuBtn.BorderColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Text = "AXIS"
MenuBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.TextSize = 14
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)

-- [ 2. 메인 프레임 ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 380)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- 상단 제목 바
local TitleBar = Instance.new("TextLabel", MainFrame)
TitleBar.Size = UDim2.new(1, -10, 0, 30)
TitleBar.Position = UDim2.new(0, 10, 0, 0)
TitleBar.Text = "AXIS Enhancements - 1st Year Middle School Edition"
TitleBar.TextColor3 = Color3.fromRGB(150, 150, 150)
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Font = Enum.Font.Gotham
TitleBar.TextSize = 12
TitleBar.BackgroundTransparency = 1

-- [ 3. 탭 시스템 ]
local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1, 0, 0, 30)
TabFrame.Position = UDim2.new(0, 0, 0, 30)
TabFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TabFrame.BorderSizePixel = 0

local TabList = Instance.new("UIListLayout", TabFrame)
TabList.FillDirection = Enum.FillDirection.Horizontal

local Pages = Instance.new("Frame", MainFrame)
Pages.Size = UDim2.new(1, -20, 1, -70)
Pages.Position = UDim2.new(0, 10, 0, 65)
Pages.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabFrame)
    TabBtn.Size = UDim2.new(0, 80, 1, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = name:lower()
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 13
    TabBtn.BorderSizePixel = 0
    
    local Page = Instance.new("ScrollingFrame", Pages)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 10)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end
        Page.Visible = true
    end)
    
    Tabs[name] = Page
    return Page
end

local MainTab = CreateTab("Main")
local VisualsTab = CreateTab("Visuals")
local MiscTab = CreateTab("Misc")
Tabs["Main"].Visible = true

-- [ 4. 섹션 및 토글 함수 ]
local function CreateSection(parent, title)
    local SectionFrame = Instance.new("Frame", parent)
    SectionFrame.Size = UDim2.new(1, -5, 0, 30)
    SectionFrame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", SectionFrame)
    Label.Text = "  " .. title:lower()
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Label.TextColor3 = Color3.fromRGB(0, 150, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UIStroke", Label).Color = Color3.fromRGB(40, 40, 40)
    
    return parent
end

local function AddToggle(parent, text, var)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -5, 0, 30)
    Frame.BackgroundTransparency = 1
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 15, 0, 15)
    Btn.Position = UDim2.new(0, 5, 0.5, -7)
    Btn.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
    Btn.Text = ""
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Position = UDim2.new(0, 25, 0, 0)
    Label.Text = text:lower()
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    Btn.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        Btn.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
    end)
end

-- 메인 탭 구성
CreateSection(MainTab, "Combat & Farming")
AddToggle(MainTab, "Auto Farm (Nearest Top)", "AutoFarm")
AddToggle(MainTab, "Aimbot Enabled", "Aimbot")
AddToggle(MainTab, "Auto Shoot (On Aim)", "AutoShoot")

CreateSection(MainTab, "Character")
AddToggle(MainTab, "Fly (IY Style)", "Fly")
AddToggle(MainTab, "Noclip", "Noclip")
AddToggle(MainTab, "Infinite Jump", "InfJump")

-- 비주얼 탭 구성
CreateSection(VisualsTab, "ESP World")
AddToggle(VisualsTab, "Player Boxes", "ESP")

-- 올스킨 버튼 (이미지처럼 심플하게)
local SkinBtn = Instance.new("TextButton", MiscTab)
SkinBtn.Size = UDim2.new(1, -5, 0, 35)
SkinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SkinBtn.Text = "Unlock All Skins"
SkinBtn.TextColor3 = Color3.fromRGB(255, 150, 0)
SkinBtn.Font = Enum.Font.GothamBold
Instance.new("UIStroke", SkinBtn).Color = Color3.fromRGB(50, 50, 50)
SkinBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))()
end)

-- [[ 5. 기능 로직 (V10.3 기반 고도화) ]] --

-- IY Fly 로직
local flying = false
local function sFly()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    flying = true
    local bg = Instance.new("BodyGyro", hrp); bg.Name = "AxisGyro"; bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.cframe = hrp.CFrame
    local bv = Instance.new("BodyVelocity", hrp); bv.Name = "AxisFly"; bv.velocity = Vector3.new(0, 0.1, 0); bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    task.spawn(function()
        while _G.Config.Fly and flying do
            task.wait()
            char.Humanoid.PlatformStand = true
            bv.velocity = Camera.CFrame.LookVector * _G.Config.FlySpeed
            bg.cframe = Camera.CFrame
        end
        bg:Destroy(); bv:Destroy(); char.Humanoid.PlatformStand = false; flying = false
    end)
end

local function GetNearest()
    local target, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local d = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then target = v; dist = d end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local target = GetNearest()

    if _G.Config.Fly and not flying then sFly() end
    if _G.Config.AutoFarm and target then
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5.5, 0)
        char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
    end
    if _G.Config.Aimbot and target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
    end
    if _G.Config.AutoShoot then
        local ray = Camera:ScreenPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local res = workspace:Raycast(ray.Origin, ray.Direction * 1000)
        if res and res.Instance and res.Instance:FindFirstAncestorOfClass("Model") and Players:GetPlayerFromCharacter(res.Instance:FindFirstAncestorOfClass("Model")) then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
    if _G.Config.Noclip or _G.Config.AutoFarm then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V11", Text = "Premium UI Loaded", Duration = 3})
