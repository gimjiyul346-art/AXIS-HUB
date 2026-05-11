local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Size = UDim2.new(0, 580, 0, 410)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -205)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
local Layout = Instance.new("UIListLayout", TabBar)
Layout.FillDirection = "Horizontal"
Layout.HorizontalAlignment = "Center"

local Pages = Instance.new("Frame", MainFrame)
Pages.Position = UDim2.new(0, 10, 0, 50)
Pages.Size = UDim2.new(1, -20, 1, -60)
Pages.BackgroundTransparency = 1

local TabPages = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name:upper()
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = "GothamBold"
    btn.TextSize = 12
    
    local pg = Instance.new("ScrollingFrame", Pages)
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.Visible = false
    pg.BackgroundTransparency = 1
    pg.ScrollBarThickness = 0
    Instance.new("UIListLayout", pg).Padding = UDim.new(0, 6)
    TabPages[name] = pg
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(TabPages) do p.Visible = false end
        for _, b in pairs(TabBar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150) end end
        pg.Visible = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    return pg
end

local main_pg = CreateTab("main")
local esp_pg = CreateTab("esp")
local misc_pg = CreateTab("misc")
TabPages["main"].Visible = true

local function AddButton(parent, name, func)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextXAlignment = "Left"
    btn.Font = "Gotham"
    btn.TextSize = 14
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        task.wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        func()
    end)
end

-- [ MAIN 기능 ]
AddButton(main_pg, "Silent Aim", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Silent-Aim/main/Resources/Scripts/Main.lua"))()
end)

AddButton(main_pg, "Wallbang", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Auto%20Wall"))()
end)

-- [ ESP 기능 ]
AddButton(esp_pg, "Box ESP", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/ESP"))()
end)

-- [ MISC 기능 ]
AddButton(misc_pg, "Fly", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.lua"))()
end)

AddButton(misc_pg, "Skin Changer", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua"))()
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "AXIS HUB V1",
    Text = "Ready to use.",
    Duration = 3
})
