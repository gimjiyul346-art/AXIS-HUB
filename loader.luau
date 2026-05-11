local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 기존 UI 제거
if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end
if CoreGui:FindFirstChild("AXIS_MENU_BTN") then CoreGui.AXIS_MENU_BTN:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

-- [ Menu 버튼 ]
local MenuBtn = Instance.new("TextButton", CoreGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 80, 0, 35)
MenuBtn.Position = UDim2.new(0, 20, 0.5, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = "GothamBold"
MenuBtn.TextSize = 14
Instance.new("UICorner", MenuBtn)

-- [ 메인 프레임 ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

MenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- [ 페이지 설정 ]
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
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Text = name:upper()
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    local pg = Instance.new("ScrollingFrame", Pages)
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.Visible = false
    pg.BackgroundTransparency = 1
    pg.ScrollBarThickness = 0
    Instance.new("UIListLayout", pg).Padding = UDim.new(0, 5)
    TabPages[name] = pg
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(TabPages) do p.Visible = false end
        pg.Visible = true
    end)
    return pg
end

local main_pg = CreateTab("Main")
local esp_pg = CreateTab("ESP")
local misc_pg = CreateTab("Misc")
TabPages["Main"].Visible = true

-- [[ 기능 로직 수정본 ]] --

-- 1. Fly (수정됨: WASD 입력 시에만 이동)
local flying = false
local flySpeed = 50
local flyConn

local function ToggleFly()
    flying = not flying
    if flying then
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local root = char.HumanoidRootPart
        local vel = Instance.new("BodyVelocity", root)
        vel.Name = "AxisFly"
        vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        flyConn = RunService.RenderStepped:Connect(function()
            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            
            vel.Velocity = moveDir * flySpeed
        end)
    else
        if flyConn then flyConn:Disconnect() end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and root:FindFirstChild("AxisFly") then root.AxisFly:Destroy() end
    end
end

-- 2. Silent Aim (보완됨: 가장 가까운 적 추적 및 레이캐스트 후킹)
local silentAimActive = false

local function GetClosestPlayer()
    local target, closestDist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local head = v.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < closestDist and dist < 200 then -- 200은 FOV 범위
                    closestDist = dist
                    target = v
                end
            end
        end
    end
    return target
end

local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldNamecall = gmt.__namecall

gmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if silentAimActive and method == "FindPartOnRayWithIgnoreList" then
        local target = GetClosestPlayer()
        if target and target.Character:FindFirstChild("Head") then
            -- 레이캐스트의 목적지를 적의 머리로 강제 변경
            local origin = args[1].Origin
            local direction = (target.Character.Head.Position - origin).Unit * 1000
            args[1] = Ray.new(origin, direction)
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- 3. ESP (기존 작동 확인됨)
local espActive = false
RunService.RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not p.Character:FindFirstChild("AxisESP") then
                    local b = Instance.new("BoxHandleAdornment", p.Character)
                    b.Name = "AxisESP"; b.Adornee = p.Character; b.AlwaysOnTop = true; b.Size = Vector3.new(4,5,1); b.Color3 = Color3.fromRGB(0,255,255); b.Transparency = 0.5
                end
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("AxisESP") then p.Character.AxisESP:Destroy() end
        end
    end
end)

-- [ UI 버튼 연결 ]
local function AddToggle(parent, name, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = name .. " [OFF]"
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1,1,1)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. (state and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 40)
        callback()
    end)
end

AddToggle(main_pg, "Silent Aim", function() silentAimActive = not silentAimActive end)
AddToggle(esp_pg, "Box ESP", function() espActive = not espActive end)
AddToggle(misc_pg, "Fly (WASD Only)", ToggleFly)
AddToggle(misc_pg, "Skin Changer", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))() end)

print("AXIS HUB LOADED - Fly Fixed & Silent Aim Patched")
