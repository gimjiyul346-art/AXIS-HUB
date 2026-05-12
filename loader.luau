local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ UI 초기화 및 정리 ]]
if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end
if CoreGui:FindFirstChild("AXIS_MENU_BTN") then CoreGui.AXIS_MENU_BTN:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

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

-- [ 1. MENU 버튼 (UI 토글) ]
local MenuBtn = Instance.new("TextButton", CoreGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 50, 0, 50)
MenuBtn.Position = UDim2.new(0, 10, 0.5, -25)
MenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MenuBtn.Text = "AXIS"
MenuBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.TextSize = 14
local Stroke = Instance.new("UIStroke", MenuBtn)
Stroke.Color = Color3.fromRGB(0, 150, 255)
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)

-- [ 2. 메인 프레임 (사진 스타일 UI) ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(40, 40, 40)

MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- 상단 탭 시스템
local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1, 0, 0, 35)
TabFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
local TabList = Instance.new("UIListLayout", TabFrame)
TabList.FillDirection = Enum.FillDirection.Horizontal

local Pages = Instance.new("Frame", MainFrame)
Pages.Size = UDim2.new(1, -20, 1, -50)
Pages.Position = UDim2.new(0, 10, 0, 45)
Pages.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", TabFrame)
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Text = name:lower()
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
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
    f.Size = UDim2.new(1, 0, 0, 30); f.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 16, 0, 16); b.Position = UDim2.new(0, 5, 0.5, -8)
    b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    b.Text = ""
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -30, 1, 0); l.Position = UDim2.new(0, 30, 0, 0); l.Text = text; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
    
    b.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    end)
end

-- 버튼 추가
AddToggle(MainTab, "Auto Farm (Top)", "AutoFarm")
AddToggle(MainTab, "Aimbot", "Aimbot")
AddToggle(MainTab, "Auto Shoot", "AutoShoot")
AddToggle(MainTab, "Fly (Stable)", "Fly")
AddToggle(MainTab, "Noclip", "Noclip")
AddToggle(VisualsTab, "Player ESP", "ESP")

-- 스킨 체인저 (렉 방지용 pcall 적용)
local SkinBtn = Instance.new("TextButton", MiscTab)
SkinBtn.Size = UDim2.new(1, 0, 0, 35); SkinBtn.Text = "Unlock All Skins"; SkinBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); SkinBtn.TextColor3 = Color3.new(1,1,1)
SkinBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))() end)
    end)
end)

-- [[ 3. 핵심 엔진 (Fly 고침 & 1인칭 지원) ]] --

local flying = false
local function ToggleFly()
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    flying = true
    local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.zero; bv.Name = "AxisV"
    local bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.Name = "AxisG"

    task.spawn(function()
        while _G.Config.Fly and flying do
            RunService.RenderStepped:Wait()
            local moveDir = char.Humanoid.MoveDirection -- 사용자가 누른 방향키 감지
            if moveDir.Magnitude > 0 then
                bv.Velocity = (Camera.CFrame.LookVector * moveDir.Z + Camera.CFrame.RightVector * moveDir.X).Unit * _G.Config.FlySpeed
            else
                bv.Velocity = Vector3.new(0, 0.1, 0) -- 가만히 있으면 정지
            end
            bg.CFrame = Camera.CFrame
            char.Humanoid.PlatformStand = true
        end
        bv:Destroy(); bg:Destroy(); char.Humanoid.PlatformStand = false; flying = false
    end)
end

-- ESP 엔진 고침
RunService.Heartbeat:Connect(function()
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
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    if _G.Config.Fly and not flying then ToggleFly() end
    
    -- Auto Farm & Noclip 최적화
    if _G.Config.AutoFarm or _G.Config.Noclip then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB | V11.5", Text = "버그 수정 및 최적화 완료", Duration = 3})
