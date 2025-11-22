-- BYW SCRIPT v1.5.0
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "BYW SCRIPT v1.5.0",
   LoadingTitle = "BYW SCRIPT v1.5.0", 
   LoadingSubtitle = "by BYW",
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
   DisableRayfieldPrompts = true
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP Variables
local ESPObjects = {}
local circle

-- ESP Settings
local showBoxes = false
local showLines = false
local showNames = false
local showChams = false
local teamCheck = false
local aimBotEnabled = false
local visibleCheckEnabled = false
local circleRadius = 50
local showFOV = false
local rainbowFOV = false
local rainbowESP = false

-- New Variables v1.5.0
local speedHackEnabled = false
local playerSpeed = 16
local noclipEnabled = false
local infiniteJumpEnabled = false
local jumpPowerEnabled = false
local jumpPowerValue = 50

-- Rainbow Colors Function
local function getRainbowColor()
    local tick = tick()
    local r = math.sin(tick * 2) * 0.5 + 0.5
    local g = math.sin(tick * 2 + 2) * 0.5 + 0.5
    local b = math.sin(tick * 2 + 4) * 0.5 + 0.5
    return Color3.new(r, g, b)
end

-- Create FOV Circle
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

-- Jump Power Function
local function updateJumpPower()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        if jumpPowerEnabled then
            character.Humanoid.JumpPower = jumpPowerValue
        else
            character.Humanoid.JumpPower = 50
        end
    end
end

-- Infinite Jump Function
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

-- Speed Hack Function
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

-- Noclip Function
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
        Rayfield:Notify({
            Title = "Noclip",
            Content = "Режим ноклип включен",
            Duration = 3,
            Image = 4483362458,
        })
    else
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end

-- ESP Functions
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

-- Исправленная функция Chams
local ChamsHighlights = {}
local function applyChams(player, character, teamColor)
    if not character then return end
    
    -- Удаляем старые Highlight если есть
    if ChamsHighlights[player] then
        ChamsHighlights[player]:Destroy()
        ChamsHighlights[player] = nil
    end
    
    -- Создаем один Highlight на весь персонаж
    local highlight = Instance.new("Highlight")
    highlight.Parent = game:GetService("CoreGui")
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = teamColor
    highlight.FillTransparency = 0.3  -- Меньше прозрачности для лучшей видимости
    highlight.OutlineColor = Color3.new(0, 0, 0)  -- Черная обводка
    highlight.OutlineTransparency = 0  -- Непрозрачная обводка
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
    
    ESPObjects[player] = {
        Box = box, 
        Line = line, 
        NameText = nameText
    }
    return ESPObjects[player]
end

local function removeESP(player)
    local esp = ESPObjects[player]
    if esp then
        if esp.Box then esp.Box:Remove() end
        if esp.Line then esp.Line:Remove() end
        if esp.NameText then esp.NameText:Remove() end
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
        end
        removeChams(player)
    end
end

local function updateESP()
    for player, esp in pairs(ESPObjects) do
        if esp then
            if esp.Box then esp.Box.Visible = false end
            if esp.Line then esp.Line.Visible = false end
            if esp.NameText then esp.NameText.Visible = false end
        end
        if not showChams then
            removeChams(player)
        end
    end

    if not (showBoxes or showLines or showNames or showChams) then return end

    for _, player in pairs(Players:GetPlayers()) do
        if not shouldShowESP(player) then
            local esp = ESPObjects[player]
            if esp then
                if esp.Box then esp.Box.Visible = false end
                if esp.Line then esp.Line.Visible = false end
                if esp.NameText then esp.NameText.Visible = false end
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
                
                -- Calculate distance
                local distance = 0
                if LocalPlayer.Character and isValidCharacter(LocalPlayer.Character) then
                    distance = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                end
                
                local teamColor = rainbowESP and getRainbowColor() or getTeamColor(player)
                
                -- Box ESP
                if showBoxes then
                    esp.Box.Position = Vector2.new(headPos2D.X - width/2, headPos2D.Y)
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Visible = true
                    esp.Box.Color = teamColor
                else
                    esp.Box.Visible = false
                end
                
                -- Line ESP
                if showLines then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.Line.From = screenCenter
                    esp.Line.To = Vector2.new(headPos2D.X, headPos2D.Y)
                    esp.Line.Color = teamColor
                    esp.Line.Visible = true
                else
                    esp.Line.Visible = false
                end
                
                -- Name ESP с дистанцией
                if showNames then
                    esp.NameText.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
                    esp.NameText.Position = Vector2.new(headPos2D.X, headPos2D.Y - 40)
                    esp.NameText.Color = teamColor
                    esp.NameText.Visible = true
                else
                    esp.NameText.Visible = false
                end
                
                -- Chams ESP (исправленная версия)
                if showChams then
                    applyChams(player, char, teamColor)
                else
                    removeChams(player)
                end
                
            else
                if esp.Box then esp.Box.Visible = false end
                if esp.Line then esp.Line.Visible = false end
                if esp.NameText then esp.NameText.Visible = false end
                removeChams(player)
            end
        else
            if esp then
                if esp.Box then esp.Box.Visible = false end
                if esp.Line then esp.Line.Visible = false end
                if esp.NameText then esp.NameText.Visible = false end
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

local function aimAtTarget(target)
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    if not head then return end
    
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then return end
    
    local targetPosition = head.Position
    local cameraPosition = currentCamera.CFrame.Position
    local direction = (targetPosition - cameraPosition).Unit
    
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
    Rayfield:Notify({
        Title = "Rejoin",
        Content = "Перезаходим на сервер...",
        Duration = 3,
        Image = 4483362458,
    })
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
end

-- Server Info Function
local function getServerInfo()
    local players = #Players:GetPlayers()
    local maxPlayers = game.PlaceId == 0 and "Unknown" or 10 -- Пример
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    Rayfield:Notify({
        Title = "Server Info",
        Content = "Игроков: " .. players .. "/" .. maxPlayers .. "\nPlace ID: " .. placeId .. "\nServer ID: " .. jobId,
        Duration = 5,
        Image = 4483362458,
    })
end

-- Create Tabs
local MainTab = Window:CreateTab("Main", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local ProtectionTab = Window:CreateTab("Protection", 4483362458)

-- Main Elements
MainTab:CreateParagraph({
    Title = "BYW SCRIPT v1.5.0",
    Content = "Добро пожаловать в BYW SCRIPT!\n\nРазработчик: BYW\nВерсия: 1.5.0\n\nЧто нового в v1.5.0:\n• Переименован SilentAim в Aim Bot\n• Добавлен Show FOV\n• Добавлен Visible Check\n• Добавлен Rainbow FOV и Rainbow ESP"
})

-- Server Info Button
local ServerInfoButton = MainTab:CreateButton({
    Name = "Server Info",
    Callback = function()
        getServerInfo()
    end,
})

-- Aim Elements
local AimBotToggle = AimTab:CreateToggle({
    Name = "Aim Bot",
    CurrentValue = false,
    Flag = "AimBotToggle",
    Callback = function(Value)
        aimBotEnabled = Value
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

-- ESP Elements
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

-- Chams Toggle (исправленная версия)
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

-- Misc Elements
local InfiniteJumpToggle = MiscTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        toggleInfiniteJump(Value)
    end,
})

local JumpPowerToggle = MiscTab:CreateToggle({
    Name = "Jump Power",
    CurrentValue = false,
    Flag = "JumpPowerToggle",
    Callback = function(Value)
        jumpPowerEnabled = Value
        updateJumpPower()
    end,
})

local JumpPowerSlider = MiscTab:CreateSlider({
    Name = "Jump Power Value",
    Range = {50, 200},
    Increment = 5,
    Suffix = "power",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        jumpPowerValue = Value
        updateJumpPower()
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

-- Protection Elements
local RejoinButton = ProtectionTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        rejoin()
    end,
})

-- Main Loop
RunService.Heartbeat:Connect(function()
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then return end
    
    updateESP()
    updateCircle()
    updateSpeed()
    updateJumpPower()
    
    if aimBotEnabled then
        local closestPlayer
        if showFOV then
            closestPlayer = getClosestPlayerInCircle()
        else
            closestPlayer = getClosestPlayer()
        end
        
        if closestPlayer then
            aimAtTarget(closestPlayer)
        end
    end
end)

-- Cleanup on script end
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        toggleInfiniteJump(false)
        -- Очищаем все Chams при выходе
        for playerName, highlight in pairs(ChamsHighlights) do
            if highlight then
                highlight:Destroy()
            end
        end
        ChamsHighlights = {}
    end
    removeESP(player)
end)

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

print("BYW SCRIPT v1.5.0 loaded!")
