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
    Wallbang = false,
    AutoFarm = false, -- 머리 위 텔레포트
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
    Box.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    Box.Text = ""
    Instance.new("UICorner", Box)

    Box.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        Box.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    end)
end

-- [[ 5. 엔진 로직 ]] --

local function GetCombatTarget()
    local target, lowestHealth = nil, 100
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
            local hp = v.Character.Humanoid.Health
            if hp > 0 and hp < lowestHealth then -- 싸우는 중인 적 우선
                target = v
                lowestHealth = hp
            end
        end
    end
    if not target then
        local dist = math.huge
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local d = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then target = v; dist = d end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local target = GetCombatTarget()

    -- Auto Farm (Top TP)
    if _G.Config.AutoFarm and target and target.Character:FindFirstChild("HumanoidRootPart") then
        -- 상대방의 머리 위(+4.5 스터드)로 좌표 설정
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 4.5, 0)
        
        -- Noclip 적용하여 몸이 끼지 않게 함
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end

    -- 모바일 에임봇 및 오토슛
    if _G.Config.Aimbot and not _G.Config.AutoFarm and target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
    end
    
    if _G.Config.AutoShoot and target then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- [[ 6. 버튼 연결 ]] --
AddToggle(combat_pg, "Mobile Aimbot", "Aimbot")
AddToggle(combat_pg, "Mobile Auto Shoot", "AutoShoot")
AddToggle(combat_pg, "Top Auto Farm (Safe)", "AutoFarm") -- 머리 위 텔포
AddToggle(combat_pg, "Wallbang", "Wallbang")

AddToggle(visuals_pg, "Highlight ESP", "ESP")
AddToggle(misc_pg, "Noclip", "Noclip")

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V8.5", Text = "머리 위 텔레포트 적용 완료", Duration = 5})
