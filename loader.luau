local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

_G.SilentAimEnabled = false
_G.TeamCheck = true
_G.RapidFire = false

local function GetClosestPlayer()
    local ClosestPlayer = nil
    local ShortestDistance = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if _G.TeamCheck and v.Team == LocalPlayer.Team then continue end
            local Distance = (v.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude
            if Distance < ShortestDistance then
                ClosestPlayer = v
                ShortestDistance = Distance
            end
        end
    end
    return ClosestPlayer
end

local OldIndex = nil
OldIndex = hookmetamethod(game, "__index", function(Self, Index)
    if Self == Mouse and (Index == "Hit" or Index == "Target") and _G.SilentAimEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            return (Index == "Hit" and Target.Character.Head.CFrame or Target.Character.Head)
        end
    end
    return OldIndex(Self, Index)
end)

if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Size = UDim2.new(0, 600, 0, 420)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 6)

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

local TabList = Instance.new("UIListLayout", TabBar)
TabList.FillDirection = "Horizontal"
TabList.HorizontalAlignment = "Center"

local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
ContentFrame.Position = UDim2.new(0, 15, 0, 85)
ContentFrame.Size = UDim2.new(1, -30, 1, -100)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 2

local UIList = Instance.new("UIListLayout", ContentFrame)
UIList.Padding = UDim.new(0, 8)

local function AddToggle(name, callback)
    local btn = Instance.new("TextButton", ContentFrame)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.Text = "  " .. name .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextXAlignment = "Left"
    btn.Font = "Gotham"
    btn.TextSize = 14
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = "  " .. name .. (enabled and " [ON]" or " [OFF]")
        btn.TextColor3 = enabled and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(200, 200, 200)
        callback(enabled)
    end)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
end

local tabs = {"main", "world", "esp", "visuals", "character", "misc", "settings"}
for i, t in pairs(tabs) do
    local tabBtn = Instance.new("TextButton", TabBar)
    tabBtn.Size = UDim2.new(0, 80, 1, 0)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = t:upper()
    tabBtn.TextColor3 = (i == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120))
    tabBtn.Font = "GothamBold"
    tabBtn.TextSize = 12
end

AddToggle("Silent Aim (Target Head)", function(state)
    _G.SilentAimEnabled = state
end)

AddToggle("Team Check", function(state)
    _G.TeamCheck = state
end)

AddToggle("Wallbang (Raycast Bypass)", function(state)
    print("Wallbang state: ", state)
end)

AddToggle("Rapid Fire (Instant)", function(state)
    _G.RapidFire = state
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "AXIS HUB V1",
    Text = "Successfully Synchronized",
    Duration = 3
})
