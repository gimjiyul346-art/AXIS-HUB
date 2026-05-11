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
    Wallbang = false,
    WalkSpeed = 16,
    Fly = false,
    Noclip = false,
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
MainFrame.Size = UDim2.new(0, 480, 0, 400)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -200)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [ 3. 탭 시스템 ]
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UIListLayout", TabBar).FillDirection = "Horizontal"

local Pages = Instance.new("Frame", MainFrame)
Pages.Position = UDim2.new(0, 10, 0, 50)
Pages.Size = UDim2.new(1, -20, 1, -60)
Pages.BackgroundTransparency = 1

local TabPages = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.Text = name:upper()
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = "GothamBold"
    
    local pg = Instance.new("ScrollingFrame", Pages)
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.Visible = false
    pg.BackgroundTransparency = 1
    pg.ScrollBarThickness = 0
    Instance.new("UIListLayout", pg).Padding = UDim.new(0, 8)
    TabPages[name] = pg
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(TabPages) do p.Visible = false end
        pg.Visible = true
    end)
    return pg
end

local combat_pg = CreateTab("Combat")
local visuals_pg = CreateTab("Visuals")
local misc_pg = CreateTab("Misc")
TabPages["Combat"].Visible = true

-- [ 4. 공용 컴포넌트 ]
local function AddToggle(parent, name, var)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Frame)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = "Left"

    local Box = Instance.new("TextButton", Frame)
    Box.Size = UDim2.new(0, 22, 0, 22)
    Box.Position = UDim2.new(1, -30, 0.5, -11)
    Box.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 50, 50)
    Box.Text = ""
    Instance.new("UICorner", Box)

    Box.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        Box.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 50, 50)
    end)
end

-- [[ 5. 모바일 전용 엔진 (Mobile Optimized) ]] --

-- 화면 중앙에서 가장 가까운 적 찾기
local function GetClosestToCenter()
    local target, dist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis or _G.Config.Wallbang then
                local mDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mDist < dist then
                    target = v
                    dist = mDist
                end
            end
        end
    end
    return target
end

-- 오토 슛 실행 함수 (모바일용 가상 클릭 대신 서버 신호 모방)
local function FastShoot()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate() -- 대부분의 모바일 환경에서 가장 안정적인 발사 신호
    end
end

RunService.RenderStepped:Connect(function()
    -- 모바일 에임봇: 조이스틱 조작 중에도 적의 머리를 부드럽게 추격
    if _G.Config.Aimbot then
        local t = GetClosestToCenter()
        if t and t.Character:FindFirstChild("Head") then
            local targetPos = t.Character.Head.Position
            -- CFrame을 사용해 카메라 방향을 적에게 직접 고정
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            
            if _G.Config.AutoShoot then
                FastShoot()
            end
        end
    end

    -- 이동 관련 (모바일 슬라이더 속도 적용)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if _G.Config.WalkSpeed > 16 and char.Humanoid.MoveDirection.Magnitude > 0 then
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (char.Humanoid.MoveDirection * (_G.Config.WalkSpeed / 300))
        end
        if _G.Config.Fly then char.HumanoidRootPart.Velocity = Vector3.new(0, 3, 0) end
    end
end)

-- [[ 6. 버튼 연결 ]] --

-- Combat
AddToggle(combat_pg, "Mobile Aimbot (Center Lock)", "Aimbot")
AddToggle(combat_pg, "Mobile Auto Shoot", "AutoShoot")
AddToggle(combat_pg, "Wallbang", "Wallbang")

-- Visuals
AddToggle(visuals_pg, "Highlight ESP", "ESP")
RunService.Heartbeat:Connect(function()
    if _G.Config.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("AxisESP") then
                local h = Instance.new("Highlight", p.Character); h.Name = "AxisESP"
            end
        end
    end
end)

-- Misc
-- 모바일에서 쓰기 편한 버튼식 속도 증가 (슬라이더 대신 10단위 증가)
local SpeedBtn = Instance.new("TextButton", misc_pg)
SpeedBtn.Size = UDim2.new(1, 0, 0, 40); SpeedBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); SpeedBtn.Text = "WalkSpeed: ".._G.Config.WalkSpeed; SpeedBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SpeedBtn)
SpeedBtn.MouseButton1Click:Connect(function()
    _G.Config.WalkSpeed = (_G.Config.WalkSpeed >= 200) and 16 or _G.Config.WalkSpeed + 20
    SpeedBtn.Text = "WalkSpeed: ".._G.Config.WalkSpeed
end)

AddToggle(misc_pg, "Fly Mode", "Fly")
AddToggle(misc_pg, "Noclip", "Noclip")

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V8", Text = "Mobile Optimized Engines Loaded", Duration = 5})
