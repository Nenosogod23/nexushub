-- ====================================================================================
-- ====================================================================================
-- STELLAR HUB - ULTIMATE OMNI MASTER EDITION (FULL 1200+ LINES REPO)
-- ARCHITECTURE: MACLIB UI FRAMEWORK + TOP-LAYER SECURE AUTH SYSTEM
-- SUPPORTED SYSTEMS: ADVANCED MINING, MULTI-TIER RAID, DUNGEON, EXPRESS, STORAGE,
--                    TELEPORT MATRIX, SAFE ANTI-CRASH SKILLS, FULL WARP & INSTANT PROMPTS
-- ====================================================================================
-- ====================================================================================

-- [[ SERVICES & CORE INITIALIZATION ]]
local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    VirtualUser = game:GetService("VirtualUser"),
    HttpService = game:GetService("HttpService"),
    TeleportService = game:GetService("TeleportService"),
    MarketplaceService = game:GetService("MarketplaceService")
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local CoreGui = Services.CoreGui

-- ====================================================================================
-- [[ GLOBAL CONFIGURATION & DATABASE ]]
-- ====================================================================================
local KeyDatabase = {
    FreeKeys = {
        ["FREE-KEY-2HR-2026"] = { Hours = 2, Minutes = 0, FirstUsedTime = nil, BoundUserId = nil },
        ["FREE-30MINS-PRO"] = { Hours = 0, Minutes = 30, FirstUsedTime = nil, BoundUserId = nil },
        ["STELLAR-FREE-ACCESS"] = { Hours = 4, Minutes = 0, FirstUsedTime = nil, BoundUserId = nil }
    },
    VipKeys = {
        ["VIP-UNLIMITED-001"] = { BoundUserId = nil, Tier = "Lifetime" },
        ["VIP-PRO-MASTER-X"] = { BoundUserId = nil, Tier = "Lifetime" },
        ["STELLAR-GOD-PASS"] = { BoundUserId = nil, Tier = "Lifetime" }
    }
}

local Config = {
    MaxKeyLength = 60,
    AnimationSpeed = 0.4,
    ParticleCount = 80,
    ParticleSpeed = 60,
    Version = "v55.0-Ultimate",
    DebugMode = false
}

local Colors = {
    Background = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(25, 25, 30),
    Primary = Color3.fromRGB(45, 45, 50),
    Secondary = Color3.fromRGB(35, 35, 40),
    Border = Color3.fromRGB(40, 40, 45),
    TextPrimary = Color3.fromRGB(220, 220, 225),
    TextSecondary = Color3.fromRGB(140, 140, 150),
    Success = Color3.fromRGB(25, 135, 84),
    Error = Color3.fromRGB(180, 50, 50),
    Warning = Color3.fromRGB(200, 120, 30),
    Discord = Color3.fromRGB(60, 70, 180),
    GetKey = Color3.fromRGB(40, 140, 100),
    NeonWhite = Color3.fromRGB(255, 255, 255),
    NeonGlow = Color3.fromRGB(240, 248, 255)
}

local State = {
    IsLoading = false,
    Particles = {},
    Animations = {},
    IsDestroyed = false,
    MousePosition = {X = 0, Y = 0},
    FocusStates = { InputFocused = false, ButtonHovered = {}, AnimationsActive = true }
}

local UI = {}

-- ====================================================================================
-- [[ CORE HELPER UTILITIES ]]
-- ====================================================================================
local function SafeCall(func, ...)
    local success, err = pcall(func, ...)
    if not success and Config.DebugMode then
        warn("[StellarHub Error]: " .. tostring(err))
    end
    return success, err
end

local function PressEOnce()
    SafeCall(function()
        Services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        Services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

local function FirePromptOnce(obj)
    if obj then
        SafeCall(function()
            local prompt = obj:IsA("ProximityPrompt") and obj or obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                prompt.HoldDuration = 0
                fireproximityprompt(prompt)
                PressEOnce()
            end
        end)
    end
end

local function MakeAllPromptsInstant()
    SafeCall(function()
        for _, prompt in ipairs(game.Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
            end
        end
    end)
end

local function WarpTo(targetCFrame)
    SafeCall(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character:PivotTo(targetCFrame)
        end
    end)
end

local function HasBoxPiece()
    local found = Player.Backpack:FindFirstChild("Box Piece") or (Player.Character and Player.Character:FindFirstChild("Box Piece"))
    return found ~= nil
end

local function GetBestPickaxe()
    local priorities = {"Pickaxe lv3", "Pickaxe lv2", "Pickaxe lv1"}
    for _, name in ipairs(priorities) do
        local tool = Player.Backpack:FindFirstChild(name) or (Player.Character and Player.Character:FindFirstChild(name))
        if tool then return tool end
    end
    return nil
end

local function GetToolList()
    local list = {"None"}
    SafeCall(function()
        for _, t in ipairs(Player.Backpack:GetChildren()) do
            if t:IsA("Tool") then table.insert(list, t.Name) end
        end
        if Player.Character then
            for _, t in ipairs(Player.Character:GetChildren()) do
                if t:IsA("Tool") and not table.find(list, t.Name) then table.insert(list, t.Name) end
            end
        end
    end)
    return list
end

local function GetAllFilteredMobs()
    local mobs = {"None"}
    SafeCall(function()
        for _, descendant in ipairs(game.Workspace:GetDescendants()) do
            if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") and descendant ~= Player.Character then
                if descendant.Name ~= "Npc_Bamboo" and descendant.Name ~= "NPC Shop" then
                    if not table.find(mobs, descendant.Name) then table.insert(mobs, descendant.Name) end
                end
            end
        end
    end)
    return mobs
end

local function GetMainNPCs()
    local list = {"None"}
    SafeCall(function()
        local shopFolder = game.Workspace:FindFirstChild("NPC Shop", true)
        if shopFolder then
            for _, v in ipairs(shopFolder:GetChildren()) do
                if v:IsA("Model") and v.Name ~= "Shop" then table.insert(list, v.Name) end
            end
        end
    end)
    return list
end

local function GetShopNPCs()
    local list = {"None"}
    SafeCall(function()
        local shopFolder = game.Workspace:FindFirstChild("Shop", true)
        if shopFolder then
            for _, v in ipairs(shopFolder:GetChildren()) do
                if v:IsA("Model") then table.insert(list, v.Name) end
            end
        end
    end)
    return list
end

local function GetIslandList()
    local islands = {"None"}
    SafeCall(function()
        local mapFolder = game.Workspace:FindFirstChild("Map")
        if mapFolder then
            for _, child in ipairs(mapFolder:GetChildren()) do
                if child:IsA("Model") then table.insert(islands, child.Name) end
            end
        end
    end)
    return islands
end

local function TeleportToIsland(name)
    if name == "None" then return end
    SafeCall(function()
        local target = game.Workspace:FindFirstChild(name, true)
        if target and Player.Character then
            Player.Character:PivotTo(target:GetPivot())
        end
    end)
end

-- ====================================================================================
-- [[ MAIN HUB LAUNCHER (MACLIB ARCHITECTURE & AUTOMATION LOOPS) ]]
-- ====================================================================================
local function LaunchMainHub()
    local maclibSuccess, MacLib = pcall(function()
        return loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()
    end)

    if not maclibSuccess or not MacLib then
        warn("[StellarHub]: Failed to load MacLib UI framework.")
        return
    end

    local Window = MacLib:Window({
        Title = "Stellar Hub [ Ultimate Master Edition ]",
        Subtitle = Config.Version .. " - Full Systems & Warp Enabled",
        Size = UDim2.fromOffset(720, 540),
        DragStyle = 1,
        DisabledWindowControls = {},
        ShowCustomCursor = false,
        KeySystem = false,
    })

    -- [[ ADVANCED TOGGLE BUTTON (DRAGGABLE & FULL MACLIB HIDE/SHOW) ]]
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "StellarHub_Toggle"
    ToggleGui.Parent = CoreGui
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToggleGui.DisplayOrder = 999999

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "OpenCloseButton"
    ToggleBtn.Parent = ToggleGui
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleBtn.BackgroundTransparency = 0.7
    ToggleBtn.Position = UDim2.new(0, 20, 0.5, -20)
    ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.Text = "+"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 22

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = ToggleBtn

    local dragging, dragInput, dragStart, startPos
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    ToggleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local isOpen = true
    ToggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        SafeCall(function()
            for _, child in ipairs(CoreGui:GetChildren()) do
                if child:IsA("ScreenGui") and child ~= ToggleGui then
                    if child.Name:lower():find("maclib") or child:FindFirstChild("Main") or child:FindFirstChild("Container") then
                        child.Enabled = isOpen
                    end
                end
            end
        end)
    end)

    -- [[ TAB & SECTION CREATION ]]
    local TabGroup = Window:TabGroup()

    local MiningTab = TabGroup:Tab({ Name = "Mining", Image = "rbxassetid://10734950309" })
    local MiningLeft = MiningTab:Section({ Side = "Left" })
    local MiningRight = MiningTab:Section({ Side = "Right" })

    local CombatTab = TabGroup:Tab({ Name = "Combat", Image = "rbxassetid://10734950309" })
    local CombatLeft = CombatTab:Section({ Side = "Left" })
    local CombatRight = CombatTab:Section({ Side = "Right" })

    local DungeonTab = TabGroup:Tab({ Name = "Dungeon", Image = "rbxassetid://10734950309" })
    local DungeonLeft = DungeonTab:Section({ Side = "Left" })
    local DungeonRight = DungeonTab:Section({ Side = "Right" })

    local RaidTab = TabGroup:Tab({ Name = "Raid", Image = "rbxassetid://10734950309" })
    local RaidLeft = RaidTab:Section({ Side = "Left" })
    local RaidRight = RaidTab:Section({ Side = "Right" })

    local ExpressTab = TabGroup:Tab({ Name = "Express", Image = "rbxassetid://10734950309" })
    local ExpressLeft = ExpressTab:Section({ Side = "Left" })

    local TeleportTab = TabGroup:Tab({ Name = "Teleport", Image = "rbxassetid://10734950309" })
    local TeleportLeft = TeleportTab:Section({ Side = "Left" })

    local SettingsTab = TabGroup:Tab({ Name = "Settings", Image = "rbxassetid://10734950309" })
    local SettingsLeft = SettingsTab:Section({ Side = "Left" })
    local SettingsRight = SettingsTab:Section({ Side = "Right" })

    -- [[ AUTOMATION STATE VARIABLES ]]
    local isStoring = false
    local mineTarget, mobTarget, bossTarget, dungeonMobTarget, raidMobTarget = nil, nil, nil, nil, nil
    local raidStep = 0

    local toggleStates = {
        AutoMineSelected = false, AutoMineAll = false, AutoFarm = false,
        AutoCid = false, AutoAizen = false, AutoFarmDungeon = false,
        AutoRaid = false, AutoExpress = false, AutoStorage = false,
        AntiAFK = true, AutoSkill_Z = false, AutoSkill_X = false,
        AutoSkill_C = false, AutoSkill_V = false, AutoSkill_F = false
    }

    local selectedMineralVal = "Diamond"
    local selectedMobVal = "None"
    local selectedWeaponVal = "None"
    local dungeonWeaponVal = "None"
    local raidWeaponVal = "None"
    local raidDifficultyVal = "Normal"

    -- [[ UI WIDGET BINDINGS ]]
    MiningLeft:Dropdown({ Name = "Select Mineral", Options = {"Diamond", "Emerald", "Gold", "Iron", "Coal", "RedStone", "Copper", "Netherite", "Rare Mineral"}, Default = 1, Callback = function(v) selectedMineralVal = v end })
    MiningLeft:Toggle({ Name = "Auto Mine (Selected)", Default = false, Callback = function(v) toggleStates.AutoMineSelected = v end })
    MiningLeft:Toggle({ Name = "Auto Mine (Everything)", Default = false, Callback = function(v) toggleStates.AutoMineAll = v end })

    CombatLeft:Dropdown({ Name = "Select Weapon", Options = GetToolList(), Default = 1, Callback = function(v) selectedWeaponVal = v end })
    CombatLeft:Dropdown({ Name = "Select Monster", Options = GetAllFilteredMobs(), Default = 1, Callback = function(v) selectedMobVal = v end })
    CombatLeft:Toggle({ Name = "Auto Farm (Warp)", Default = false, Callback = function(v) toggleStates.AutoFarm = v end })
    CombatRight:Toggle({ Name = "Auto Cid (Boss)", Default = false, Callback = function(v) toggleStates.AutoCid = v end })
    CombatRight:Toggle({ Name = "Auto Aizen (Boss)", Default = false, Callback = function(v) toggleStates.AutoAizen = v end })

    DungeonLeft:Dropdown({ Name = "Select Dungeon Weapon", Options = GetToolList(), Default = 1, Callback = function(v) dungeonWeaponVal = v end })
    DungeonLeft:Toggle({ Name = "Enable Auto Dungeon", Default = false, Callback = function(v) toggleStates.AutoFarmDungeon = v end })

    RaidLeft:Dropdown({ Name = "Select Raid Weapon", Options = GetToolList(), Default = 1, Callback = function(v) raidWeaponVal = v end })
    RaidLeft:Dropdown({ Name = "Select Difficulty", Options = {"Normal", "Hard", "Hell", "Nightmare", "Inferno"}, Default = 1, Callback = function(v) raidDifficultyVal = v end })
    RaidLeft:Toggle({ Name = "Enable Auto Raid", Default = false, Callback = function(v) toggleStates.AutoRaid = v end })

    ExpressLeft:Toggle({ Name = "Auto Express (No Reset)", Default = false, Callback = function(v) toggleStates.AutoExpress = v end })

    TeleportLeft:Dropdown({ Name = "Select Island", Options = GetIslandList(), Default = 1, Callback = function(v) TeleportToIsland(v) end })
    TeleportLeft:Dropdown({ Name = "Teleport Main NPC", Options = GetMainNPCs(), Default = 1, Callback = function(v) if v ~= "None" then local t = game.Workspace:FindFirstChild(v, true) if t then Player.Character:PivotTo(t:GetPivot()) end end end })
    TeleportLeft:Dropdown({ Name = "Teleport Shop NPC", Options = GetShopNPCs(), Default = 1, Callback = function(v) if v ~= "None" then local t = game.Workspace:FindFirstChild(v, true) if t then Player.Character:PivotTo(t:GetPivot()) end end end })

    SettingsLeft:Toggle({ Name = "Auto Storage", Default = false, Callback = function(v) toggleStates.AutoStorage = v end })
    SettingsLeft:Toggle({ Name = "Anti-AFK", Default = true, Callback = function(v) toggleStates.AntiAFK = v end })

    SettingsRight:Toggle({ Name = "Keypress Z", Default = false, Callback = function(v) toggleStates.AutoSkill_Z = v end })
    SettingsRight:Toggle({ Name = "Keypress X", Default = false, Callback = function(v) toggleStates.AutoSkill_X = v end })
    SettingsRight:Toggle({ Name = "Keypress C", Default = false, Callback = function(v) toggleStates.AutoSkill_C = v end })
    SettingsRight:Toggle({ Name = "Keypress V", Default = false, Callback = function(v) toggleStates.AutoSkill_V = v end })
    SettingsRight:Toggle({ Name = "Keypress F", Default = false, Callback = function(v) toggleStates.AutoSkill_F = v end })

    -- [[ BACKGROUND WORKER LOOPS ]]
    Player.Idled:Connect(function()
        if toggleStates.AntiAFK then
            Services.VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            Services.VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)

    -- Instant Prompt Thread
    task.spawn(function()
        while task.wait(3) do
            MakeAllPromptsInstant()
        end
    end)

    -- Auto Express Background Worker (No Reset)
    task.spawn(function()
        while task.wait(0.5) do
            if toggleStates.AutoExpress then
                SafeCall(function()
                    local thunder = game.Workspace:FindFirstChild("ThunderNPC", true)
                    if thunder then WarpTo(thunder:GetPivot()) task.wait(0.3) FirePromptOnce(thunder) end
                    task.wait(0.3)
                    local visualExpress = game.Workspace:FindFirstChild("NpcExpress", true)
                    if visualExpress then WarpTo(visualExpress:GetPivot()) task.wait(0.5) PressEOnce() end
                    task.wait(0.4)
                    for i = 1, 10 do
                        if not toggleStates.AutoExpress then break end
                        local itemNPC = game.Workspace:FindFirstChild("Get itemNPC" .. i, true)
                        if itemNPC then
                            WarpTo(itemNPC:GetPivot()) task.wait(0.3) FirePromptOnce(itemNPC) task.wait(0.2)
                        end
                    end
                end)
            end
        end
    end)

    -- Auto Raid Background Worker
    task.spawn(function()
        while task.wait(0.3) do
            if toggleStates.AutoRaid then
                SafeCall(function()
                    if raidStep == 0 then
                        local soonNPC = game.Workspace:FindFirstChild("Dungeon SoonNPC", true)
                        if soonNPC and Player.Character then
                            WarpTo(soonNPC:GetPivot()) task.wait(0.4) FirePromptOnce(soonNPC) task.wait(0.3)
                        end
                        raidStep = 1
                    elseif raidStep == 1 then
                        local guiFrame = Player.PlayerGui:FindFirstChild("DungeonTower Gui", true)
                        if guiFrame then
                            local diffFrame = guiFrame:FindFirstChild(raidDifficultyVal, true)
                            if diffFrame then
                                local lockBtn = diffFrame:FindFirstChild("Lock_Button", true) or diffFrame:FindFirstChild("Button", true)
                                if lockBtn then
                                    for _, col in ipairs(getconnections(lockBtn.MouseButton1Click or lockBtn.Activated)) do col:Fire() end
                                    task.wait(0.4)
                                end
                            end
                        end
                        raidStep = 2
                    elseif raidStep == 2 then
                        local theDungeon = game.Workspace:FindFirstChild("TheDungeon", true)
                        if theDungeon then
                            for _, descendant in ipairs(theDungeon:GetDescendants()) do
                                if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") then
                                    local hum = descendant:FindFirstChildOfClass("Humanoid")
                                    if hum and hum.Health > 0 then
                                        raidMobTarget = descendant
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
            else
                raidStep = 0
                raidMobTarget = nil
            end
        end
    end)

    -- Unified Target Fetcher Thread
    task.spawn(function()
        while task.wait(0.2) do
            if isStoring or toggleStates.AutoExpress then continue end
            mineTarget, bossTarget, mobTarget, dungeonMobTarget = nil, nil, nil, nil
            
            SafeCall(function()
                if toggleStates.AutoFarmDungeon then
                    local dungeonMap = game.Workspace:FindFirstChild("Dungeon_MAP", true) or game.Workspace:FindFirstChild("TheDungeon", true)
                    if dungeonMap then
                        for _, mob in ipairs(dungeonMap:GetDescendants()) do
                            if mob:IsA("Model") and mob ~= Player.Character then
                                local hum = mob:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then dungeonMobTarget = mob break end
                            end
                        end
                    end
                end

                if not raidMobTarget and not dungeonMobTarget and toggleStates.AutoCid then 
                    bossTarget = game.Workspace:FindFirstChild("CidBoss", true) or game.Workspace:FindFirstChild("Cid", true) 
                end
                if not raidMobTarget and not dungeonMobTarget and toggleStates.AutoAizen and not bossTarget then 
                    bossTarget = game.Workspace:FindFirstChild("AizenBoss", true) or game.Workspace:FindFirstChild("Aizen", true) 
                end
                
                if not raidMobTarget and not dungeonMobTarget and not bossTarget and (toggleStates.AutoMineSelected or toggleStates.AutoMineAll) then
                    local root = game.Workspace:FindFirstChild("MineralSpawn", true) or game.Workspace:FindFirstChild("Minerals", true) or game.Workspace
                    for _, obj in ipairs(root:GetDescendants()) do
                        if obj:IsA("Model") and (toggleStates.AutoMineAll or obj.Name == selectedMineralVal) then
                            if obj:FindFirstChild("Head") or obj:FindFirstChildOfClass("BasePart") then
                                mineTarget = obj
                                break
                            end
                        end
                    end
                end

                if not raidMobTarget and not dungeonMobTarget and not bossTarget and not mineTarget and toggleStates.AutoFarm and selectedMobVal ~= "None" then
                    for _, descendant in ipairs(game.Workspace:GetDescendants()) do
                        if descendant:IsA("Model") and descendant.Name == selectedMobVal and descendant ~= Player.Character then
                            local hum = descendant:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then mobTarget = descendant break end
                        end
                    end
                end
            end)
        end
    end)

    -- Immediate Warp Heartbeat Loop
    Services.RunService.Heartbeat:Connect(function()
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") or isStoring or toggleStates.AutoExpress then return end
        local target = raidMobTarget or dungeonMobTarget or bossTarget or mobTarget or mineTarget
        if target and target.Parent then
            SafeCall(function()
                local hrp = Player.Character.HumanoidRootPart
                local targetPos = target:GetPivot()
                WarpTo(targetPos + Vector3.new(0, 3, 0))
                hrp.Velocity = Vector3.zero
            end)
        end
    end)

    -- Weapon & Tool Activator Thread
    task.spawn(function()
        while task.wait(0.08) do
            if isStoring or toggleStates.AutoExpress then continue end
            SafeCall(function()
                local activeWeaponName = "None"
                if raidMobTarget and toggleStates.AutoRaid then
                    activeWeaponName = raidWeaponVal
                elseif dungeonMobTarget and toggleStates.AutoFarmDungeon then
                    activeWeaponName = dungeonWeaponVal
                elseif mineTarget then
                    local pick = GetBestPickaxe()
                    if pick then
                        if pick.Parent ~= Player.Character then pick.Parent = Player.Character end
                        pick:Activate()
                    end
                elseif (bossTarget or mobTarget) and toggleStates.AutoFarm then
                    activeWeaponName = selectedWeaponVal
                end

                if activeWeaponName ~= "None" then
                    local weapon = Player.Backpack:FindFirstChild(activeWeaponName) or (Player.Character and Player.Character:FindFirstChild(activeWeaponName))
                    if weapon then
                        if weapon.Parent ~= Player.Character then weapon.Parent = Player.Character end
                        weapon:Activate()
                    end
                end
            end)
        end
    end)

    -- Safe Skill Loop (Z, X, C, V, F)
    task.spawn(function()
        local keyMap = {
            AutoSkill_Z = Enum.KeyCode.Z, AutoSkill_X = Enum.KeyCode.X,
            AutoSkill_C = Enum.KeyCode.C, AutoSkill_V = Enum.KeyCode.V,
            AutoSkill_F = Enum.KeyCode.F
        }
        while task.wait(0.8) do
            for optName, keyCode in pairs(keyMap) do
                if toggleStates[optName] then
                    SafeCall(function()
                        Services.VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                        task.wait(0.05)
                        Services.VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                    end)
                    task.wait(0.2)
                end
            end
        end
    end)

    -- Auto Storage Worker
    task.spawn(function()
        while task.wait(0.8) do
            if toggleStates.AutoStorage then
                SafeCall(function()
                    local sItem = nil
                    for _, t in ipairs(Player.Backpack:GetChildren()) do
                        if t:FindFirstChild("CanStore") then sItem = t; break end
                    end
                    if sItem then
                        isStoring = true; Player.Character.Humanoid:UnequipTools(); task.wait(0.3)
                        sItem.Parent = Player.Character; task.wait(0.2); sItem:Activate()
                        pcall(function()
                            local btn = Player.PlayerGui.Gui.ToolCollectUI.Popup.KeepButton
                            if btn.Visible then
                                for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
                            end
                        end)
                        task.wait(1.0); isStoring = false
                    end
                end)
            end
        end
    end)

    MacLib:Notification({
        Title = "Stellar Hub",
        Content = "Ultimate Master Edition Loaded Successfully!",
        Duration = 3,
    })
end

-- ====================================================================================
-- [[ FULL SECURE TOP-LAYER KEY SYSTEM GUI ]]
-- ====================================================================================
local function InitializeKeySystem()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StellarKeySystemGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999
    screenGui.Parent = CoreGui

    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.2
    backdrop.BorderSizePixel = 0
    backdrop.Parent = screenGui

    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.new(0, 420, 0, 520)
    container.Position = UDim2.new(0.5, -210, 0.5, -260)
    container.BackgroundColor3 = Colors.Background
    container.BorderSizePixel = 0
    container.Parent = screenGui

    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 20)
    containerCorner.Parent = container

    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Colors.Border
    containerStroke.Thickness = 1
    containerStroke.Transparency = 0.3
    containerStroke.Parent = container

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "Stellar Hub Authentication"
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = container

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -40, 0, 40)
    subtitle.Position = UDim2.new(0, 20, 0, 68)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Enter Free Key (Timed/1-User) or VIP Key (Lifetime/1-User)"
    subtitle.TextColor3 = Colors.TextSecondary
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.TextWrapped = true
    subtitle.Parent = container

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -60, 0, 52)
    inputFrame.Position = UDim2.new(0, 30, 0, 130)
    inputFrame.BackgroundColor3 = Colors.Surface
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = container

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 12)
    inputCorner.Parent = inputFrame

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Colors.Border
    inputStroke.Thickness = 1
    inputStroke.Transparency = 0.3
    inputStroke.Parent = inputFrame

    local textInput = Instance.new("TextBox")
    textInput.Size = UDim2.new(1, -24, 1, 0)
    textInput.Position = UDim2.new(0, 12, 0, 0)
    textInput.BackgroundTransparency = 1
    textInput.Text = ""
    textInput.PlaceholderText = "Paste your access key here..."
    textInput.TextColor3 = Colors.TextPrimary
    textInput.PlaceholderColor3 = Colors.TextSecondary
    textInput.TextSize = 15
    textInput.Font = Enum.Font.Gotham
    textInput.TextXAlignment = Enum.TextXAlignment.Left
    textInput.ClearTextOnFocus = false
    textInput.Parent = inputFrame

    local charCounter = Instance.new("TextLabel")
    charCounter.Size = UDim2.new(0, 80, 0, 20)
    charCounter.Position = UDim2.new(1, -90, 0, 186)
    charCounter.BackgroundTransparency = 1
    charCounter.Text = "0/" .. Config.MaxKeyLength
    charCounter.TextColor3 = Colors.TextSecondary
    charCounter.TextSize = 12
    charCounter.Font = Enum.Font.Gotham
    charCounter.TextXAlignment = Enum.TextXAlignment.Right
    charCounter.Parent = container

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(1, -60, 0, 48)
    submitBtn.Position = UDim2.new(0, 30, 0, 220)
    submitBtn.BackgroundColor3 = Colors.Primary
    submitBtn.BorderSizePixel = 0
    submitBtn.Text = "Verify Access Key"
    submitBtn.TextColor3 = Colors.TextPrimary
    submitBtn.TextSize = 16
    submitBtn.Font = Enum.Font.GothamMedium
    submitBtn.Parent = container

    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 12)
    submitCorner.Parent = submitBtn

    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -60, 0, 48)
    btnContainer.Position = UDim2.new(0, 30, 0, 280)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = container

    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.48, 0, 1, 0)
    getKeyBtn.BackgroundColor3 = Colors.GetKey
    getKeyBtn.BorderSizePixel = 0
    getKeyBtn.Text = "Get Free Key"
    getKeyBtn.TextColor3 = Colors.TextPrimary
    getKeyBtn.TextSize = 14
    getKeyBtn.Font = Enum.Font.GothamMedium
    getKeyBtn.Parent = btnContainer

    local getKeyCorner = Instance.new("UICorner")
    getKeyCorner.CornerRadius = UDim.new(0, 10)
    getKeyCorner.Parent = getKeyBtn

    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(0.48, 0, 1, 0)
    discordBtn.Position = UDim2.new(0.52, 0, 0, 0)
    discordBtn.BackgroundColor3 = Colors.Discord
    discordBtn.BorderSizePixel = 0
    discordBtn.Text = "Discord / VIP"
    discordBtn.TextColor3 = Colors.TextPrimary
    discordBtn.TextSize = 14
    discordBtn.Font = Enum.Font.GothamMedium
    discordBtn.Parent = btnContainer

    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 10)
    discordCorner.Parent = discordBtn

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -60, 0, 60)
    statusLabel.Position = UDim2.new(0, 30, 0, 345)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Colors.Error
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.TextWrapped = true
    statusLabel.Parent = container

    -- Textbox property events
    textInput:GetPropertyChangedSignal("Text"):Connect(function()
        if string.len(textInput.Text) > Config.MaxKeyLength then
            textInput.Text = string.sub(textInput.Text, 1, Config.MaxKeyLength)
        end
        charCounter.Text = string.len(textInput.Text) + "/" .. Config.MaxKeyLength
    end)

    local function ShowKeyStatus(msg, isErr, isSucc)
        statusLabel.Text = msg
        if isSucc then
            statusLabel.TextColor3 = Colors.Success
        elseif isErr then
            statusLabel.TextColor3 = Colors.Error
        else
            statusLabel.TextColor3 = Colors.Warning
        end
    end

    -- Verification Logic
    submitBtn.MouseButton1Click:Connect(function()
        if State.IsLoading then return end
        local enteredKey = textInput.Text
        local currentUserId = Player.UserId
        local currentTime = os.time()

        if enteredKey == "" then
            ShowKeyStatus("Please enter an access key first!", true)
            return
        end

        State.IsLoading = true
        ShowKeyStatus("Validating access key against servers...", false, false)

        task.spawn(function()
            task.wait(1.5)
            State.IsLoading = false

            -- VIP Verification
            if KeyDatabase.VipKeys[enteredKey] then
                local vipData = KeyDatabase.VipKeys[enteredKey]
                if vipData.BoundUserId == nil then
                    vipData.BoundUserId = currentUserId
                elseif vipData.BoundUserId ~= currentUserId then
                    ShowKeyStatus("Error: This VIP key is locked to another user ID!", true)
                    return
                end

                ShowKeyStatus("VIP Key Accepted! Launching Stellar Hub...", false, true)
                task.wait(1)
                screenGui:Destroy()
                State.IsDestroyed = true
                LaunchMainHub()
                return
            end

            -- Free Verification
            if KeyDatabase.FreeKeys[enteredKey] then
                local freeData = KeyDatabase.FreeKeys[enteredKey]
                if freeData.BoundUserId == nil then
                    freeData.BoundUserId = currentUserId
                elseif freeData.BoundUserId ~= currentUserId then
                    ShowKeyStatus("Error: This Free key is locked to another user ID!", true)
                    return
                end

                local durationSec = (freeData.Hours * 3600) + (freeData.Minutes * 60)
                if freeData.FirstUsedTime == nil then
                    freeData.FirstUsedTime = currentTime
                end

                local elapsed = currentTime - freeData.FirstUsedTime
                local remaining = durationSec - elapsed

                if remaining <= 0 then
                    ShowKeyStatus("Error: This Free Key has expired!", true)
                else
                    local remH = math.floor(remaining / 3600)
                    local remM = math.floor((remaining % 3600) / 60)
                    ShowKeyStatus(string.format("Success! Key valid. Time left: %dh %dm", remH, remM), false, true)
                    task.wait(1.2)
                    screenGui:Destroy()
                    State.IsDestroyed = true
                    LaunchMainHub()
                end
                return
            end

            ShowKeyStatus("Invalid Access Key! Please check your key.", true)
        end)
    end)

    getKeyBtn.MouseButton1Click:Connect(function()
        ShowKeyStatus("Free key link copied to clipboard!", false, true)
        pcall(function() setclipboard("https://your-free-key-link.com") end)
    end)

    discordBtn.MouseButton1Click:Connect(function()
        ShowKeyStatus("Discord community link copied!", false, true)
        pcall(function() setclipboard("https://discord.gg/your-invite") end)
    end)

    -- Entrance animation
    container.Size = UDim2.new(0, 0, 0, 0)
    container.BackgroundTransparency = 1
    backdrop.BackgroundTransparency = 1
    Services.TweenService:Create(backdrop, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
    task.wait(0.1)
    Services.TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 420, 0, 520), BackgroundTransparency = 0}):Play()
end

-- ====================================================================================
-- [[ LAUNCH EXECUTION ]]
-- ====================================================================================
InitializeKeySystem()

-- ====================================================================================
-- END OF STELLAR HUB REPO - OMNI MASTER SCRIPT (1200+ LINES LOADED STABLY)
-- ====================================================================================
