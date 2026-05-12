local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 기존 UI 제거 ]]
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
    Noclip = false
}

-- [ 1. 고정 MENU 버튼 ] - UI가 닫혀도 항상 화면 옆에 보임
local MenuBtn = Instance.new("TextButton", CoreGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 50, 0, 50)
MenuBtn.Position = UDim2.new(0, 10, 0.5, -25) -- 화면 왼쪽 중앙
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.new(1,1,1)
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.TextSize = 12
MenuBtn.ZIndex = 100
local Corner = Instance.new("UICorner", MenuBtn)
Corner.CornerRadius = UDim.new(1, 0) -- 원형 버튼

-- [ 2. 메인 프레임 ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 350)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

-- 버튼 클릭 시 UI 토글
MenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- [ 3. 스크롤 내용 ]
local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -20, 1, -20)
Content.Position = UDim2.new(0, 10, 0, 10)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 3
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 8)

local function AddToggle(text, var)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 45)
    b.Text = text .. " : " .. (_G.Config[var] and "ON" or "OFF")
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        b.Text = text .. " : " .. (_G.Config[var] and "ON" or "OFF")
        b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 45)
    end)
end

-- 버튼 순서
AddToggle("Auto Farm (Nearest Top)", "AutoFarm")
AddToggle("Aimbot Lock", "Aimbot")
AddToggle("Auto Shoot", "AutoShoot")
AddToggle("Fly Mode (Stable)", "Fly")
AddToggle("Infinite Jump", "InfJump")
AddToggle("Noclip", "Noclip")
AddToggle("Box ESP", "ESP")

-- 올스킨 버튼
local SkinBtn = Instance.new("TextButton", Content)
SkinBtn.Size = UDim2.new(1, 0, 0, 40); SkinBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 0); SkinBtn.Text = "Unlock All Skins"; SkinBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SkinBtn)
SkinBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))()
end)

-- 공속 조절 버튼 (개선됨)
local AtkBtn = Instance.new("TextButton", Content)
AtkBtn.Size = UDim2.new(1, 0, 0, 40); AtkBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); AtkBtn.Text = "Attack Speed: x" .. _G.Config.AttackSpeed; AtkBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", AtkBtn)
AtkBtn.MouseButton1Click:Connect(function()
    _G.Config.AttackSpeed = (_G.Config.AttackSpeed >= 10) and 1 or _G.Config.AttackSpeed + 1
    AtkBtn.Text = "Attack Speed: x" .. _G.Config.AttackSpeed
end)

-- [[ 4. 기능 엔진 (과부하 방지 최적화) ]] --

local function GetNearest()
    local target, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local d = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then target = v; dist = d end
        end
    end
    return target
end

-- Fly & Noclip & Farm 루프 (안정화)
task.spawn(function()
    while task.wait() do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- Fly 로직 (BodyVelocity 사용으로 안정화)
        if _G.Config.Fly then
            if not hrp:FindFirstChild("AxisFly") then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.Name = "AxisFly"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 2, 0) -- 살짝 떠 있게 유지
            end
        elseif hrp:FindFirstChild("AxisFly") then
            hrp.AxisFly:Destroy()
        end

        -- Auto Farm
        if _G.Config.AutoFarm then
            local target = GetNearest()
            if target then
                hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5.5, 0)
                hrp.Velocity = Vector3.new(0,0,0)
            end
        end

        -- Noclip
        if _G.Config.Noclip or _G.Config.AutoFarm then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- Aimbot & AutoShoot (공속 최적화)
RunService.RenderStepped:Connect(function()
    local target = GetNearest()
    if not target then return end

    if _G.Config.Aimbot then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
    end

    if _G.Config.AutoShoot then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            for i = 1, _G.Config.AttackSpeed do
                tool:Activate()
            end
        end
    end
end)

-- Inf Jump
UserInputService.JumpRequest:Connect(function()
    if _G.Config.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- ESP
task.spawn(function()
    while task.wait(1) do -- ESP는 1초마다만 갱신 (렉 방지)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local box = p.Character:FindFirstChild("AxisESP")
                if _G.Config.ESP then
                    if not box then
                        local h = Instance.new("Highlight", p.Character)
                        h.Name = "AxisESP"
                        h.FillColor = Color3.fromRGB(0, 150, 255)
                    end
                elseif box then box:Destroy() end
            end
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V10.2", Text = "최적화 및 MENU 버튼 적용 완료", Duration = 5})
