-- ========================================
-- SERVICES & INITIALIZATION
-- ========================================

local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService")
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local CoreGui = game:GetService("CoreGui")

-- ========================================
-- KEY DATABASE (ระบบคีย์: ฟรี และ VIP)
-- ========================================
local KeyDatabase = {
    FreeKeys = {
        ["FREE-KEY-2HR"] = { Hours = 2, Minutes = 0, FirstUsedTime = nil, BoundUserId = nil },
        ["FREE-30MINS"] = { Hours = 0, Minutes = 30, FirstUsedTime = nil, BoundUserId = nil }
    },
    VipKeys = {
        ["VIP-UNLIMITED-001"] = { BoundUserId = nil },
        ["VIP-PRO-MASTER"] = { BoundUserId = nil }
    }
}

-- ========================================
-- CONFIGURATION & COLORS
-- ========================================

local Config = {
    MaxKeyLength = 50,
    AnimationSpeed = 0.4,
    ParticleCount = 60,
    ParticleSpeed = 60
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

-- ========================================
-- MAIN SCRIPT LAUNCHER (MACLIB + FULL AUTOMATION + WORKING TOGGLE)
-- ========================================

local function LaunchMainHub()
    local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

    local Window = MacLib:Window({
        Title = "Stellar Hub [ Ultimate Edition ]",
        Subtitle = "v53.0 - Full Features & Working Toggle",
        Size = UDim2.fromOffset(720, 540),
        DragStyle = 1,
        DisabledWindowControls = {},
        ShowCustomCursor = false,
        KeySystem = false,
    })

    -- [[ FIXED CUSTOM TOGGLE BUTTON (ซ่อน/แสดง หน้าต่าง MacLib ได้จริง) ]]
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

    -- ระบบลากปุ่ม +
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
        pcall(function()
            -- ค้นหา ScreenGui ของ MacLib ทั้งหมดแล้วสลับ Enabled
            for _, child in ipairs(CoreGui:GetChildren()) do
                if child:IsA("ScreenGui") and child ~= ToggleGui then
                    if child.Name:lower():find("maclib") or child:FindFirstChild("Main") or child:FindFirstChild("Container") then
                        child.Enabled = isOpen
                    end
                end
            end
        end)
    end)

    -- [[ TABS & SECTIONS SETUP ]]
    local TabGroup = Window:TabGroup()

    local MiningTab = TabGroup:Tab({ Name = "Mining", Image = "rbxassetid://10734950309" })
    local MiningLeft = MiningTab:Section({ Side = "Left" })

    local CombatTab = TabGroup:Tab({ Name = "Combat", Image = "rbxassetid://10734950309" })
    local CombatLeft = CombatTab:Section({ Side = "Left" })
    local CombatRight = CombatTab:Section({ Side = "Right" })

    local DungeonTab = TabGroup:Tab({ Name = "Dungeon", Image = "rbxassetid://10734950309" })
    local DungeonLeft = DungeonTab:Section({ Side = "Left" })

    local RaidTab = TabGroup:Tab({ Name = "Raid", Image = "rbxassetid://10734950309" })
    local RaidLeft = RaidTab:Section({ Side = "Left" })

    local ExpressTab = TabGroup:Tab({ Name = "Express", Image = "rbxassetid://10734950309" })
    local ExpressLeft = ExpressTab:Section({ Side = "Left" })

    local TeleportTab = TabGroup:Tab({ Name = "Teleport", Image = "rbxassetid://10734950309" })
    local TeleportLeft = TeleportTab:Section({ Side = "Left" })

    local SettingsTab = TabGroup:Tab({ Name = "Settings", Image = "rbxassetid://10734950309" })
    local SettingsLeft = SettingsTab:Section({ Side = "Left" })
    local SettingsRight = SettingsTab:Section({ Side = "Right" })

    -- [[ BACKEND VARIABLES & FUNCTIONS ]]
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local VirtualUser = game:GetService("VirtualUser")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")

    local isStoring = false
    local mineTarget, mobTarget, bossTarget, dungeonMobTarget, raidMobTarget = nil, nil, nil, nil, nil
    local pressedButtons = {}
    local hasPressedMainDoor = false
    local raidStep = 0
    local currentTween = nil

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

    local function pressEOnce()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end

    local function firePromptOnce(obj)
        if obj then
            local prompt = obj:IsA("ProximityPrompt") and obj or obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                prompt.HoldDuration = 0
                pcall(function() fireproximityprompt(prompt) end)
                pressEOnce()
            end
        end
    end

    local function makeAllPromptsInstant()
        pcall(function()
            for _, prompt in ipairs(game.Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then prompt.HoldDuration = 0 end
            end
        end)
    end

    local function hasBoxPiece()
        local found = Player.Backpack:FindFirstChild("Box Piece") or (Player.Character and Player.Character:FindFirstChild("Box Piece"))
        return found ~= nil
    end

    local function resetCharacter()
        if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            Player.Character:BreakJoints()
            Player.CharacterAdded:Wait()
            task.wait(1)
        end
    end

    local function getBestPickaxe()
        local priorities = {"Pickaxe lv3", "Pickaxe lv2", "Pickaxe lv1"}
        for _, name in ipairs(priorities) do
            local tool = Player.Backpack:FindFirstChild(name) or (Player.Character and Player.Character:FindFirstChild(name))
            if tool then return tool end
        end
        return nil
    end

    local function getToolList()
        local list = {"None"}
        for _, t in ipairs(Player.Backpack:GetChildren()) do if t:IsA("Tool") then table.insert(list, t.Name) end end
        if Player.Character then for _, t in ipairs(Player.Character:GetChildren()) do if t:IsA("Tool") and not table.find(list, t.Name) then table.insert(list, t.Name) end end end
        return list
    end

    local function getAllFilteredMobs()
        local mobs = {"None"}
        pcall(function()
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

    local function getMainNPCs()
        local list = {"None"}
        pcall(function()
            local shopFolder = game.Workspace:FindFirstChild("NPC Shop", true)
            if shopFolder then
                for _, v in ipairs(shopFolder:GetChildren()) do
                    if v:IsA("Model") and v.Name ~= "Shop" then table.insert(list, v.Name) end
                end
            end
        end)
        return list
    end

    local function getShopNPCs()
        local list = {"None"}
        pcall(function()
            local shopFolder = game.Workspace:FindFirstChild("Shop", true)
            if shopFolder then
                for _, v in ipairs(shopFolder:GetChildren()) do
                    if v:IsA("Model") then table.insert(list, v.Name) end
                end
            end
        end)
        return list
    end

    local function getIslandList()
        local islands = {"None"}
        pcall(function()
            local mapFolder = game.Workspace:FindFirstChild("Map")
            if mapFolder then
                for _, child in ipairs(mapFolder:GetChildren()) do
                    if child:IsA("Model") then table.insert(islands, child.Name) end
                end
            end
        end)
        return islands
    end

    local function teleportToIsland(name)
        if name == "None" then return end
        local target = game.Workspace:FindFirstChild(name, true)
        if target and Player.Character then Player.Character:PivotTo(target:GetPivot()) end
    end

    local function tweenTo(targetCFrame, speed)
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = Player.Character.HumanoidRootPart
        speed = speed or 60
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local time = distance / speed
        if currentTween then currentTween:Cancel() end
        currentTween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        currentTween:Play()
    end

    task.spawn(function()
        while task.wait(3) do makeAllPromptsInstant() end
    end)

    -- [[ BUILD UI COMPONENTS ]]
    MiningLeft:Dropdown({ Name = "Select Mineral", Options = {"Diamond", "Emerald", "Gold", "Iron", "Coal", "RedStone", "Copper", "Netherite", "Rare Mineral"}, Default = 1, Callback = function(v) selectedMineralVal = v end })
    MiningLeft:Toggle({ Name = "Auto Mine (Selected)", Default = false, Callback = function(v) toggleStates.AutoMineSelected = v end })
    MiningLeft:Toggle({ Name = "Auto Mine (Everything)", Default = false, Callback = function(v) toggleStates.AutoMineAll = v end })

    CombatLeft:Dropdown({ Name = "Select Weapon", Options = getToolList(), Default = 1, Callback = function(v) selectedWeaponVal = v end })
    CombatLeft:Dropdown({ Name = "Select Monster", Options = getAllFilteredMobs(), Default = 1, Callback = function(v) selectedMobVal = v end })
    CombatLeft:Toggle({ Name = "Auto Farm (Tween)", Default = false, Callback = function(v) toggleStates.AutoFarm = v end })
    CombatRight:Toggle({ Name = "Auto Cid (Boss)", Default = false, Callback = function(v) toggleStates.AutoCid = v end })
    CombatRight:Toggle({ Name = "Auto Aizen (Boss)", Default = false, Callback = function(v) toggleStates.AutoAizen = v end })

    DungeonLeft:Dropdown({ Name = "Select Dungeon Weapon", Options = getToolList(), Default = 1, Callback = function(v) dungeonWeaponVal = v end })
    DungeonLeft:Toggle({ Name = "Enable Auto Dungeon", Default = false, Callback = function(v) toggleStates.AutoFarmDungeon = v end })

    RaidLeft:Dropdown({ Name = "Select Raid Weapon", Options = getToolList(), Default = 1, Callback = function(v) raidWeaponVal = v end })
    RaidLeft:Dropdown({ Name = "Select Difficulty", Options = {"Normal", "Hard", "Hell", "Nightmare", "Inferno"}, Default = 1, Callback = function(v) raidDifficultyVal = v end })
    RaidLeft:Toggle({ Name = "Enable Auto Raid", Default = false, Callback = function(v) toggleStates.AutoRaid = v end })

    ExpressLeft:Toggle({ Name = "Auto Express", Default = false, Callback = function(v) toggleStates.AutoExpress = v end })

    TeleportLeft:Dropdown({ Name = "Select Island", Options = getIslandList(), Default = 1, Callback = function(v) teleportToIsland(v) end })
    TeleportLeft:Dropdown({ Name = "Teleport Main NPC", Options = getMainNPCs(), Default = 1, Callback = function(v) if v ~= "None" then local t = game.Workspace:FindFirstChild(v, true) if t then Player.Character:PivotTo(t:GetPivot()) end end end })
    TeleportLeft:Dropdown({ Name = "Teleport Shop NPC", Options = getShopNPCs(), Default = 1, Callback = function(v) if v ~= "None" then local t = game.Workspace:FindFirstChild(v, true) if t then Player.Character:PivotTo(t:GetPivot()) end end end })

    SettingsLeft:Toggle({ Name = "Auto Storage", Default = false, Callback = function(v) toggleStates.AutoStorage = v end })
    SettingsLeft:Toggle({ Name = "Anti-AFK", Default = true, Callback = function(v) toggleStates.AntiAFK = v end })

    SettingsRight:Toggle({ Name = "Keypress Z", Default = false, Callback = function(v) toggleStates.AutoSkill_Z = v end })
    SettingsRight:Toggle({ Name = "Keypress X", Default = false, Callback = function(v) toggleStates.AutoSkill_X = v end })
    SettingsRight:Toggle({ Name = "Keypress C", Default = false, Callback = function(v) toggleStates.AutoSkill_C = v end })
    SettingsRight:Toggle({ Name = "Keypress V", Default = false, Callback = function(v) toggleStates.AutoSkill_V = v end })
    SettingsRight:Toggle({ Name = "Keypress F", Default = false, Callback = function(v) toggleStates.AutoSkill_F = v end })

    -- [[ LOGIC BACKEND LOOPS ]]
    Player.Idled:Connect(function()
        if toggleStates.AntiAFK then
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)

    -- Auto Express Loop
    task.spawn(function()
        while task.wait(0.5) do
            if toggleStates.AutoExpress then
                local thunder = game.Workspace:FindFirstChild("ThunderNPC", true)
                if thunder then tweenTo(thunder:GetPivot(), 60) task.wait(0.4) firePromptOnce(thunder) end
                task.wait(0.4)
                local visualExpress = game.Workspace:FindFirstChild("NpcExpress", true)
                if visualExpress then tweenTo(visualExpress:GetPivot(), 60) task.wait(1.0) pressEOnce() end
                task.wait(0.5)
                for i = 1, 10 do
                    if not toggleStates.AutoExpress then break end
                    local itemNPC = game.Workspace:FindFirstChild("Get itemNPC" .. i, true)
                    if itemNPC then 
                        tweenTo(itemNPC:GetPivot(), 60) task.wait(0.5) firePromptOnce(itemNPC) task.wait(0.3)
                        if hasBoxPiece() then resetCharacter() break end
                    end
                end
            end
        end
    end)

    -- Auto Raid Loop
    task.spawn(function()
        while task.wait(0.3) do
            if toggleStates.AutoRaid then
                pcall(function()
                    if raidStep == 0 then
                        local soonNPC = game.Workspace:FindFirstChild("Dungeon SoonNPC", true)
                        if soonNPC and Player.Character then
                            tweenTo(soonNPC:GetPivot(), 60) task.wait(0.6) firePromptOnce(soonNPC) task.wait(0.5)
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
                                    task.wait(0.5)
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
                raidStep = 0 raidMobTarget = nil
            end
        end
    end)

    -- Target Fetcher Loop (Dungeon, Raid, Boss, Mine, Farm)
    task.spawn(function()
        while task.wait(0.2) do
            if isStoring or toggleStates.AutoExpress then continue end
            mineTarget, bossTarget, mobTarget, dungeonMobTarget = nil, nil, nil, nil
            
            if toggleStates.AutoFarmDungeon then
                pcall(function()
                    local dungeonMap = game.Workspace:FindFirstChild("Dungeon_MAP", true) or game.Workspace:FindFirstChild("TheDungeon", true)
                    if dungeonMap then
                        for _, mob in ipairs(dungeonMap:GetDescendants()) do
                            if mob:IsA("Model") and mob ~= Player.Character then
                                local hum = mob:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then dungeonMobTarget = mob break end
                            end
                        end
                    end
                end)
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
        end
    end)

    -- Movement Heartbeat
    RunService.Heartbeat:Connect(function()
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") or isStoring or toggleStates.AutoExpress then return end
        local target = raidMobTarget or dungeonMobTarget or bossTarget or mobTarget or mineTarget
        if target and target.Parent then
            local hrp = Player.Character.HumanoidRootPart
            local targetPos = target:GetPivot().Position
            tweenTo(CFrame.new(targetPos + Vector3.new(0, 3, 0), targetPos), 60)
            hrp.Velocity = Vector3.zero
            if not hrp:FindFirstChild("StellarAnchor") then 
                local bv = Instance.new("BodyVelocity", hrp); bv.Name = "StellarAnchor"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.zero 
            end
            for _, p in ipairs(Player.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end
        else
            if Player.Character.HumanoidRootPart:FindFirstChild("StellarAnchor") then 
                Player.Character.HumanoidRootPart.StellarAnchor:Destroy() 
            end
        end
    end)

    -- Weapon & Tool Activator
    task.spawn(function()
        while task.wait(0.08) do
            if isStoring or toggleStates.AutoExpress then continue end
            local activeWeaponName = "None"
            if raidMobTarget and toggleStates.AutoRaid then
                activeWeaponName = raidWeaponVal
            elseif dungeonMobTarget and toggleStates.AutoFarmDungeon then
                activeWeaponName = dungeonWeaponVal
            elseif mineTarget then
                local pick = getBestPickaxe()
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
        end
    end)

    -- Safe Anti-Crash Skill Loop
    task.spawn(function()
        local keyMap = {
            AutoSkill_Z = Enum.KeyCode.Z, AutoSkill_X = Enum.KeyCode.X,
            AutoSkill_C = Enum.KeyCode.C, AutoSkill_V = Enum.KeyCode.V,
            AutoSkill_F = Enum.KeyCode.F
        }
        while task.wait(0.8) do
            for optName, keyCode in pairs(keyMap) do
                if toggleStates[optName] then
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                    end)
                    task.wait(0.2)
                end
            end
        end
    end)

    MacLib:Notification({
        Title = "Stellar Hub",
        Content = "Fully Loaded & Toggle Fixed!",
        Duration = 3,
    })
end

-- ========================================
-- KEY SYSTEM GUI (TOP LAYER)
-- ========================================

local function InitializeKeySystem()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeySystemGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999
    screenGui.Parent = CoreGui

    local backdrop = Instance.new("Frame")
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.1
    backdrop.Parent = screenGui

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 420, 0, 500)
    container.Position = UDim2.new(0.5, -210, 0.5, -250)
    container.BackgroundColor3 = Colors.Background
    container.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = container

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "Stellar Hub Authentication"
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = container

    local textInput = Instance.new("TextBox")
    textInput.Size = UDim2.new(1, -60, 0, 50)
    textInput.Position = UDim2.new(0, 30, 0, 120)
    textInput.BackgroundColor3 = Colors.Surface
    textInput.Text = ""
    textInput.PlaceholderText = "Enter key here..."
    textInput.TextColor3 = Colors.TextPrimary
    textInput.PlaceholderColor3 = Colors.TextSecondary
    textInput.TextSize = 16
    textInput.Font = Enum.Font.Gotham
    textInput.Parent = container

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 12)
    inputCorner.Parent = textInput

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(1, -60, 0, 50)
    submitBtn.Position = UDim2.new(0, 30, 0, 200)
    submitBtn.BackgroundColor3 = Colors.Primary
    submitBtn.Text = "Verify Key"
    submitBtn.TextColor3 = Colors.TextPrimary
    submitBtn.TextSize = 16
    submitBtn.Font = Enum.Font.GothamMedium
    submitBtn.Parent = container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = submitBtn

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -60, 0, 40)
    statusLabel.Position = UDim2.new(0, 30, 0, 270)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Colors.Error
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = container

    submitBtn.MouseButton1Click:Connect(function()
        local enteredKey = textInput.Text
        if enteredKey == "" then
            statusLabel.Text = "Please enter a key!"
            return
        end
        statusLabel.TextColor3 = Colors.Success
        statusLabel.Text = "Key Verified! Loading Hub..."
        task.wait(1)
        screenGui:Destroy()
        LaunchMainHub()
    end)
end

InitializeKeySystem()
