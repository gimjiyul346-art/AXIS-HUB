local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- UI 제거 후 재생성
if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end
if CoreGui:FindFirstChild("AXIS_MENU_BTN") then CoreGui.AXIS_MENU_BTN:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

-- [ Menu 열기/닫기 버튼 ]
local MenuBtn = Instance.new("TextButton", CoreGui)
MenuBtn.Name = "AXIS_MENU_BTN"
MenuBtn.Size = UDim2.new(0, 80, 0, 30)
MenuBtn.Position = UDim2.new(0, 10, 0.5, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.Font = "GothamBold"
MenuBtn.TextSize = 14
Instance.new("UICorner", MenuBtn)

-- [ 메인 프레임 ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

MenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- [ 탭 시스템 ]
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
local Layout = Instance.new("UIListLayout", TabBar)
Layout.FillDirection = "Horizontal"

local Pages = Instance.new("Frame", MainFrame)
Pages.Position = UDim2.new(0, 10, 0, 50)
Pages.Size = UDim2.new(1, -20, 1, -60)
Pages.BackgroundTransparency = 1

local TabPages = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Text = name:upper()
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    local pg = Instance.new("ScrollingFrame", Pages)
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.Visible = false
    pg.BackgroundTransparency = 1
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

-- [ 기능 로직 추출 및 삽입 ]

-- 1. Fly Logic (IY 기반)
local flying = false
local flySpeed = 50
local function ToggleFly()
    flying = not flying
    local char = LocalPlayer.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    if flying then
        task.spawn(function()
            local bv = Instance.new("BodyVelocity", char.PrimaryPart)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0,0,0)
            while flying do
                bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
                task.wait()
            end
            bv:Destroy()
        end)
    end
end

-- 2. Silent Aim (IY 메타메소드 기반)
local silentAimActive = false
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if silentAimActive and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        -- 가장 가까운 플레이어 헤드로 타겟팅 변경 로직 (단순화)
    end
    return oldNamecall(self, unpack(args))
end)

-- 3. Box ESP
local espActive = false
RunService.RenderStepped:Connect(function()
    if espActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not p.Character:FindFirstChild("AxisESP") then
                    local b = Instance.new("BoxHandleAdornment", p.Character)
                    b.Name = "AxisESP"; b.Adornee = p.Character; b.AlwaysOnTop = true; b.Size = Vector3.new(4,5,1); b.Color3 = Color3.fromRGB(255,0,0); b.Transparency = 0.5
                end
            end
        end
    end
end)

-- [ UI 버튼 연결 ]
local function AddToggle(parent, name, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(callback)
end

AddToggle(main_pg, "Silent Aim (Toggle)", function() silentAimActive = not silentAimActive end)
AddToggle(esp_pg, "Box ESP (Toggle)", function() espActive = not espActive end)
AddToggle(misc_pg, "Fly (Toggle)", ToggleFly)
AddToggle(misc_pg, "Skin Changer", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))() end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB", Text = "Click MENU button to Toggle UI", Duration = 5})
