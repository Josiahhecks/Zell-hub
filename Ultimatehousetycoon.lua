-- Load WindUI from the correct source
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create window
local Window = WindUI:CreateWindow({
    Title = "Zell Hub",
    Icon = "cog",
    Author = "Zell Hub",
    Theme = "Dark",
    Transparent = false,
    SideBarWidth = 180,
    ScrollBarEnabled = true
})

-- Add a tab
local Tab = Window:Tab({
    Title = "Ultimate House Tycoon",
    Icon = "hammer",
    Locked = false
})

-- Wait for game
repeat task.wait() until game:IsLoaded()

-- Get player and plot
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local plot = workspace:WaitForChild("Player_Plots_F"):FindFirstChild(tostring(player.UserId) .. "_Plot")

if not plot then
    warn("Zell Hub: Player plot not found.")
    Tab:Paragraph("Plot not found. Please load into your tycoon first.")
    return
end

-- Get plot parts
local buttonsFolder = plot:WaitForChild("Builds_F"):WaitForChild("Buttons_F")
local mailbox = plot:WaitForChild("Mailbox"):WaitForChild("Main_Censor")

-- Automation state
local autoPurchase = false
local autoCollect = false

-- Purchase loop
task.spawn(function()
    while true do
        if autoPurchase then
            for _, button in pairs(buttonsFolder:GetChildren()) do
                local touchPart = button:FindFirstChild("Touch_P")
                if touchPart and touchPart:IsA("BasePart") then
                    hrp.CFrame = touchPart.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.3)
                end
            end
        end
        task.wait(1)
    end
end)

-- Collect loop
task.spawn(function()
    while true do
        if autoCollect then
            hrp.CFrame = mailbox.CFrame + Vector3.new(0, 2, 0)
            task.wait(1.5)
        end
        task.wait(1)
    end
end)

-- UI: Automation toggles
Tab:Checkbox({
    Title = "Auto Purchase",
    Description = "Buys available upgrades on your plot",
    Value = false,
    Callback = function(val)
        autoPurchase = val
    end
})

Tab:Checkbox({
    Title = "Auto Collect",
    Description = "Collects income from mailbox",
    Value = false,
    Callback = function(val)
        autoCollect = val
    end
})

-- UI: Script loaded message
Tab:Button({
    Title = "Confirm Load",
    Desc = "Script loaded successfully",
    Callback = function()
        print("Zell Hub loaded.")
    end
})
