local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ UI 초기화 ]]
local UI_Parent = CoreGui -- 실행기에 따라 PlayerGui로 자동 전환될 수 있음
if not pcall(function() local a = CoreGui.Name end) then UI_Parent = LocalPlayer:WaitForChild("PlayerGui") end

if UI_Parent:FindFirstChild("AXIS_HUB") then UI_Parent.AXIS_HUB:Destroy() end
if UI_Parent:FindFirstChild("AXIS_MENU_BTN") then UI_Parent.AXIS_MENU_BTN:Destroy() end

local ScreenGui = Instance.new("ScreenGui", UI_Parent)
ScreenGui.Name = "AXIS_HUB"
ScreenGui.ResetOnSpawn = false

_G.Config = {
    Aimbot = false,
    AutoShoot = false,
    AutoFarm = false, -- 상대방 밑으로 텔포
    WalkSpeed = 16,
    ESP = false
}

-- [ 1. MENU 버튼 ]
local MenuBtn = Instance.new("TextButton", ScreenGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 60, 0, 60)
MenuBtn.Position = UDim2.new(0, 10, 0.4, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)

-- [ 2. 메인 프레임 ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 300)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [ 3. UI 레이아웃 ]
local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -20, 1, -20)
Content.Position = UDim2.new(0, 10, 0, 10)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 1.5, 0)
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 8)

local function AddToggle(text, var)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Text = text .. " : OFF"
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = "Gotham"
    Instance.new("UICorner", b)

    b.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        b.Text = text .. " : " .. (_G.Config[var] and "ON" or "OFF")
        b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    end)
end

-- 버튼들
AddToggle("Mobile Aimbot", "Aimbot")
AddToggle("Auto Shoot", "AutoShoot")
AddToggle("Auto Farm (TP Under)", "AutoFarm")
AddToggle("Highlight ESP", "ESP")

-- [ 4. 핵심 엔진 ]
local function GetClosest()
    local target, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Character.Humanoid.Health > 0 then
                local pos, vis = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if vis or _G.Config.AutoFarm then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then
                        target = v
                        dist = mag
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local target = GetClosest()
    
    -- Auto Farm (대상 발밑 텔레포트)
    if _G.Config.AutoFarm and target and target.Character:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
        -- 통과 처리를 위해 CanCollide 끄기
        for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end

    -- Aimbot (시점 고정)
    if _G.Config.Aimbot and target and target.Character:FindFirstChild("Head") and not _G.Config.AutoFarm then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
    end

    -- Auto Shoot (총 자동 발사)
    if _G.Config.AutoShoot and target then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- ESP 로직
RunService.Heartbeat:Connect(function()
    if _G.Config.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("AxisESP") then
                local h = Instance.new("Highlight", p.Character)
                h.Name = "AxisESP"
                h.FillColor = Color3.fromRGB(0, 150, 255)
            end
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB", Text = "모바일 버전 실행 완료", Duration = 5})

