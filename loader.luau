local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
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
    AutoFarm = false, -- 머리 위 고정
    WalkSpeed = 16,
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
MainFrame.Size = UDim2.new(0, 400, 0, 350)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [ 3. 레이아웃 ]
local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -20, 1, -20)
Content.Position = UDim2.new(0, 10, 0, 10)
Content.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 8)

local function AddToggle(name, var)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
    btn.Text = name .. " : " .. (_G.Config[var] and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        btn.Text = name .. " : " .. (_G.Config[var] and "ON" or "OFF")
        btn.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
    end)
end

AddToggle("Aimbot (Lock)", "Aimbot")
AddToggle("Auto Shoot", "AutoShoot")
AddToggle("Nearest Farm (Top)", "AutoFarm")
AddToggle("Player ESP", "ESP")

-- [[ 5. 가장 가까운 거리 타겟팅 엔진 ]] --

local function GetNearestPlayer()
    local target, closestDist = nil, math.huge
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    
    if not myPos then return nil end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
            if v.Character.Humanoid.Health > 0 then
                local dist = (v.Character.HumanoidRootPart.Position - myPos).Magnitude
                if dist < closestDist then
                    target = v
                    closestDist = dist
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local target = GetNearestPlayer()

    -- Auto Farm (가장 가까운 적 머리 위)
    if _G.Config.AutoFarm and target and target.Character:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        -- 머리 위 5.5 스터드 (조금 더 안전하게 높임)
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5.5, 0)
        
        -- Noclip 강화
        for _, v in pairs(char:GetDescendants()) do 
            if v:IsA("BasePart") then v.CanCollide = false end 
        end
    end

    -- Aimbot (타겟 추적)
    if _G.Config.Aimbot and target and target.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
    end
    
    -- Auto Shoot
    if _G.Config.AutoShoot and target then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V8.7", Text = "가장 가까운 적 추적 모드", Duration = 5})
