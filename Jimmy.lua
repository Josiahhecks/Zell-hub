-- Merged Gem Farming Script for 99 Nights in the Forest
-- Flashlight Hub Themed Full-Screen UI with Rainbow Stroke Effect
-- Merged logic from: opFarmGems99Nights.txt + local Players = gameGetServic.docx

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote / Interface
local gemRemote
if ReplicatedStorage:FindFirstChild("RemoteEvents") then
    gemRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("RequestTakeDiamonds")
end

local interface = nil
local gemCountLabel = { Text = "0" }
if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
    interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
    if interface then
        local success, lbl = pcall(function()
            return interface:WaitForChild("DiamondCount"):WaitForChild("Count")
        end)
        if success and lbl then gemCountLabel = lbl end
    end
end

-- State
local startTime = tick()
local farmingEnabled = false
local chest, proxPrompt

-- Helper: rainbow stroke
local function rainbowStroke(stroke)
    task.spawn(function()
        while stroke and stroke.Parent do
            for hue = 0, 1, 0.01 do
                if not stroke.Parent then break end
                stroke.Color = Color3.fromHSV(hue, 1, 1)
                task.wait(0.02)
            end
        end
    end)
end

-- Helper: format time
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Server hopping (attempt to teleport to another public server)
local function hopServer()
    local gameId = game.PlaceId
    -- Keep trying until a valid server found and teleport attempted
    while true do
        local success, body = pcall(function()
            return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
        end)
        if success and body then
            local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
            if ok and data and data.data then
                for _, server in ipairs(data.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        pcall(function()
                            TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
                        end)
                        return
                    end
                end
            end
        end
        task.wait(0.5)
    end
end

-- Detect duplicate character and hop
task.spawn(function()
    while true do
        task.wait(1)
        if farmingEnabled then
            local chars = workspace:FindFirstChild("Characters")
            if chars then
                for _, char in pairs(chars:GetChildren()) do
                    if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                        if char.Humanoid.DisplayName == LocalPlayer.DisplayName then
                            pcall(function()
                                StarterGui:SetCore("SendNotification", {
                                    Title = "Notification",
                                    Text = "Duplicate character detected, hopping servers...",
                                    Duration = 3
                                })
                            end)
                            hopServer()
                            return
                        end
                    end
                end
            end
        end
    end
end)

-- ===== UI: Flashlight Hub Themed Full-Screen UI =====
local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "FlashlightHubGemUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local bgFrame = Instance.new("Frame", screenGui)
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
local bgGradient = Instance.new("UIGradient", bgFrame)
bgGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
}
bgGradient.Rotation = 45
bgFrame.BackgroundTransparency = 0.6
bgFrame.BorderSizePixel = 0

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0.4, 0, 0.35, 0)
mainFrame.Position = UDim2.new(0.3, 0, 0.325, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 15)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 3
rainbowStroke(mainStroke)

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔦 Flashlight Hub - Gem Farmer"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 24
titleLabel.TextStrokeTransparency = 0.5

local gemsLabel = Instance.new("TextLabel", mainFrame)
gemsLabel.Size = UDim2.new(1, -20, 0.3, 0)
gemsLabel.Position = UDim2.new(0, 10, 0.3, 0)
gemsLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
gemsLabel.BackgroundTransparency = 0.4
gemsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
gemsLabel.Font = Enum.Font.SourceSansBold
gemsLabel.TextSize = 20
gemsLabel.BorderSizePixel = 0
local gemsCorner = Instance.new("UICorner", gemsLabel)
gemsCorner.CornerRadius = UDim.new(0, 10)

local timeLabel = Instance.new("TextLabel", mainFrame)
timeLabel.Size = UDim2.new(1, -20, 0.3, 0)
timeLabel.Position = UDim2.new(0, 10, 0.6, 0)
timeLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
timeLabel.BackgroundTransparency = 0.4
timeLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
timeLabel.Font = Enum.Font.SourceSansBold
timeLabel.TextSize = 20
timeLabel.BorderSizePixel = 0
local timeCorner = Instance.new("UICorner", timeLabel)
timeCorner.CornerRadius = UDim.new(0, 10)

local settingsFrame = Instance.new("Frame", screenGui)
settingsFrame.Size = UDim2.new(0.2, 0, 0.25, 0)
settingsFrame.Position = UDim2.new(0.78, 0, 0.73, 0)
settingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
settingsFrame.BorderSizePixel = 0
settingsFrame.Active = true
settingsFrame.Draggable = true
local settingsCorner = Instance.new("UICorner", settingsFrame)
settingsCorner.CornerRadius = UDim.new(0, 15)
local settingsStroke = Instance.new("UIStroke", settingsFrame)
settingsStroke.Thickness = 2
rainbowStroke(settingsStroke)

local toggleButton = Instance.new("TextButton", settingsFrame)
toggleButton.Size = UDim2.new(1, -10, 0.4, 0)
toggleButton.Position = UDim2.new(0, 5, 0.1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
toggleButton.Text = "Start Farming"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 0)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
local toggleCorner = Instance.new("UICorner", toggleButton)
toggleCorner.CornerRadius = UDim.new(0, 10)

local exitButton = Instance.new("TextButton", settingsFrame)
exitButton.Size = UDim2.new(1, -10, 0.4, 0)
exitButton.Position = UDim2.new(0, 5, 0.5, 0)
exitButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
exitButton.Text = "Exit Script"
exitButton.TextColor3 = Color3.fromRGB(255, 255, 0)
exitButton.Font = Enum.Font.SourceSansBold
exitButton.TextSize = 16
local exitCorner = Instance.new("UICorner", exitButton)
exitCorner.CornerRadius = UDim.new(0, 10)

-- Update gem count and runtime display
task.spawn(function()
    while true do
        task.wait(0.2)
        local countText = "N/A"
        pcall(function() countText = tostring(gemCountLabel.Text or "0") end)
        gemsLabel.Text = "Gems: " .. countText
        timeLabel.Text = "Runtime: " .. formatTime(tick() - startTime)
    end
end)

-- ===== Farming logic (integrated/improved) =====
local function farmGems()
    while farmingEnabled do
        task.wait(0.1)

        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end

        -- Find gem chest (prefer Stronghold Diamond Chest)
        chest = workspace:FindFirstChild("Items") and workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest")
        if not chest then
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Flashlight Hub",
                    Text = "No gem chest found, hopping servers...",
                    Duration = 3
                })
            end)
            hopServer()
            return
        end

        -- Teleport to chest (slightly above to avoid clipping)
        pcall(function()
            LocalPlayer.Character:PivotTo(CFrame.new(chest:GetPivot().Position + Vector3.new(0, 5, 0)))
        end)

        -- Find proximity prompt inside chest
        proxPrompt = nil
        local proxCheckStart = tick()
        repeat
            task.wait(0.1)
            local mainPart = chest:FindFirstChild("Main")
            if mainPart and mainPart:FindFirstChild("ProximityAttachment") then
                proxPrompt = mainPart.ProximityAttachment:FindFirstChild("ProximityInteraction") or mainPart.ProximityAttachment:FindFirstChildWhichIsA("ProximityPrompt") -- flexible
            end
            if (tick() - proxCheckStart) > 6 then break end
        until proxPrompt

        if not proxPrompt then
            -- If no prox prompt found, try again or hop
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Flashlight Hub",
                    Text = "Proximity prompt not found, hopping servers...",
                    Duration = 3
                })
            end)
            hopServer()
            return
        end

        -- Interact with chest (attempt for up to 10 seconds)
        local interactStart = tick()
        while proxPrompt and proxPrompt.Parent and (tick() - interactStart) < 10 and farmingEnabled do
            pcall(function()
                -- support both fireproximityprompt or fireproximityprompt shorthand
                if typeof(fireproximityprompt) == "function" then
                    pcall(function() fireproximityprompt(proxPrompt) end)
                else
                    -- fallback: try .Triggered or other interaction (best-effort)
                    if proxPrompt.Trigger then
                        pcall(function() proxPrompt:Trigger() end)
                    end
                end
            end)
            task.wait(0.2)
        end

        -- If prompt still present after timeout -> server likely starting; hop
        if proxPrompt and proxPrompt.Parent then
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Flashlight Hub",
                    Text = "Chest interaction timed out / stronghold starting, hopping servers...",
                    Duration = 3
                })
            end)
            hopServer()
            return
        end

        -- Wait for diamonds to spawn
        repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or not farmingEnabled
        if not farmingEnabled then return end

        -- Collect diamonds (fire remote for each Model named "Diamond")
        for _, v in pairs(workspace:GetDescendants()) do
            if v.ClassName == "Model" and v.Name == "Diamond" and farmingEnabled then
                if gemRemote and typeof(gemRemote.FireServer) == "function" then
                    pcall(function() gemRemote:FireServer(v) end)
                else
                    -- Try using a common fallback remote name
                    local fallback = ReplicatedStorage:FindFirstChild("RemoteEvents")
                    if fallback and fallback:FindFirstChild("RequestTakeDiamonds") then
                        pcall(function() fallback.RequestTakeDiamonds:FireServer(v) end)
                    end
                end
            end
        end

        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Flashlight Hub",
                Text = "Collected all gems, hopping servers...",
                Duration = 3
            })
        end)
        task.wait(1)
        hopServer()
        return
    end
end

-- Toggle button functionality
toggleButton.MouseButton1Click:Connect(function()
    farmingEnabled = not farmingEnabled
    toggleButton.BackgroundColor3 = farmingEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    toggleButton.Text = farmingEnabled and "Stop Farming" or "Start Farming"
    if farmingEnabled then
        startTime = tick()
        task.spawn(farmGems)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Flashlight Hub",
                Text = "Gem farming started!",
                Duration = 3
            })
        end)
    else
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Flashlight Hub",
                Text = "Gem farming stopped!",
                Duration = 3
            })
        end)
    end
end)

-- Exit button functionality
exitButton.MouseButton1Click:Connect(function()
    farmingEnabled = false
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Flashlight Hub",
            Text = "Gem Farmer script terminated.",
            Duration = 3
        })
    end)
end)

-- Initial notification
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Flashlight Hub",
        Text = "Gem Farmer loaded for 99 Nights in the Forest. Use the settings frame to control farming.",
        Duration = 5
    })
end)
