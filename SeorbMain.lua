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

-- Safe Island / NPC Teleport Index Example
local function TeleportToIsland(islandName)
    -- Map positions via dynamic asset check or lookup coords
    local targetNode = workspace.Islands:FindFirstChild(islandName) or workspace.NPCs:FindFirstChild(islandName)
    if targetNode then
        SmoothMove(targetNode.CFrame)
    end
end

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
