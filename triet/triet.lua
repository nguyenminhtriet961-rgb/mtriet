-- 🍊 MINH TRIẾT HUB - BLOX FRUITS SCRIPT
-- Tính năng: Auto Farm, Teleport, Raid, Aim Chiêu, UI Tiếng Việt
-- Tối ưu cho Executor - Anti-Kick - Avatar chính xác

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Load Rayfield UI Library
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn("Không thể tải Rayfield UI, sử dụng UI thay thế")
    Rayfield = nil
end

-- Cấu hình chính
local Config = {
    -- Cài đặt Auto Farm
    AutoFarm = false,
    AutoQuest = false,
    MobAura = false,
    BringMobs = false,
    UseSkills = true,
    SafeMode = true,
    
    -- Cài đặt Combat
    AttackRange = 20,
    BringRange = 30,
    AimbotEnabled = false,
    AimbotRange = 100,
    AutoSkills = true,
    
    -- Cài đặt Delay (milliseconds)
    QuestDelay = {min = 1500, max = 3000},
    MoveDelay = {min = 500, max = 1000},
    AttackDelay = {min = 200, max = 400},
    SkillDelay = {min = 2000, max = 4000},
    
    -- Cài đặt Raid
    AutoRaid = false,
    AutoBuyChip = false,
    RaidDifficulty = "Normal",
    
    -- Cài đặt UI
    Minimized = false,
    ShowNotifications = true,
    
    -- Cài đặt tối ưu
    TeleportTimeout = 10,
    SearchInterval = 0.5,
    MaxSearchDistance = 500
}

-- Biến dừng khẩn cấp
_G.StopFarm = false

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

-- Vị trí teleport các đảo
local IslandLocations = {
    ["Biển 1"] = {
        ["Đảo Khởi Đầu"] = CFrame.new(1071.29, 16.52, 1421.47),
        ["Pháo Đài Hải Quân"] = CFrame.new(-2795.84, 72.99, -357.68),
        ["Thị Trấn Giữa"] = CFrame.new(-672.73, 15.09, 576.46),
        ["Rừng Rậm"] = CFrame.new(-1248.43, 11.88, 341.35),
        ["Làng Cướp Biển"] = CFrame.new(-1122.65, 4.79, 3856.16),
        ["Sa Mạc"] = CFrame.new(1094.91, 6.44, 4192.89),
        ["Đảo Băng"] = CFrame.new(1345.23, 87.27, -1385.34),
        ["MarineFord"] = CFrame.new(-2713.74, 24.61, 2023.58),
        ["Đấu Trường"] = CFrame.new(-1425.85, 7.39, -2994.84)
    },
    ["Biển 2"] = {
        ["Vương Quốc Hoa Hồng"] = CFrame.new(-392.38, 122.53, 1266.71),
        ["Sân Vận Động Tối"] = CFrame.new(3780.03, 16.68, -7363.35),
        ["Dinh Thự"] = CFrame.new(-12463.67, 374.68, -7564.92),
        ["Dinh Thự Flamingo"] = CFrame.new(-4867.23, 733.16, -2667.45),
        ["Khu Vực Xanh"] = CFrame.new(-2372.86, 3.89, -2164.29),
        ["Quán Cà Phê"] = CFrame.new(-385.26, 73.05, 297.68),
        ["Nghĩa Trang"] = CFrame.new(-5684.64, 487.54, -765.23)
    },
    ["Biển 3"] = {
        ["Thị Trấn Cảng"] = CFrame.new(-610.47, 15.34, 6742.73),
        ["Đảo Hydra"] = CFrame.new(5229.99, 7.44, 1100.03),
        ["Lâu Đài Trên Biển"] = CFrame.new(-5477.39, 313.76, -2813.94),
        ["Cây Lớn"] = CFrame.new(2179.95, 28.73, -6740.64),
        ["Rùa Bay"] = CFrame.new(-13274.53, 323.24, -8323.06),
        ["Lâu Đài Ma"] = CFrame.new(-9515.37, 142.14, 5533.23),
        ["Đảo Lạc Đường"] = CFrame.new(-2062.79, 36.85, -10240.81),
        ["Đảo Kem"] = CFrame.new(-819.38, 65.84, -10965.79)
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
local Window = nil
local playerAvatar = nil

-- === HÀM TIỆN ÍCH ===

-- Lấy delay ngẫu nhiên để tránh bị ban
local function getRandomDelay(minDelay, maxDelay)
    return math.random(minDelay, maxDelay) / 1000
end

-- Task.wait an toàn với delay ngẫu nhiên
local function safeTaskWait(minDelay, maxDelay)
    local delay = getRandomDelay(minDelay, maxDelay)
    if Config.SafeMode then
        task.wait(delay)
    else
        task.wait(minDelay / 1000)
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

-- Lấy avatar người chơi chính xác (hỗ trợ cả Rayfield và UI dự phòng)
local function getPlayerAvatar()
    local success, avatarImage = pcall(function()
        -- Sử dụng AvatarHeadShot để lấy ảnh khuôn mặt
        return "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
    end)
    
    if not success then
        success, avatarImage = pcall(function()
            -- Phương pháp dự phòng
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
    end
    
    if success then
        return avatarImage
    else
        return "rbxasset://textures/ui/GuiImagePlaceholder.png"
    end
end

-- Teleport mượt mà với TweenService (anti-kick) và timeout
local function smoothTeleport(position)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local humanoidRootPart = character.HumanoidRootPart
    local distance = (humanoidRootPart.Position - position.Position).Magnitude
    local startTime = tick()
    local timeout = Config.TeleportTimeout
    
    -- Nếu khoảng cách quá xa, chia thành nhiều bước nhỏ
    if distance > 1000 then
        local steps = math.ceil(distance / 500)
        for i = 1, steps do
            -- Kiểm tra timeout
            if tick() - startTime > timeout then
                warn("Teleport timeout - đang dừng")
                return false
            end
            
            -- Kiểm tra dừng khẩn cấp
            if _G.StopFarm then return false end
            
            local progress = i / steps
            local targetPos = humanoidRootPart.Position:Lerp(position.Position, progress)
            local targetCFrame = CFrame.new(targetPos, position.Position)
            
            local tweenInfo = TweenInfo.new(
                getRandomDelay(Config.MoveDelay.min, Config.MoveDelay.max),
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )
            
            local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
                CFrame = targetCFrame
            })
            tween:Play()
            
            -- Đợi với timeout
            local completed = false
            local connection
            connection = tween.Completed:Connect(function()
                completed = true
                if connection then connection:Disconnect() end
            end)
            
            local waitTime = 0
            while not completed and waitTime < timeout do
                task.wait(0.1)
                waitTime = waitTime + 0.1
                if _G.StopFarm then
                    if connection then connection:Disconnect() end
                    return false
                end
            end
            
            if connection then connection:Disconnect() end
            safeTaskWait(100, 300) -- Delay nhỏ giữa các bước
        end
    else
        -- Teleport trực tiếp cho khoảng cách ngắn
        local tweenInfo = TweenInfo.new(
            getRandomDelay(Config.MoveDelay.min, Config.MoveDelay.max),
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
            CFrame = position
        })
        tween:Play()
        
        -- Đợi với timeout
        local completed = false
        local connection
        connection = tween.Completed:Connect(function()
            completed = true
            if connection then connection:Disconnect() end
        end)
        
        local waitTime = 0
        while not completed and waitTime < timeout do
            task.wait(0.1)
            waitTime = waitTime + 0.1
            if _G.StopFarm then
                if connection then connection:Disconnect() end
                return false
            end
        end
        
        if connection then connection:Disconnect() end
    end
    
    return true
end

-- Tối ưu tìm kiếm NPC - chỉ tìm trong các thư mục cụ thể
local function findQuestNPC(npcName)
    -- Các thư mục cần tìm kiếm
    local searchLocations = {
        Workspace:FindFirstChild("NPCs"),
        Workspace:FindFirstChild("QuestNPCs"),
        Workspace:FindFirstChild("Map"):FindFirstChild("NPCs"),
        Workspace
    }
    
    for _, location in pairs(searchLocations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if obj.Name == npcName and obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                    return obj
                end
            end
        end
    end
    return nil
end

-- Tối ưu tìm kiếm NPC bán chip Raid
local function findRaidChipNPC()
    local searchLocations = {
        Workspace:FindFirstChild("NPCs"),
        Workspace:FindFirstChild("Raid"),
        Workspace:FindFirstChild("Map"):FindFirstChild("NPCs"),
        Workspace
    }
    
    for _, location in pairs(searchLocations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if obj.Name == "RaidChip" or obj.Name == "Microchip" or obj.Name == "ChipDealer" then
                    return obj
                end
            end
        end
    end
    return nil
end

-- Tối ưu tìm kiếm cổng Raid
local function findRaidPortal()
    local searchLocations = {
        Workspace:FindFirstChild("Raid"),
        Workspace:FindFirstChild("Map"):FindFirstChild("Raid"),
        Workspace
    }
    
    for _, location in pairs(searchLocations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if obj.Name == "RaidPortal" or obj.Name == "RaidEntrance" or obj.Name == "MysteriousDoor" then
                    return obj
                end
            end
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
    safeTaskWait(Config.QuestDelay.min, Config.QuestDelay.max)
    
    -- Nhận nhiệm vụ với nhiều phương pháp
    fireclickdetector(npc:FindFirstChildOfClass("ClickDetector"))
    
    -- Thử các remote events khác nhau
    local questRemotes = {
        ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Quests"),
        ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Quest"),
        ReplicatedStorage:FindFirstChild("Quests"),
        ReplicatedStorage:FindFirstChild("Quest")
    }
    
    for _, remote in pairs(questRemotes) do
        if remote then
            pcall(function()
                remote:InvokeServer("AcceptQuest", questData.npc)
                remote:InvokeServer("StartQuest", questData.npc)
                remote:FireServer("AcceptQuest", questData.npc)
            end)
        end
    end
    
    currentQuest = questData
    return true
end

-- Tối ưu tìm kiếm kẻ địch - chỉ tìm trong các thư mục cụ thể
local function findEnemies(enemyName, range)
    local enemies = {}
    local playerPos = character.HumanoidRootPart.Position
    
    -- Các thư mục cần tìm kiếm
    local searchLocations = {
        Workspace:FindFirstChild("Enemies"),
        Workspace:FindFirstChild("Mobs"),
        Workspace:FindFirstChild("Map"):FindFirstChild("Enemies"),
        Workspace:FindFirstChild("Map"):FindFirstChild("Mobs")
    }
    
    -- Nếu không tìm thấy thư mục cụ thể, tìm trong một phạm vi giới hạn
    local foundInSpecificFolders = false
    for _, location in pairs(searchLocations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("Model") and string.find(obj.Name, enemyName) and obj:FindFirstChild("Humanoid") then
                    local humanoid = obj.Humanoid
                    -- Kiểm tra máu của quái vật trước khi thêm vào danh sách
                    if humanoid and humanoid.Health > 0 then
                        local distance = (playerPos - obj.PrimaryPart.Position).Magnitude
                        if distance <= range then
                            table.insert(enemies, {model = obj, distance = distance, humanoid = humanoid})
                            foundInSpecificFolders = true
                        end
                    end
                end
            end
        end
    end
    
    -- Nếu không tìm thấy trong thư mục cụ thể, tìm trong phạm vi giới hạn của Workspace
    if not foundInSpecificFolders then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and string.find(obj.Name, enemyName) and obj:FindFirstChild("Humanoid") then
                local humanoid = obj.Humanoid
                if humanoid and humanoid.Health > 0 then
                    local distance = (playerPos - obj.PrimaryPart.Position).Magnitude
                    if distance <= math.min(range, Config.MaxSearchDistance) then
                        table.insert(enemies, {model = obj, distance = distance, humanoid = humanoid})
                    end
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
    if not Config.BringMobs or not currentQuest then return end
    
    local enemies = findEnemies(currentQuest.enemy, Config.BringRange)
    for _, enemy in pairs(enemies) do
        -- Kiểm tra lại máu trước khi gom
        if enemy.humanoid and enemy.humanoid.Health > 0 then
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
            if humanoid and humanoid.Health > 0 and obj ~= character then
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

-- Cập nhật aimbot
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
        -- Thử nhiều phương pháp remote khác nhau
        local skillRemotes = {
            ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Skills"),
            ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Combat"),
            ReplicatedStorage:FindFirstChild("Skills"),
            ReplicatedStorage:FindFirstChild("Combat")
        }
        
        for _, remote in pairs(skillRemotes) do
            if remote then
                pcall(function()
                    -- Sử dụng Mouse.Hit.p để điều hướng chiêu thức
                    local targetPos = aimbotTarget.HumanoidRootPart.Position
                    remote:FireServer("UseSkill", skill, targetPos)
                    remote:FireServer(skill, targetPos)
                end)
            end
        end
    end
    
    lastSkillTime = tick()
end

-- Tấn công kẻ địch (hỗ trợ cả Mobile) - Tối ưu khoảng cách
local function attackEnemy(enemy)
    if not enemy or not enemy:FindFirstChild("Humanoid") then
        return false
    end
    
    local humanoid = enemy.Humanoid
    -- Kiểm tra máu trước khi tấn công
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    
    -- Kiểm tra dừng khẩn cấp
    if _G.StopFarm then return false end
    
    -- Tính khoảng cách đến quái
    local distance = (character.HumanoidRootPart.Position - enemy.PrimaryPart.Position).Magnitude
    
    -- Tối ưu di chuyển: chỉ teleport khi xa, xoay mặt khi gần
    if distance > 5 then
        -- Di chuyển đến vị trí tấn công
        local attackPos = enemy.PrimaryPart.Position + Vector3.new(0, 5, 0)
        character.HumanoidRootPart.CFrame = CFrame.new(attackPos)
    else
        -- Nếu gần, chỉ cần xoay mặt về phía quái để tránh giật
        character.HumanoidRootPart.CFrame = CFrame.new(
            character.HumanoidRootPart.Position,
            enemy.PrimaryPart.Position
        )
    end
    
    -- Tấn công với nhiều phương pháp
    local combatRemotes = {
        ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Combat"),
        ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Melee"),
        ReplicatedStorage:FindFirstChild("Combat"),
        ReplicatedStorage:FindFirstChild("Melee")
    }
    
    for _, remote in pairs(combatRemotes) do
        if remote then
            pcall(function()
                remote:FireServer("MouseClick", enemy.HumanoidRootPart)
                remote:FireServer("Attack", enemy.HumanoidRootPart)
            end)
        end
    end
    
    -- Hỗ trợ Mobile với VirtualInputManager
    local VirtualInputManager = game:GetService("VirtualInputManager")
    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(getRandomDelay(Config.AttackDelay.min, Config.AttackDelay.max))
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end
    
    -- Click chuột ảo (phương pháp dự phòng)
    pcall(function()
        VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        safeTaskWait(Config.AttackDelay.min, Config.AttackDelay.max)
        VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
    
    return true
end

-- Mob Aura - Tấn công tất cả kẻ địch trong phạm vi
local function mobAura()
    if not Config.MobAura or not currentQuest then return end
    
    local enemies = findEnemies(currentQuest.enemy, Config.AttackRange)
    for _, enemy in pairs(enemies) do
        if enemy.distance <= Config.AttackRange then
            -- Kiểm tra máu lần nữa
            if enemy.humanoid and enemy.humanoid.Health > 0 then
                pcall(function()
                    attackEnemy(enemy.model)
                end)
            end
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
    
    local chipNPC = findRaidChipNPC()
    if chipNPC then
        -- Di chuyển đến NPC
        smoothTeleport(chipNPC.CFrame)
        safeTaskWait(1000, 2000)
        
        -- Thử mua chip
        fireclickdetector(chipNPC:FindFirstChildOfClass("ClickDetector"))
        
        -- Thử phương pháp khác
        local buyRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("BuyRaidChip")
        if buyRemote then
            pcall(function()
                buyRemote:InvokeServer()
            end)
        end
        
        return true
    end
    return false
end

-- Bắt đầu Raid tự động
local function startRaid()
    if raidActive then return end
    
    if buyRaidChip() then
        safeTaskWait(1000, 2000)
        
        local portal = findRaidPortal()
        if portal then
            smoothTeleport(portal.CFrame)
            safeTaskWait(1000, 2000)
            
            -- Thử vào portal
            fireclickdetector(portal:FindFirstChildOfClass("ClickDetector"))
            
            -- Thử phương pháp khác
            local raidRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("StartRaid")
            if raidRemote then
                pcall(function()
                    raidRemote:InvokeServer()
                end)
            end
            
            raidActive = true
            return true
        end
    end
    return false
end

-- Tự động tiêu diệt quái trong Raid
local function autoRaidFarm()
    if not raidActive or not Config.AutoRaid or _G.StopFarm then return end
    
    -- Tìm quái Raid và boss
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (string.find(obj.Name, "Raid") or string.find(obj.Name, "Boss") or string.find(obj.Name, "Enemy")) then
            if obj:FindFirstChild("Humanoid") then
                local humanoid = obj.Humanoid
                if humanoid and humanoid.Health > 0 then
                    -- Tấn công quái Raid
                    local distance = (character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude
                    if distance <= Config.AttackRange then
                        attackEnemy(obj)
                        autoCastSkills()
                    end
                end
            end
        end
    end
    
    -- Kiểm tra xem raid đã kết thúc chưa
    local raidEnemies = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (string.find(obj.Name, "Raid") or string.find(obj.Name, "Boss")) then
            if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                raidEnemies = raidEnemies + 1
            end
        end
    end
    
    if raidEnemies == 0 then
        raidActive = false
    end
end

-- === LOGIC AUTO FARM CHÍNH ===

-- Logic farm hoàn chỉnh: Quest -> Teleport -> Gom quái -> Đánh quái
local function autoFarm()
    if not Config.AutoFarm or _G.StopFarm then return end
    
    -- Bước 1: Nhận nhiệm vụ nếu cần
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
            safeTaskWait(500, 1000) -- Delay sau khi nhận quest
        end
    end
    
    -- Bước 2: Farm quái nếu có nhiệm vụ
    if currentQuest then
        -- Bước 2a: Gom quái
        bringMobs()
        
        -- Bước 2b: Mob Aura
        mobAura()
        
        -- Bước 2c: Tìm và tấn công quái gần nhất
        local enemies = findEnemies(currentQuest.enemy, Config.AttackRange)
        if #enemies > 0 and not isAttacking then
            isAttacking = true
            currentTarget = enemies[1].model
            
            local success = pcall(function()
                attackEnemy(currentTarget)
            end)
            
            if not success or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
                isAttacking = false
                currentTarget = nil
            else
                isAttacking = false
            end
        end
    end
end

-- === GIAO DIỆN UI TIẾNG VIỆT ===

-- Tạo UI đơn giản nếu Rayfield lỗi
local function createSimpleUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.Name = "BloxFruitsUI"
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 450)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Avatar và thông tin người chơi
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 260, 0, 80)
    avatarFrame.Position = UDim2.new(0, 10, 0, 10)
    avatarFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    avatarFrame.BorderSizePixel = 0
    avatarFrame.Parent = mainFrame
    
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(0, 60, 0, 60)
    avatarImage.Position = UDim2.new(0, 10, 0, 10)
    avatarImage.Image = playerAvatar or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    avatarImage.BackgroundTransparency = 0
    avatarImage.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    avatarImage.Parent = avatarFrame
    
    local playerInfo = Instance.new("TextLabel")
    playerInfo.Size = UDim2.new(0, 180, 0, 60)
    playerInfo.Position = UDim2.new(0, 80, 0, 10)
    playerInfo.Text = "Người chơi: " .. player.Name .. "\nCấp độ: " .. getPlayerLevel() .. "\nUserId: " .. player.UserId
    playerInfo.BackgroundColor3 = Color3.new(0, 0, 0)
    playerInfo.TextColor3 = Color3.new(1, 1, 1)
    playerInfo.TextXAlignment = Enum.TextXAlignment.Left
    playerInfo.Font = Enum.Font.SourceSans
    playerInfo.Parent = avatarFrame
    
    -- Tiêu đề
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 100)
    title.Text = "🍊 MINH TRIẾT HUB"
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    -- Auto Farm Toggle
    local autoFarmToggle = Instance.new("TextButton")
    autoFarmToggle.Size = UDim2.new(0, 260, 0, 40)
    autoFarmToggle.Position = UDim2.new(0, 10, 0, 140)
    autoFarmToggle.Text = "Tự động Farm: TẮT"
    autoFarmToggle.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    autoFarmToggle.Parent = mainFrame
    
    autoFarmToggle.MouseButton1Click:Connect(function()
        Config.AutoFarm = not Config.AutoFarm
        autoFarmToggle.Text = "Tự động Farm: " .. (Config.AutoFarm and "BẬT" or "TẮT")
        autoFarmToggle.BackgroundColor3 = Config.AutoFarm and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.2, 0.2)
    end)
    
    -- Auto Quest Toggle
    local autoQuestToggle = Instance.new("TextButton")
    autoQuestToggle.Size = UDim2.new(0, 260, 0, 40)
    autoQuestToggle.Position = UDim2.new(0, 10, 0, 190)
    autoQuestToggle.Text = "Tự động Nhận Quest: TẮT"
    autoQuestToggle.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    autoQuestToggle.Parent = mainFrame
    
    autoQuestToggle.MouseButton1Click:Connect(function()
        Config.AutoQuest = not Config.AutoQuest
        autoQuestToggle.Text = "Tự động Nhận Quest: " .. (Config.AutoQuest and "BẬT" or "TẮT")
        autoQuestToggle.BackgroundColor3 = Config.AutoQuest and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.2, 0.2)
    end)
    
    -- Mob Aura Toggle
    local mobAuraToggle = Instance.new("TextButton")
    mobAuraToggle.Size = UDim2.new(0, 260, 0, 40)
    mobAuraToggle.Position = UDim2.new(0, 10, 0, 240)
    mobAuraToggle.Text = "Mob Aura: TẮT"
    mobAuraToggle.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    mobAuraToggle.Parent = mainFrame
    
    mobAuraToggle.MouseButton1Click:Connect(function()
        Config.MobAura = not Config.MobAura
        mobAuraToggle.Text = "Mob Aura: " .. (Config.MobAura and "BẬT" or "TẮT")
        mobAuraToggle.BackgroundColor3 = Config.MobAura and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.2, 0.2)
    end)
    
    -- Info Label
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0, 260, 0, 100)
    infoLabel.Position = UDim2.new(0, 10, 0, 290)
    infoLabel.Text = "Trạng thái: Đang chờ\nNhiệm vụ: Không có\nMục tiêu: Không có"
    infoLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.Parent = mainFrame
    
    return screenGui, infoLabel
end

-- Tạo UI chính
local function createUI()
    playerAvatar = getPlayerAvatar()
    
    if Rayfield then
        Window = Rayfield:CreateWindow({
            Name = "🍊 MINH TRIẾT HUB",
            LoadingTitle = "Đang tải MINH TRIẾT HUB...",
            LoadingSubtitle = "Phiên bản cuối cùng",
            ConfigurationSaving = {
                Enabled = true,
                FolderName = "MinhTrietHub",
                FileName = "MinhTrietConfig"
            }
        })
        
        -- Tab Auto Farm
        local FarmTab = Window:CreateTab("🚜 Tự động Farm", 4483362458)
        
        FarmTab:CreateToggle({
            Name = "Tự động Farm",
            CurrentValue = false,
            Flag = "AutoFarm",
            Callback = function(Value) 
                Config.AutoFarm = Value
                -- Tự động lưu trạng thái
                pcall(function()
                    if Rayfield and Rayfield.SaveConfiguration then
                        Rayfield.SaveConfiguration()
                    end
                end)
            end,
        })
        
        FarmTab:CreateToggle({
            Name = "Tự động Nhận Quest",
            CurrentValue = false,
            Flag = "AutoQuest",
            Callback = function(Value) 
                Config.AutoQuest = Value
                -- Tự động lưu trạng thái
                pcall(function()
                    if Rayfield and Rayfield.SaveConfiguration then
                        Rayfield.SaveConfiguration()
                    end
                end)
            end,
        })
        
        FarmTab:CreateToggle({
            Name = "Mob Aura",
            CurrentValue = false,
            Flag = "MobAura",
            Callback = function(Value) 
                Config.MobAura = Value
                -- Tự động lưu trạng thái
                pcall(function()
                    if Rayfield and Rayfield.SaveConfiguration then
                        Rayfield.SaveConfiguration()
                    end
                end)
            end,
        })
        
        FarmTab:CreateToggle({
            Name = "Gom Quái",
            CurrentValue = false,
            Flag = "BringMobs",
            Callback = function(Value) 
                Config.BringMobs = Value
                -- Tự động lưu trạng thái
                pcall(function()
                    if Rayfield and Rayfield.SaveConfiguration then
                        Rayfield.SaveConfiguration()
                    end
                end)
            end,
        })
        
        FarmTab:CreateSlider({
            Name = "Phạm vi Tấn công",
            Range = {10, 50},
            Increment = 5,
            CurrentValue = 20,
            Flag = "AttackRange",
            Callback = function(Value) Config.AttackRange = Value end,
        })
        
        -- Tab Teleport
        local TeleportTab = Window:CreateTab("🌍 Dịch chuyển", 4483362458)
        
        TeleportTab:CreateDropdown({
            Name = "Đảo Biển 1",
            Options = {"Đảo Khởi Đầu", "Pháo Đài Hải Quân", "Thị Trấn Giữa", "Rừng Rậm", "Làng Cướp Biển", "Sa Mạc", "Đảo Băng", "MarineFord", "Đấu Trường"},
            CurrentOption = "Đảo Khởi Đầu",
            Flag = "Sea1Island",
            Callback = function(Option) teleportToIsland("Biển 1", Option) end,
        })
        
        TeleportTab:CreateDropdown({
            Name = "Đảo Biển 2",
            Options = {"Vương Quốc Hoa Hồng", "Sân Vận Động Tối", "Dinh Thự", "Dinh Thự Flamingo", "Khu Vực Xanh", "Quán Cà Phê", "Nghĩa Trang"},
            CurrentOption = "Vương Quốc Hoa Hồng",
            Flag = "Sea2Island",
            Callback = function(Option) teleportToIsland("Biển 2", Option) end,
        })
        
        TeleportTab:CreateDropdown({
            Name = "Đảo Biển 3",
            Options = {"Thị Trấn Cảng", "Đảo Hydra", "Lâu Đài Trên Biển", "Cây Lớn", "Rùa Bay", "Lâu Đài Ma", "Đảo Lạc Đường", "Đảo Kem"},
            CurrentOption = "Thị Trấn Cảng",
            Flag = "Sea3Island",
            Callback = function(Option) teleportToIsland("Biển 3", Option) end,
        })
        
        -- Tab Raid
        local RaidTab = Window:CreateTab("⚔️ Raid", 4483362458)
        
        RaidTab:CreateToggle({
            Name = "Tự động Raid",
            CurrentValue = false,
            Flag = "AutoRaid",
            Callback = function(Value)
                Config.AutoRaid = Value
                if Value then startRaid() end
            end,
        })
        
        RaidTab:CreateToggle({
            Name = "Tự động Mua Chip",
            CurrentValue = false,
            Flag = "AutoBuyChip",
            Callback = function(Value) Config.AutoBuyChip = Value end,
        })
        
        -- Tab Aim Chiêu
        local AimTab = Window:CreateTab("🎯 Aim Chiêu", 4483362458)
        
        AimTab:CreateToggle({
            Name = "Aimbot (Khóa mục tiêu)",
            CurrentValue = false,
            Flag = "AimbotEnabled",
            Callback = function(Value) 
                Config.AimbotEnabled = Value
                -- Tự động lưu trạng thái
                pcall(function()
                    if Rayfield and Rayfield.SaveConfiguration then
                        Rayfield.SaveConfiguration()
                    end
                end)
            end,
        })
        
        AimTab:CreateToggle({
            Name = "Tự động Chiêu (Z, X, C, V)",
            CurrentValue = true,
            Flag = "AutoSkills",
            Callback = function(Value) 
                Config.AutoSkills = Value
                -- Tự động lưu trạng thái
                pcall(function()
                    if Rayfield and Rayfield.SaveConfiguration then
                        Rayfield.SaveConfiguration()
                    end
                end)
            end,
        })
        
        AimTab:CreateSlider({
            Name = "Phạm vi Aimbot",
            Range = {50, 200},
            Increment = 10,
            CurrentValue = 100,
            Flag = "AimbotRange",
            Callback = function(Value) Config.AimbotRange = Value end,
        })
        
        -- Tab Cài đặt
        local SettingsTab = Window:CreateTab("⚙️ Cài đặt", 4483362458)
        
        SettingsTab:CreateToggle({
            Name = "Chế độ An toàn (Chống ban)",
            CurrentValue = true,
            Flag = "SafeMode",
            Callback = function(Value) 
                Config.SafeMode = Value
                -- Tự động lưu trạng thái
                pcall(function()
                    if Rayfield and Rayfield.SaveConfiguration then
                        Rayfield.SaveConfiguration()
                    end
                end)
            end,
        })
        
        SettingsTab:CreateLabel("Tên người chơi: " .. player.Name)
        SettingsTab:CreateLabel("Cấp độ: " .. getPlayerLevel())
        SettingsTab:CreateLabel("UserId: " .. player.UserId)
        
        -- Thêm avatar
        local avatarLabel = SettingsTab:CreateLabel("Avatar: Đang tải...")
        if playerAvatar then
            avatarLabel.Image = playerAvatar
        end
        
    else
        return createSimpleUI()
    end
    
    return nil
end

-- === KHỞI TẠO ===

-- Tạo UI
local simpleUI, infoLabel = createUI()

-- Phím tắt để thu gọn/mở menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        Config.Minimized = not Config.Minimized
        if Window then
            if Config.Minimized then
                Window:Minimize()
            else
                Window:Restore()
            end
        elseif simpleUI then
            simpleUI.Enabled = not Config.Minimized
        end
    end
end)

-- Anti-AFK protection
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
end)

-- Vòng lặp chính
RunService.Heartbeat:Connect(function()
    -- Kiểm tra dừng khẩn cấp
    if _G.StopFarm then
        -- Reset trạng thái khi dừng
        isAttacking = false
        currentTarget = nil
        return
    end
    
    -- Auto Farm logic hoàn chỉnh
    autoFarm()
    
    -- Auto Raid
    autoRaidFarm()
    
    -- Aimbot và skills
    updateAimbot()
    autoCastSkills()
    
    -- Cập nhật UI đơn giản
    if infoLabel then
        local status = Config.AutoFarm and "Đang farm" or "Đang chờ"
        if _G.StopFarm then status = "Đã dừng" end
        local quest = currentQuest and currentQuest.enemy or "Không có"
        local target = currentTarget and currentTarget.Name or "Không có"
        
        infoLabel.Text = "Trạng thái: " .. status .. 
                        "\nNhiệm vụ: " .. quest ..
                        "\nMục tiêu: " .. target ..
                        "\n\n⚠️ Gõ _G.StopFarm = true để dừng"
    end
end)

-- Thông báo thành công
print("✅ MINH TRIẾT HUB đã tải thành công!")
print("🎯 Tính năng: Auto Farm, Teleport, Raid, Aim Chiêu")
print("🌍 Giao diện Tiếng Việt đầy đủ")
print("⌨️ Nhấn Left/Right Control để thu gọn/mở menu")
print("🛡️ Chế độ an toàn đã được bật")
print("📱 Hỗ trợ Mobile với VirtualInputManager")
print("⚡ Tối ưu tìm kiếm trong thư mục cụ thể")
print("🚨 Dừng khẩn cấp: Gõ _G.StopFarm = true")
print("🍊 Chúc bạn farm vui vẻ!")
