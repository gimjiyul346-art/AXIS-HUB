local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 중복 제거
if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end
if CoreGui:FindFirstChild("AXIS_MENU_BTN") then CoreGui.AXIS_MENU_BTN:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

-- [ MENU 열기/닫기 버튼 ]
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
MainFrame.Size = UDim2.new(0, 480, 0, 350)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -175)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

MenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- [ 상단 탭 바 ]
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
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name:upper()
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = "GothamBold"
    btn.TextSize = 13
    
    local pg = Instance.new("ScrollingFrame", Pages)
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.Visible = false
    pg.BackgroundTransparency = 1
    pg.ScrollBarThickness = 2
    Instance.new("UIListLayout", pg).Padding = UDim.new(0, 8)
    TabPages[name] = pg
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(TabPages) do p.Visible = false end
        for _, b in pairs(TabBar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150) end end
        pg.Visible = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    return pg
end

local main_pg = CreateTab("Main")
local esp_pg = CreateTab("ESP")
local misc_pg = CreateTab("Misc")
TabPages["Main"].Visible = true

-- [ 네모 박스 토글 UI 생성 함수 ]
local function AddToggle(parent, name, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Frame)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.Font = "Gotham"
    Label.TextSize = 14
    Label.TextXAlignment = "Left"

    local Box = Instance.new("TextButton", Frame)
    Box.Size = UDim2.new(0, 24, 0, 24)
    Box.Position = UDim2.new(1, -35, 0.5, -12)
    Box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Box.Text = ""
    local Corner = Instance.new("UICorner", Box)
    Corner.CornerRadius = UDim.new(0, 4)

    local state = false
    Box.MouseButton1Click:Connect(function()
        state = not state
        -- 켰을 때 색깔 채워짐 (파란색), 껐을 때 어두운 회색
        Box.BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 45)
        callback(state)
    end)
end

-- [[ 기능 로직 ]] --

-- 1. Fly (WASD 입력 시에만 이동)
local flying = false
local flySpeed = 50
local flyConn
local function ToggleFly(state)
    flying = state
    if flying then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
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

-- 2. Emote Logic
local emoteActive = false
local currentAnimTrack = nil
local animIdStr = "rbxassetid://92281817840531"

local function playEmote(char)
    if not emoteActive then return end
    local Hum = char:FindFirstChildWhichIsA("Humanoid")
    if not Hum then return end
    
    local animation = Instance.new("Animation")
    animation.AnimationId = animIdStr
    
    for _, track in next, Hum:GetPlayingAnimationTracks() do track:Stop() end
    
    currentAnimTrack = Hum:LoadAnimation(animation)
    currentAnimTrack.Priority = Enum.AnimationPriority.Action4
    currentAnimTrack:Play()
    currentAnimTrack:AdjustSpeed(999) -- 속도
    
    currentAnimTrack.Stopped:Connect(function()
        if emoteActive then playEmote(char) end
    end)
end

-- 3. Silent Aim (메타메소드 방식)
local silentAimActive = false
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldNc = gmt.__namecall
gmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if silentAimActive and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        -- (간략화된 타겟팅 로직이 여기에 들어갑니다)
    end
    return oldNc(self, ...)
end)

-- [[ UI 버튼 연결 ]] --

-- MAIN 탭
AddToggle(main_pg, "Silent Aim", function(s) silentAimActive = s end)
AddToggle(main_pg, "Emote Loop", function(s) 
    emoteActive = s 
    if s then playEmote(LocalPlayer.Character) 
    elseif currentAnimTrack then currentAnimTrack:Stop() end 
end)

-- ESP 탭
AddToggle(esp_pg, "Box ESP", function(s) 
    _G.ESP = s
    if s then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/ESP"))()
    end
end)

-- MISC 탭
AddToggle(misc_pg, "Fly (WASD)", ToggleFly)
AddToggle(misc_pg, "Skin Changer", function(s)
    if s then loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))() end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V1", Text = "Emote & Fly Updated", Duration = 3})
