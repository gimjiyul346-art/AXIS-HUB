local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- [[ 기존 UI 완전 제거 ]]
if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end
if CoreGui:FindFirstChild("AXIS_MENU_BTN") then CoreGui.AXIS_MENU_BTN:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

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
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

MenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

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
    btn.Size = UDim2.new(0, 110, 1, 0)
    btn.Text = name:upper()
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    
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

local function AddToggle(parent, name, callback)
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
    Box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Box.Text = ""
    Instance.new("UICorner", Box)

    local state = false
    Box.MouseButton1Click:Connect(function()
        state = not state
        Box.BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 50, 50)
        callback(state)
    end)
end

-- [[ 4. 기능 로직 구현 ]] --

-- 타겟팅 함수
local function GetClosestPlayer()
    local target, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mDist < dist then target = v; dist = mDist end
            end
        end
    end
    return target
end

-- Silent Aim (Namecall Hook)
local silentAimActive = false
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldNc = gmt.__namecall
gmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if silentAimActive and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList") then
        local t = GetClosestPlayer()
        if t then
            if method == "Raycast" then
                args[2] = (t.Character.Head.Position - args[1]).Unit * 1000
            end
            return oldNc(self, unpack(args))
        end
    end
    return oldNc(self, ...)
end)

-- Aimbot
local aimbotActive = false
RunService.RenderStepped:Connect(function()
    if aimbotActive and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosestPlayer()
        if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position) end
    end
end)

-- [[ Fly 수정본 (수직 이동 및 리스폰 완벽 대응) ]]
local flying = false
local flySpeed = 60
local function ApplyFly()
    local char = LocalPlayer.Character
    if not char or not flying then return end
    
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    
    -- 기존 비행체 제거
    if root:FindFirstChild("AxisFly") then root.AxisFly:Destroy() end
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "AxisFly"
    bv.Parent = root
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    
    task.spawn(function()
        while flying and char and root.Parent do
            local moveDir = Vector3.new(0,0,0)
            -- 카메라 방향 기반 이동 (W/S는 상하 각도 포함, A/D는 좌우)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            
            -- 조이스틱/키 입력이 없을 때 미세 부양 (추락 방지)
            if moveDir.Magnitude > 0 then
                bv.Velocity = moveDir * flySpeed
            else
                bv.Velocity = Vector3.new(0, 0.1, 0)
            end
            task.wait()
        end
        if bv then bv:Destroy() end
    end)
end

-- 라운드 변경/사망 시 자동 재연결
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.5) -- 리스폰 안정화 대기
    if flying then ApplyFly() end
end)

-- [[ 5. 버튼 연결 ]] --

-- Combat
AddToggle(combat_pg, "Silent Aim (Bullet)", function(s) silentAimActive = s end)
AddToggle(combat_pg, "Aimbot (Right Click)", function(s) aimbotActive = s end)
AddToggle(combat_pg, "Gun Mod (8x Speed)", function(s) 
    if s then loadstring(game:HttpGet("https://raw.githubusercontent.com/gimjiyul346-art/AXIS-HUB/refs/heads/main/loader.luau"))() end
end)

-- Visuals
AddToggle(visuals_pg, "Highlight ESP", function(s)
    if s then
        _G.ESP_LOOP = RunService.Heartbeat:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("AxisESP") then
                    local h = Instance.new("Highlight", p.Character); h.Name = "AxisESP"
                end
            end
        end)
    else
        if _G.ESP_LOOP then _G.ESP_LOOP:Disconnect() end
        for _, v in pairs(Players:GetPlayers()) do if v.Character and v.Character:FindFirstChild("AxisESP") then v.Character.AxisESP:Destroy() end end
    end
end)

-- Misc
AddToggle(misc_pg, "Fixed Fly (Cam Dir)", function(s) flying = s; ApplyFly() end)
AddToggle(misc_pg, "Noclip", function(s)
    _G.NOCLIP_LOOP = RunService.Stepped:Connect(function()
        if s and LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
    end)
end)
AddToggle(misc_pg, "Infinite Jump", function(s)
    _G.INF_JUMP = UserInputService.JumpRequest:Connect(function()
        if s then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V4.1", Text = "Fly & Combat Fixed", Duration = 5})
