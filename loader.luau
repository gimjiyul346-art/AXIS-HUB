local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

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
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 8)
    TabPages[name] = Page
    return Page
end

local function ShowPage(name)
    for n, p in pairs(TabPages) do
        p.Visible = (n == name)
    end
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
        for _, b in pairs(TabBar:GetChildren()) do
            if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(120, 120, 120) end
        end
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    if i == 1 then tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255); page.Visible = true end
end

local function AddToggle(parent, name, func)
    local ToggleFrame = Instance.new("Frame", parent)
    ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 4)

    local TextLabel = Instance.new("TextLabel", ToggleFrame)
    TextLabel.Text = "  " .. name
    TextLabel.Size = UDim2.new(1, -50, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextXAlignment = "Left"
    TextLabel.Font = "Gotham"
    TextLabel.TextSize = 14

    local Checkbox = Instance.new("TextButton", ToggleFrame)
    Checkbox.Size = UDim2.new(0, 25, 0, 25)
    Checkbox.Position = UDim2.new(1, -35, 0.5, -12)
    Checkbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Checkbox.Text = ""
    Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 4)

    local isToggled = false
    Checkbox.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        if isToggled then
            TweenService:Create(Checkbox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 255, 50)}):Play()
            func(true)
        else
            TweenService:Create(Checkbox, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            func(false)
        end
    end)
end

-- [ MAIN 탭 기능 리스트 ]

-- 1. Soluna Silent Aim
AddToggle(TabPages["main"], "Soluna Silent Aim", function(state)
    if state then
        task.spawn(function()
            loadstring(game:HttpGet("https://soluna-script.vercel.app/main.lua", true))()
        end)
    end
end)

-- 2. Soluna Aimbot
AddToggle(TabPages["main"], "Soluna Aimbot", function(state)
    if state then
        task.spawn(function()
            loadstring(game:HttpGet("https://soluna-script.vercel.app/main.lua", true))()
        end)
    end
end)

-- 3. Unlock All Skins (올스킨핵)
AddToggle(TabPages["main"], "Unlock All Skins", function(state)
    if state then
        task.spawn(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua", true))()
        end)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "AXIS HUB V1",
    Text = "All Scripts Integrated.",
    Duration = 3
})
