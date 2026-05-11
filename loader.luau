local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ UI 초기화 ]]
if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

_G.Config = {
    Aimbot = false,
    AutoShoot = false,
    AutoFarm = false,
    AttackSpeed = 1, -- 공격 속도 배율
    ESP = false,
    Fly = false,
    InfJump = false,
    Noclip = false,
    SkinChange = false
}

-- [ 1. MENU 버튼 ]
local MenuBtn = Instance.new("TextButton", CoreGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 60, 0, 60)
MenuBtn.Position = UDim2.new(0, 15, 0.45, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)

-- [ 2. 메인 프레임 ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 380)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [ 3. 스크롤 뷰 ]
local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -20, 1, -20)
Content.Position = UDim2.new(0, 10, 0, 10)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 2, 0)
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 10)

-- [ 4. 공용 컴포넌트 함수 ]
local function AddToggle(text, var)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(1, 0, 0, 45)
    b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    b.Text = text .. " : " .. (_G.Config[var] and "ON" or "OFF")
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        b.Text = text .. " : " .. (_G.Config[var] and "ON" or "OFF")
        b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    end)
end

-- 버튼들 추가
AddToggle("Nearest Farm (Top)", "AutoFarm")
AddToggle("Aimbot Lock", "Aimbot")
AddToggle("Auto Shoot", "AutoShoot")
AddToggle("Box ESP", "ESP")
AddToggle("Fly Mode", "Fly")
AddToggle("Infinite Jump", "InfJump")
AddToggle("Noclip", "Noclip")
AddToggle("Skin Changer (Gold)", "SkinChange")

-- [ 공격 속도 조절 버튼 ]
local AtkBtn = Instance.new("TextButton", Content)
AtkBtn.Size = UDim2.new(1, 0, 0, 45)
AtkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AtkBtn.Text = "Attack Speed: x" .. _G.Config.AttackSpeed
AtkBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", AtkBtn)
AtkBtn.MouseButton1Click:Connect(function()
    _G.Config.AttackSpeed = (_G.Config.AttackSpeed >= 10) and 1 or _G.Config.AttackSpeed + 1
    AtkBtn.Text = "Attack Speed: x" .. _G.Config.AttackSpeed
end)

-- [[ 5. 기능 엔진 엔진 ]] --

-- 가장 가까운 적 찾기
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

-- 인피니트 점프
UserInputService.JumpRequest:Connect(function()
    if _G.Config.InfJump then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local target = GetNearest()

    -- 1. Auto Farm
    if _G.Config.AutoFarm and target then
        char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5.5, 0)
    end

    -- 2. Noclip & Fly
    if _G.Config.Noclip or _G.Config.AutoFarm then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    if _G.Config.Fly then char.HumanoidRootPart.Velocity = Vector3.new(0, 20, 0) end

    -- 3. Aimbot & Auto Shoot & Attack Speed
    if target then
        if _G.Config.Aimbot then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position) end
        if _G.Config.AutoShoot then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then 
                for i = 1, _G.Config.AttackSpeed do tool:Activate() end 
            end
        end
    end

    -- 4. Skin Changer (골드 스킨 예시)
    if _G.Config.SkinChange then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") then v.Color = Color3.fromRGB(255, 215, 0); v.Material = Enum.Material.Neon end
        end
    end
end)

-- 5. ESP 수정 (박스 형태)
RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local box = p.Character:FindFirstChild("AxisBox")
            if _G.Config.ESP then
                if not box then
                    local h = Instance.new("Highlight", p.Character)
                    h.Name = "AxisBox"
                    h.FillTransparency = 0.5
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            elseif box then box:Destroy() end
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V10", Text = "모든 기능 로드 완료", Duration = 5})
