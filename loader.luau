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

-- [ MENU 버튼 (모바일 배려) ]
local MenuBtn = Instance.new("TextButton", CoreGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 70, 0, 70) -- 모바일 터치 편의를 위해 크게 설정
MenuBtn.Position = UDim2.new(0, 10, 0.4, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = "GothamBold"
MenuBtn.TextSize = 14
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0) -- 원형 버튼

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

-- [ 탭 시스템 ]
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 45)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UIListLayout", TabBar).FillDirection = "Horizontal"

local Pages = Instance.new("Frame", MainFrame)
Pages.Position = UDim2.new(0, 10, 0, 55)
Pages.Size = UDim2.new(1, -20, 1, -65)
Pages.BackgroundTransparency = 1

local TabPages = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 110, 1, 0)
    btn.Text = name:upper()
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    
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

local main_pg = CreateTab("Main")
local esp_pg = CreateTab("ESP")
local misc_pg = CreateTab("Misc")
TabPages["Main"].Visible = true

-- [ 공용 토글 함수 ]
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

-- [[ 기능 로직 고침 ]] --

-- 1. Fly (PC/모바일 공용 - 방향키 및 조이스틱 대응)
local flying = false
local flySpeed = 50
function ToggleFly(state)
    flying = state
    local char = LocalPlayer.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    if flying and root then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "AxisFly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while flying do
                -- Humanoid.MoveDirection을 사용하여 PC(WASD)와 모바일(조이스틱) 모두 대응
                local moveDir = char.Humanoid.MoveDirection
                if moveDir.Magnitude > 0 then
                    bv.Velocity = moveDir * flySpeed
                else
                    bv.Velocity = Vector3.new(0, 0.1, 0) -- 정지 시 미세부양으로 추락방지
                end
                task.wait()
            end
            bv:Destroy()
        end)
    end
end

-- 2. Silent Aim (가장 확실한 방식)
local silentAimActive = false
local function GetClosest()
    local target, dist = nil, 2000
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

-- 총알 궤적 수정
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, index)
    if silentAimActive and self == Mouse and index == "Hit" then
        local target = GetClosest()
        if target then return target.Character.Head.CFrame end
    end
    return oldIndex(self, index)
end)

-- 3. ESP 고침 (Box + Tracers)
local function CreateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("AxisESP") then
            local b = Instance.new("Highlight", p.Character)
            b.Name = "AxisESP"; b.FillTransparency = 0.5; b.OutlineColor = Color3.new(1,0,0)
        end
    end
end

-- 4. Emote (익스큐터 직접 실행 방식)
function RunEmote(state)
    if state then
        -- 요청하신 애니메이션 스크립트 본체
        local animId = "rbxassetid://92281817840531"
        local anim = Instance.new("Animation")
        anim.AnimationId = animId
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local track = hum:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action4
        track:Play(0.1, 1, 9999) -- 속도 9999
    end
end

-- [[ 버튼 연결 ]] --
AddToggle(main_pg, "Silent Aim", function(s) silentAimActive = s end)
AddToggle(main_pg, "Emote Loop (Execute)", RunEmote)

AddToggle(esp_pg, "High Quality ESP", function(s)
    if s then RunService:BindToRenderStep("ESP", 1, CreateESP)
    else 
        RunService:UnbindFromRenderStep("ESP")
        for _, v in pairs(Players:GetPlayers()) do if v.Character and v.Character:FindFirstChild("AxisESP") then v.Character.AxisESP:Destroy() end end
    end
end)

AddToggle(misc_pg, "Mobile/PC Fly", ToggleFly)
AddToggle(misc_pg, "Skin Changer", function(s)
    if s then loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))() end
end)
