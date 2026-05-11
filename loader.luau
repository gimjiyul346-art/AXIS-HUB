local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- [[ UI 초기화 및 중복 제거 ]]
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

-- [[ 4. 기능 로직 교체 및 강화 ]] --

-- [A] Silent Aim 교체 (요청하신 Pastebin 소스 적용)
local function LoadSilentAim(state)
    if state then
        loadstring(game:HttpGet('https://pastebin.com/raw/Ntnsncmj'))()
    end
end

-- [B] Fly 수정 (카메라 방향 수직이동 엔진 통합)
local flying = false
local flySpeed = 60
local function ApplyFly()
    local char = LocalPlayer.Character
    if not char or not flying then return end
    local root = char:WaitForChild("HumanoidRootPart")
    
    if root:FindFirstChild("AxisFly") then root.AxisFly:Destroy() end
    local bv = Instance.new("BodyVelocity", root)
    bv.Name = "AxisFly"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    
    task.spawn(function()
        while flying and root.Parent do
            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            
            bv.Velocity = (moveDir.Magnitude > 0) and (moveDir * flySpeed) or Vector3.new(0, 0.1, 0)
            task.wait()
        end
        if bv then bv:Destroy() end
    end)
end
LocalPlayer.CharacterAdded:Connect(function() task.wait(1); if flying then ApplyFly() end end)

-- [C] Noclip 로직
local noclip = false
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- [[ 5. 버튼 연결 ]] --

-- COMBAT
AddToggle(combat_pg, "Advanced Silent Aim", LoadSilentAim)
AddToggle(combat_pg, "Aimbot (Right Click)", function(s) 
    _G.Aimbot = s -- Aimbot 로직은 V4.1 기반 유지
end)
AddToggle(combat_pg, "Gun Mod (8x Speed)", function(s)
    if s then loadstring(game:HttpGet("https://raw.githubusercontent.com/gimjiyul346-art/AXIS-HUB/refs/heads/main/loader.luau"))() end
end)

-- VISUALS
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

-- MISC
AddToggle(misc_pg, "High Performance Fly", function(s) flying = s; ApplyFly() end)
AddToggle(misc_pg, "Noclip", function(s) noclip = s end)
AddToggle(misc_pg, "Infinite Jump", function(s)
    _G.INF_JUMP = UserInputService.JumpRequest:Connect(function()
        if s then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V5", Text = "Engines Successfully Integrated", Duration = 5})
