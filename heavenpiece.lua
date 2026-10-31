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
-- KEY DATABASE (ตั้งค่าคีย์, เวลา และการล็อกผู้ใช้)
-- ========================================
local KeyDatabase = {
    -- [[ คีย์ฟรี: กำหนดเวลาหมดอายุ (ชม./นาที) และล็อก 1 คน ]]
    FreeKeys = {
        ["FREE-KEY-2HR"] = {
            Hours = 2,
            Minutes = 0,
            FirstUsedTime = nil,
            BoundUserId = nil
        },
        ["FREE-30MINS"] = {
            Hours = 0,
            Minutes = 30,
            FirstUsedTime = nil,
            BoundUserId = nil
        }
    },
    
    -- [[ คีย์ VIP: อินฟินิตี้ตลอดชีพ และล็อก 1 คน ]]
    VipKeys = {
        ["VIP-UNLIMITED-001"] = {
            BoundUserId = nil
        },
        ["VIP-PRO-MASTER"] = {
            BoundUserId = nil
        }
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
    FocusStates = {
        InputFocused = false,
        ButtonHovered = {},
        AnimationsActive = true
    }
}

local UI = {}

-- ========================================
-- MAIN SCRIPT LAUNCHER (MACLIB + FULL FEATURES)
-- ========================================

local function LaunchMainHub()
    local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

    local Window = MacLib:Window({
        Title = "Stellar Hub [ MacLib Edition ]",
        Subtitle = "v51.0 - Top-Layer Key System & Safe Skills",
        Size = UDim2.fromOffset(720, 540),
        DragStyle = 1,
        DisabledWindowControls = {},
        ShowCustomCursor = false,
        KeySystem = false,
    })

    -- [[ CUSTOM TOGGLE BUTTON (Small, Draggable, Transparency 0.7, Text "+") ]]
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
        pcall(function()
            for _, child in ipairs(CoreGui:GetChildren()) do
                if child:IsA("ScreenGui") and child ~= ToggleGui and child:FindFirstChild("Frame", true) then
                    child.Enabled = isOpen
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
            local mod = game.Workspace:FindFirstChild("Mod")
            if mod then
                for _, descendant in ipairs(mod:GetDescendants()) do
                    if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") then
                        if descendant.Name ~= "Npc_Bamboo" and not descendant:IsDescendantOf(mod:FindFirstChild("NPC Shop")) and descendant.Name ~= "NPC Shop" then
                            if not table.find(mobs, descendant.Name) then table.insert(mobs, descendant.Name) end
                        end
                    end
                end
            end
        end)
        return mobs
    end

    local function getMainNPCs()
        local list = {"None"}
        pcall(function()
            for _, v in ipairs(game.Workspace.Mod["NPC Shop"]:GetChildren()) do
                if v:IsA("Model") and v.Name ~= "Shop" then table.insert(list, v.Name) end
            end
        end)
        return list
    end

    local function getShopNPCs()
        local list = {"None"}
        pcall(function()
            local shopFolder = game.Workspace.Mod["NPC Shop"]:FindFirstChild("Shop")
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
        local blackList = {["TimePlayedLeaderboard"] = true, ["cafe2"] = true, ["Room Board"] = true, ["Ocean"] = true, ["Grill"] = true, ["DungeonBoss_MAP"] = true}
        pcall(function()
            local mapFolder = game.Workspace:FindFirstChild("Map")
            if mapFolder then
                for i = 1, 12 do
                    local islandModel = mapFolder:FindFirstChild(tostring(i))
                    if islandModel and islandModel:IsA("Model") then table.insert(islands, islandModel.Name) end
                end
            end
            local modFolder = game.Workspace:FindFirstChild("Mod")
            if modFolder then
                for _, child in ipairs(modFolder:GetChildren()) do
                    if child:IsA("Model") and not blackList[child.Name] then table.insert(islands, child.Name) end
                end
            end
        end)
        return islands
    end

    local function teleportToIsland(name)
        if name == "None" then return end
        local target = game.Workspace.Map:FindFirstChild(name) or game.Workspace.Mod:FindFirstChild(name)
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
    TeleportLeft:Dropdown({ Name = "Teleport Main NPC", Options = getMainNPCs(), Default = 1, Callback = function(v) if v ~= "None" then local t = game.Workspace.Mod["NPC Shop"]:FindFirstChild(v) if t then Player.Character:PivotTo(t:GetPivot()) end end end })
    TeleportLeft:Dropdown({ Name = "Teleport Shop NPC", Options = getShopNPCs(), Default = 1, Callback = function(v) if v ~= "None" then local t = game.Workspace.Mod["NPC Shop"].Shop:FindFirstChild(v) if t then Player.Character:PivotTo(t:GetPivot()) end end end })

    SettingsLeft:Toggle({ Name = "Auto Storage", Default = false, Callback = function(v) toggleStates.AutoStorage = v end })
    SettingsLeft:Toggle({ Name = "Anti-AFK", Default = true, Callback = function(v) toggleStates.AntiAFK = v end })

    SettingsLeft:Slider({
        Name = "UI Size Scale", Min = 0.8, Max = 1.3, Default = 1.0, Precise = 1,
        Callback = function(Value)
            pcall(function()
                for _, child in ipairs(CoreGui:GetChildren()) do
                    if child:IsA("ScreenGui") and child ~= ToggleGui then
                        local mf = child:FindFirstChild("Container") or child:FindFirstChild("Main")
                        if mf then
                            local scale = mf:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", mf)
                            scale.Scale = Value
                        end
                    end
                end
            end)
        end
    })

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

    task.spawn(function()
        while task.wait(0.5) do
            if toggleStates.AutoExpress then
                local thunder = game.Workspace:FindFirstChild("Mod", true) and game.Workspace.Mod:FindFirstChild("NPC Shop", true) and game.Workspace.Mod["NPC Shop"]:FindFirstChild("ThunderNPC", true)
                if thunder then tweenTo(thunder:GetPivot(), 60) task.wait(0.4) firePromptOnce(thunder) end
                task.wait(0.4)
                local visualExpress = game.Workspace:FindFirstChild("Visuals", true) and game.Workspace.Visuals:FindFirstChild("NpcExpress", true)
                if visualExpress then tweenTo(visualExpress:GetPivot(), 60) task.wait(1.0) pressEOnce() end
                task.wait(0.5)
                for i = 1, 10 do
                    if not toggleStates.AutoExpress then break end
                    local itemNPC = game.Workspace:FindFirstChild("Mod", true) and game.Workspace.Mod:FindFirstChild("Get itemNPC" .. i, true)
                    if itemNPC then 
                        tweenTo(itemNPC:GetPivot(), 60) task.wait(0.5) firePromptOnce(itemNPC) task.wait(0.3)
                        if hasBoxPiece() then resetCharacter() break end
                    end
                end
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.3) do
            if toggleStates.AutoRaid then
                pcall(function()
                    if raidStep == 0 then
                        local soonNPC = game.Workspace:FindFirstChild("Mod") and game.Workspace.Mod:FindFirstChild("NPC Shop") and game.Workspace.Mod["NPC Shop"]:FindFirstChild("Dungeon SoonNPC")
                        if soonNPC and Player.Character then
                            tweenTo(soonNPC:GetPivot(), 60) task.wait(0.6) firePromptOnce(soonNPC) task.wait(0.5)
                            raidStep = 1
                        else
                            raidStep = 1
                        end
                    elseif raidStep == 1 then
                        local diff = raidDifficultyVal
                        local guiFrame = Player.PlayerGui:FindFirstChild("DungeonTower Gui") and Player.PlayerGui["DungeonTower Gui"]:FindFirstChild("Main_Frame") and Player.PlayerGui["DungeonTower Gui"].Main_Frame:FindFirstChild("Main_Frame")
                        if guiFrame then
                            local diffFrame = guiFrame:FindFirstChild(diff)
                            if diffFrame then
                                local lockBtn = diffFrame:FindFirstChild("Lock_Button")
                                if lockBtn then
                                    for _, col in ipairs(getconnections(lockBtn.MouseButton1Click or lockBtn.Activated)) do col:Fire() end
                                    task.wait(0.5)
                                end
                            end
                        end
                        raidStep = 2
                    elseif raidStep == 2 then
                        local theDungeon = game.Workspace:FindFirstChild("TheDungeon")
                        local diffFolder = theDungeon and theDungeon:FindFirstChild(raidDifficultyVal)
                        if diffFolder then
                            local rooms = {}
                            for _, child in ipairs(diffFolder:GetChildren()) do
                                if child.Name:find("island") then table.insert(rooms, child) end
                            end
                            table.sort(rooms, function(a, b) return a.Name < b.Name end)
                            for _, room in ipairs(rooms) do
                                local dungeonFolder = room:FindFirstChild("Dungeon")
                                local npcsFolder = room:FindFirstChild("NPCs")
                                if dungeonFolder then
                                    local btnPart = dungeonFolder:FindFirstChild("Buttonpart", true) or dungeonFolder:FindFirstChild("ButtonPart", true)
                                    if btnPart and not pressedButtons[btnPart] then
                                        if Player.Character then
                                            tweenTo(btnPart:GetPivot(), 60) task.wait(0.6) firePromptOnce(btnPart)
                                            pressedButtons[btnPart] = true task.wait(0.5)
                                        end
                                    end
                                    for _, descendant in ipairs(dungeonFolder:GetDescendants()) do
                                        local prompt = descendant:FindFirstChild("DoorPrompt") or (descendant:IsA("ProximityPrompt") and descendant.Name == "DoorPrompt" and descendant)
                                        if prompt then
                                            local doorPart = prompt.Parent
                                            if doorPart and not pressedButtons[prompt] then
                                                if Player.Character then
                                                    local targetPart = doorPart:IsA("BasePart") and doorPart or doorPart:FindFirstChildWhichIsA("BasePart", true)
                                                    if targetPart then
                                                        tweenTo(targetPart:GetPivot(), 60) task.wait(0.6) firePromptOnce(prompt)
                                                        pressedButtons[prompt] = true task.wait(0.5)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if npcsFolder then
                                    local hasBoss = false
                                    for _, mob in ipairs(npcsFolder:GetChildren()) do
                                        if mob:IsA("Model") and mob ~= Player.Character then
                                            local hum = mob:FindFirstChildOfClass("Humanoid")
                                            if hum and hum.Health > 0 then
                                                raidMobTarget = mob
                                                if mob.Name == "AnosBoss" then hasBoss = true end
                                                break
                                            end
                                        end
                                    end
                                    if hasBoss and not raidMobTarget then
                                        resetCharacter() raidStep = 0 pressedButtons = {} break
                                    end
                                end
                                if raidMobTarget then break end
                            end
                        end
                    end
                end)
            else
                raidStep = 0 raidMobTarget = nil
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.2) do
            if isStoring or toggleStates.AutoExpress then continue end
            mineTarget, bossTarget, mobTarget, dungeonMobTarget = nil, nil, nil, nil
            
            if toggleStates.AutoFarmDungeon then
                pcall(function()
                    if not hasPressedMainDoor then
                        local mapFolder = game.Workspace:FindFirstChild("Map")
                        local dungeonDoorFolder = mapFolder and mapFolder:FindFirstChild("DungeonDoor")
                        if dungeonDoorFolder then
                            local doorPart = dungeonDoorFolder:IsA("BasePart") and dungeonDoorFolder or dungeonDoorFolder:FindFirstChildWhichIsA("BasePart", true)
                            if doorPart and Player.Character then
                                tweenTo(doorPart:GetPivot(), 60) task.wait(0.6) firePromptOnce(doorPart) task.wait(0.5)
                                hasPressedMainDoor = true
                            end
                        else
                            hasPressedMainDoor = true
                        end
                    end
                    local mapFolder = game.Workspace:FindFirstChild("Map")
                    local dungeonMap = mapFolder and mapFolder:FindFirstChild("Dungeon_MAP")
                    if dungeonMap then
                        for _, room in ipairs(dungeonMap:GetChildren()) do
                            local npcsFolder = room:FindFirstChild("NPCs")
                            if npcsFolder then
                                for _, mob in ipairs(npcsFolder:GetChildren()) do
                                    if mob:IsA("Model") and mob ~= Player.Character then
                                        local hum = mob:FindFirstChildOfClass("Humanoid")
                                        if hum and hum.Health > 0 then dungeonMobTarget = mob break end
                                    end
                                end
                            end
                            if not dungeonMobTarget then
                                local subFolder = room:FindFirstChild("Dungeon") or room:FindFirstChild("Mod_Dungeon")
                                if subFolder then
                                    local buttonPart = subFolder:FindFirstChild("Buttonpart", true) or subFolder:FindFirstChild("ButtonPart", true)
                                    if buttonPart and not pressedButtons[buttonPart] then
                                        local part = buttonPart:IsA("BasePart") and buttonPart or buttonPart:FindFirstChildWhichIsA("BasePart", true)
                                        if part and Player.Character then
                                            tweenTo(part:GetPivot(), 60) task.wait(0.5) firePromptOnce(part)
                                            pressedButtons[buttonPart] = true task.wait(0.5)
                                        end
                                    end
                                end
                            else
                                break
                            end
                        end
                    end
                end)
            else
                hasPressedMainDoor = false
            end

            if not raidMobTarget and not dungeonMobTarget and toggleStates.AutoCid then 
                bossTarget = game.Workspace:FindFirstChild("CidBoss", true) or game.Workspace:FindFirstChild("Cid", true) 
            end
            if not raidMobTarget and not dungeonMobTarget and toggleStates.AutoAizen and not bossTarget then 
                bossTarget = game.Workspace:FindFirstChild("AizenBoss", true) or game.Workspace:FindFirstChild("Aizen", true) 
            end
            
            if not raidMobTarget and not dungeonMobTarget and not bossTarget and (toggleStates.AutoMineSelected or toggleStates.AutoMineAll) then
                local root = game.Workspace:FindFirstChild("MineralSpawn", true)
                if root then 
                    for _, obj in ipairs(root:GetDescendants()) do 
                        if obj:IsA("Model") and obj.Name ~= "PartSpawn" then 
                            if toggleStates.AutoMineAll or (obj.Name == selectedMineralVal) then 
                                mineTarget = obj; break 
                            end 
                        end 
                    end 
                end
            end

            if not raidMobTarget and not dungeonMobTarget and not bossTarget and not mineTarget and toggleStates.AutoFarm and selectedMobVal ~= "None" then
                local mod = game.Workspace:FindFirstChild("Mod")
                if mod then
                    for _, descendant in ipairs(mod:GetDescendants()) do
                        if descendant:IsA("Model") and descendant.Name == selectedMobVal and descendant.Name ~= "Npc_Bamboo" and not descendant:IsDescendantOf(mod:FindFirstChild("NPC Shop")) then
                            local hum = descendant:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then mobTarget = descendant break end
                        end
                    end
                end
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") or isStoring or toggleStates.AutoExpress then return end
        local target = raidMobTarget or dungeonMobTarget or bossTarget or mobTarget or mineTarget
        if target and target.Parent then
            local hrp = Player.Character.HumanoidRootPart
            if target ~= mineTarget then
                local targetHRP = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head") or target:GetPivot()
                local targetPos = (typeof(targetHRP) == "Instance" and targetHRP:IsA("BasePart")) and targetHRP.Position or target:GetPivot().Position
                tweenTo(CFrame.new(targetPos + Vector3.new(0, 3, 0), targetPos), 60)
            else
                local headTarget = target:FindFirstChild("Head") or target:GetPivot()
                local targetHeadPos = (typeof(headTarget) == "Instance" and headTarget:IsA("BasePart")) and headTarget.Position or target:GetPivot().Position
                tweenTo(CFrame.lookAt(targetHeadPos + Vector3.new(0, 2, 0), targetHeadPos), 40)
            end
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

    -- [[ SAFE ANTI-CRASH SKILL LOOP ]]
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

    task.spawn(function()
        while task.wait(0.8) do
            if toggleStates.AutoStorage then
                local sItem = nil
                for _, t in ipairs(Player.Backpack:GetChildren()) do if t:FindFirstChild("CanStore") then sItem = t; break end end
                if sItem then
                    isStoring = true; Player.Character.Humanoid:UnequipTools(); task.wait(0.5)
                    sItem.Parent = Player.Character; task.wait(0.3); sItem:Activate()
                    pcall(function() local btn = Player.PlayerGui.Gui.ToolCollectUI.Popup.KeepButton if btn.Visible then for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end end end)
                    task.wait(1.5); isStoring = false
                end
            end
        end
    end)

    MacLib:Notification({
        Title = "Stellar Hub",
        Content = "Maclib Loaded Successfully!",
        Duration = 3,
    })
end

-- ========================================
-- KEY SYSTEM GUI & FUNCTIONS (TOP LAYER)
-- ========================================

local function CreateMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeySystemGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999 -- อยู่บนสุดเหนือทุก UI
    screenGui.Parent = CoreGui      -- ดันไปอยู่ชั้น CoreGui เพื่อความชัวร์ว่าทับทุกอย่าง
    UI.ScreenGui = screenGui
    return screenGui
end

local function CreateBackdrop(parent)
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.1
    backdrop.BorderSizePixel = 0
    backdrop.ZIndex = 100
    backdrop.Parent = parent
    UI.Backdrop = backdrop
    return backdrop
end

local function CreateContainer(parent)
    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.new(0, 420, 0, 600)
    container.Position = UDim2.new(0.5, -210, 0.5, -300)
    container.BackgroundColor3 = Colors.Background
    container.BorderSizePixel = 0
    container.ZIndex = 110
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = container
    
    UI.Container = container
    return container
end

local function CreateAnimatedBorder(parent)
    local border = Instance.new("Frame")
    border.Name = "AnimatedBorder"
    border.Size = UDim2.new(1, 6, 1, 6)
    border.Position = UDim2.new(0, -3, 0, -3)
    border.BackgroundTransparency = 1
    border.ZIndex = 109
    border.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 23)
    corner.Parent = border
    
    local stroke = Instance.new("UIStroke")  
    stroke.Color = Colors.NeonWhite
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = border
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.NeonWhite),
        ColorSequenceKeypoint.new(0.5, Colors.NeonGlow),
        ColorSequenceKeypoint.new(1, Colors.NeonWhite)
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.2, 0.1),
        NumberSequenceKeypoint.new(0.8, 0.1),
        NumberSequenceKeypoint.new(1, 0.9)
    }
    gradient.Parent = stroke
    
    UI.AnimatedBorder = {Frame = border, Gradient = gradient, Stroke = stroke}
    return border
end

local function CreateHeader(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 100)
    header.BackgroundTransparency = 1
    header.ZIndex = 11
    header.Parent = parent
    
    local iconContainer = Instance.new("Frame")
    iconContainer.Size = UDim2.new(0, 56, 0, 56)
    iconContainer.Position = UDim2.new(0.5, -28, 0, 24)
    iconContainer.BackgroundColor3 = Colors.Primary
    iconContainer.BorderSizePixel = 0
    iconContainer.ZIndex = 12
    iconContainer.Parent = header
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 14)
    iconCorner.Parent = iconContainer
    
    local iconImage = Instance.new("ImageLabel")
    iconImage.Size = UDim2.new(0.8, 0, 0.8, 0)
    iconImage.Position = UDim2.new(0.1, 0, 0.1, 0)
    iconImage.BackgroundTransparency = 1
    iconImage.Image = "rbxassetid://95233466475324"
    iconImage.ImageColor3 = Colors.NeonWhite
    iconImage.ImageTransparency = 0.1
    iconImage.ScaleType = Enum.ScaleType.Fit
    iconImage.ZIndex = 13
    iconImage.Parent = iconContainer
    
    UI.Header = {Container = header}
    return header
end

local function CreateContent(parent)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -64, 0, 440)
    content.Position = UDim2.new(0, 32, 0, 120)
    content.BackgroundTransparency = 1
    content.ZIndex = 11
    content.Parent = parent
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundTransparency = 1
    title.Text = "Stellar Hub Authentication"
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 12
    title.Parent = content
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 40)
    subtitle.Position = UDim2.new(0, 0, 0, 36)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Enter Free Key (Timed/1-User) or VIP Key (Infinite/1-User)"
    subtitle.TextColor3 = Colors.TextSecondary
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.TextWrapped = true
    subtitle.ZIndex = 12
    subtitle.Parent = content
    
    UI.Content = content
    return content
end

local function CreateInputSection(parent)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 100)
    section.Position = UDim2.new(0, 0, 0, 100)
    section.BackgroundTransparency = 1
    section.ZIndex = 12
    section.Parent = parent
    
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, 0, 0, 52)
    inputContainer.BackgroundColor3 = Colors.Surface
    inputContainer.BorderSizePixel = 0
    inputContainer.ZIndex = 13
    inputContainer.Parent = section
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = inputContainer
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = inputContainer
    
    local textInput = Instance.new("TextBox")
    textInput.Size = UDim2.new(1, -24, 1, 0)
    textInput.Position = UDim2.new(0, 12, 0, 0)
    textInput.BackgroundTransparency = 1
    textInput.Text = ""
    textInput.PlaceholderText = "Enter key here..."
    textInput.TextColor3 = Colors.TextPrimary
    textInput.PlaceholderColor3 = Colors.TextSecondary
    textInput.TextSize = 16
    textInput.Font = Enum.Font.Gotham
    textInput.TextXAlignment = Enum.TextXAlignment.Left
    textInput.ClearTextOnFocus = false
    textInput.ZIndex = 14
    textInput.Parent = inputContainer
    
    local charCounter = Instance.new("TextLabel")
    charCounter.Size = UDim2.new(0, 80, 0, 20)
    charCounter.Position = UDim2.new(1, -85, 0, 60)
    charCounter.BackgroundTransparency = 1
    charCounter.Text = "0/" .. Config.MaxKeyLength
    charCounter.TextColor3 = Colors.TextSecondary
    charCounter.TextSize = 12
    charCounter.Font = Enum.Font.Gotham
    charCounter.TextXAlignment = Enum.TextXAlignment.Right
    charCounter.ZIndex = 13
    charCounter.Parent = section
    
    UI.Input = {
        Container = inputContainer,
        TextBox = textInput,
        Counter = charCounter,
        Stroke = stroke
    }
    
    return section
end

local function CreateButtons(parent)
    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(1, 0, 0, 48)
    submitButton.Position = UDim2.new(0, 0, 0, 200)
    submitButton.BackgroundColor3 = Colors.Primary
    submitButton.BorderSizePixel = 0
    submitButton.Text = "Verify Key"
    submitButton.TextColor3 = Colors.TextPrimary
    submitButton.TextSize = 16
    submitButton.Font = Enum.Font.GothamMedium
    submitButton.ZIndex = 13
    submitButton.Parent = parent
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 12)
    submitCorner.Parent = submitButton
    
    local loadingContainer = Instance.new("Frame")
    loadingContainer.Size = UDim2.new(0, 24, 0, 24)
    loadingContainer.Position = UDim2.new(0.5, -12, 0, 12)
    loadingContainer.BackgroundTransparency = 1
    loadingContainer.Visible = false
    loadingContainer.ZIndex = 14
    loadingContainer.Parent = submitButton
    
    local spinner = Instance.new("Frame")
    spinner.Size = UDim2.new(1, 0, 1, 0)
    spinner.BackgroundColor3 = Colors.TextPrimary
    spinner.BorderSizePixel = 0
    spinner.ZIndex = 15
    spinner.Parent = loadingContainer
    
    local spinnerCorner = Instance.new("UICorner")
    spinnerCorner.CornerRadius = UDim.new(1, 0)
    spinnerCorner.Parent = spinner
    
    local spinnerGradient = Instance.new("UIGradient")
    spinnerGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.8, 0.8),
        NumberSequenceKeypoint.new(1, 1)
    }
    spinnerGradient.Parent = spinner
    
    local buttonsContainer = Instance.new("Frame")
    buttonsContainer.Size = UDim2.new(1, 0, 0, 48)
    buttonsContainer.Position = UDim2.new(0, 0, 0, 260)
    buttonsContainer.BackgroundTransparency = 1
    buttonsContainer.ZIndex = 12
    buttonsContainer.Parent = parent
    
    local getKeyButton = Instance.new("TextButton")
    getKeyButton.Size = UDim2.new(0.48, 0, 1, 0)
    getKeyButton.BackgroundColor3 = Colors.GetKey
    getKeyButton.BorderSizePixel = 0
    getKeyButton.Text = "Get Free Key"
    getKeyButton.TextColor3 = Colors.TextPrimary
    getKeyButton.TextSize = 14
    getKeyButton.Font = Enum.Font.GothamMedium
    getKeyButton.ZIndex = 13
    getKeyButton.Parent = buttonsContainer
    
    local getKeyCorner = Instance.new("UICorner")
    getKeyCorner.CornerRadius = UDim.new(0, 10)
    getKeyCorner.Parent = getKeyButton
    
    local discordButton = Instance.new("TextButton")
    discordButton.Size = UDim2.new(0.48, 0, 1, 0)
    discordButton.Position = UDim2.new(0.52, 0, 0, 0)
    discordButton.BackgroundColor3 = Colors.Discord
    discordButton.BorderSizePixel = 0
    discordButton.Text = "Discord / VIP"
    discordButton.TextColor3 = Colors.TextPrimary
    discordButton.TextSize = 14
    discordButton.Font = Enum.Font.GothamMedium
    discordButton.ZIndex = 13
    discordButton.Parent = buttonsContainer
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 10)
    discordCorner.Parent = discordButton
    
    UI.Buttons = {
        Submit = submitButton,
        GetKey = getKeyButton,
        Discord = discordButton,
        Loading = {Container = loadingContainer, Spinner = spinner}
    }
    
    return {submitButton, getKeyButton, discordButton}
end

local function CreateStatus(parent)
    local statusContainer = Instance.new("Frame")
    statusContainer.Size = UDim2.new(1, 0, 0, 60)
    statusContainer.Position = UDim2.new(0, 0, 0, 330)
    statusContainer.BackgroundTransparency = 1
    statusContainer.ZIndex = 12
    statusContainer.Parent = parent
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Colors.Error
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.TextWrapped = true
    statusLabel.ZIndex = 13
    statusLabel.Parent = statusContainer
    
    UI.Status = statusLabel
    return statusLabel
end

local function CreateParticleContainer(parent)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ZIndex = 105
    container.Parent = parent
    UI.ParticleContainer = container
    return container
end

local function CreateParticle()
    if not UI.ParticleContainer or not UI.ParticleContainer.Parent or State.IsDestroyed then return nil end
    local size = math.random(8, 24)
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, size, 0, size)
    particle.Position = UDim2.new(math.random() * 1.4 - 0.2, 0, 1.2, 0)
    particle.BackgroundColor3 = Colors.NeonWhite
    particle.BackgroundTransparency = math.random(60, 85) / 100
    particle.BorderSizePixel = 0
    particle.ZIndex = 106
    particle.Parent = UI.ParticleContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    local particleData = {
        frame = particle,
        vx = (math.random() - 0.5) * 0.004,
        vy = -math.random(20, 50) / 10000,
        created = tick(),
        lifetime = math.random(30, 60)
    }
    table.insert(State.Particles, particleData)
    return particle
end

local function UpdateParticles()
    if State.IsDestroyed or not UI.ParticleContainer then return end
    for i = #State.Particles, 1, -1 do
        local p = State.Particles[i]
        if not p or not p.frame or not p.frame.Parent then
            table.remove(State.Particles, i)
        else
            local currentPos = p.frame.Position
            local age = tick() - p.created
            if currentPos.Y.Scale < -0.3 or age > p.lifetime then
                p.frame:Destroy()
                table.remove(State.Particles, i)
            else
                p.frame.Position = UDim2.new(currentPos.X.Scale + p.vx, 0, currentPos.Y.Scale + p.vy, 0)
            end
        end
    end
end

local function ShowStatus(message, isError, isSuccess)
    if not UI.Status then return end
    UI.Status.Text = message
    if isSuccess then
        UI.Status.TextColor3 = Colors.Success
    elseif isError then
        UI.Status.TextColor3 = Colors.Error
    else
        UI.Status.TextColor3 = Colors.Warning
    end
end

local function SetLoading(isLoading)
    State.IsLoading = isLoading
    if not UI.Buttons then return end
    UI.Buttons.Loading.Container.Visible = isLoading
    UI.Buttons.Submit.Text = isLoading and "" or "Verify Key"
    if isLoading then
        local tween = Services.TweenService:Create(UI.Buttons.Loading.Spinner, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
        tween:Play()
        State.Animations.SpinTween = tween
    else
        if State.Animations.SpinTween then State.Animations.SpinTween:Cancel() end
    end
end

-- ========================================
-- VERIFICATION SYSTEM LOGIC (TIMED & BOUND)
-- ========================================

local function VerifyKeyInput()
    local enteredKey = UI.Input.TextBox.Text
    local currentUserId = Player.UserId
    local currentTime = os.time()

    if enteredKey == "" then
        ShowStatus("Please enter an access key!", true)
        return
    end

    SetLoading(true)
    ShowStatus("Validating key...", false, false)

    task.spawn(function()
        task.wait(1.5)
        SetLoading(false)

        -- 1. ตรวจสอบคีย์ VIP (Inf + ล็อกคนเดียว)
        if KeyDatabase.VipKeys[enteredKey] then
            local vipData = KeyDatabase.VipKeys[enteredKey]
            if vipData.BoundUserId == nil then
                vipData.BoundUserId = currentUserId
            elseif vipData.BoundUserId ~= currentUserId then
                ShowStatus("This VIP key is already used by another user!", true)
                return
            end

            ShowStatus("VIP Key Accepted! Loading Hub...", false, true)
            task.wait(1)
            UI.ScreenGui:Destroy()
            State.IsDestroyed = true
            LaunchMainHub()
            return
        end

        -- 2. ตรวจสอบคีย์ FREE (จำกัดเวลา + ล็อกคนเดียว)
        if KeyDatabase.FreeKeys[enteredKey] then
            local freeData = KeyDatabase.FreeKeys[enteredKey]
            if freeData.BoundUserId == nil then
                freeData.BoundUserId = currentUserId
            elseif freeData.BoundUserId ~= currentUserId then
                ShowStatus("This Free key is already used by another user!", true)
                return
            end

            local durationInSeconds = (freeData.Hours * 3600) + (freeData.Minutes * 60)
            if freeData.FirstUsedTime == nil then
                freeData.FirstUsedTime = currentTime
            end

            local elapsedTime = currentTime - freeData.FirstUsedTime
            local remainingTime = durationInSeconds - elapsedTime

            if remainingTime <= 0 then
                ShowStatus("This Free Key has expired!", true)
            else
                local remHours = math.floor(remainingTime / 3600)
                local remMins = math.floor((remainingTime % 3600) / 60)
                ShowStatus(string.format("Success! Time left: %dh %dm", remHours, remMins), false, true)
                task.wait(1.2)
                UI.ScreenGui:Destroy()
                State.IsDestroyed = true
                LaunchMainHub()
            end
            return
        end

        ShowStatus("Invalid Key! Please check and try again.", true)
    end)
end

local function ConnectEvents()
    UI.Input.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        if string.len(UI.Input.TextBox.Text) > Config.MaxKeyLength then
            UI.Input.TextBox.Text = string.sub(UI.Input.TextBox.Text, 1, Config.MaxKeyLength)
        end
        UI.Input.Counter.Text = string.len(UI.Input.TextBox.Text) .. "/" .. Config.MaxKeyLength
    end)
    
    UI.Buttons.Submit.MouseButton1Click:Connect(function()
        if not State.IsLoading then VerifyKeyInput() end
    end)
    
    UI.Buttons.GetKey.MouseButton1Click:Connect(function()
        ShowStatus("Free key link copied!", false, true)
        pcall(function() setclipboard("https://your-free-key-link.com") end)
    end)
    
    UI.Buttons.Discord.MouseButton1Click:Connect(function()
        ShowStatus("Discord link copied!", false, true)
        pcall(function() setclipboard("https://discord.gg/your-invite") end)
    end)
end

local function StartAnimationLoops()
    task.spawn(function()
        for i = 1, 25 do
            if State.IsDestroyed then break end
            CreateParticle()
            task.wait(0.05)
        end
        while not State.IsDestroyed and UI.ScreenGui.Parent do
            if #State.Particles < Config.ParticleCount then CreateParticle() end
            task.wait(0.8)
        end
    end)
    task.spawn(function()
        while not State.IsDestroyed and UI.ScreenGui.Parent do
            pcall(UpdateParticles)
            task.wait(1/Config.ParticleSpeed)
        end
    end)
end

local function InitializeKeySystem()
    local screenGui = CreateMainGUI()
    local backdrop = CreateBackdrop(screenGui)
    CreateParticleContainer(backdrop)
    local container = CreateContainer(screenGui)
    CreateAnimatedBorder(container)
    CreateHeader(container)
    local content = CreateContent(container)
    CreateInputSection(content)
    CreateButtons(content)
    CreateStatus(content)
    
    ConnectEvents()
    StartAnimationLoops()
    
    UI.Container.Size = UDim2.new(0, 0, 0, 0)
    UI.Container.BackgroundTransparency = 1
    backdrop.BackgroundTransparency = 1
    Services.TweenService:Create(backdrop, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    task.wait(0.1)
    Services.TweenService:Create(UI.Container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 420, 0, 600), BackgroundTransparency = 0}):Play()
end

-- ========================================
-- RUN KEY SYSTEM INITIALIZATION
-- ========================================
InitializeKeySystem()
