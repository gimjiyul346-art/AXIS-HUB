local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("AXIS_HUB") then CoreGui.AXIS_HUB:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AXIS_HUB"

-- [ 메인 프레임 생성 ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- [ 탭 및 페이지 시스템 (중복 방지) ]
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UIListLayout", TabBar).FillDirection = "Horizontal"

local Pages = Instance.new("Frame", MainFrame)
Pages.Position = UDim2.new(0, 10, 0, 50)
Pages.Size = UDim2.new(1, -20, 1, -60)
Pages.BackgroundTransparency = 1

local TabPages = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.Text = name:upper()
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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

-- 탭 생성
local main = CreateTab("main")
local esp = CreateTab("esp")
local misc = CreateTab("misc")
TabPages["main"].Visible = true

-- [ 토글 생성 함수 ]
local function AddToggle(parent, name, url)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = "  [OFF] " .. name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextXAlignment = "Left"
    Instance.new("UICorner", btn)

    local active = false
    btn.MouseButton1Click:Connect(function()
        if not active then
            active = true
            btn.Text = "  [ON] " .. name
            btn.TextColor3 = Color3.fromRGB(0, 255, 100)
            task.spawn(function()
                pcall(function() loadstring(game:HttpGet(url))() end)
            end)
        end
    end)
end

-- [ 기능 연결 ]
-- MAIN: Silent Aim / Wallbang
AddToggle(main, "Soluna Silent Aim", "https://soluna-script.vercel.app/main.lua")
AddToggle(main, "Wallbang (Universal)", "https://raw.githubusercontent.com/ZIVC4S/atlantas-script/refs/heads/main/Script")

-- ESP: Box ESP
AddToggle(esp, "Unicorn ESP (Safe)", "https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal_ESP.lua")

-- MISC: Fly / Skin
AddToggle(misc, "Infinite Yield (Fly/Misc)", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
AddToggle(misc, "Unlock All Skins", "https://raw.githubusercontent.com/QP-Offcial/Roblox/refs/heads/main/UnlockAll.lua")

print("AXIS HUB V1 LOADED SUCCESSFULLY")
