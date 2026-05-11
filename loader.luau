-- [[ Nameless Hub | v1 - Advanced Multi-Tab UI ]] --

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- 기존 UI 제거
if CoreGui:FindFirstChild("NamelessHub") then
    CoreGui.NamelessHub:Destroy()
end

-- 메인 스크린
local NamelessHub = Instance.new("ScreenGui")
NamelessHub.Name = "NamelessHub"
NamelessHub.Parent = CoreGui

-- 메인 프레임 (어두운 테마)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = NamelessHub
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 5)
MainCorner.Parent = MainFrame

-- 상단 탭 컨테이너 (사진의 7개 카테고리 구현)
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Parent = MainFrame
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.BorderSizePixel = 0

local TabList = Instance.new("UIListLayout")
TabList.Parent = TabBar
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.SortOrder = Enum.SortOrder.LayoutOrder

-- 기능 영역 (탭마다 내용이 바뀜)
local ContentHolder = Instance.new("Frame")
ContentHolder.Name = "ContentHolder"
ContentHolder.Parent = MainFrame
ContentHolder.BackgroundTransparency = 1
ContentHolder.Position = UDim2.new(0, 10, 0, 45)
ContentHolder.Size = UDim2.new(1, -20, 1, -55)

-- 탭 생성 함수
local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Parent = TabBar
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.Font = Enum.Font.Gotham
    btn.Text = name:lower() -- 소문자로 표시
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.TextSize = 14
    btn.LayoutOrder = order

    -- 탭 클릭 시 효과 (여기 아래에 각 탭별 기능을 붙이면 됩니다)
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(TabBar:GetChildren()) do
            if v:IsA("TextButton") then
                TweenService:Create(v, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            end
        end
        TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        print(name .. " 탭이 선택되었습니다.")
    end)
end

-- 사진에 있는 7개 탭 생성
createTab("Main", 1)
createTab("World", 2)
createTab("ESP", 3)
createTab("Visuals", 4)
createTab("Character", 5)
createTab("Misc", 6)
createTab("Settings", 7)

-- 알림 메시지
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Nameless Hub",
    Text = "v1 UI Loaded Successfully!",
    Duration = 3
})
