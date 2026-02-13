-- Ultimate Blox Fruits Script - Phiên bản đầy đủ
-- Tính năng: Auto Farm, Teleport, Raid, Aim Chiêu, UI hiện đại với Avatar

-- Dịch vụ cần thiết
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Cấu hình chính
local Config = {
    -- Auto Farm
    AutoFarm = false,
    AutoQuest = false,
    MobAura = false,
    BringMobs = false,
    UseSkills = true,
    SafeMode = true,
    
    -- Combat
    AttackRange = 20,
    BringRange = 30,
    AimbotEnabled = false,
    AimbotRange = 100,
    AutoSkills = true,
    
    -- Delays (ms)
    QuestDelay = {min = 1500, max = 3000},
    MoveDelay = {min = 300, max = 800},
    AttackDelay = {min = 200, max = 400},
    SkillDelay = {min = 2000, max = 4000},
    
    -- Raid
    AutoRaid = false,
    AutoBuyChip = false,
    RaidDifficulty = "Normal",
    
    -- UI
    Minimized = false
}

-- Dữ liệu nhiệm vụ theo cấp độ
local QuestData = {
    [1] = {npc = "BanditQuestGiver", enemy = "Bandit", level = 1, location = CFrame.new(1061.66, 16.52, 1548.27)},
    [10] = {npc = "MonkeyQuestGiver", enemy = "Monkey", level = 10, location = CFrame.new(-1448.52, 37.88, 32.88)},
    [30] = {npc = "GorillaQuestGiver", enemy = "Gorilla", level = 30, location = CFrame.new(-1245.28, 6.61, -534.68)},
    [50] = {npc = "PirateQuestGiver", enemy = "Pirate", level = 50, location = CFrame.new(-1139.59, 4.75, 3850.81)},
    [70] = {npc = "MarineQuestGiver", enemy = "Marine", level = 70, location = CFrame.new(-2715.94, 24.61, 2023.58)},
    [100] = {npc = "DesertQuestGiver", enemy = "Desert Bandit", level = 100, location = CFrame.new(937.03, 6.45, 4339.86)},
    [150] = {npc = "SnowQuestGiver", enemy = "Snow Bandit", level = 150, location = CFrame.new(1384.68, 87.27, -1298.81)},
    [200] = {npc = "SkyQuestGiver", enemy = "Sky Bandit", level = 200, location = CFrame.new(-4867.23, 733.16, -2667.45)}
}

-- Dữ liệu teleport các đảo
local IslandLocations = {
    ["Sea 1"] = {
        ["Starter Island"] = CFrame.new(1071.29, 16.52, 1421.47),
        ["Marine Fortress"] = CFrame.new(-2795.84, 72.99, -357.68),
        ["Middle Town"] = CFrame.new(-672.73, 15.09, 576.46),
        ["Jungle"] = CFrame.new(-1248.43, 11.88, 341.35),
        ["Pirate Village"] = CFrame.new(-1122.65, 4.79, 3856.16),
        ["Desert"] = CFrame.new(1094.91, 6.44, 4192.89),
        ["Snow Island"] = CFrame.new(1345.23, 87.27, -1385.34),
        ["MarineFord"] = CFrame.new(-2713.74, 24.61, 2023.58),
        ["Colosseum"] = CFrame.new(-1425.85, 7.39, -2994.84)
    },
    ["Sea 2"] = {
        ["Kingdom of Rose"] = CFrame.new(-392.38, 122.53, 1266.71),
        ["Dark Arena"] = CFrame.new(3780.03, 16.68, -7363.35),
        ["Mansion"] = CFrame.new(-12463.67, 374.68, -7564.92),
        ["Flamingo Mansion"] = CFrame.new(-4867.23, 733.16, -2667.45),
        ["Green Zone"] = CFrame.new(-2372.86, 3.89, -2164.29),
        ["Cafe"] = CFrame.new(-385.26, 73.05, 297.68),
        ["Graveyard"] = CFrame.new(-5684.64, 487.54, -765.23)
    },
    ["Sea 3"] = {
        ["Port Town"] = CFrame.new(-610.47, 15.34, 6742.73),
        ["Hydra Island"] = CFrame.new(5229.99, 7.44, 1100.03),
        ["Castle on the Sea"] = CFrame.new(-5477.39, 313.76, -2813.94),
        ["Great Tree"] = CFrame.new(2179.95, 28.73, -6740.64),
        ["Floating Turtle"] = CFrame.new(-13274.53, 323.24, -8323.06),
        ["Haunted Castle"] = CFrame.new(-9515.37, 142.14, 5533.23),
        ["Peanut Island"] = CFrame.new(-2062.79, 36.85, -10240.81),
        ["Ice Cream Island"] = CFrame.new(-819.38, 65.84, -10965.79)
    }
}

-- Biến trạng thái
local currentQuest = nil
local currentTarget = nil
local isAttacking = false
local lastActionTime = 0
local lastSkillTime = 0
local raidActive = false
local aimbotTarget = nil

-- === HÀM TIỆN ÍCH ===

-- Lấy delay ngẫu nhiên để tránh bị ban
local function getRandomDelay(minDelay, maxDelay)
    return math.random(minDelay, maxDelay) / 1000
end

-- Wait an toàn với delay ngẫu nhiên
local function safeWait(minDelay, maxDelay)
    local delay = getRandomDelay(minDelay, maxDelay)
    if Config.SafeMode then
        wait(delay)
    else
        wait(minDelay / 1000)
    end
end

-- Lấy cấp độ người chơi
local function getPlayerLevel()
    local stats = player:FindFirstChild("Stats")
    if stats and stats:FindFirstChild("Level") then
        return stats.Level.Value
    end
    return 1
end

-- Teleport mượt mà
local function smoothTeleport(position)
    local tweenInfo = TweenInfo.new(
        getRandomDelay(Config.MoveDelay.min, Config.MoveDelay.max),
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(character.HumanoidRootPart, tweenInfo, {
        CFrame = position
    })
    tween:Play()
    tween.Completed:Wait()
end

-- Tìm NPC nhiệm vụ
local function findQuestNPC(npcName)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == npcName and obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
            return obj
        end
    end
    return nil
end

-- === AUTO FARM ===

-- Nhận nhiệm vụ tự động
local function acceptQuest(questData)
    local npc = findQuestNPC(questData.npc)
    if not npc then return false end
    
    -- Teleport đến NPC
    smoothTeleport(questData.location)
    safeWait(Config.QuestDelay.min, Config.QuestDelay.max)
    
    -- Nhận nhiệm vụ
    fireclickdetector(npc:FindFirstChildOfClass("ClickDetector"))
    
    -- Phương pháp thay thế: sử dụng remote events
    local questRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Quests")
    if questRemote then
        pcall(function()
            questRemote:InvokeServer("AcceptQuest", questData.npc)
        end)
    end
    
    currentQuest = questData
    return true
end

-- Tìm kẻ địch trong phạm vi
local function findEnemies(enemyName, range)
    local enemies = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(obj.Name, enemyName) and obj:FindFirstChild("Humanoid") then
            local humanoid = obj.Humanoid
            if humanoid.Health > 0 then
                local distance = (character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude
                if distance <= range then
                    table.insert(enemies, {model = obj, distance = distance})
                end
            end
        end
    end
    
    -- Sắp xếp theo khoảng cách
    table.sort(enemies, function(a, b) return a.distance < b.distance end)
    return enemies
end

-- Gom quái về gần người chơi
local function bringMobs()
    if not Config.BringMobs then return end
    
    local enemies = findEnemies(currentQuest.enemy, Config.BringRange)
    for _, enemy in pairs(enemies) do
        local targetPos = character.HumanoidRootPart.Position + Vector3.new(
            math.random(-5, 5),
            0,
            math.random(-5, 5)
        )
        
        if enemy.model:FindFirstChild("HumanoidRootPart") then
            enemy.model.HumanoidRootPart.CFrame = CFrame.new(targetPos)
        end
    end
end

-- === AIM CHIÊU ===

-- Tìm mục tiêu gần nhất cho aimbot
local function findAimbotTarget()
    local nearestTarget = nil
    local shortestDistance = Config.AimbotRange
    
    -- Tìm kẻ địch
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local humanoid = obj.Humanoid
            if humanoid.Health > 0 and obj ~= character then
                local distance = (character.HumanoidRootPart.Position - obj.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestTarget = obj
                end
            end
        end
    end
    
    return nearestTarget
end

-- Tự động nhắm mục tiêu
local function updateAimbot()
    if not Config.AimbotEnabled then
        aimbotTarget = nil
        return
    end
    
    aimbotTarget = findAimbotTarget()
    if aimbotTarget and aimbotTarget:FindFirstChild("HumanoidRootPart") then
        -- Sử dụng Mouse.Hit.p để điều hướng chính xác
        local targetPos = aimbotTarget.HumanoidRootPart.Position
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPos)
    end
end

-- Tung chiêu thức tự động vào mục tiêu
local function autoCastSkills()
    if not Config.AutoSkills or not aimbotTarget then return end
    
    if (tick() - lastSkillTime) < getRandomDelay(Config.SkillDelay.min, Config.SkillDelay.max) then
        return
    end
    
    local skills = {"Z", "X", "C", "V"}
    for _, skill in pairs(skills) do
        local skillRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Skills")
        if skillRemote then
            pcall(function()
                -- Sử dụng Mouse.Hit.p để điều hướng chiêu thức
                local targetPos = aimbotTarget.HumanoidRootPart.Position
                skillRemote:FireServer("UseSkill", skill, targetPos)
            end)
        end
    end
    
    lastSkillTime = tick()
end

-- Tấn công kẻ địch
local function attackEnemy(enemy)
    if not enemy or not enemy:FindFirstChild("Humanoid") or enemy.Humanoid.Health <= 0 then
        return false
    end
    
    -- Di chuyển đến vị trí tấn công
    local attackPos = enemy.PrimaryPart.Position + Vector3.new(0, 5, 0)
    character.HumanoidRootPart.CFrame = CFrame.new(attackPos)
    
    -- Tấn công với Magical Melee
    local combatRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Combat")
    if combatRemote then
        pcall(function()
            combatRemote:FireServer("MouseClick", enemy.HumanoidRootPart)
        end)
    end
    
    -- Click chuột ảo
    VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    safeWait(Config.AttackDelay.min, Config.AttackDelay.max)
    VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    
    return true
end

-- Mob Aura - Tấn công tất cả kẻ địch trong phạm vi
local function mobAura()
    if not Config.MobAura then return end
    
    local enemies = findEnemies(currentQuest.enemy, Config.AttackRange)
    for _, enemy in pairs(enemies) do
        if enemy.distance <= Config.AttackRange then
            pcall(function()
                attackEnemy(enemy.model)
            end)
        end
    end
end

-- === TELEPORT ===

-- Teleport đến đảo
local function teleportToIsland(sea, islandName)
    if IslandLocations[sea] and IslandLocations[sea][islandName] then
        smoothTeleport(IslandLocations[sea][islandName])
        return true
    end
    return false
end

-- === RAID ===

-- Mua chip Raid tự động
local function buyRaidChip()
    if not Config.AutoBuyChip then return false end
    
    -- Tìm NPC bán chip Raid
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "RaidChip" or obj.Name == "Microchip" then
            -- Mua chip (cần điều chỉnh theo game cụ thể)
            fireclickdetector(obj:FindFirstChildOfClass("ClickDetector"))
            return true
        end
    end
    return false
end

-- Bắt đầu Raid tự động
local function startRaid()
    if raidActive then return end
    
    if buyRaidChip() then
        -- Tìm phòng Raid
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "RaidPortal" or obj.Name == "RaidEntrance" then
                smoothTeleport(obj.CFrame)
                fireclickdetector(obj:FindFirstChildOfClass("ClickDetector"))
                raidActive = true
                return true
            end
        end
    end
    return false
end

-- Tự động tiêu diệt quái trong Raid
local function autoRaidFarm()
    if not raidActive or not Config.AutoRaid then return end
    
    -- Tìm quái Raid
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (string.find(obj.Name, "Raid") or string.find(obj.Name, "Boss")) then
            if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                -- Tấn công boss Raid
                local distance = (character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude
                if distance <= Config.AttackRange then
                    attackEnemy(obj)
                    autoCastSkills()
                end
            end
        end
    end
end

-- === CHÍNH AUTO FARM ===

-- Hàm Auto Farm chính
local function autoFarm()
    if not Config.AutoFarm then return end
    
    -- Nhận nhiệm vụ nếu cần
    if Config.AutoQuest and not currentQuest then
        local level = getPlayerLevel()
        local appropriateQuest = nil
        
        for questLevel, questData in pairs(QuestData) do
            if level >= questLevel then
                appropriateQuest = questData
            else
                break
            end
        end
        
        if appropriateQuest then
            acceptQuest(appropriateQuest)
        end
    end
    
    -- Farm quái
    if currentQuest then
        bringMobs()
        mobAura()
        
        -- Tìm và tấn công quái gần nhất
        local enemies = findEnemies(currentQuest.enemy, Config.AttackRange)
        if #enemies > 0 and not isAttacking then
            isAttacking = true
            currentTarget = enemies[1].model
            
            local success = pcall(function()
                attackEnemy(currentTarget)
            end)
            
            if not success or currentTarget.Humanoid.Health <= 0 then
                isAttacking = false
                currentTarget = nil
            end
        end
    end
end

-- === GIAO DIỆN UI ===

-- Tạo avatar người chơi
local function createPlayerAvatar()
    local userId = player.UserId
    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
    return avatarUrl
end

-- Tạo cửa sổ chính
local Window = Rayfield:CreateWindow({
    Name = "🍊 Ultimate Blox Fruits",
    LoadingTitle = "Đang tải script...",
    LoadingSubtitle = "Phiên bản Pro",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BloxFruitsUltimate",
        FileName = "UltimateConfig"
    }
})

-- Tab Auto Farm
local FarmTab = Window:CreateTab("🚜 Auto Farm", 4483362458)

-- Section Auto Farm
local FarmSection = FarmTab:CreateSection("Cài đặt Auto Farm")

FarmTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        Config.AutoFarm = Value
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Quest",
    CurrentValue = false,
    Flag = "AutoQuest",
    Callback = function(Value)
        Config.AutoQuest = Value
    end,
})

-- Section Combat
local CombatSection = FarmTab:CreateSection("Cài đặt Combat")

FarmTab:CreateToggle({
    Name = "Mob Aura",
    CurrentValue = false,
    Flag = "MobAura",
    Callback = function(Value)
        Config.MobAura = Value
    end,
})

FarmTab:CreateToggle({
    Name = "Bring Mobs",
    CurrentValue = false,
    Flag = "BringMobs",
    Callback = function(Value)
        Config.BringMobs = Value
    end,
})

FarmTab:CreateSlider({
    Name = "Attack Range",
    Range = {10, 50},
    Increment = 5,
    CurrentValue = 20,
    Flag = "AttackRange",
    Callback = function(Value)
        Config.AttackRange = Value
    end,
})

-- Tab Teleport
local TeleportTab = Window:CreateTab("🌍 Teleport", 4483362458)

-- Tạo dropdown cho Sea 1
local Sea1Dropdown = TeleportTab:CreateDropdown({
    Name = "Sea 1 Islands",
    Options = {"Starter Island", "Marine Fortress", "Middle Town", "Jungle", "Pirate Village", "Desert", "Snow Island", "MarineFord", "Colosseum"},
    CurrentOption = "Starter Island",
    Flag = "Sea1Island",
    Callback = function(Option)
        teleportToIsland("Sea 1", Option)
    end,
})

-- Tạo dropdown cho Sea 2
local Sea2Dropdown = TeleportTab:CreateDropdown({
    Name = "Sea 2 Islands",
    Options = {"Kingdom of Rose", "Dark Arena", "Mansion", "Flamingo Mansion", "Green Zone", "Cafe", "Graveyard"},
    CurrentOption = "Kingdom of Rose",
    Flag = "Sea2Island",
    Callback = function(Option)
        teleportToIsland("Sea 2", Option)
    end,
})

-- Tạo dropdown cho Sea 3
local Sea3Dropdown = TeleportTab:CreateDropdown({
    Name = "Sea 3 Islands",
    Options = {"Port Town", "Hydra Island", "Castle on the Sea", "Great Tree", "Floating Turtle", "Haunted Castle", "Peanut Island", "Ice Cream Island"},
    CurrentOption = "Port Town",
    Flag = "Sea3Island",
    Callback = function(Option)
        teleportToIsland("Sea 3", Option)
    end,
})

-- Tab Raid
local RaidTab = Window:CreateTab("⚔️ Raid", 4483362458)

local RaidSection = RaidTab:CreateSection("Cài đặt Raid")

RaidTab:CreateToggle({
    Name = "Auto Raid",
    CurrentValue = false,
    Flag = "AutoRaid",
    Callback = function(Value)
        Config.AutoRaid = Value
        if Value then
            startRaid()
        end
    end,
})

RaidTab:CreateToggle({
    Name = "Auto Buy Chip",
    CurrentValue = false,
    Flag = "AutoBuyChip",
    Callback = function(Value)
        Config.AutoBuyChip = Value
    end,
})

-- Tab Aim Chiêu
local AimTab = Window:CreateTab("🎯 Aim Chiêu", 4483362458)

local AimSection = AimTab:CreateSection("Cài đặt Aimbot")

AimTab:CreateToggle({
    Name = "Aimbot (Khóa mục tiêu)",
    CurrentValue = false,
    Flag = "AimbotEnabled",
    Callback = function(Value)
        Config.AimbotEnabled = Value
    end,
})

AimTab:CreateToggle({
    Name = "Auto Skills (Z, X, C, V)",
    CurrentValue = true,
    Flag = "AutoSkills",
    Callback = function(Value)
        Config.AutoSkills = Value
    end,
})

AimTab:CreateSlider({
    Name = "Aimbot Range",
    Range = {50, 200},
    Increment = 10,
    CurrentValue = 100,
    Flag = "AimbotRange",
    Callback = function(Value)
        Config.AimbotRange = Value
    end,
})

-- Tab Settings
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

local SettingsSection = SettingsTab:CreateSection("Cài đặt chung")

SettingsTab:CreateToggle({
    Name = "Safe Mode (Chống ban)",
    CurrentValue = true,
    Flag = "SafeMode",
    Callback = function(Value)
        Config.SafeMode = Value
    end,
})

-- Hiển thị thông tin người chơi
local InfoSection = SettingsTab:CreateSection("Thông tin")

SettingsTab:CreateLabel("Tên: " .. player.Name)
SettingsTab:CreateLabel("Cấp độ: " .. getPlayerLevel())
SettingsTab:CreateLabel("UserId: " .. player.UserId)

-- Thêm avatar
local avatarLabel = SettingsTab:CreateLabel("Avatar: Đang tải...")
avatarLabel.Image = createPlayerAvatar()

-- Phím tắt để thu gọn menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        Config.Minimized = not Config.Minimized
        if Config.Minimized then
            Window:Minimize()
        else
            Window:Restore()
        end
    end
end)

-- === VÒNG LẶP CHÍNH ===

-- Anti-AFK protection
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
end)

-- Vòng lặp chính
RunService.Heartbeat:Connect(function()
    -- Auto Farm
    autoFarm()
    
    -- Auto Raid
    autoRaidFarm()
    
    -- Aimbot và skills
    updateAimbot()
    autoCastSkills()
    
    -- Cập nhật thông tin UI
    if Window and not Config.Minimized then
        -- Cập nhật thông tin real-time nếu cần
    end
end)

print("✅ Ultimate Blox Fruits Script đã tải thành công!")
print("🎯 Tính năng: Auto Farm, Teleport, Raid, Aim Chiêu")
print("⌨️ Nhấn Left/Right Control để thu gọn/mở menu")
print("🛡️ Safe Mode đã được bật để tránh bị ban")
