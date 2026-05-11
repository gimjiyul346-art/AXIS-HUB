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
MenuBtn.Size = UDim2.new(0, 65, 0, 65)
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
MainFrame.Size = UDim2.new(0, 480, 0, 380)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -190)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

MenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- [ 3. 탭 시스템 ]
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

local main_pg = CreateTab("Main")
local esp_pg = CreateTab("ESP")
local misc_pg = CreateTab("Misc")
TabPages["Main"].Visible = true

-- [ 4. 공용 토글 함수 ]
local function AddToggle(parent, name, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 42)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Instance.new("UICorner", Frame)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -55, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = "Left"
    Label.Font = "Gotham"

    local Box = Instance.new("TextButton", Frame)
    Box.Size = UDim2.new(0, 24, 0, 24)
    Box.Position = UDim2.new(1, -35, 0.5, -12)
    Box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Box.Text = ""
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)

    local state = false
    Box.MouseButton1Click:Connect(function()
        state = not state
        Box.BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 50, 50)
        callback(state)
    end)
end

-- [[ 5. 주요 기능 구현 ]] --

-- Gun Mod (FireRate 8x)
local function ApplyGunMod(state)
    if state then
        task.spawn(function()
            while state do
                pcall(function()
                    for _, v in pairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
                        if v:IsA("Tool") and v:FindFirstChild("Handle") then
                            -- 일반적인 총기 스크립트 변수 수정 (게임마다 다를 수 있음)
                            local gunScript = v:FindFirstChildOfClass("LocalScript")
                            if gunScript then
                                local env = getfenv(gunScript.source)
                                if env.FireRate then env.FireRate = 8 end
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end

-- Fly (Camera Direction)
local flying = false
local function ApplyFly()
    if not flying then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local bv = root:FindFirstChild("AxisFly") or Instance.new("BodyVelocity", root)
        bv.Name = "AxisFly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while flying and root do
                local moveDir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
                bv.Velocity = moveDir * 60
                task.wait()
            end
            bv:Destroy()
        end)
    end
end
LocalPlayer.CharacterAdded:Connect(function() task.wait(1); if flying then ApplyFly() end end)

-- [[ 6. 버튼 연결 ]] --

-- MAIN 탭
AddToggle(main_pg, "Rage Bot (Key Needed)", function(s)
    if s then loadstring(game:HttpGet("https://pastebin.com/raw/Fkt1pBTJ"))() end
end)
AddToggle(main_pg, "Gun Modpack (8x Speed)", ApplyGunMod)
AddToggle(main_pg, "Silent Aim (Universal)", function(s) _G.SilentAim = s end)
AddToggle(main_pg, "Emote Loop", function(s) 
    if s then 
        local a = Instance.new("Animation"); a.AnimationId = "rbxassetid://92281817840531"
        local t = LocalPlayer.Character.Humanoid:LoadAnimation(a); t:Play(0.1, 1, 9999)
    end 
end)

-- ESP 탭
AddToggle(esp_pg, "Highlight ESP", function(s)
    if s then
        _G.EL = RunService.Heartbeat:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("AxisESP") then
                    local h = Instance.new("Highlight", p.Character); h.Name = "AxisESP"
                end
            end
        end)
    else
        if _G.EL then _G.EL:Disconnect() end
        for _, v in pairs(Players:GetPlayers()) do if v.Character and v.Character:FindFirstChild("AxisESP") then v.Character.AxisESP:Destroy() end end
    end
end)

-- MISC 탭
AddToggle(misc_pg, "Fly (Camera Dir)", function(s) flying = s; ApplyFly() end)
AddToggle(misc_pg, "Infinite Jump", function(s)
    _G.InfJ = UserInputService.JumpRequest:Connect(function()
        if s then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)
AddToggle(misc_pg, "Noclip", function(s)
    _G.Noc = RunService.Stepped:Connect(function()
        if s and LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
    end)
end)
AddToggle(misc_pg, "Skin Changer", function(s) if s then loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))() end end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V3", Text = "Gun Mod & Ragebot Loaded", Duration = 5})
