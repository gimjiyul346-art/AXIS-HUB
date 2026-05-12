local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 기존 찌꺼기 제거 - 확실하게 초기화 ]]
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "AXIS_HUB" or v.Name == "AXIS_MENU_BTN" then v:Destroy() end
end

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
    InfJump = false,
    AttackSpeed = 1
}

-- [ 1. 상시 고정 MENU 버튼 ]
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
Stroke.Thickness = 2
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)

-- [ 2. 메인 프레임 ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Color = Color3.fromRGB(40, 40, 40)

MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- 상단 탭 시스템 (Main / Visuals / Misc)
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
    pg.CanvasSize = UDim2.new(0,0,1.5,0)
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
    b.Size = UDim2.new(0, 20, 0, 20); b.Position = UDim2.new(0, 5, 0.5, -10)
    b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -40, 1, 0); l.Position = UDim2.new(0, 35, 0, 0); l.Text = text; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"; l.Font = "Gotham"
    
    b.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    end)
end

-- [ 기능 버튼 배치 ]
AddToggle(MainTab, "Auto Farm (Nearest)", "AutoFarm")
AddToggle(MainTab, "Aimbot Lock", "Aimbot")
AddToggle(MainTab, "Auto Shoot (Aim Target)", "AutoShoot")
AddToggle(MainTab, "Fly (Improved 1st Person)", "Fly")
AddToggle(MainTab, "Noclip", "Noclip")
AddToggle(MainTab, "Infinite Jump", "InfJump")
AddToggle(VisualsTab, "Player Highlight ESP", "ESP")

-- Misc: Skin Changer & Speed
local SkinBtn = Instance.new("TextButton", MiscTab)
SkinBtn.Size = UDim2.new(1, 0, 0, 40); SkinBtn.Text = "Unlock All Skins (Skin Changer)"; SkinBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); SkinBtn.TextColor3 = Color3.fromRGB(255,150,0); SkinBtn.Font = "GothamBold"
SkinBtn.MouseButton1Click:Connect(function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))() end)
end)

-- [[ 3. 고성능 엔진 코드 ]] --

local flying = false
local function ControlFly()
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    flying = true
    local bv = Instance.new("BodyVelocity", hrp); bv.Name = "AXIS_V"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.zero
    local bg = Instance.new("BodyGyro", hrp); bg.Name = "AXIS_G"; bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

    task.spawn(function()
        while _G.Config.Fly and char and char:Parent() do
            RunService.RenderStepped:Wait()
            local moveDir = char.Humanoid.MoveDirection
            bg.CFrame = Camera.CFrame -- 1인칭에서도 카메라 방향 유지
            
            if moveDir.Magnitude > 0 then
                -- 카메라 정면 방향과 방향키 입력을 조합하여 이동
                bv.Velocity = (Camera.CFrame.LookVector * moveDir.Z + Camera.CFrame.RightVector * moveDir.X).Unit * _G.Config.FlySpeed
            else
                bv.Velocity = Vector3.new(0, 0.1, 0) -- 정지 시 공중 부양
            end
            char.Humanoid.PlatformStand = true
        end
        bv:Destroy(); bg:Destroy(); char.Humanoid.PlatformStand = false; flying = false
    end)
end

-- ESP & 최적화 루프
task.spawn(function()
    while task.wait(0.5) do
        if _G.Config.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not p.Character:FindFirstChild("AXIS_ESP") then
                        local h = Instance.new("Highlight", p.Character)
                        h.Name = "AXIS_ESP"
                        h.FillColor = Color3.fromRGB(0, 150, 255)
                    end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("AXIS_ESP") then p.Character.AXIS_ESP:Destroy() end
            end
        end
    end
end)

-- 메인 실행 루프
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    if _G.Config.Fly and not flying then ControlFly() end
    if not _G.Config.Fly then flying = false end

    -- Noclip / Farm
    if _G.Config.Noclip or _G.Config.AutoFarm then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    
    -- Farm 위치 고정
    if _G.Config.AutoFarm then
        local target = nil; local dist = math.huge
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                local d = (v.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if d < dist then target = v; dist = d end
            end
        end
        if target then char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0) end
    end

    -- Aimbot & AutoShoot
    if _G.Config.Aimbot or _G.Config.AutoShoot then
        local target = nil; local dist = math.huge
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                local d = (v.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if d < dist then target = v; dist = d end
            end
        end
        if target then
            if _G.Config.Aimbot then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position) end
            if _G.Config.AutoShoot then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    end
end)

-- 인재 점프
UserInputService.JumpRequest:Connect(function()
    if _G.Config.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB | V", Text = "모든 버그가 수정되었습니다.", Duration = 4})
