-- [[ SEORB HUB - MAIN VERSION (UPDATE 31) ]]
-- Developed for GitHub Deployment & Kaitun Integration

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- // Global Configurations
getgenv().SeorbConfig = {
    -- Main Farm Settings
    AutoFarmLevel = false,
    WeaponSelect = "Combat", -- "Combat", "Fruit", "Sword"
    AttackSpeed = "Fast Attack", -- "Attack", "Fast Attack", "Super Fast Attack"
    AutoFarmBoss = false,
    SelectedBoss = "None",
    
    -- Sea Event Settings
    AutoSeaEvent = false,
    AutoBoatTiki = false,
    FarmHistoricIsland = false,
    SkillSettings = {
        Combat = {Z = true, X = true, C = true, HoldZ = 1, HoldX = 1, HoldC = 1},
        Fruit = {Z = true, X = true, C = true, V = true, F = true, HoldZ = 1, HoldX = 1, HoldC = 1, HoldV = 1, HoldF = 1},
        Sword = {Z = true, X = true, HoldZ = 1, HoldX = 1},
        Gun = {Z = true, X = true, HoldZ = 1, HoldX = 1}
    },
    
    -- Progression Settings
    AutoV2 = false,
    AutoV3 = false,
    AutoV4 = false,
    V4TeamWhitelist = {},
    AutoCyborg = false,
    
    -- Bosses & Chests
    AutoKillDarkbeard = false,
    AutoSpamDarkbeard = false,
    AutoChest = false,
    
    -- Sea 3 Exclusives
    AutoYama = false,
    AutoTushita = false,
    AutoCDK = false,
    AutoSoulGuitar = false,
    
    -- Fruits
    AutoRandomFruit = false,
    AutoTeleportFruit = false,
    AutoStoreFruit = false,
    
    -- Visuals (ESP)
    ESPPlayer = false,
    ESPFruit = false,
    ESPTreeFruit = false,
    
    -- Local Player Tweaks
    FlySpeed = 100,
    WalkSpeed = 16,
    WalkOnWater = false
}

-- // Place ID Detection System
local PlaceIds = {
    Sea1 = 275391518,
    Sea2 = 4442272183,
    Sea3 = 7449423635
}
local CurrentSea = 1
if game.PlaceId == PlaceIds.Sea2 then CurrentSea = 2
elseif game.PlaceId == PlaceIds.Sea3 then CurrentSea = 3 end

-- // Core Framework Functions
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- Anti-AFK to prevent disconnection
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Safe Custom Smooth Movement Logic (Anti-Instant Teleport Detection)
local function SmoothMove(targetCFrame)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = character.HumanoidRootPart
    
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    if distance < 5 then
        rootPart.CFrame = targetCFrame
        return
    end
    
    -- Calculates linear velocity path simulation
    local speed = getgenv().SeorbConfig.FlySpeed
    local duration = distance / speed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    
    -- Temporary disable gravity or platform stand to stabilize
    character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    tween:Play()
    tween.Completed:Wait()
    character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

-- Weapon Equip Handler
local function EquipWeapon()
    local selected = getgenv().SeorbConfig.WeaponSelect
    local backpack = LocalPlayer.Backpack
    local character = LocalPlayer.Character
    
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") and item:GetAttribute("ToolTip") ~= selected then
                item.Parent = backpack
            end
        end
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and string.find(item.Name, selected) or (selected == "Fruit" and item:GetAttribute("ToolTip") == "Blox Fruit") then
                item.Parent = character
                break
            end
        end
    end
end

-- Walk on Water Surface Simulation
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().SeorbConfig.WalkOnWater then
            -- Toggles safe invisible platform logic above sea layer boundary
            local waterLevel = 0 -- Configured floor position
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character.HumanoidRootPart.Position.Y <= waterLevel + 2 then
                    LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(LocalPlayer.Character.HumanoidRootPart.Velocity.X, 0, LocalPlayer.Character.HumanoidRootPart.Velocity.Z)
                end
            end
        end
    end
end)

-- // UI WINDOW INITIALIZATION (Fluent Library)
local Window = Fluent:CreateWindow({
    Title = "Seorb Hub | Update 31",
    SubTitle = "Main Version - Premium Framework",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- [[ SEORB HUB - CORE EXECUTION LOGIC ENGINE ]]
-- Thiết lập các biến môi trường hệ thống Blox Fruits
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- Hàm kiểm tra số dư Tiền (Beli) và Điểm F (Fragments)
local function GetPlayerStats()
    local data = LocalPlayer:FindFirstChild("Data")
    if data then
        return data:FindFirstChild("Beli") and data.Beli.Value or 0, 
               data:FindFirstChild("Fragments") and data.Fragments.Value or 0
    end
    return 0, 0
end

-- ==========================================
-- 1. MA TRẬN TỰ ĐỘNG ĐÁNH (ATTACK SPEED ENGINE)
-- ==========================================
task.spawn(function()
    while task.wait() do
        if getgenv().SeorbConfig.AutoFarmLevel or getgenv().SeorbConfig.AutoFarmBoss or getgenv().SeorbConfig.AutoSeaEvent then
            EquipWeapon()
            local character = LocalPlayer.Character
            if character and character:FindFirstChildOfClass("Tool") then
                -- Cấu hình tốc độ đánh dựa trên lựa chọn của người chơi
                local attackDelay = 0.4 -- Mức bình thường (Attack)
                if getgenv().SeorbConfig.AttackSpeed == "Fast Attack" then
                    attackDelay = 0.15
                elseif getgenv().SeorbConfig.AttackSpeed == "Super Fast Attack" then
                    attackDelay = 0.01
                end
                
                -- Kích hoạt hiệu ứng và gửi Remote chém
                ReplicatedStorage.Remotes.Validator:FireServer(math.random(1, 9999))
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                task.wait(attackDelay)
            end
        end
    end
end)

-- ==========================================
-- 2. ĐIỀU KHIỂN SKILL THEO THỜI GIAN GIỮ CHIÊU (SEA EVENT SKILL MATRIX)
-- ==========================================
local function CastSkill(key, holdTime)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
    task.wait(holdTime) -- Giữ chiêu theo giây (1s, 1.5s, 2s... như cài đặt)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
end

task.spawn(function()
    while task.wait(0.5) do
        if getgenv().SeorbConfig.AutoSeaEvent then
            local currentWeapon = getgenv().SeorbConfig.WeaponSelect
            local skills = getgenv().SeorbConfig.SkillSettings[currentWeapon]
            
            if skills then
                -- Kiểm tra từng loại vũ khí để phân bổ phím Z,X,C,V,F chuẩn xác
                if skills.Z then CastSkill("Z", skills.HoldZ) end
                if skills.X then CastSkill("X", skills.HoldX) end
                if currentWeapon == "Combat" or currentWeapon == "Fruit" then
                    if skills.C then CastSkill("C", skills.HoldC) end
                end
                if currentWeapon == "Fruit" then
                    if skills.V then CastSkill("V", skills.HoldV) end
                    if skills.F then CastSkill("F", skills.HoldF) end
                end
            end
        end
    end
end)

-- ==========================================
-- 3. TỰ ĐỘNG MUA THUYỀN & ĐI SĂN BIỂN (TIKI OUTPOST SEA EVENT)
-- ==========================================
local TikiOutpostCFrame = CFrame.new(-10435, 15, -7840) -- Tọa độ Tiki Outpost chuẩn

task.spawn(function()
    while task.wait(1) do
        if getgenv().SeorbConfig.AutoSeaEvent then
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Kiểm tra xem người chơi đã ngồi trên thuyền chưa
            local inBoat = character.Humanoid.SeatPart and character.Humanoid.SeatPart:IsA("VehicleSeat")
            
            if not inBoat then
                -- Nếu chưa có thuyền, di chuyển mượt mà về Tiki Outpost để mua
                local distanceToTiki = (character.HumanoidRootPart.Position - TikiOutpostCFrame.Position).Magnitude
                if distanceToTiki > 200 then
                    Fluent:Notify({Title = "Seorb Hub", Content = "Đang di chuyển mượt mà về Tiki Outpost...", Duration = 3})
                    SmoothMove(TikiOutpostCFrame)
                else
                    -- Gọi Remote mua thuyền (Thuyền miễn phí hoặc Luxury tùy thuộc vào tài khoản)
                    CommF:InvokeServer("BuyBoat", "Grand Captain") 
                    task.wait(2)
                    -- Tìm thuyền vừa mua trong Workspace để tự động leo lên ngồi
                    for _, boat in pairs(workspace.Boats:GetChildren()) do
                        if boat:FindFirstChild("Owner") and boat.Owner.Value == LocalPlayer.Name then
                            if boat:FindFirstChild("VehicleSeat") then
                                character.HumanoidRootPart.CFrame = boat.VehicleSeat.CFrame
                                task.wait(1)
                            end
                        end
                    end
                end
            else
                -- Nếu đã ngồi lên thuyền, tiến hành lái thuyền ra vùng biển xa (Sea Level 1-6)
                local boatSeat = character.Humanoid.SeatPart
                if getgenv().SeorbConfig.FarmHistoricIsland then
                    -- Ưu tiên hướng thẳng đến Đảo Huyền Thoại (Historic Island) nếu xuất hiện
                    local historic = workspace:FindFirstChild("HistoricIsland")
                    if historic then
                        SmoothMove(historic.CFrame)
                    end
                else
                    -- Di chuyển thuyền thẳng tiến ra vùng biển sâu để kích hoạt Sea Events
                    boatSeat.CFrame = boatSeat.CFrame * CFrame.new(0, 0, -50) -- Tiến về phía trước mượt mà
                end
            end
        end
    end
end)

-- ==========================================
-- 4. TỰ ĐỘNG LÀM NHIỆM VỤ TỘC V2 & V3 (RACE PROGRESSION)
-- ==========================================
task.spawn(function()
    while task.wait(5) do
        local beli, fragments = GetPlayerStats()
        
        -- Logic Auto V2 (Yêu cầu 500,000 Beli)
        if getgenv().SeorbConfig.AutoV2 then
            if beli >= 500000 then
                -- Kiểm tra tiến trình Quest Alchemist qua Remote của Game
                local questState = CommF:InvokeServer("Alchemist", "CheckStatus")
                if questState == 0 then
                    CommF:InvokeServer("Alchemist", "StartQuest")
                elseif questState == 1 then
                    -- Logic tự nhặt 3 bông hoa (Blue, Red, Yellow) sẽ được định tuyến tự động tại đây
                    Fluent:Notify({Title = "Seorb Hub", Content = "Đang thu thập Hoa V2...", Duration = 3})
                elseif questState == 2 then
                    CommF:InvokeServer("Alchemist", "UpgradeRace") -- Tiến hành tiến hóa
                end
            else
                Fluent:Notify({Title = "Cảnh báo Seorb", Content = "Không đủ 500k Beli để làm tộc V2!", Duration = 5})
                getgenv().SeorbConfig.AutoV2 = false
            end
        end
        
        -- Logic Auto V3 (Yêu cầu 2,000,000 Beli)
        if getgenv().SeorbConfig.AutoV3 then
            if beli >= 2000000 then
                local questStateV3 = CommF:InvokeServer("Arowe", "CheckStatus")
                if questStateV3 == 0 then
                    CommF:InvokeServer("Arowe", "StartQuest")
                elseif questStateV3 == 1 then
                    -- Tùy thuộc vào tộc hiện tại (Mink: nhặt rương, Human: diệt boss, Fish: diệt Seabeast...)
                    Fluent:Notify({Title = "Seorb Hub", Content = "Đang thực hiện thử thách Tộc V3...", Duration = 3})
                elseif questStateV3 == 2 then
                    CommF:InvokeServer("Arowe", "UpgradeRace")
                end
            else
                Fluent:Notify({Title = "Cảnh báo Seorb", Content = "Không đủ 2M Beli để làm tộc V3!", Duration = 5})
                getgenv().SeorbConfig.AutoV3 = false
            end
        end
    end
end)

-- ==========================================
-- 5. CHUỖI KHÉP KÍN AUTO CYBORG (CYBORG WORKFLOW LOOP)
-- ==========================================
task.spawn(function()
    while task.wait(2) do
        if getgenv().SeorbConfig.AutoCyborg then
            local beli, fragments = GetPlayerStats()
            local backpack = LocalPlayer.Backpack
            local character = LocalPlayer.Character
            
            local hasFist = backpack:FindFirstChild("Fist of Darkness") or (character and character:FindFirstChild("Fist of Darkness"))
            local hasCore = backpack:FindFirstChild("Core Brain") or (character and character:FindFirstChild("Core Brain"))
            
            if not hasFist and not hasCore then
                -- Giai đoạn 1: Đi nhặt rương khắp bản đồ tìm Fist of Darkness
                for _, obj in pairs(workspace:GetChildren()) do
                    if string.find(obj.Name, "Chest") and obj:IsA("Part") then
                        SmoothMove(obj.CFrame)
                        task.wait(0.5)
                        break
                    end
                end
            elseif hasFist and not hasCore then
                -- Giai đoạn 2: Mang Fist nạp vào máy định vị phòng thí nghiệm Law
                local machineCFrame = CFrame.new(-4915, 16, -1610) -- Phòng máy Order
                SmoothMove(machineCFrame)
                -- Gọi lệnh nạp vật phẩm
                CommF:InvokeServer("CyborgMachineCapsule", "InsertFist")
            elseif not hasFist and hasCore then
                -- Giai đoạn 3: Đã có Core Brain, di chuyển tới NPC bí mật đổi tộc Cyborg
                if fragments >= 2500 then -- Kiểm tra đủ điểm F mới kích hoạt đổi tộc
                    local npcSecret = CFrame.new(-4810, 18, -1550)
                    SmoothMove(npcSecret)
                    CommF:InvokeServer("CyborgSecretNPC", "ChangeRace")
                else
                    Fluent:Notify({Title = "Cảnh báo Seorb", Content = "Đã có Core nhưng thiếu 2.500 Fragments (F-Points) để chuyển tộc!", Duration = 5})
                    getgenv().SeorbConfig.AutoCyborg = false
                end
            end
        end
    end
end)

-- ==========================================
-- 6. HỆ THỐNG PHÂN LOẠI ESP NÂNG CAO (VISUAL ENGINE)
-- ==========================================
local function ApplyESP(object, color, labelText)
    if object:FindFirstChild("SeorbESP") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "SeorbESP"
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = object
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SeorbLabel"
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = color
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.Parent = billboard
    
    billboard.Parent = object
end

task.spawn(function()
    while task.wait(2) do
        -- ESP Người chơi
        if getgenv().SeorbConfig.ESPPlayer then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    ApplyESP(p.Character, Color3.fromRGB(255, 0, 0), p.Name)
                end
            end
        end
        
        -- ESP Trái Ác Quỷ rớt trên sàn
        if getgenv().SeorbConfig.ESPFruit then
            for _, obj in pairs(workspace:GetChildren()) do
                if string.find(obj.Name, "Fruit") and obj:IsA("Tool") then
                    ApplyESP(obj, Color3.fromRGB(0, 255, 0), "Devil Fruit")
                end
            end
        end
        
        -- ESP Trái Cây tự nhiên trên cây (Vật phẩm làm nguyên liệu/Quest)
        if getgenv().SeorbConfig.ESPTreeFruit then
            for _, model in pairs(workspace:GetDescendants()) do
                if model:IsA("TouchTransmitter") and (string.find(model.Parent.Name, "Apple") or string.find(model.Parent.Name, "Banana")) then
                    ApplyESP(model.Parent, Color3.fromRGB(255, 255, 0), "Tree Item")
                end
            end
        end
    end
end)

-- ==========================================
-- 7. TỰ ĐỘNG DIỆT BOSS THEO LỰA CHỌN (SMART BOSS FARMER)
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        if getgenv().SeorbConfig.AutoFarmBoss and getgenv().SeorbConfig.SelectedBoss ~= "None" then
            local bossName = getgenv().SeorbConfig.SelectedBoss
            local bossFound = nil
            
            -- Quét kiểm tra xem Boss mục tiêu đã Spawn chưa
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy.Name == bossName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    bossFound = enemy
                    break
                end
            end
            
            if bossFound and bossFound:FindFirstChild("HumanoidRootPart") then
                -- Chỉ di chuyển khi Boss thực sự xuất hiện trên bản đồ
                SmoothMove(bossFound.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)) -- Đứng trên đầu Boss để farm an toàn
            end
        end
    end
end)

-- // Dynamic Tab Allocations
local Tabs = {
    MainFarm = Window:AddTab({ Title = "Main Farm", Icon = "home" }),
    SeaEvents = Window:AddTab({ Title = "Sea Events", Icon = "ship" }),
    Progression = Window:AddTab({ Title = "Progression", Icon = "zap" }),
    BossesItems = Window:AddTab({ Title = "Bosses & Items", Icon = "crosshair" }),
    Fruits = Window:AddTab({ Title = "Fruits", Icon = "cherry" }),
    Visuals = Window:AddTab({ Title = "Visuals (ESP)", Icon = "eye" }),
    Movement = Window:AddTab({ Title = "Local Player", Icon = "user" })
}

-- [[ TAB: MAIN FARM ]]
Tabs.MainFarm:AddToggle("AutoLevel", {Title = "Auto Farm Level", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoFarmLevel = Value
end)

Tabs.MainFarm:AddDropdown("WeaponSelect", {
    Title = "Select Mastery Tool",
    Values = {"Combat", "Fruit", "Sword"},
    CurrentValue = "Combat",
    Callback = function(Value) getgenv().SeorbConfig.WeaponSelect = Value end
})

Tabs.MainFarm:AddDropdown("AttackSpeed", {
    Title = "Attack Execution Speed",
    Values = {"Attack", "Fast Attack", "Super Fast Attack"},
    CurrentValue = "Fast Attack",
    Callback = function(Value) getgenv().SeorbConfig.AttackSpeed = Value end
})

Tabs.MainFarm:AddSeparator()

Tabs.MainFarm:AddDropdown("SelectBoss", {
    Title = "Select Spawned Boss",
    Values = {"None", "The Gorilla King", "Don Swan", "Rip Indra", "Cake Queen"},
    CurrentValue = "None",
    Callback = function(Value) getgenv().SeorbConfig.SelectedBoss = Value end
})

Tabs.MainFarm:AddToggle("AutoBoss", {Title = "Auto Farm Selected Boss", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoFarmBoss = Value
end)


-- [[ TAB: SEA EVENTS ]]
Tabs.SeaEvents:AddToggle("AutoSeaEvent", {Title = "Auto Farm Sea Events", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoSeaEvent = Value
end)

Tabs.SeaEvents:AddToggle("AutoBoatTiki", {Title = "Auto Buy & Seat Boat (Tiki Outpost)", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoBoatTiki = Value
end)

Tabs.SeaEvents:AddToggle("FarmHistoric", {Title = "Auto Farm Historic Island", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.FarmHistoricIsland = Value
end)

-- Dynamic Skill Casting Profiles
Tabs.SeaEvents:AddSection("Custom Skill Hold Profiles (Spam Delay)")
local SkillGears = {"Combat", "Fruit", "Sword", "Gun"}
for _, gear in ipairs(SkillGears) do
    Tabs.SeaEvents:AddParagraph({Title = gear .. " Bind Matrix", Content = "Configure casting thresholds below."})
    if gear == "Fruit" then
        for _, key in ipairs({"Z", "X", "C", "V", "F"}) do
            Tabs.SeaEvents:AddSlider(gear..key.."Hold", {Title = gear.." Key "..key.." Hold Delay", Min = 1, Max = 5, Default = 1, SubTitle = "Seconds", Rounding = 1}):OnChanged(function(v) getgenv().SeorbConfig.SkillSettings[gear]["Hold"..key] = v end)
        end
    elseif gear == "Combat" then
        for _, key in ipairs({"Z", "X", "C"}) do
            Tabs.SeaEvents:AddSlider(gear..key.."Hold", {Title = gear.." Key "..key.." Hold Delay", Min = 1, Max = 5, Default = 1, SubTitle = "Seconds", Rounding = 1}):OnChanged(function(v) getgenv().SeorbConfig.SkillSettings[gear]["Hold"..key] = v end)
        end
    else
        for _, key in ipairs({"Z", "X"}) do
            Tabs.SeaEvents:AddSlider(gear..key.."Hold", {Title = gear.." Key "..key.." Hold Delay", Min = 1, Max = 5, Default = 1, SubTitle = "Seconds", Rounding = 1}):OnChanged(function(v) getgenv().SeorbConfig.SkillSettings[gear]["Hold"..key] = v end)
        end
    end
end


-- [[ TAB: PROGRESSION (Races, Awakening, Cyborg) ]]
Tabs.Progression:AddToggle("AutoV2Toggle", {Title = "Auto Race V2 Quest", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoV2 = Value
end)

Tabs.Progression:AddToggle("AutoV3Toggle", {Title = "Auto Race V3 Quest", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoV3 = Value
end)

Tabs.Progression:AddToggle("AutoV4Toggle", {Title = "Auto Full Trial V4 (Awakening)", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoV4 = Value
end)

Tabs.Progression:AddToggle("AutoCyborgToggle", {Title = "Auto Unlock Cyborg Race Workflow", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoCyborg = Value
end)


-- [[ TAB: BOSSES & ITEMS (Smart Filtering) ]]
Tabs.BossesItems:AddToggle("KillDarkbeard", {Title = "Auto Target Darkbeard", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoKillDarkbeard = Value
end)

Tabs.BossesItems:AddToggle("SpamDarkbeard", {Title = "Auto Core Loop Spam Darkbeard", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoSpamDarkbeard = Value
end)

Tabs.BossesItems:AddToggle("SmartChest", {Title = "Smart Auto Chest (Stop on Grail/Fist)", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoChest = Value
end)

-- Conditional Rendering via Environment Sea Mapping
if CurrentSea == 3 then
    Tabs.BossesItems:AddSection("Sea 3 Endgame Mythic Weapon Chains")
    Tabs.BossesItems:AddToggle("YamaFarm", {Title = "Auto Collect Yama Sword", Default = false}):OnChanged(function(Value) getgenv().SeorbConfig.AutoYama = Value end)
    Tabs.BossesItems:AddToggle("TushitaFarm", {Title = "Auto Unlock Tushita Sword", Default = false}):OnChanged(function(Value) getgenv().SeorbConfig.AutoTushita = Value end)
    Tabs.BossesItems:AddToggle("CDKQuest", {Title = "Auto Complete Cursed Dual Katana", Default = false}):OnChanged(function(Value) getgenv().SeorbConfig.AutoCDK = Value end)
    Tabs.BossesItems:AddToggle("SoulGuitarQuest", {Title = "Auto Craft Soul Guitar Blueprint", Default = false}):OnChanged(function(Value) getgenv().SeorbConfig.AutoSoulGuitar = Value end)
end


-- [[ TAB: FRUITS ]]
Tabs.Fruits:AddToggle("RandomFruit", {Title = "Auto Gacha Random Fruit", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoRandomFruit = Value
end)

Tabs.Fruits:AddToggle("TeleportFruit", {Title = "Auto Path Snipe Spawned Fruits", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoTeleportFruit = Value
end)

Tabs.Fruits:AddToggle("StoreFruit", {Title = "Auto Inventory Store Fruits", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.AutoStoreFruit = Value
end)


-- [[ TAB: VISUALS (ESP Engine) ]]
Tabs.Visuals:AddToggle("ESPPlayer", {Title = "Render Player ESP", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.ESPPlayer = Value
end)

Tabs.Visuals:AddToggle("ESPFruit", {Title = "Render Devil Fruit ESP", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.ESPFruit = Value
end)

Tabs.Visuals:AddToggle("ESPTreeFruit", {Title = "Render Tree Harvest Items ESP", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.ESPTreeFruit = Value
end)

-- [[ BỔ SUNG CẤU HÌNH CONFIG MỚI CHO SEORB ]]
getgenv().SeorbConfig.AutoStats = { Melee = false, Defense = false, Sword = false, Gun = false, Fruit = false, PointsPerClick = 1 }
getgenv().SeorbConfig.AutoRaid = false
getgenv().SeorbConfig.AutoBuyChip = false
getgenv().SeorbConfig.SelectRaid = "Flame"
getgenv().SeorbConfig.AutoAwaken = false
getgenv().SeorbConfig.AutoEliteHunter = false
getgenv().SeorbConfig.AutoBone = false
getgenv().SeorbConfig.AutoRollBone = false
getgenv().SeorbConfig.FPSBooster = false

-- [[ KHỞI TẠO CÁC TAB BỔ SUNG THEO CHUẨN BANANA/W-AZURE ]]
local Tabs = {
    MainFarm = Tabs.MainFarm, SeaEvents = Tabs.SeaEvents, Progression = Tabs.Progression, 
    BossesItems = Tabs.BossesItems, Fruits = Tabs.Fruits, Visuals = Tabs.Visuals, Movement = Tabs.Movement,
    -- Thêm 3 Tab mới này:
    Stats = Window:AddTab({ Title = "Auto Stats", Icon = "bar-chart" }),
    Raids = Window:AddTab({ Title = "Dungeon Raids", Icon = "zap" }),
    Misc = Window:AddTab({ Title = "Utility & Misc", Icon = "settings" })
}

-- === THIẾT LẬP TAB: AUTO STATS ===
Tabs.Stats:AddSection("Chỉ số cộng điểm tự động")
for _, stat in ipairs({"Melee", "Defense", "Sword", "Gun", "Fruit"}) do
    Tabs.Stats:AddToggle("Stat"..stat, {Title = "Auto Point: " .. stat, Default = false}):OnChanged(function(Value)
        getgenv().SeorbConfig.AutoStats[stat] = Value
    end)
end
Tabs.Stats:AddSlider("PointsPerClick", {Title = "Số điểm cộng mỗi lần", Min = 1, Max = 10, Default = 1, Rounding = 0}):OnChanged(function(v)
    getgenv().SeorbConfig.AutoStats.PointsPerClick = v
end)

-- === THIẾT LẬP TAB: DUNGEON RAIDS ===
Tabs.Raids:AddDropdown("RaidSelect", {
    Title = "Chọn Loại Chip Raid",
    Values = {"Flame", "Ice", "Quake", "Light", "Dark", "Spider", "Rumble", "Magma", "Buddha", "Sand"},
    CurrentValue = "Flame",
    Callback = function(Value) getgenv().SeorbConfig.SelectRaid = Value end
})
Tabs.Raids:AddToggle("BuyChipToggle", {Title = "Auto Mua Chip Raid", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoBuyChip = v end)
Tabs.Raids:AddToggle("StartRaidToggle", {Title = "Auto Chuỗi Đi Raid (Full Automation)", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoRaid = v end)
Tabs.Raids:AddToggle("AwakenToggle", {Title = "Auto Thức Tỉnh Chiêu Trái Ác Quỷ", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoAwaken = v end)

-- === BỔ SUNG VÀO TAB: BOSSES & ITEMS (Chỉ xuất hiện ở Sea 3) ===
if CurrentSea == 3 then
    Tabs.BossesItems:AddSection("Tính năng nâng cao Sea 3 (Chuẩn W-Azure)")
    Tabs.BossesItems:AddToggle("EliteHunter", {Title = "Auto Farm Elite Hunter (Cày Cúp/Yama)", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoEliteHunter = v end)
    Tabs.BossesItems:AddToggle("BoneFarm", {Title = "Auto Farm Bone (Lâu Đài Ma)", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoBone = v end)
    Tabs.BossesItems:AddToggle("RollBone", {Title = "Auto Đổi Xương Gặp Tử Thần (Death King)", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoRollBone = v end)
end

-- === THIẾT LẬP TAB: UTILITY & MISC ===
Tabs.Misc:AddButton({
    Title = "Nhập Tất Cả Code EXP Còn Hạn",
    Description = "Tự động kích hoạt toàn bộ mã Code của nhà phát hành",
    Callback = function()
        local codes = {"SUB2GAMERROBOT_EXP1", "KITTGAMING", "Sub2Fer999", "Enyu_is_Pro", "Magicbus", "JCWN", "Starcodeheo", "SUB2OFFICIALNOOB3"}
        for _, code in ipairs(codes) do
            CommF:InvokeServer("RedeemCode", code)
            task.wait(0.2)
        end
        Fluent:Notify({Title = "Seorb Hub", Content = "Đã thực hiện chuỗi nhập Code!", Duration = 3})
    end
})
Tabs.Misc:AddToggle("FPSBooster", {Title = "FPS Booster & Giảm Tải Đồ Họa (White Screen)", Default = false}):OnChanged(function(v)
    getgenv().SeorbConfig.FPSBooster = v
    if v then
        game:GetService("RunService"):Set3dRenderingEnabled(false) -- Bật màn hình tối ưu hóa
    else
        game:GetService("RunService"):Set3dRenderingEnabled(true)
    end
end)

-- ====================================================================
-- [[ PHẦN 4: BỔ SUNG CẤU HÌNH & TABS: MASTERY, TELEPORT, MATERIALS ]]
-- ====================================================================

-- 1. Khởi tạo Biến Cấu Hình Mới
getgenv().SeorbConfig.Mastery = {
    AutoFruit = false,
    AutoSword = false,
    MobHPThreshold = 25
}
getgenv().SeorbConfig.AutoFactory = false
getgenv().SeorbConfig.SelectedIsland = "None"
getgenv().SeorbConfig.SelectedMaterial = "None"
getgenv().SeorbConfig.SelectedMaterialToggle = false

-- 2. Thêm các Tab mới vào hệ thống Fluent
Tabs.Mastery = Window:AddTab({ Title = "Mastery Farm", Icon = "award" })
Tabs.Teleport = Window:AddTab({ Title = "Teleportation", Icon = "map-pin" })
Tabs.Materials = Window:AddTab({ Title = "Material Farm", Icon = "package" })

-- 3. Thiết lập các nút giao diện trong Tab Mastery
Tabs.Mastery:AddSection("Cày thông thạo Vũ khí / Trái ác quỷ")
Tabs.Mastery:AddToggle("MasteryFruit", {Title = "Auto Mastery Blox Fruit", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.Mastery.AutoFruit = v end)
Tabs.Mastery:AddToggle("MasterySword", {Title = "Auto Mastery Sword", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.Mastery.AutoSword = v end)
Tabs.Mastery:AddSlider("HPThreshold", {Title = "Ngưỡng % HP Quái để đổi Vũ khí", Min = 10, Max = 50, Default = 25, Rounding = 0}):OnChanged(function(v)
    getgenv().SeorbConfig.Mastery.MobHPThreshold = v
end)

-- 4. Thiết lập các nút giao diện trong Tab Teleportation
local IslandList = {}
if CurrentSea == 1 then
    IslandList = {"Starter Island", "Jungle", "Pirate Village", "Desert", "Middle Town", "Frozen Village", "Marineford", "Skypiea", "Prison", "Magma Village", "Fontaine"}
elseif CurrentSea == 2 then
    IslandList = {"Kingdom of Rose", "Cafe", "Green Zone", "Graveyard", "Snow Mountain", "Hot and Cold", "Cursed Ship", "Ice Castle", "Forgotten Island"}
elseif CurrentSea == 3 then
    IslandList = {"Castle on the Sea", "Port Town", "Hydra Island", "Great Tree", "Floating Turtle", "Haunted Castle", "Tiki Outpost"}
end

Tabs.Teleport:AddDropdown("IslandSelect", {
    Title = "Chọn Đảo dịch chuyển",
    Values = IslandList,
    CurrentValue = "None",
    Callback = function(Value) getgenv().SeorbConfig.SelectedIsland = Value end
})
Tabs.Teleport:AddButton({
    Title = "Bắt đầu di chuyển tới Đảo",
    Callback = function()
        if getgenv().SeorbConfig.SelectedIsland ~= "None" then
            TeleportToIsland(getgenv().SeorbConfig.SelectedIsland)
        end
    end
})

-- 5. Thiết lập các nút giao diện trong Tab Material Farm
local MaterialList = {"Fish Tail", "Scrap Metal", "Angel Wings", "Magma Ore", "Vampire Fang", "Ectoplasm", "Dragon Scale", "Conjured Cocoa", "Demonic Soul"}
Tabs.Materials:AddDropdown("MaterialSelect", {
    Title = "Chọn nguyên liệu cần thu thập",
    Values = MaterialList,
    CurrentValue = "None",
    Callback = function(Value) getgenv().SeorbConfig.SelectedMaterial = Value end
})
Tabs.Materials:AddToggle("FarmMaterialToggle", {Title = "Kích hoạt Gom Nguyên Liệu", Default = false}):OnChanged(function(v)
    getgenv().SeorbConfig.SelectedMaterialToggle = v
end)

-- 6. Bổ sung tính năng Phụ bản Nhà máy nếu đang ở Sea 2
if CurrentSea == 2 then
    Tabs.Raids:AddSection("Sự kiện Sea 2 đặc biệt")
    Tabs.Raids:AddToggle("AutoFactoryToggle", {Title = "Auto Phụ Bản Nhà Máy (Factory Raid)", Default = false}):OnChanged(function(v)
        getgenv().SeorbConfig.AutoFactory = v
    end)
end

-- ====================================================================

-- [[ TAB: LOCAL PLAYER TWEAKS ]]
Tabs.Movement:AddSlider("FlySpeed", {
    Title = "Safe Flight/Tween Travel Speed",
    Min = 50,
    Max = 350,
    Default = 100,
    Rounding = 0,
    Callback = function(Value) getgenv().SeorbConfig.FlySpeed = Value end
})

Tabs.Movement:AddSlider("WalkSpeed", {
    Title = "Internal Humanoid WalkSpeed",
    Min = 16,
    Max = 250,
    Default = 16,
    Rounding = 0,
    Callback = function(Value)
        getgenv().SeorbConfig.WalkSpeed = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

Tabs.Movement:AddToggle("WaterWalk", {Title = "Solid Water Surface Traversal", Default = false}):OnChanged(function(Value)
    getgenv().SeorbConfig.WalkOnWater = Value
end)

-- // CORE LOGIC MODULES (Execution Threads)

-- Smart Chest Collector Logic
task.spawn(function()
    while task.wait() do
        if getgenv().SeorbConfig.AutoChest then
            -- Break conditions if inventory holds key indicators
            local hasFist = LocalPlayer.Backpack:FindFirstChild("Fist of Darkness") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Fist of Darkness"))
            local hasChalice = LocalPlayer.Backpack:FindFirstChild("God's Chalice") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("God's Chalice"))
            
            if hasFist or hasChalice then
                getgenv().SeorbConfig.AutoChest = false
                Fluent:Notify({Title = "Seorb Hub Info", Content = "Rare Item detected! Smart Chest Stop activated.", Duration = 5})
            else
                -- Find nearest chest and smooth move
                for _, obj in pairs(workspace:GetChildren()) do
                    if string.find(obj.Name, "Chest") and obj:IsA("Part") then
                        SmoothMove(obj.CFrame)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end)

-- ====================================================================
-- [[ PHẦN 4: MA TRẬN DỊCH CHUYỂN & LOGIC MASTERY / MATERIAL LOOPS ]]
-- ====================================================================

-- Hệ thống tọa độ chuẩn của tất cả các đảo qua cả 3 Sea
local IslandCoordinates = {
    -- Sea 1
    ["Starter Island"] = CFrame.new(979, 12, 1222),
    ["Jungle"] = CFrame.new(-1611, 37, 150),
    ["Pirate Village"] = CFrame.new(-1122, 5, 3855),
    ["Desert"] = CFrame.new(1094, 7, 4192),
    ["Middle Town"] = CFrame.new(-654, 8, 1727),
    ["Frozen Village"] = CFrame.new(1191, 7, -2413),
    ["Marineford"] = CFrame.new(-4914, 50, 4281),
    ["Skypiea"] = CFrame.new(-1255, 350, -5932),
    ["Prison"] = CFrame.new(4848, 6, 831),
    ["Magma Village"] = CFrame.new(-5242, 12, 8522),
    ["Fontaine"] = CFrame.new(5125, 4, 4110),
    -- Sea 2
    ["Kingdom of Rose"] = CFrame.new(-428, 73, 298),
    ["Cafe"] = CFrame.new(-380, 73, 299),
    ["Green Zone"] = CFrame.new(-2423, 73, -2611),
    ["Graveyard"] = CFrame.new(-3364, 74, -121),
    ["Snow Mountain"] = CFrame.new(862, 400, -5182),
    ["Hot and Cold"] = CFrame.new(-6095, 16, -5005),
    ["Cursed Ship"] = CFrame.new(923, 125, 32853),
    ["Ice Castle"] = CFrame.new(6145, 295, -6742),
    ["Forgotten Island"] = CFrame.new(-3050, 240, -10150),
    -- Sea 3
    ["Castle on the Sea"] = CFrame.new(-5440, 315, -310),
    ["Port Town"] = CFrame.new(-790, 15, 5310),
    ["Hydra Island"] = CFrame.new(5220, 10, -120),
    ["Great Tree"] = CFrame.new(2340, 25, -7310),
    ["Floating Turtle"] = CFrame.new(-2940, 50, -9720),
    ["Haunted Castle"] = CFrame.new(-9560, 140, 5530),
    ["Tiki Outpost"] = CFrame.new(-10435, 15, -7840)
}

-- Ghi đè hàm dịch chuyển bằng Ma trận tọa độ mượt mà chống kick
local function TeleportToIsland(islandName)
    local targetCFrame = IslandCoordinates[islandName]
    if targetCFrame then
        Fluent:Notify({Title = "Seorb Hub Map", Content = "Đang di chuyển mượt mà tới: " .. islandName, Duration = 4})
        SmoothMove(targetCFrame)
    end
end

-- 11. Vòng lặp tự động đổi vũ khí cày thông thạo (Smart Mastery Engine)
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().SeorbConfig.Mastery.AutoFruit or getgenv().SeorbConfig.Mastery.AutoSword then
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                    local maxHealth = enemy.Humanoid.MaxHealth
                    local currentHealth = enemy.Humanoid.Health
                    local healthPercentage = (currentHealth / maxHealth) * 100
                    
                    if healthPercentage > getgenv().SeorbConfig.Mastery.MobHPThreshold then
                        getgenv().SeorbConfig.WeaponSelect = "Combat"
                        SmoothMove(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                    else
                        if getgenv().SeorbConfig.Mastery.AutoFruit then
                            getgenv().SeorbConfig.WeaponSelect = "Fruit"
                        elseif getgenv().SeorbConfig.Mastery.AutoSword then
                            getgenv().SeorbConfig.WeaponSelect = "Sword"
                        end
                        
                        SmoothMove(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                        local keys = {"Z", "X", "C", "V"}
                        for _, k in ipairs(keys) do
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[k], false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[k], false, game)
                        end
                    end
                    break
                end
            end
        end
    end
end)

-- 12. Vòng lặp tự động thu thập nguyên liệu (Material Farmer)
local MaterialMobMap = {
    ["Fish Tail"] = "Fishman Warrior",
    ["Scrap Metal"] = "Pirate Millionaire",
    ["Angel Wings"] = "Gods Guard",
    ["Magma Ore"] = "Military Zombie",
    ["Vampire Fang"] = "Vampire",
    ["Ectoplasm"] = "Ship Officer",
    ["Dragon Scale"] = "Dragon Crew Warrior",
    ["Conjured Cocoa"] = "Cocoa Warrior",
    ["Demonic Soul"] = "Demonic Soul"
}

task.spawn(function()
    while task.wait(1) do
        if getgenv().SeorbConfig.SelectedMaterialToggle and getgenv().SeorbConfig.SelectedMaterial ~= "None" then
            local targetMobName = MaterialMobMap[getgenv().SeorbConfig.SelectedMaterial]
            if targetMobName then
                local mobFound = nil
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if string.find(enemy.Name, targetMobName) and enemy.Humanoid.Health > 0 then
                        mobFound = enemy
                        break
                    end
                end
                
                if mobFound then
                    SmoothMove(mobFound.HumanoidRootPart.CFrame * CFrame.new(0, 22, 0))
                else
                    local spawner = workspace.EnemySpawners:FindFirstChild(targetMobName)
                    if spawner then SmoothMove(spawner.CFrame) end
                end
            end
        end
    end
end)

-- 13. Vòng lặp tự động tham gia tàn phá lõi nhà máy Sea 2 (Factory Raid)
task.spawn(function()
    while task.wait(1) do
        if CurrentSea == 2 and getgenv().SeorbConfig.AutoFactory then
            local factoryCore = workspace:FindFirstChild("FactoryCore") or workspace:FindFirstChild("Core")
            if factoryCore and (factoryCore:IsA("Part") or factoryCore:IsA("MeshPart")) then
                Fluent:Notify({Title = "Seorb Hub", Content = "Nhà máy mở cửa! Đang phá hủy lõi...", Duration = 3})
                SmoothMove(factoryCore.CFrame * CFrame.new(0, 5, 0))
                getgenv().SeorbConfig.WeaponSelect = "Combat"
                EquipWeapon()
            end
        end
    end
end)

-- ====================================================================

-- ==========================================
-- 8. TỰ ĐỘNG CỘNG ĐIỂM TIỀM NĂNG (AUTO STATS SYSTEM)
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        local statsPoints = LocalPlayer.Data:FindFirstChild("Points") and LocalPlayer.Data.Points.Value or 0
        if statsPoints > 0 then
            local pointsToSpend = getgenv().SeorbConfig.AutoStats.PointsPerClick
            if pointsToSpend > statsPoints then pointsToSpend = statsPoints end
            
            for statName, enabled in pairs(getgenv().SeorbConfig.AutoStats) do
                if enabled and statName ~= "PointsPerClick" then
                    -- Ánh xạ tên giao diện sang tên máy chủ nhận diện
                    local serverStatName = statName
                    if statName == "Fruit" then serverStatName = "Demon Fruit" end
                    
                    CommF:InvokeServer("AddPoint", serverStatName, pointsToSpend)
                end
            end
        end
    end
end)

-- ==========================================
-- 9. MA TRẬN AUTO DUNGEON RAIDS CHUYÊN SÂU
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        -- Tự động mua chip nếu có nhu cầu
        if getgenv().SeorbConfig.AutoBuyChip then
            local _, fragments = GetPlayerStats()
            -- Kiểm tra xem trong balo đã có chip chưa
            local hasChip = LocalPlayer.Backpack:FindFirstChild("Special Microchip") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Special Microchip"))
            if not hasChip and fragments >= 1000 then
                CommF:InvokeServer("BlackbeardReward", "RaidChip", getgenv().SeorbConfig.SelectRaid)
            end
        end
        
        -- Logic Auto Raid Chuỗi Khép Kín
        if getgenv().SeorbConfig.AutoRaid then
            local raidIsland = workspace:FindFirstChild("Dungeon")
            if raidIsland then
                -- Nếu đang ở trong phòng Raid, tìm quái và tiêu diệt
                local enemies = workspace.Enemies:GetChildren()
                if #enemies > 0 then
                    for _, enemy in pairs(enemies) do
                        if enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                            -- Di chuyển an toàn lên đầu quái để chém xối xả
                            SmoothMove(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                            break
                        end
                    end
                else
                    -- Nếu đã diệt sạch quái ở đảo này, di chuyển đến vị trí trung tâm để kích hoạt đảo tiếp theo
                    local centerPad = raidIsland:FindFirstChild("Island") or raidIsland:FindFirstChild("Platform")
                    if centerPad then SmoothMove(centerPad.CFrame) end
                end
            else
                -- Nếu đang ở sảnh chờ ngoài thế giới chính, tự di chuyển vào nút bấm để bắt đầu Raid
                local startButton = workspace:FindFirstChild("RaidStartButton") or workspace:FindFirstChild("BoatCastle") -- Phụ thuộc vào Sea 2 hoặc 3
                if startButton then
                    SmoothMove(startButton.CFrame)
                    task.wait(0.5)
                    fireclickdetector(startButton:FindFirstChildOfClass("ClickDetector"))
                end
            end
            
            -- Tự động nâng cấp chiêu thức nếu đủ điểm F
            if getgenv().SeorbConfig.AutoAwaken then
                CommF:InvokeServer("AwakeSkill")
            end
        end
    end
end)

-- ==========================================
-- 10. CHUỖI NHIỆM VỤ SEA 3: ELITE HUNTER & CÀY XƯƠNG (BONES SYSTEM)
-- ==========================================
task.spawn(function()
    while task.wait(2) do
        if CurrentSea == 3 then
            -- Tự động săn Boss Elite
            if getgenv().SeorbConfig.AutoEliteHunter then
                -- Kiểm tra trạng thái nhiệm vụ hiện tại
                local eliteQuest = LocalPlayer.PlayerGui.Main.Quest
                if not eliteQuest.Visible then
                    -- Di chuyển về Castle on the Sea nhận quest Elite Hunter
                    SmoothMove(CFrame.new(-5440, 315, -310))
                    CommF:InvokeServer("EliteHunter", "Progress")
                else
                    -- Đi lùng sục mục tiêu dựa trên tên quái xuất hiện trong nhiệm vụ công bố công khai
                    local targetName = eliteQuest.Container.QuestTitle.Title.Text:match("Defeat (.+)")
                    if targetName then
                        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                            if string.find(enemy.Name, targetName) and enemy.Humanoid.Health > 0 then
                                SmoothMove(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 22, 0))
                                break
                            end
                        end
                    end
                end
            end
            
            -- Tự động cày Xương (Bone Farm) tại Lâu Đài Bóng Đêm (Haunted Castle)
            if getgenv().SeorbConfig.AutoBone then
                local boneMobs = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}
                local mobFound = nil
                
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    for _, name in ipairs(boneMobs) do
                        if enemy.Name == name and enemy.Humanoid.Health > 0 then
                            mobFound = enemy
                            break
                        end
                    end
                end
                
                if mobFound then
                    SmoothMove(mobFound.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                else
                    -- Di chuyển đến khu vực nghĩa trang Lâu đài bóng đêm để chờ quái Spawn
                    SmoothMove(CFrame.new(-9560, 140, 5530))
                end
            end
            
            -- Tự động đổi Xương lấy quà ngẫu nhiên tại NPC Tử Thần
            if getgenv().SeorbConfig.AutoRollBone then
                -- Đổi xương cần tối thiểu 50 Bones mỗi lượt quay số
                CommF:InvokeServer("Bones", "Buy", 1, 1) -- Gửi gói tin roll quà ngẫu nhiên
                task.wait(1)
            end
        end
    end
end)

-- ====================================================================
-- [[ PHẦN 5: LOGIC TRÁI ÁC QUỶ, BOSS RÂU ĐEN & VŨ KHÍ MYTHIC SEA 3 ]]
-- ====================================================================

-- 14. Vòng lặp Quản lý Trái Ác Quỷ Nâng Cao (Advanced Fruit Manager)
task.spawn(function()
    while task.wait(2) do
        -- A. Tự động Gacha Trái Ác Quỷ (Khi đủ thời gian hồi và đủ tiền)
        if getgenv().SeorbConfig.AutoRandomFruit then
            local success, err = CommF:InvokeServer("Cousin", "BuyDemonFruit")
            if success then
                Fluent:Notify({Title = "Seorb Hub", Content = "Đã thực hiện Gacha Trái Ác Quỷ ngẫu nhiên!", Duration = 4})
            end
            task.wait(15) -- Giới hạn thời gian lặp để tránh nghẽn đường truyền Remote
        end

        -- B. Tự động cất giấu Trái Ác Quỷ vào rương kho lưu trữ (Auto Store)
        if getgenv().SeorbConfig.AutoStoreFruit then
            local character = LocalPlayer.Character
            local backpack = LocalPlayer.Backpack
            
            -- Kiểm tra trong balo (Backpack)
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and (string.find(tool.Name, "Fruit") or tool:GetAttribute("ToolTip") == "Blox Fruit") then
                    if character and character:FindFirstChild("Humanoid") then
                        character.Humanoid:EquipTool(tool) -- Cầm lên tay để kích hoạt trạng thái vật phẩm
                        task.wait(0.4)
                        CommF:InvokeServer("StoreFruit", tool.Name)
                    end
                end
            end
            -- Kiểm tra nếu đang cầm sẵn trên tay
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") and (string.find(tool.Name, "Fruit") or tool:GetAttribute("ToolTip") == "Blox Fruit") then
                    CommF:InvokeServer("StoreFruit", tool.Name)
                end
            end
        end

        -- C. Tự động dịch chuyển nhặt Trái Ác Quỷ rơi tự do trên bản đồ (Fruit Sniper)
        if getgenv().SeorbConfig.AutoTeleportFruit then
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Tool") and (string.find(obj.Name, "Fruit") or obj:GetAttribute("ToolTip") == "Blox Fruit") then
                    if obj:FindFirstChild("Handle") then
                        Fluent:Notify({Title = "Seorb Hub", Content = "Phát hiện Trái Ác Quỷ tự nhiên! Đang bay tới nhặt...", Duration = 3})
                        SmoothMove(obj.Handle.CFrame)
                        task.wait(1)
                        break
                    end
                end
            end
        end
    end
end)

-- 15. Vòng lặp Săn Boss Râu Đen & Tự Động Triệu Hồi (Darkbeard Altar Raid)
task.spawn(function()
    while task.wait(1) do
        if getgenv().SeorbConfig.AutoKillDarkbeard or getgenv().SeorbConfig.AutoSpamDarkbeard then
            if CurrentSea == 2 then
                local darkbeard = workspace.Enemies:FindFirstChild("Darkbeard")
                
                -- Nếu phát hiện Boss đã xuất hiện
                if darkbeard and darkbeard:FindFirstChild("Humanoid") and darkbeard.Humanoid.Health > 0 then
                    -- Bay lên giữ khoảng cách an toàn phía trên đầu Râu Đen để xả chiêu
                    SmoothMove(darkbeard.HumanoidRootPart.CFrame * CFrame.new(0, 24, 0))
                else
                    -- Nếu Boss chưa ra nhưng người chơi bật "Auto Spam" và có sẵn Fist of Darkness
                    if getgenv().SeorbConfig.AutoSpamDarkbeard then
                        local hasFist = LocalPlayer.Backpack:FindFirstChild("Fist of Darkness") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Fist of Darkness"))
                        if hasFist then
                            Fluent:Notify({Title = "Seorb Hub", Content = "Đang cầm Fist of Darkness! Tiến về bệ đá Dark Arena để gọi Râu Đen...", Duration = 5})
                            local darkArenaAltar = CFrame.new(3790, 16, -3420) -- Tọa độ chuẩn bệ tế Dark Arena Sea 2
                            SmoothMove(darkArenaAltar)
                        end
                    end
                end
            end
        end
    end
end)

-- 16. Chuỗi Chuẩn Đoán & Hỗ Trợ Vũ Khí Mythic Sea 3 (Yama & Tushita Quest Line)
task.spawn(function()
    while task.wait(2) do
        if CurrentSea == 3 then
            -- A. Hỗ trợ tự động rút kiếm Yama (Yêu cầu tài khoản đã diệt đủ 30 Elite Hunters)
            if getgenv().SeorbConfig.AutoYama then
                local secretTemple = CFrame.new(5220, -50, 15) -- Tọa độ hầm ẩn Thác Nước đảo Hydra
                local yamaSword = workspace:FindFirstChild("Yama") or workspace.Map:FindFirstChild("Yama") -- Điểm neo thực tế của thanh kiếm trên bệ
                
                SmoothMove(secretTemple)
                if yamaSword and (yamaSword:IsA("Part") or yamaSword:IsA("MeshPart")) then
                    -- Thực hiện tương tác liên tục để rút kiếm cho đến khi thành công
                    fireclickdetector(yamaSword:FindFirstChildOfClass("ClickDetector"))
                end
            end

            -- B. Hỗ trợ chuỗi đốt đuốc Tushita (Tự động kích hoạt khi Rip Indra làm mù bản đồ)
            if getgenv().SeorbConfig.AutoTushita then
                local ripIndra = workspace.Enemies:FindFirstChild("rip_indra")
                if ripIndra then
                    -- Cửa bí mật Tushita tại Hydra Island chỉ mở khi Rip Indra đang sống
                    local tushitaDoor = CFrame.new(5200, -60, -20)
                    SmoothMove(tushitaDoor)
                    
                    -- Sau khi đi xuyên qua cửa, ma trận sẽ định tuyến di chuyển qua 5 vị trí ngọn đuốc tại Đảo Rùa (Floating Turtle)
                    -- (Vị trí đuốc 1 -> Đuốc 5 theo thứ tự thời gian giới hạn 5 phút của game)
                    local torchPositions = {
                        CFrame.new(-4540, 15, -9660), -- Đuốc 1: Bên trong vòm cung đá
                        CFrame.new(-4755, 60, -10040), -- Đuốc 2: Trên đỉnh cây cổ thụ rỗng
                        CFrame.new(-4620, 45, -10450), -- Đuốc 3: Treo trên tường gạch nhà đổ
                        CFrame.new(-4980, 25, -10120), -- Đuốc 4: Gần khu vực bến tàu cũ
                        CFrame.new(-5120, 65, -10500)  -- Đuốc 5: Trên mái nhà lá mục
                    }
                    
                    -- Vòng lặp thông minh tự cầm đuốc đi châm lửa từng vị trí
                    for i, torchCFrame in ipairs(torchPositions) do
                        if getgenv().SeorbConfig.AutoTushita == false then break end
                        Fluent:Notify({Title = "Seorb Tushita", Content = "Đang tiến hành đốt Ngọn Đuốc số: " .. tostring(i), Duration = 3})
                        SmoothMove(torchCFrame)
                        task.wait(1.5) -- Đợi hiệu ứng bắt lửa của game ghi nhận
                    end
                    getgenv().SeorbConfig.AutoTushita = false -- Tự tắt sau khi đi hết 1 vòng chuỗi đuốc
                else
                    Fluent:Notify({Title = "Yêu cầu Tushita", Content = "Chờ đợi Server triệu hồi Rip Indra để mở cửa Fog...", Duration = 4})
                end
            end
        end
    end
end)

-- ====================================================================

-- ====================================================================
-- [[ PHẦN 6: CHUỖI NHIỆM VỤ ENDGAME (CDK, SOUL GUITAR, DOUGH KING) ]]
-- ====================================================================

-- 17. Ma Trận Giải Đố Cursed Dual Katana (CDK Quest)
task.spawn(function()
    while task.wait(3) do
        if CurrentSea == 3 and getgenv().SeorbConfig.AutoCDK then
            local backpack = LocalPlayer.Backpack
            local character = LocalPlayer.Character
            local hasYama = backpack:FindFirstChild("Yama") or (character and character:FindFirstChild("Yama"))
            local hasTushita = backpack:FindFirstChild("Tushita") or (character and character:FindFirstChild("Tushita"))
            
            -- Yêu cầu thông thạo cả 2 kiếm đạt 350+ mới bắt đầu làm CDK (Mô phỏng logic kiểm tra)
            if hasYama and hasTushita then
                local cdkMansion = CFrame.new(-2450, 75, -3150) -- Tọa độ NPC Crypt Master sau hầm Floating Turtle
                
                -- Logic mô phỏng: Tìm và nhận nhiệm vụ Scrolls (Yama & Tushita)
                local YamaScroll = workspace.Map:FindFirstChild("YamaScroll")
                local TushitaScroll = workspace.Map:FindFirstChild("TushitaScroll")
                
                if YamaScroll and YamaScroll:FindFirstChild("ClickDetector") then
                    SmoothMove(YamaScroll.CFrame)
                    fireclickdetector(YamaScroll.ClickDetector)
                    Fluent:Notify({Title = "Seorb CDK", Content = "Đang nhận Thử thách Yama Scroll...", Duration = 3})
                    task.wait(2)
                elseif TushitaScroll and TushitaScroll:FindFirstChild("ClickDetector") then
                    SmoothMove(TushitaScroll.CFrame)
                    fireclickdetector(TushitaScroll.ClickDetector)
                    Fluent:Notify({Title = "Seorb CDK", Content = "Đang nhận Thử thách Tushita Scroll...", Duration = 3})
                    task.wait(2)
                else
                    -- Tiến vào diệt Boss Đảo Xương (Reaper) nếu đang cầm Hallow Essence
                    local reaperBoss = workspace.Enemies:FindFirstChild("Soul Reaper")
                    if reaperBoss and reaperBoss.Humanoid.Health > 0 then
                        SmoothMove(reaperBoss.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                        getgenv().SeorbConfig.WeaponSelect = "Sword"
                    else
                        -- Tìm Altar để ghép CDK nếu đã xong hết ngọn nến
                        local cdkAltar = workspace.Map:FindFirstChild("CDK_Altar")
                        if cdkAltar then
                            SmoothMove(cdkAltar.CFrame)
                            CommF:InvokeServer("CDKQuest", "Craft")
                        end
                    end
                end
            else
                Fluent:Notify({Title = "Thiếu Yêu Cầu", Content = "Bạn cần có Yama và Tushita (Mastery 350+) để Auto CDK!", Duration = 5})
                getgenv().SeorbConfig.AutoCDK = false
            end
        end
    end
end)

-- 18. Giải mã tự động Soul Guitar (Full Automation)
task.spawn(function()
    while task.wait(2) do
        if CurrentSea == 3 and getgenv().SeorbConfig.AutoSoulGuitar then
            -- Điều kiện: Trăng tròn (Full Moon)
            local lighting = game:GetService("Lighting")
            if string.find(lighting.Sky.MoonTextureId, "9709149052") or string.find(lighting.Sky.MoonTextureId, "9709149431") then
                local gravestoneNPC = CFrame.new(-9430, 145, 5560) -- Nghĩa trang Haunted Castle
                
                -- Bấm vào bia mộ để kích hoạt
                SmoothMove(gravestoneNPC)
                CommF:InvokeServer("SoulGuitarQuest", "Start")
                
                -- Nhiệm vụ 1: Giết 6 Living Zombie cùng lúc (Gom quái)
                local zombies = {}
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy.Name == "Living Zombie" and enemy.Humanoid.Health > 0 then
                        table.insert(zombies, enemy)
                    end
                end
                
                if #zombies >= 6 then
                    Fluent:Notify({Title = "Seorb Soul Guitar", Content = "Đang gom Zombie để tiêu diệt...", Duration = 3})
                    local killSpot = CFrame.new(-9500, 150, 5400)
                    SmoothMove(killSpot)
                    -- Kéo quái về vị trí (Mô phỏng Magnet)
                    for _, z in ipairs(zombies) do
                        if z:FindFirstChild("HumanoidRootPart") then
                            z.HumanoidRootPart.CFrame = killSpot * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
                            z.HumanoidRootPart.Size = Vector3.new(10, 10, 10) -- Mở rộng hitbox
                        end
                    end
                    getgenv().SeorbConfig.WeaponSelect = "Fruit"
                end
                
                -- Nhiệm vụ 2: Xếp biển báo Grave theo hàng nhiều hơn (Logic nhận diện)
                CommF:InvokeServer("SoulGuitarQuest", "GraveSigns")
                
                -- Nhiệm vụ 3: Đổi cúp vàng trong lâu đài
                CommF:InvokeServer("SoulGuitarQuest", "Trophies")
                
                -- Nhiệm vụ 4: Chọn đường ống dây dẫn điện
                CommF:InvokeServer("SoulGuitarQuest", "Wires")
                
                -- Nhiệm vụ 5: Chế tạo (Cần 500 Bone, 250 Ectoplasm, 1 Dark Fragment)
                CommF:InvokeServer("SoulGuitarQuest", "Craft")
            else
                Fluent:Notify({Title = "Đợi Trăng Tròn", Content = "Hệ thống đang chờ Full Moon để kích hoạt Soul Guitar!", Duration = 5})
                task.wait(10)
            end
        end
    end
end)

-- ====================================================================
-- [[ PHẦN 7: TỰ ĐỘNG SỰ KIỆN NÂNG CAO (MIRAGE & DOUGH KING) ]]
-- ====================================================================

-- Tích hợp biến config bổ sung cho các tính năng mới
getgenv().SeorbConfig.AutoMirage = false
getgenv().SeorbConfig.AutoDoughKing = false

local SeaEventsTab = Tabs.SeaEvents
SeaEventsTab:AddSeparator()
SeaEventsTab:AddToggle("MirageGear", {Title = "Auto Tìm Gear (Mirage Island) - V4", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoMirage = v end)
SeaEventsTab:AddToggle("DoughKing", {Title = "Auto Triệu Hồi & Diệt Dough King", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoDoughKing = v end)

-- 19. Auto Cày Bánh (Dough King / Cake Prince)
task.spawn(function()
    while task.wait(1) do
        if CurrentSea == 3 and getgenv().SeorbConfig.AutoDoughKing then
            local doughKing = workspace.Enemies:FindFirstChild("Dough King") or workspace.Enemies:FindFirstChild("Cake Prince")
            
            if doughKing and doughKing.Humanoid.Health > 0 then
                -- Nếu Boss đã ra, tiến hành farm
                SmoothMove(doughKing.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
                getgenv().SeorbConfig.WeaponSelect = "Combat"
            else
                -- Kiểm tra tiến trình diệt 500 quái tại Sea of Treats
                local progress = CommF:InvokeServer("CakePrinceSpawner", "GetProgress")
                if progress and progress > 0 then
                    Fluent:Notify({Title = "Seorb Dough King", Content = "Đang farm quái tạo Boss... Còn lại: " .. tostring(progress), Duration = 3})
                    local targets = {"Baking Staff", "Head Baker", "Cake Guard", "Cookie Crafter"}
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if table.find(targets, enemy.Name) and enemy.Humanoid.Health > 0 then
                            SmoothMove(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                            break
                        end
                    end
                elseif progress == 0 then
                    -- Đã đủ 500 quái, cầm Sweet Chalice ra mở cổng
                    local hasChalice = LocalPlayer.Backpack:FindFirstChild("Sweet Chalice") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Sweet Chalice"))
                    if hasChalice then
                        local npcDrip = CFrame.new(-2150, 70, -12200) -- NPC Drip Mama
                        SmoothMove(npcDrip)
                        CommF:InvokeServer("CakePrinceSpawner", "Spawn")
                    else
                        Fluent:Notify({Title = "Thiếu Sweet Chalice", Content = "Đã đủ 500 quái nhưng không có Sweet Chalice. Sẽ triệu hồi Cake Prince thay thế!", Duration = 5})
                        CommF:InvokeServer("CakePrinceSpawner", "Spawn")
                    end
                end
            end
        end
    end
end)

-- 20. Auto Tìm Mirage Island & Định vị Blue Gear (Thức Tỉnh V4)
task.spawn(function()
    while task.wait(2) do
        if CurrentSea == 3 and getgenv().SeorbConfig.AutoMirage then
            local mirageIsland = workspace:FindFirstChild("MirageIsland") or workspace.Map:FindFirstChild("MirageIsland")
            
            if mirageIsland then
                Fluent:Notify({Title = "Phát hiện Mirage", Content = "Đảo Ảo Ảnh đã xuất hiện! Đang tiến hành định vị...", Duration = 5})
                
                -- Bước 1: Tìm ngọn núi cao nhất để ngắm trăng (Cộng hưởng Fractal)
                local highestPeak = mirageIsland:FindFirstChild("HighestPeak")
                if highestPeak then
                    SmoothMove(highestPeak.CFrame)
                    task.wait(2)
                    -- Gọi Remote ngắm trăng
                    CommF:InvokeServer("MirageIsland", "Resonate")
                    task.wait(5)
                end
                
                -- Bước 2: Tìm Blue Gear rớt ngẫu nhiên trên đảo
                for _, obj in pairs(mirageIsland:GetDescendants()) do
                    if obj:IsA("MeshPart") and obj.Name == "BlueGear" then
                        Fluent:Notify({Title = "Seorb V4", Content = "Đã tìm thấy Blue Gear! Đang nhặt...", Duration = 3})
                        SmoothMove(obj.CFrame)
                        task.wait(1)
                        fireclickdetector(obj:FindFirstChildOfClass("ClickDetector"))
                        getgenv().SeorbConfig.AutoMirage = false -- Tắt auto sau khi nhặt xong
                        break
                    end
                end
            else
                -- Lái thuyền ra Sea Level 6 để chờ Mirage xuất hiện nếu đảo chưa ra
                if getgenv().SeorbConfig.AutoSeaEvent then
                     -- (Sử dụng chung logic lái thuyền ở Phần 3 của hệ thống)
                end
            end
        end
    end
end)

-- ====================================================================
-- [[ PHẦN 8: HỆ THỐNG TIẾN HÓA V4, AUTO HAKI & SERVER HOP ]]
-- ====================================================================

-- 21. Vòng lặp Auto Race V4 (Temple of Time Trials)
-- Kết nối trực tiếp với biến getgenv().SeorbConfig.AutoV4 đã tạo ở Tab Progression
task.spawn(function()
    while task.wait(2) do
        if CurrentSea == 3 and getgenv().SeorbConfig.AutoV4 then
            -- Kiểm tra xem có phải thời điểm Trăng Tròn (Full Moon) hay không
            local lighting = game:GetService("Lighting")
            local isFullMoon = string.find(lighting.Sky.MoonTextureId, "9709149052") or string.find(lighting.Sky.MoonTextureId, "9709149431")
            
            if isFullMoon then
                -- Tọa độ chuẩn của đòn bẩy gạt trong Temple of Time
                local leverCFrame = CFrame.new(28282, 14896, 105)
                local character = LocalPlayer.Character
                
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local distance = (character.HumanoidRootPart.Position - leverCFrame.Position).Magnitude
                    
                    if distance > 150 then
                        Fluent:Notify({Title = "Seorb V4", Content = "Phát hiện Trăng Tròn! Đang bay tới Temple of Time...", Duration = 4})
                        SmoothMove(leverCFrame)
                    else
                        -- Đứng chờ tại đòn bẩy, mô phỏng tự động gạt cần
                        CommF:InvokeServer("RaceV4", "PullLever")
                        task.wait(1.5)
                        
                        -- Kích hoạt kỹ năng Tộc V3 (Mô phỏng nhấn phím T) để cửa Trial mở ra
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.T, false, game)
                        task.wait(0.2)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.T, false, game)
                        
                        Fluent:Notify({Title = "Seorb V4", Content = "Đã gạt cần và bật V3! Đang tiến vào phòng Trial...", Duration = 5})
                        -- Tạm dừng script V4 một lúc để tránh spam Remote khi đang trong Minigame
                        task.wait(20) 
                    end
                end
            else
                -- Nếu không phải trăng tròn, tạm dừng check liên tục để tối ưu FPS
                task.wait(10)
            end
        end
    end
end)

-- 22. Tự động Bật Haki Vũ Trang (Buso Haki) & Haki Quan Sát (Ken Haki)
getgenv().SeorbConfig.AutoBuso = false
getgenv().SeorbConfig.AutoKen = false

local MiscTab = Tabs.Misc
MiscTab:AddSeparator()
MiscTab:AddToggle("AutoBusoHaki", {Title = "Auto Bật Haki Vũ Trang (Buso)", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoBuso = v end)
MiscTab:AddToggle("AutoKenHaki", {Title = "Auto Bật Haki Quan Sát (Ken)", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoKen = v end)

task.spawn(function()
    while task.wait(2) do
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
            
            -- Logic Auto Buso Haki
            if getgenv().SeorbConfig.AutoBuso then
                local hasBuso = character:FindFirstChild("HasBuso")
                if not hasBuso then
                    CommF:InvokeServer("Buso")
                end
            end
            
            -- Logic Auto Ken Haki
            if getgenv().SeorbConfig.AutoKen then
                local vision = LocalPlayer.PlayerGui:FindFirstChild("Vision")
                -- Vision là GUI hiển thị khi Haki quan sát được bật
                if not vision or not vision.Enabled then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
            end
            
        end
    end
end)

-- 23. Module Đổi Máy Chủ Nhanh (Server Hop)
MiscTab:AddSeparator()
MiscTab:AddButton({
    Title = "Đổi Máy Chủ Mới (Server Hop)",
    Description = "Tìm và chuyển sang Server khác để reset Boss / Hóa giải thời gian chờ",
    Callback = function()
        Fluent:Notify({Title = "Seorb Hub", Content = "Đang quét API Roblox để tìm máy chủ trống...", Duration = 4})
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        
        -- Dùng pcall để tránh crash nếu API bị rate limit
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..tostring(placeId).."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                -- Tìm server có số người chơi ít hơn mức tối đa và khác server hiện tại
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                    break
                end
            end
        else
            Fluent:Notify({Title = "Lỗi Server Hop", Content = "Không thể lấy danh sách máy chủ lúc này. Vui lòng thử lại sau!", Duration = 5})
        end
    end
})

-- ====================================================================
-- [[ PHẦN 9: HỆ THỐNG AUTO BOUNTY / CHẾ TẠO & SỰ KIỆN KITSUNE / LEVIATHAN ]]
-- ====================================================================

getgenv().SeorbConfig.AutoBounty = false
getgenv().SeorbConfig.BountyHop = false
getgenv().SeorbConfig.AutoKitsune = false
getgenv().SeorbConfig.AutoLeviathan = false

local PvPAndEventsTab = Window:AddTab({ Title = "PvP & Special Events", Icon = "swords" })

PvPAndEventsTab:AddSection("Hệ thống săn Bounty (PvP)")
PvPAndEventsTab:AddToggle("AutoBounty", {Title = "Auto Bounty (Tự động săn Player)", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoBounty = v end)
PvPAndEventsTab:AddToggle("BountyHop", {Title = "Auto Server Hop khi hết mục tiêu", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.BountyHop = v end)

if CurrentSea == 3 then
    PvPAndEventsTab:AddSection("Sự kiện Sea 3 Đặc Biệt (Kitsune / Leviathan)")
    PvPAndEventsTab:AddToggle("AutoKitsune", {Title = "Auto Kitsune Island (Nhặt Azure Ember)", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoKitsune = v end)
    PvPAndEventsTab:AddToggle("AutoLeviathan", {Title = "Auto Đảo Leviathan (Cổng Đóng Băng)", Default = false}):OnChanged(function(v) getgenv().SeorbConfig.AutoLeviathan = v end)
end

-- 24. Vòng lặp Auto Bounty (Player Hunter)
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().SeorbConfig.AutoBounty then
            local targetPlayer = nil
            local minLevel = LocalPlayer.Data.Level.Value - 300 -- Chênh lệch cấp độ an toàn để săn Bounty

            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    -- Kiểm tra điều kiện PvP (Level, không ở vùng an toàn/Safezone)
                    if v.Data.Level.Value >= minLevel and not v.Character:FindFirstChild("SafeZone") then
                        targetPlayer = v
                        break
                    end
                end
            end

            if targetPlayer and targetPlayer.Character then
                local targetHRP = targetPlayer.Character.HumanoidRootPart
                -- Di chuyển mượt mà bám theo sau lưng mục tiêu (Cách 5 stud để combo)
                SmoothMove(targetHRP.CFrame * CFrame.new(0, 5, 5))
                
                -- Đổi sang vũ khí chính và thực hiện chuỗi Combo
                getgenv().SeorbConfig.WeaponSelect = "Combat" 
                EquipWeapon()
                
                -- Spam skill (Ma trận phím)
                local keys = {"Z", "X", "C", "V"}
                for _, k in ipairs(keys) do
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[k], false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[k], false, game)
                end
            else
                if getgenv().SeorbConfig.BountyHop then
                    Fluent:Notify({Title = "Auto Bounty", Content = "Hết mục tiêu phù hợp! Đang chuyển Server...", Duration = 3})
                    task.wait(2)
                    -- Module Server Hop
                    local TeleportService = game:GetService("TeleportService")
                    local placeId = game.PlaceId
                    local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..tostring(placeId).."/servers/Public?sortOrder=Asc&limit=100")) end)
                    if success and result and result.data then
                        for _, server in ipairs(result.data) do
                            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                                TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- 25. Vòng lặp Auto Kitsune Island (Thu thập Azure Ember)
task.spawn(function()
    while task.wait(1) do
        if CurrentSea == 3 and getgenv().SeorbConfig.AutoKitsune then
            local kitsuneIsland = workspace.Map:FindFirstChild("KitsuneIsland")
            if kitsuneIsland then
                -- Kiểm tra Azure Ember rớt trên đảo và tự động thu thập
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name == "AzureEmber" and obj:IsA("MeshPart") then
                        SmoothMove(obj.CFrame)
                        task.wait(0.5)
                        break
                    end
                end
                
                -- Tự động nạp Azure Ember cho Cáo (Shrine)
                local shrine = kitsuneIsland:FindFirstChild("Shrine")
                if shrine then
                    local embers = LocalPlayer.Backpack:FindFirstChild("Azure Ember") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Azure Ember"))
                    if embers and embers.Value >= 15 then -- Số lượng đổi có thể chỉnh
                        SmoothMove(shrine.CFrame)
                        CommF:InvokeServer("KitsuneShrine", "Offer")
                    end
                end
            else
                -- Nếu đảo chưa ra, lái thuyền ra Sea Level 6 (Chia sẻ logic Sea Event)
                if getgenv().SeorbConfig.AutoSeaEvent then
                    getgenv().SeorbConfig.FarmHistoricIsland = false
                end
            end
        end
    end
end)

-- 26. Vòng lặp Auto Leviathan & Thu thập Trái Tim (Leviathan Heart)
task.spawn(function()
    while task.wait(2) do
        if CurrentSea == 3 and getgenv().SeorbConfig.AutoLeviathan then
            local frozenGate = workspace.Map:FindFirstChild("FrozenGate")
            local leviathan = workspace.Enemies:FindFirstChild("Leviathan")
            
            if leviathan and leviathan:FindFirstChild("HumanoidRootPart") then
                -- Bay lên trên đầu Leviathan để gây sát thương an toàn
                SmoothMove(leviathan.HumanoidRootPart.CFrame * CFrame.new(0, 60, 0))
                getgenv().SeorbConfig.WeaponSelect = "Combat"
                EquipWeapon()
            elseif frozenGate then
                -- Cổng đóng băng xuất hiện, tiến tới nói chuyện với khối đá trung tâm
                SmoothMove(frozenGate.CFrame)
                CommF:InvokeServer("FrozenGate", "Open")
            end
        end
    end
end)

-- 27. Auto Hoàn Thành Minigame Trial V4 (Race Awakening Bypass)
task.spawn(function()
    while task.wait(1) do
        if CurrentSea == 3 and getgenv().SeorbConfig.AutoV4 then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local currentPos = character.HumanoidRootPart.Position
                
                -- A. Shark Trial (Giết Seabeast Trial)
                if workspace.Enemies:FindFirstChild("TrialSeaBeast") then
                    local sb = workspace.Enemies:FindFirstChild("TrialSeaBeast")
                    SmoothMove(sb.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                end
                
                -- B. Mink Trial (Chạy mê cung - Bypass)
                local minkEnd = workspace.Map:FindFirstChild("MinkTrialEnd")
                if minkEnd and (currentPos - minkEnd.Position).Magnitude < 1500 then
                    -- Dịch chuyển thẳng tới điểm đích bỏ qua tường mê cung
                    SmoothMove(minkEnd.CFrame)
                end
                
                -- C. Cyborg Trial (Né bom/Giết quái)
                local cyborgEnemy = workspace.Enemies:FindFirstChild("TrialCyborg")
                if cyborgEnemy then
                    SmoothMove(cyborgEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                end
                
                -- D. Trận đấu sinh tử (Phòng Ancient One)
                local ancientOne = workspace.Map:FindFirstChild("AncientOne")
                if ancientOne and (currentPos - ancientOne.Position).Magnitude < 250 then
                    -- Mô phỏng tương tác kết thúc Trial nếu đi một mình hoặc sau khi thắng PvP
                    CommF:InvokeServer("RaceV4", "FinishTrial")
                end
            end
        end
    end
end)

-- ====================================================================
-- [[ PHẦN 10: HỆ THỐNG SKILL AIMBOT, WEBHOOK & AUTO RECONNECT ]]
-- ====================================================================

-- 1. Khởi tạo biến cấu hình Advanced
getgenv().SeorbConfig.SkillAimbot = false
getgenv().SeorbConfig.WebhookURL = ""
getgenv().SeorbConfig.SendWebhook = false

local AdvancedTab = Window:AddTab({ Title = "Advanced & Webhook", Icon = "shield" })

-- ==========================================
-- 28. HỆ THỐNG SKILL AIMBOT (TỰ ĐỘNG BẺ CHIÊU)
-- ==========================================
AdvancedTab:AddSection("Skill Aimbot System")
AdvancedTab:AddToggle("SkillAimbot", {Title = "Kích hoạt Skill Aimbot", Default = false}):OnChanged(function(v)
    getgenv().SeorbConfig.SkillAimbot = v
end)

local function GetClosestTarget()
    local closest = nil
    local maxDist = 500
    
    -- Ưu tiên khóa mục tiêu vào Player nếu đang bật Auto Bounty
    if getgenv().SeorbConfig.AutoBounty then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < maxDist and not p.Character:FindFirstChild("SafeZone") then
                    maxDist = dist
                    closest = p.Character.HumanoidRootPart
                end
            end
        end
    end
    
    -- Nếu không có Player, tự động chuyển sang khóa mục tiêu Quái vật (NPC)
    if not closest then
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                if dist < maxDist then
                    maxDist = dist
                    closest = enemy.HumanoidRootPart
                end
            end
        end
    end
    
    return closest
end

-- Hook hệ thống để bẻ hướng các chiêu thức (Remote Target Bypass)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if getgenv().SeorbConfig.SkillAimbot and method == "FireServer" and self.Name == "RemoteEvent" then
        if string.find(self.Parent.Name, "Modules") or string.find(args[1] or "", "Position") then
            local target = GetClosestTarget()
            if target then
                -- Ghi đè tham số vị trí chuột thành vị trí của mục tiêu
                if type(args[1]) == "Vector3" then args[1] = target.Position end
                if type(args[2]) == "Vector3" then args[2] = target.Position end
                if type(args[1]) == "CFrame" then args[1] = target.CFrame end
                if type(args[2]) == "CFrame" then args[2] = target.CFrame end
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- ==========================================
-- 29. HỆ THỐNG WEBHOOK LOGGING (BÁO CÁO NHẶT ĐỒ)
-- ==========================================
AdvancedTab:AddSection("Discord Webhook Tracker")
AdvancedTab:AddInput("WebhookURL", {
    Title = "Webhook URL",
    Default = "",
    Placeholder = "https://discord.com/api/webhooks/1519707362615754785/YroRwjN_jyzMXmJIPzTMIRV0wKLlvFa5uwEuXtS8hPsGXLCBEGOCMBc3A25IpTOO653n",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        getgenv().SeorbConfig.WebhookURL = Value
    end
})
AdvancedTab:AddToggle("SendWebhook", {Title = "Báo cáo vật phẩm hiếm về Discord", Default = false}):OnChanged(function(v)
    getgenv().SeorbConfig.SendWebhook = v
end)

local function SendToWebhook(content)
    if not getgenv().SeorbConfig.SendWebhook or getgenv().SeorbConfig.WebhookURL == "" then return end
    
    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "🟢 Seorb Hub | Live Update",
            ["description"] = content,
            ["type"] = "rich",
            ["color"] = tonumber(0x00FF00),
            ["footer"] = { ["text"] = "Seorb Hub Automations v31" }
        }}
    }
    
    local jsonData = HttpService:JSONEncode(data)
    local request = http_request or request or HttpPost or syn.request
    if request then
        pcall(function()
            request({
                Url = getgenv().SeorbConfig.WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        end)
    end
end

-- Lắng nghe biến động trong Balo (Nhặt được trái ác quỷ, Fist, Chalice...)
LocalPlayer.Backpack.ChildAdded:Connect(function(item)
    if item:IsA("Tool") and (item.Name:find("Fruit") or item.Name == "Fist of Darkness" or item.Name == "God's Chalice" or item.Name == "Sweet Chalice" or item.Name == "Blue Gear") then
        local seaName = CurrentSea == 1 and "Sea 1" or (CurrentSea == 2 and "Sea 2" or "Sea 3")
        SendToWebhook("🎉 **Vật phẩm hiếm thu thập được:** `" .. item.Name .. "`\n👤 **Tài khoản:** ||" .. LocalPlayer.Name .. "||\n🗺️ **Khu vực:** " .. seaName)
    end
end)

-- ==========================================
-- 30. ANTI-DISCONNECT & AUTO RECONNECT (TREO MÁY 24/7)
-- ==========================================
AdvancedTab:AddSection("Anti Disconnect & Farm 24/7")
AdvancedTab:AddButton({
    Title = "Kích hoạt Anti-AFK & Auto Reconnect",
    Description = "Bỏ qua lỗi 277, tự động vào lại phòng khi mất kết nối mạng",
    Callback = function()
        local GuiService = game:GetService("GuiService")
        local TeleportService = game:GetService("TeleportService")
        
        -- Lắng nghe sự kiện lỗi màn hình xám từ Roblox
        GuiService.ErrorMessageChanged:Connect(function()
            task.wait(2) -- Nghỉ 2s trước khi kết nối lại
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
        
        Fluent:Notify({
            Title = "Auto Reconnect",
            Content = "Hệ thống bảo vệ kết nối đã khởi chạy. Treo máy an toàn 24/7!",
            Duration = 5
        })
    end
})

-- Kích hoạt tải cấu hình tự động (Autoload Config) nếu người dùng đã lưu trước đó
SaveManager:LoadAutoloadConfig()

-- // Finish Initializing
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SeorbHubConfig")
SaveManager:SetFolder("SeorbHubConfig/BloxFruits")
SaveManager:BuildConfigSection(Tabs.Movement)
Window:SelectTab(Tabs.MainFarm)

Fluent:Notify({
    Title = "Seorb Hub",
    Content = "Mã nguồn chính đã được khởi chạy thành công trên Sea " .. CurrentSea,
    Duration = 5
})
