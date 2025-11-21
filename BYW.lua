-- BYW SCRIPT
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "BYW SCRIPT  v1.0",
   LoadingTitle = "BYW SCRIPT", 
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
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP Variables
local ESPObjects = {}
local circle

-- ESP Settings
local showBoxes = false
local showLines = false
local showNames = false
local teamCheck = false
local aimbotEnabled = false
local silentAimEnabled = false
local wallCheckEnabled = false
local circleRadius = 50

-- Create Silent Aim Circle
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
    
    ESPObjects[player] = {Box = box, Line = line, NameText = nameText}
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
end

local function clearESP()
    for player, esp in pairs(ESPObjects) do
        if esp then
            if esp.Box then esp.Box.Visible = false end
            if esp.Line then esp.Line.Visible = false end
            if esp.NameText then esp.NameText.Visible = false end
        end
    end
end

local function updateESP()
    for player, esp in pairs(ESPObjects) do
        if esp then
            if esp.Box then esp.Box.Visible = false end
            if esp.Line then esp.Line.Visible = false end
            if esp.NameText then esp.NameText.Visible = false end
        end
    end

    if not (showBoxes or showLines or showNames) then return end

    for _, player in pairs(Players:GetPlayers()) do
        if not shouldShowESP(player) then
            local esp = ESPObjects[player]
            if esp then
                if esp.Box then esp.Box.Visible = false end
                if esp.Line then esp.Line.Visible = false end
                if esp.NameText then esp.NameText.Visible = false end
            end
            continue
        end
        
        local esp = ESPObjects[player]
        if not esp then
            esp = createESP(player)
        end
        if not esp then continue end
        
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
            local head = char.Head
            local hrp = char.HumanoidRootPart
            
            local headPos, headVisible = Camera:WorldToViewportPoint(head.Position)
            local feetPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
            
            if headVisible and feetPos.Z > 0 then
                local headPos2D = Vector2.new(headPos.X, headPos.Y)
                local feetPos2D = Vector2.new(feetPos.X, feetPos.Y)
                
                local height = math.abs(feetPos2D.Y - headPos2D.Y)
                local width = height * 0.6
                
                if showBoxes then
                    esp.Box.Position = Vector2.new(headPos2D.X - width/2, headPos2D.Y)
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Visible = true
                    esp.Box.Color = getTeamColor(player)
                else
                    esp.Box.Visible = false
                end
                
                if showLines then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.Line.From = screenCenter
                    esp.Line.To = Vector2.new(headPos2D.X, headPos2D.Y)
                    esp.Line.Color = getTeamColor(player)
                    esp.Line.Visible = true
                else
                    esp.Line.Visible = false
                end
                
                if showNames then
                    local distance = 0
                    if LocalPlayer.Character and isValidCharacter(LocalPlayer.Character) then
                        distance = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    end
                    
                    esp.NameText.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
                    esp.NameText.Position = Vector2.new(headPos2D.X, headPos2D.Y - 40)
                    esp.NameText.Color = getTeamColor(player)
                    esp.NameText.Visible = true
                else
                    esp.NameText.Visible = false
                end
                
            else
                if esp.Box then esp.Box.Visible = false end
                if esp.Line then esp.Line.Visible = false end
                if esp.NameText then esp.NameText.Visible = false end
            end
        else
            if esp then
                if esp.Box then esp.Box.Visible = false end
                if esp.Line then esp.Line.Visible = false end
                if esp.NameText then esp.NameText.Visible = false end
            end
        end
    end
end

local function isVisible(target)
    if not wallCheckEnabled then return true end
    
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
    local localChar = LocalPlayer.Character
    local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localHRP then return nil end
    
    local closestPlayer = nil
    local closestDistance = 500
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        if teamCheck and not isEnemy(player) then
            continue
        end
        
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
            local hrp = char.HumanoidRootPart
            local distance = (localHRP.Position - hrp.Position).Magnitude
            
            if distance < closestDistance then
                if not wallCheckEnabled or isVisible(player) then
                    closestPlayer = player
                    closestDistance = distance
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
                    if not wallCheckEnabled or isVisible(player) then
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
        circle.Visible = silentAimEnabled
        circle.Radius = circleRadius
        local currentCamera = workspace.CurrentCamera
        if currentCamera then
            circle.Position = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)
        end
    end
end

-- Create Tabs
local ESPTab = Window:CreateTab("ESP", 4483362458)
local AimTab = Window:CreateTab("Aim", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Добавляем отступ сверху для всех вкладок (пустой элемент)
local function addTopPadding(tab)
    tab:CreateSection(" ") -- Пустая секция для отступа
end

-- Добавляем отступы ко всем вкладкам
addTopPadding(ESPTab)
addTopPadding(AimTab) 
addTopPadding(SettingsTab)

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
        clearESP()
    end,
})

-- Aim Elements
local AimbotToggle = AimTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        aimbotEnabled = Value
    end,
})

local SilentAimToggle = AimTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAimToggle",
    Callback = function(Value)
        silentAimEnabled = Value
        updateCircle()
    end,
})

-- Settings Elements
local TeamCheckToggle = SettingsTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "TeamCheckToggle",
    Callback = function(Value)
        teamCheck = Value
        clearESP()
    end,
})

local WallCheckToggle = SettingsTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Flag = "WallCheckToggle",
    Callback = function(Value)
        wallCheckEnabled = Value
    end,
})

local CircleSizeSlider = SettingsTab:CreateSlider({
    Name = "Silent Aim Circle Size",
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

-- Main Loop
RunService.RenderStepped:Connect(function()
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then return end
    
    updateESP()
    updateCircle()
    
    if aimbotEnabled then
        local closest = getClosestPlayer()
        if closest then
            aimAtTarget(closest)
        end
    end
    
    if silentAimEnabled then
        local closestInCircle = getClosestPlayerInCircle()
        if closestInCircle then
            aimAtTarget(closestInCircle)
        end
    end
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

print("BYW SCRIPT loaded!")
