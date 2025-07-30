--[[  Zell Hub – Ultimate House Tycoon  ]]
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- 1) window & tab
local Window = WindUI:CreateWindow({ Title = "🔮 Zell Hub", Author = "Zell Hub", Theme = "Dark" })
local Tab    = Window:Tab({ Title = "Tycoon", Icon = "house" })

-- 2) wait for game
repeat task.wait() until game:IsLoaded()
local plr  = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")

local plot = workspace:WaitForChild("Player_Plots_F")[tostring(plr.UserId) .. "_Plot"]
if not plot then
    WindUI:Popup({
        Title   = "Plot Not Found",
        Content = "Load your plot and re-execute.",
        Buttons = { { Title = "OK", Callback = function() end } }
    })
    return
end

local buttonsFolder = plot.Builds_F.Buttons_F
local mailbox       = plot.Mailbox.Main_Censor

-- 3) toggles
local autoBuy   = false
local autoClaim = false

-- 4) loops
task.spawn(function()
    while task.wait() do
        if autoBuy then
            for _, b in ipairs(buttonsFolder:GetChildren()) do
                local part = b:FindFirstChild("Touch_P")
                if part then
                    hrp.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.3)
                end
            end
        else
            task.wait(0.5) -- idle
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if autoClaim then
            hrp.CFrame = mailbox.CFrame + Vector3.new(0, 2, 0)
        else
            task.wait(0.5) -- idle
        end
    end
end)

-- 5) toggles on the UI
Tab:Toggle({
    Title    = "🏗 Auto Purchase",
    Icon     = "hammer",
    Type     = "Switch",
    Default  = false,
    Callback = function(v) autoBuy = v end
})

Tab:Toggle({
    Title    = "💰 Auto Collect",
    Icon     = "mail",
    Type     = "Switch",
    Default  = false,
    Callback = function(v) autoClaim = v end
})
