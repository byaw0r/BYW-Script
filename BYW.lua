--BYW SCRIPT v1.7.0
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "BYW SCRIPT v1.7.0",
    LoadingTitle = "BYW SCRIPT v1.7.0", 
    LoadingSubtitle = "by Bdev",
    Theme = {
    TextColor = Color3.fromRGB(255, 255, 255),
    Background = Color3.fromRGB(0, 0, 0),
    Topbar = Color3.fromRGB(30, 30, 30),
    Shadow = Color3.fromRGB(10, 10, 10),
    NotificationBackground = Color3.fromRGB(20, 20, 20),
    NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
    TabBackground = Color3.fromRGB(255, 255, 255),
    TabStroke = Color3.fromRGB(200, 200, 200),
    TabBackgroundSelected = Color3.fromRGB(200, 200, 200),
    TabTextColor = Color3.fromRGB(0, 0, 0),
    SelectedTabTextColor = Color3.fromRGB(0, 0, 0),
    ElementBackground = Color3.fromRGB(35, 35, 35),
    ElementBackgroundHover = Color3.fromRGB(50, 50, 50),
    SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
    ElementStroke = Color3.fromRGB(60, 60, 60),
    SecondaryElementStroke = Color3.fromRGB(50, 50, 50),
    SliderBackground = Color3.fromRGB(220, 220, 220),
    SliderProgress = Color3.fromRGB(80, 80, 80),
    SliderStroke = Color3.fromRGB(200, 200, 200),
    ToggleBackground = Color3.fromRGB(40, 40, 40),
    ToggleEnabled = Color3.fromRGB(220, 220, 220),
    ToggleDisabled = Color3.fromRGB(120, 120, 120),
    ToggleEnabledStroke = Color3.fromRGB(200, 200, 200),
    ToggleDisabledStroke = Color3.fromRGB(150, 150, 150),
    ToggleEnabledOuterStroke = Color3.fromRGB(180, 180, 180),
    ToggleDisabledOuterStroke = Color3.fromRGB(80, 80, 80),
    DropdownSelected = Color3.fromRGB(50, 50, 50),
    DropdownUnselected = Color3.fromRGB(30, 30, 30),
    InputBackground = Color3.fromRGB(30, 30, 30),
    InputStroke = Color3.fromRGB(70, 70, 70),
    PlaceholderColor = Color3.fromRGB(180, 180, 180)
},
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BYW Script",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink", 
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "BYW SCRIPT",
        Subtitle = "Key System",
        Note = "Enter key to continue",
        FileName = "BYWKey", 
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"BYW"}
    },
    DisableRayfieldPrompts = false,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPObjects = {}
local circle

local showBoxes = false
local showLines = false
local showNames = false
local showChams = false
local showHealthBar = false
local showDistanceESP = false
local teamCheck = false
local aimBotEnabled = false
local aimPredictionEnabled = false
local visibleCheckEnabled = false
local circleRadius = 50
local showFOV = false
local rainbowFOV = false
local rainbowESP = false

local espMaxDistance = 1000

local speedHackEnabled = false
local playerSpeed = 16
local noclipEnabled = false
local infiniteJumpEnabled = false

local customSpawnEnabled = false
local customSpawnLocation = nil
local customSpawnPart = nil
local respawnConnection = nil
local predictionStrength = 0.1

local function getRainbowColor()
    local tick = tick()
    local r = math.sin(tick * 2) * 0.5 + 0.5
    local g = math.sin(tick * 2 + 2) * 0.5 + 0.5
    local b = math.sin(tick * 2 + 4) * 0.5 + 0.5
    return Color3.new(r, g, b)
end

if Drawing then
    circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Color = Color3.new(1, 1, 1)
    circle.Thickness = 1
    circle.NumSides = 64
    circle.Filled = false
    circle.Radius = circleRadius
    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function toggleCustomSpawn(value)
    customSpawnEnabled = value
    
    if value then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local position = character.HumanoidRootPart.Position
            
            customSpawnLocation = position
            
            if customSpawnPart then
                customSpawnPart:Destroy()
            end
            
            customSpawnPart = Instance.new("Part")
            customSpawnPart.Name = "CustomSpawnPoint"
            customSpawnPart.Size = Vector3.new(5, 1, 5)
            customSpawnPart.Position = position
            customSpawnPart.Anchored = true
            customSpawnPart.CanCollide = false
            customSpawnPart.Transparency = 0.7
            customSpawnPart.Color = Color3.fromRGB(0, 255, 0)
            customSpawnPart.Material = Enum.Material.Neon
            customSpawnPart.Parent = workspace
            
            local pointLight = Instance.new("PointLight")
            pointLight.Brightness = 1
            pointLight.Range = 10
            pointLight.Color = Color3.fromRGB(0, 255, 0)
            pointLight.Parent = customSpawnPart
        end
        
        if respawnConnection then
            respawnConnection:Disconnect()
        end
        
        respawnConnection = LocalPlayer.CharacterAdded:Connect(function(character)
            wait(0.1)
            
            if customSpawnEnabled and customSpawnLocation then
                local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
                if humanoidRootPart then
                    humanoidRootPart.CFrame = CFrame.new(customSpawnLocation)
                end
            end
        end)
        
    else
        if customSpawnPart then
            customSpawnPart:Destroy()
            customSpawnPart = nil
        end
        
        customSpawnLocation = nil
        
        if respawnConnection then
            respawnConnection:Disconnect()
            respawnConnection = nil
        end
    end
end

local infiniteJumpConnection
local function toggleInfiniteJump(value)
    infiniteJumpEnabled = value
    if value then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
        end
    end
end

local function updateSpeed()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        if speedHackEnabled then
            character.Humanoid.WalkSpeed = playerSpeed
        else
            character.Humanoid.WalkSpeed = 16
        end
    end
end

local noclipConnection
local function toggleNoclip(value)
    noclipEnabled = value
    if value then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end

local function isEnemy(player)
    if not teamCheck then return true end
    if not LocalPlayer.Team then return true end
    if not player.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

local function getTeamColorFromLeaderboard(plr)
    if plr.Team then
        local teamColor = plr.Team.TeamColor
        if teamColor then
            return teamColor.Color
        end
    end
    
    local leaderboard = game:GetService("Players"):FindFirstChild("Leaderboard")
    if not leaderboard then
        leaderboard = workspace:FindFirstChild("Leaderboard")
    end
    if not leaderboard then
        leaderboard = game:GetService("StarterGui"):FindFirstChild("Leaderboard")
    end
    
    if not leaderboard then
        return Color3.fromRGB(255, 50, 50)
    end
    
    local hasTeams = false
    for _, child in pairs(leaderboard:GetChildren()) do
        if child:IsA("Team") then
            hasTeams = true
            break
        end
    end
    
    if not hasTeams then
        return Color3.fromRGB(255, 50, 50)
    end
    
    for _, child in pairs(leaderboard:GetChildren()) do
        if child:IsA("Team") then
            for _, member in pairs(child:GetPlayers()) do
                if member == plr then
                    if child.TeamColor then
                        return child.TeamColor.Color
                    end
                    break
                end
            end
        end
    end
    
    return Color3.fromRGB(255, 50, 50)
end

local function getTeamColor(plr)
    local teamColor = getTeamColorFromLeaderboard(plr)
    if teamCheck and not isEnemy(plr) then
        return Color3.new(teamColor.R * 0.3, teamColor.G * 0.3, teamColor.B * 0.3)
    end
    return teamColor
end

local function shouldShowESP(player)
    if player == LocalPlayer then return false end
    if teamCheck then
        return isEnemy(player)
    end
    return true
end

local function isValidCharacter(char)
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    return hrp and humanoid and humanoid.Health > 0
end

local function isWithinESPdistance(player)
    if not LocalPlayer.Character then return false end
    if not player.Character then return false end
    if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    if not player.Character:FindFirstChild("HumanoidRootPart") then return false end
    
    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
    return distance <= espMaxDistance
end

local ChamsHighlights = {}
local function applyChams(player, character, teamColor)
    if not character then return end
    
    if ChamsHighlights[player] then
        ChamsHighlights[player]:Destroy()
        ChamsHighlights[player] = nil
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = game:GetService("CoreGui")
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = teamColor
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Color3.new(0, 0, 0)
    highlight.OutlineTransparency = 0
    highlight.Enabled = true
    
    ChamsHighlights[player] = highlight
end

local function removeChams(player)
    if ChamsHighlights[player] then
        ChamsHighlights[player]:Destroy()
        ChamsHighlights[player] = nil
    end
end

local function createESP(player)
    if ESPObjects[player] then return ESPObjects[player] end
    if not Drawing then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Visible = false
    box.Color = Color3.new(1, 0, 0)
    
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Visible = false
    line.ZIndex = 1
    
    local nameText = Drawing.new("Text")
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Visible = false
    nameText.ZIndex = 1
    
    local healthBarOutline = Drawing.new("Square")
    healthBarOutline.Thickness = 1
    healthBarOutline.Filled = false
    healthBarOutline.Visible = false
    healthBarOutline.ZIndex = 1
    
    local healthBarFill = Drawing.new("Square")
    healthBarFill.Thickness = 1
    healthBarFill.Filled = true
    healthBarFill.Visible = false
    healthBarFill.ZIndex = 1
    
    local distanceText = Drawing.new("Text")
    distanceText.Size = 14
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.Visible = false
    distanceText.ZIndex = 1
    
    ESPObjects[player] = {
        Box = box, 
        Line = line, 
        NameText = nameText,
        HealthBarOutline = healthBarOutline,
        HealthBarFill = healthBarFill,
        DistanceText = distanceText
    }
    return ESPObjects[player]
end

local function removeESP(player)
    local esp = ESPObjects[player]
    if esp then
        if esp.Box then esp.Box:Remove() end
        if esp.Line then esp.Line:Remove() end
        if esp.NameText then esp.NameText:Remove() end
        if esp.HealthBarOutline then esp.HealthBarOutline:Remove() end
        if esp.HealthBarFill then esp.HealthBarFill:Remove() end
        if esp.DistanceText then esp.DistanceText:Remove() end
        ESPObjects[player] = nil
    end
    removeChams(player)
end

local function clearESP()
    for player, esp in pairs(ESPObjects) do
        if esp then
            if esp.Box then esp.Box.Visible = false end
            if esp.Line then esp.Line.Visible = false end
            if esp.NameText then esp.NameText.Visible = false end
            if esp.HealthBarOutline then esp.HealthBarOutline.Visible = false end
            if esp.HealthBarFill then esp.HealthBarFill.Visible = false end
            if esp.DistanceText then esp.DistanceText.Visible = false end
        end
        if not showChams then
            removeChams(player)
        end
    end

    if not (showBoxes or showLines or showNames or showChams or showHealthBar or showDistanceESP) then return end
end

local function updateESP()
    for player, esp in pairs(ESPObjects) do
        if esp then
            if esp.Box then esp.Box.Visible = false end
            if esp.Line then esp.Line.Visible = false end
            if esp.NameText then esp.NameText.Visible = false end
            if esp.HealthBarOutline then esp.HealthBarOutline.Visible = false end
            if esp.HealthBarFill then esp.HealthBarFill.Visible = false end
            if esp.DistanceText then esp.DistanceText.Visible = false end
        end
        if not showChams then
            removeChams(player)
        end
    end

    if not (showBoxes or showLines or showNames or showChams or showHealthBar or showDistanceESP) then return end

    for _, player in pairs(Players:GetPlayers()) do
        if not isWithinESPdistance(player) then
            local esp = ESPObjects[player]
            if esp then
                if esp.Box then esp.Box.Visible = false end
                if esp.Line then esp.Line.Visible = false end
                if esp.NameText then esp.NameText.Visible = false end
                if esp.HealthBarOutline then esp.HealthBarOutline.Visible = false end
                if esp.HealthBarFill then esp.HealthBarFill.Visible = false end
                if esp.DistanceText then esp.DistanceText.Visible = false end
            end
            removeChams(player)
            continue
        end
        
        if not shouldShowESP(player) then
            local esp = ESPObjects[player]
            if esp then
                if esp.Box then esp.Box.Visible = false end
                if esp.Line then esp.Line.Visible = false end
                if esp.NameText then esp.NameText.Visible = false end
                if esp.HealthBarOutline then esp.HealthBarOutline.Visible = false end
                if esp.HealthBarFill then esp.HealthBarFill.Visible = false end
                if esp.DistanceText then esp.DistanceText.Visible = false end
            end
            removeChams(player)
            continue
        end
        
        local esp = ESPObjects[player]
        if not esp then
            esp = createESP(player)
        end
        if not esp then continue end
        
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and char:FindFirstChildOfClass("Humanoid") then
            local head = char.Head
            local hrp = char.HumanoidRootPart
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            local headPos, headVisible = Camera:WorldToViewportPoint(head.Position)
            local feetPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
            
            if headVisible and feetPos.Z > 0 then
                local headPos2D = Vector2.new(headPos.X, headPos.Y)
                local feetPos2D = Vector2.new(feetPos.X, feetPos.Y)
                
                local height = math.abs(feetPos2D.Y - headPos2D.Y)
                local width = height * 0.6
                
                local minSize = 15
                if width < minSize then
                    width = minSize
                    height = minSize / 0.6
                end
                
                if height < 5 then
                    if esp.Box then esp.Box.Visible = false end
                    if esp.HealthBarOutline then esp.HealthBarOutline.Visible = false end
                    if esp.HealthBarFill then esp.HealthBarFill.Visible = false end
                    continue
                end
                
                local distance = 0
                if LocalPlayer.Character and isValidCharacter(LocalPlayer.Character) then
                    distance = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                end
                
                local teamColor = rainbowESP and getRainbowColor() or getTeamColor(player)
                
                if showBoxes then
                    esp.Box.Position = Vector2.new(headPos2D.X - width/2, headPos2D.Y)
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Visible = true
                    esp.Box.Color = teamColor
                else
                    esp.Box.Visible = false
                end
                
                if showLines then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.Line.From = screenCenter
                    esp.Line.To = Vector2.new(headPos2D.X, headPos2D.Y)
                    esp.Line.Color = teamColor
                    esp.Line.Visible = true
                else
                    esp.Line.Visible = false
                end
                
                if showNames then
                    esp.NameText.Text = player.Name
                    esp.NameText.Position = Vector2.new(headPos2D.X, headPos2D.Y - height/2 - 20)
                    esp.NameText.Color = teamColor
                    esp.NameText.Visible = true
                else
                    esp.NameText.Visible = false
                end
                
                if showHealthBar then
                    local health = humanoid.Health
                    local maxHealth = humanoid.MaxHealth
                    local healthPercent = math.clamp(health / maxHealth, 0, 1)
                    
                    local barWidth = 4
                    local barHeight = math.max(height - 4, 10)
                    local barX = headPos2D.X - width/2 - 10
                    local barY = headPos2D.Y + 2
                    
                    esp.HealthBarOutline.Position = Vector2.new(barX - 1, barY - 1)
                    esp.HealthBarOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
                    esp.HealthBarOutline.Color = Color3.new(0, 0, 0)
                    esp.HealthBarOutline.Visible = true
                    
                    local fillHeight = barHeight * healthPercent
                    local fillY = barY + (barHeight - fillHeight)
                    
                    esp.HealthBarFill.Position = Vector2.new(barX, fillY)
                    esp.HealthBarFill.Size = Vector2.new(barWidth, fillHeight)
                    
                    local healthColor = Color3.new(1 - healthPercent, healthPercent, 0)
                    esp.HealthBarFill.Color = healthColor
                    esp.HealthBarFill.Visible = true
                else
                    esp.HealthBarOutline.Visible = false
                    esp.HealthBarFill.Visible = false
                end
                
                if showDistanceESP then
                    esp.DistanceText.Text = math.floor(distance) .. "m"
                    esp.DistanceText.Position = Vector2.new(headPos2D.X, headPos2D.Y + height/2 + 10)
                    esp.DistanceText.Color = teamColor
                    esp.DistanceText.Visible = true
                else
                    esp.DistanceText.Visible = false
                end
                
                if showChams then
                    applyChams(player, char, teamColor)
                else
                    removeChams(player)
                end
                
            else
                if esp.Box then esp.Box.Visible = false end
                if esp.Line then esp.Line.Visible = false end
                if esp.NameText then esp.NameText.Visible = false end
                if esp.HealthBarOutline then esp.HealthBarOutline.Visible = false end
                if esp.HealthBarFill then esp.HealthBarFill.Visible = false end
                if esp.DistanceText then esp.DistanceText.Visible = false end
                removeChams(player)
            end
        else
            if esp then
                if esp.Box then esp.Box.Visible = false end
                if esp.Line then esp.Line.Visible = false end
                if esp.NameText then esp.NameText.Visible = false end
                if esp.HealthBarOutline then esp.HealthBarOutline.Visible = false end
                if esp.HealthBarFill then esp.HealthBarFill.Visible = false end
                if esp.DistanceText then esp.DistanceText.Visible = false end
            end
            removeChams(player)
        end
    end
end

local function isVisible(target)
    if not visibleCheckEnabled then return true end
    
    local localChar = LocalPlayer.Character
    local targetChar = target.Character
    if not localChar or not targetChar then return false end
    
    local targetHead = targetChar:FindFirstChild("Head")
    if not targetHead then return false end
    
    local origin = Camera.CFrame.Position
    local targetPos = targetHead.Position
    
    local checkPoints = {
        targetPos,
        targetPos - Vector3.new(0, 1.5, 0),
        targetPos - Vector3.new(0, 3, 0)
    }
    
    for _, point in ipairs(checkPoints) do
        local direction = (point - origin).Unit
        local distance = (point - origin).Magnitude
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {localChar, targetChar}
        
        local raycastResult = workspace:Raycast(origin, direction * distance, raycastParams)
        
        if not raycastResult then
            return true
        end
        
        local hitModel = raycastResult.Instance:FindFirstAncestorOfClass("Model")
        if hitModel == targetChar then
            return true
        end
    end
    
    return false
end

local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        if teamCheck and not isEnemy(player) then
            continue
        end
        
        local char = player.Character
        if char and char:FindFirstChild("Head") then
            local head = char.Head
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local distanceToPlayer = (head.Position - Camera.CFrame.Position).Magnitude
                
                if not visibleCheckEnabled or isVisible(player) then
                    if distanceToPlayer < closestDistance then
                        closestPlayer = player
                        closestDistance = distanceToPlayer
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function getClosestPlayerInCircle()
    local closestPlayer = nil
    local closestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        if teamCheck and not isEnemy(player) then
            continue
        end
        
        local char = player.Character
        if char and char:FindFirstChild("Head") then
            local head = char.Head
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local screenPos = Vector2.new(headPos.X, headPos.Y)
                local distanceToCenter = (screenPos - screenCenter).Magnitude
                
                if distanceToCenter <= circleRadius then
                    if not visibleCheckEnabled or isVisible(player) then
                        if distanceToCenter < closestDistance then
                            closestPlayer = player
                            closestDistance = distanceToCenter
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimAtTarget(predictedTargetPosition)
    if not predictedTargetPosition then return end 
    
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then return end
    
    local cameraPosition = currentCamera.CFrame.Position
    local direction = (predictedTargetPosition - cameraPosition).Unit
    
    currentCamera.CFrame = CFrame.lookAt(cameraPosition, cameraPosition + direction)
end

local function updateCircle()
    if circle then
        circle.Visible = showFOV
        circle.Radius = circleRadius
        if rainbowFOV then
            circle.Color = getRainbowColor()
        else
            circle.Color = Color3.new(1, 1, 1)
        end
        local currentCamera = workspace.CurrentCamera
        if currentCamera then
            circle.Position = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)
        end
    end
end

local function rejoin()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
end

local MainTab = Window:CreateTab("Main", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local ProtectionTab = Window:CreateTab("Protection", 4483362458)

MainTab:CreateParagraph({
    Title = "BYW SCRIPT v1.7.0",
    Content = "Добро пожаловать в BYW SCRIPT!\n\nРазработчик: Bdev\nВерсия: 1.7.0\n\nЧто нового в v1.7.0:\n• Добавлено Health Bar\n• Добавлено Distance ESP\n• Добавлен ESP Distance (слайдер)\n• Добавлен Custom Spawn\n• Добавлен Aim Prediction (BETA)\n• Удалено Jump Power\n• Удалено Server Info\n• Исправлен баг с AimBot\n• Исправлен баг с Visible Check\n• Поменяли окраску меню теперь оно черно-белое"
})

local AimBotToggle = AimTab:CreateToggle({
    Name = "Aim Bot",
    CurrentValue = false,
    Flag = "AimBotToggle",
    Callback = function(Value)
        aimBotEnabled = Value
    end,
})

local AimPredictionToggle = AimTab:CreateToggle({
    Name = "Aim Prediction (BETA)",
    CurrentValue = false,
    Flag = "AimPredictionToggle",
    Callback = function(Value)
        aimPredictionEnabled = Value
    end,
})

local ShowFOVToggle = AimTab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = false,
    Flag = "ShowFOVToggle",
    Callback = function(Value)
        showFOV = Value
        updateCircle()
    end,
})

local VisibleCheckToggle = AimTab:CreateToggle({
    Name = "Visible Check",
    CurrentValue = false,
    Flag = "VisibleCheckToggle",
    Callback = function(Value)
        visibleCheckEnabled = Value
    end,
})

local RainbowFOVToggle = AimTab:CreateToggle({
    Name = "Rainbow FOV",
    CurrentValue = false,
    Flag = "RainbowFOVToggle",
    Callback = function(Value)
        rainbowFOV = Value
    end,
})

local CircleSizeSlider = AimTab:CreateSlider({
    Name = "FOV Circle Size",
    Range = {10, 200},
    Increment = 5,
    Suffix = "px",
    CurrentValue = 50,
    Flag = "CircleSizeSlider",
    Callback = function(Value)
        circleRadius = Value
        updateCircle()
    end,
})

local PredictionStrengthSlider = AimTab:CreateSlider({
    Name = "Prediction Strength",
    Range = {0, 1.0},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = 0.1,
    Flag = "PredictionStrengthSlider",
    Callback = function(Value)
        predictionStrength = Value
    end,
})

local BoxesToggle = ESPTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Flag = "BoxesToggle",
    Callback = function(Value)
        showBoxes = Value
        if not Value then
            clearESP()
        end
    end,
})

local LinesToggle = ESPTab:CreateToggle({
    Name = "Line ESP", 
    CurrentValue = false,
    Flag = "LinesToggle",
    Callback = function(Value)
        showLines = Value
        clearESP()
    end,
})

local NamesToggle = ESPTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Flag = "NamesToggle",
    Callback = function(Value)
        showNames = Value
        if not Value then
            clearESP()
        end
    end,
})

local ChamsToggle = ESPTab:CreateToggle({
    Name = "Chams ESP",
    CurrentValue = false,
    Flag = "ChamsToggle",
    Callback = function(Value)
        showChams = Value
        if not Value then
            clearESP()
        end
    end,
})

local HealthBarToggle = ESPTab:CreateToggle({
    Name = "Health Bar",
    CurrentValue = false,
    Flag = "HealthBarToggle",
    Callback = function(Value)
        showHealthBar = Value
        if not Value then
            clearESP()
        end
    end,
})

local DistanceESPToggle = ESPTab:CreateToggle({
    Name = "Distance ESP",
    CurrentValue = false,
    Flag = "DistanceESPToggle",
    Callback = function(Value)
        showDistanceESP = Value
        if not Value then
            clearESP()
        end
    end,
})

local RainbowESPToggle = ESPTab:CreateToggle({
    Name = "Rainbow ESP",
    CurrentValue = false,
    Flag = "RainbowESPToggle",
    Callback = function(Value)
        rainbowESP = Value
    end,
})

local TeamCheckToggle = ESPTab:CreateToggle({
    Name = "Team Check (Aim,ESP)",
    CurrentValue = false,
    Flag = "TeamCheckToggle",
    Callback = function(Value)
        teamCheck = Value
        clearESP()
    end,
})

local ESPDistanceSlider = ESPTab:CreateSlider({
    Name = "ESP Distance",
    Range = {100, 1000},
    Increment = 50,
    Suffix = "studs",
    CurrentValue = 1000,
    Flag = "ESPDistanceSlider",
    Callback = function(Value)
        espMaxDistance = Value
    end,
})

local CustomSpawnToggle = MiscTab:CreateToggle({
    Name = "Custom Spawn",
    CurrentValue = false,
    Flag = "CustomSpawnToggle",
    Callback = function(Value)
        toggleCustomSpawn(Value)
    end,
})

local InfiniteJumpToggle = MiscTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        toggleInfiniteJump(Value)
    end,
})

local SpeedHackToggle = MiscTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Flag = "SpeedHackToggle",
    Callback = function(Value)
        speedHackEnabled = Value
        updateSpeed()
    end,
})

local SpeedSlider = MiscTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 100},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        playerSpeed = Value
        updateSpeed()
    end,
})

local NoclipToggle = MiscTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        toggleNoclip(Value)
    end,
})

local RejoinButton = ProtectionTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        rejoin()
    end,
})

RunService.Heartbeat:Connect(function()
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then return end
    
    updateESP()
    updateCircle()
    updateSpeed()
    
    if aimBotEnabled then
        local closestPlayer
        if showFOV then
            closestPlayer = getClosestPlayerInCircle()
        else
            closestPlayer = getClosestPlayer()
        end
        
        if closestPlayer then
            local targetChar = closestPlayer.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChildOfClass("Humanoid") then
                local targetHead = targetChar.Head
                local targetPosition = targetHead.Position
                local targetHRP = targetChar.HumanoidRootPart
                local targetVelocity = targetHRP.Velocity
                local predictedPosition = targetPosition
                if aimPredictionEnabled then
                    predictedPosition = targetPosition + (targetVelocity * predictionStrength)
                end
                aimAtTarget(predictedPosition)
            end
        end
    end
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        toggleInfiniteJump(false)
        toggleCustomSpawn(false)
        for playerName, highlight in pairs(ChamsHighlights) do
            if highlight then
                highlight:Destroy()
            end
        end
        ChamsHighlights = {}
    end
    removeESP(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

print("BYW SCRIPT v1.7.0 loaded!")
