local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

-- [ 메인 프레임 & 탭 시스템 ] --
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Size = UDim2.new(0, 600, 0, 420)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local TitleBar = Instance.new("TextLabel", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TitleBar.Text = "  AXIS HUB | V1"
TitleBar.TextColor3 = Color3.fromRGB(0, 180, 255)
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 18

local TabBar = Instance.new("Frame", MainFrame)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = "Horizontal"
TabListLayout.HorizontalAlignment = "Center"

local Pages = Instance.new("Frame", MainFrame)
Pages.Position = UDim2.new(0, 15, 0, 85)
Pages.Size = UDim2.new(1, -30, 1, -100)
Pages.BackgroundTransparency = 1

local TabPages = {}
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", Pages)
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)
    TabPages[name] = Page
    return Page
end

local function ShowPage(name)
    for n, p in pairs(TabPages) do p.Visible = (n == name) end
end

local tabs = {"main", "world", "esp", "visuals", "character", "misc", "settings"}
for i, t in pairs(tabs) do
    local tabBtn = Instance.new("TextButton", TabBar)
    tabBtn.Size = UDim2.new(0, 80, 1, 0)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = t:upper()
    tabBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    tabBtn.Font = "GothamBold"
    tabBtn.TextSize = 12
    local page = CreatePage(t)
    tabBtn.MouseButton1Click:Connect(function()
        ShowPage(t)
        for _, b in pairs(TabBar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(120, 120, 120) end end
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    if i == 1 then tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255); page.Visible = true end
end

local function AddToggle(parent, name, func)
    local ToggleFrame = Instance.new("Frame", parent)
    ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 4)
    local TextLabel = Instance.new("TextLabel", ToggleFrame); TextLabel.Text = "  " .. name; TextLabel.Size = UDim2.new(1, -50, 1, 0); TextLabel.BackgroundTransparency = 1; TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255); TextLabel.TextXAlignment = "Left"; TextLabel.Font = "Gotham"; TextLabel.TextSize = 14
    local Checkbox = Instance.new("TextButton", ToggleFrame); Checkbox.Size = UDim2.new(0, 25, 0, 25); Checkbox.Position = UDim2.new(1, -35, 0.5, -12); Checkbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Checkbox.Text = ""; Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 4)
    local toggled = false
    Checkbox.MouseButton1Click:Connect(function()
        toggled = not toggled
        Checkbox.BackgroundColor3 = toggled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(40, 40, 40)
        func(toggled)
    end)
end

-- [[ 기능 로직 시작 ]] --

-- 1. Main: Silent Aim & Wallbang (IY 스타일)
local SilentAimEnabled = false
local WallbangEnabled = false

local function GetClosestPlayer()
    local target, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen then
                local mDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mDist < dist then target = v; dist = mDist end
            end
        end
    end
    return target
end

local OldNC
OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if not checkcaller() and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") and WallbangEnabled then
        return nil -- Wallbang 로직: 레이캐스트 무시
    end
    if method == "FireServer" and self.Name == "RemoteEvent" and SilentAimEnabled then -- 게임마다 이벤트명 다를 수 있음
        local target = GetClosestPlayer()
        if target then args[1] = target.Character.Head.Position end
    end
    return OldNC(self, unpack(args))
end)

AddToggle(TabPages["main"], "Silent Aim", function(state) SilentAimEnabled = state end)
AddToggle(TabPages["main"], "Wallbang", function(state) WallbangEnabled = state end)

-- 2. ESP: Box ESP
local ESPEnabled = false
AddToggle(TabPages["esp"], "Box ESP", function(state)
    ESPEnabled = state
    if not state then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("AxisBox") then v.Character.AxisBox:Destroy() end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                if not v.Character:FindFirstChild("AxisBox") then
                    local b = Instance.new("BoxHandleAdornment", v.Character)
                    b.Name = "AxisBox"; b.AlwaysOnTop = true; b.ZIndex = 5; b.Adornee = v.Character; b.Color3 = Color3.fromRGB(0, 180, 255); b.Size = Vector3.new(4, 5, 1); b.Transparency = 0.5
                end
            end
        end
    end
end)

-- 3. Misc: Fly & Skin Changer
AddToggle(TabPages["misc"], "Fly (Infinite Yield Style)", function(state)
    if state then
        task.spawn(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
        -- IY가 로드되면 명령어창에 'fly'를 입력하거나 IY 내부 기능을 사용하세요.
    end
end)

AddToggle(TabPages["misc"], "Skin Changer", function(state)
    if state then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua", true))()
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "AXIS HUB V1", Text = "All Modules Synchronized", Duration = 3})
