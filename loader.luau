local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ UI 초기화 ]]
if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

_G.Config = {
    Aimbot = false,
    AutoShoot = false,
    AutoFarm = false,
    AttackSpeed = 1, 
    ESP = false,
    Fly = false,
    InfJump = false,
    Noclip = false
}

-- [ 1. MENU 버튼 ]
local MenuBtn = Instance.new("TextButton", CoreGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 60, 0, 60)
MenuBtn.Position = UDim2.new(0, 15, 0.45, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)

-- [ 2. 메인 프레임 ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 400)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -20, 1, -20)
Content.Position = UDim2.new(0, 10, 0, 10)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 2.2, 0)
local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 10)

-- [ 3. 공용 토글 함수 ]
local function AddToggle(text, var)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(1, 0, 0, 45)
    b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    b.Text = text .. " : " .. (_G.Config[var] and "ON" or "OFF")
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        _G.Config[var] = not _G.Config[var]
        b.Text = text .. " : " .. (_G.Config[var] and "ON" or "OFF")
        b.BackgroundColor3 = _G.Config[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    end)
end

-- [ 4. 특수 버튼 (올스킨) ]
local SkinBtn = Instance.new("TextButton", Content)
SkinBtn.Size = UDim2.new(1, 0, 0, 45)
SkinBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
SkinBtn.Text = "✨ UNLOCK ALL SKINS (Load Script)"
SkinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SkinBtn)
SkinBtn.MouseButton1Click:Connect(function()
    SkinBtn.Text = "Loading Skins..."
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))()
    end)
    SkinBtn.Text = "✅ Skins Loaded!"
end)

-- 기능 버튼들
AddToggle("Nearest Farm (Top)", "AutoFarm")
AddToggle("Aimbot Lock", "Aimbot")
AddToggle("Auto Shoot (Required for Speed)", "AutoShoot")
AddToggle("Box ESP", "ESP")
AddToggle("Fly Mode", "Fly")
AddToggle("Infinite Jump", "InfJump")
AddToggle("Noclip", "Noclip")

-- [ 5. 공격 속도 조절 막대기(버튼) ]
local AtkBtn = Instance.new("TextButton", Content)
AtkBtn.Size = UDim2.new(1, 0, 0, 45)
AtkBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AtkBtn.Text = "Attack Speed: x" .. _G.Config.AttackSpeed .. " (Click to Increase)"
AtkBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", AtkBtn)
AtkBtn.MouseButton1Click:Connect(function()
    _G.Config.AttackSpeed = (_G.Config.AttackSpeed >= 15) and 1 or _G.Config.AttackSpeed + 2
    AtkBtn.Text = "Attack Speed: x" .. _G.Config.AttackSpeed
end)

-- [[ 6. 핵심 엔진 로직 ]] --

local function GetNearest()
    local target, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local d = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then target = v; dist = d end
        end
    end
    return target
end

-- 인피니트 점프
UserInputService.JumpRequest:Connect(function()
    if _G.Config.InfJump then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local target = GetNearest()

    -- 1. Auto Farm & Noclip
    if _G.Config.AutoFarm and target then
        char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5.5, 0)
    end
    if _G.Config.Noclip or _G.Config.AutoFarm then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end

    -- 2. Fly
    if _G.Config.Fly then char.HumanoidRootPart.Velocity = Vector3.new(0, 30, 0) end

    -- 3. Aimbot & 공격 속도 강화 루프
    if target then
        if _G.Config.Aimbot then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position) end
        
        if _G.Config.AutoShoot then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then 
                -- 공격 속도 배율만큼 루프 실행 (Fast Attack)
                for i = 1, _G.Config.AttackSpeed do
                    tool:Activate()
                    -- 도구 내부에 'Handle'이나 'RemoteEvent'가 있는 경우 신호를 강제로 보냄
                    local remote = tool:FindFirstChildOfClass("RemoteEvent") or tool:FindFirstChild("Remote")
                    if remote then remote:FireServer(target.Character.HumanoidRootPart.Position) end
                end 
            end
        end
    end
end)

-- 4. ESP
RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local box = p.Character:FindFirstChild("AxisHighlight")
            if _G.Config.ESP then
                if not box then
                    local h = Instance.new("Highlight", p.Character)
                    h.Name = "AxisHighlight"
                    h.FillColor = Color3.fromRGB(0, 150, 255)
                    h.OutlineColor = Color3.new(1, 1, 1)
                end
            elseif box then box:Destroy() end
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V10.1", Text = "올스킨 & 공속 강화 적용됨", Duration = 5})
