local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Player and plot setup
repeat task.wait() until game:IsLoaded()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local userId = player.UserId
local plotName = tostring(userId) .. "_Plot"
local plotFolder = workspace:WaitForChild("Player_Plots_F")
local plot = plotFolder:FindFirstChild(plotName)

if not plot then
    WindUI:Notify({
        Title = "Error",
        Content = "Could not find your plot: " .. plotName,
        Icon = "triangle-alert",
        Duration = 5,
    })
    return
end

local buttonsFolder = plot:WaitForChild("Builds_F"):WaitForChild("Buttons_F")
local mailbox = plot:WaitForChild("Mailbox"):WaitForChild("Main_Censor")

-- Toggle states
local autoPurchase = false
local autoCollect = false

-- Create main UI window
local Window = WindUI:CreateWindow({
    Title = "zell Hub",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "Automation Script",
    Folder = "TycoonHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    ScrollBarEnabled = true,
})

-- Create Automation section and tab
local AutomationSection = Window:Section({
    Title = "Automation",
    Opened = true,
})

local AutomationTab = AutomationSection:Tab({
    Title = "Automation",
    Icon = "settings",
    Desc = "Manage automation settings for your tycoon.",
    ShowTabTitle = true,
})

-- Add toggles to the Automation tab
AutomationTab:Toggle({
    Title = "Auto Purchase",
    Desc = "Automatically interact with purchase buttons.",
    Value = false,
    Callback = function(state)
        autoPurchase = state
        if state then
            WindUI:Notify({
                Title = "Auto Purchase",
                Content = "Auto Purchase has been enabled.",
                Duration = 3,
            })
        else
            WindUI:Notify({
                Title = "Auto Purchase",
                Content = "Auto Purchase has been disabled.",
                Duration = 3,
            })
        end
    end,
})

AutomationTab:Toggle({
    Title = "Auto Collect",
    Desc = "Automatically collect from the mailbox.",
    Value = false,
    Callback = function(state)
        autoCollect = state
        if state then
            WindUI:Notify({
                Title = "Auto Collect",
                Content = "Auto Collect has been enabled.",
                Duration = 3,
            })
        else
            WindUI:Notify({
                Title = "Auto Collect",
                Content = "Auto Collect has been disabled.",
                Duration = 3,
            })
        end
    end,
})

-- Auto Purchase logic
task.spawn(function()
    while true do
        if autoPurchase then
            for _, button in ipairs(buttonsFolder:GetChildren()) do
                local part = button:FindFirstChild("Touch_P")
                if part then
                    hrp.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.3)
                end
            end
        end
        task.wait(1)
    end
end)

-- Auto Collect logic
task.spawn(function()
    while true do
        if autoCollect then
            hrp.CFrame = mailbox.CFrame + Vector3.new(0, 2, 0)
            task.wait(1.5)
        end
        task.wait(1)
    end
end)

-- Select the Automation tab by default
Window:SelectTab(1)

-- Notify when UI is closed
Window:OnClose(function()
    WindUI:Notify({
        Title = "Tycoon Hub",
        Content = "UI has been closed.",
        Duration = 5,
    })
end)
