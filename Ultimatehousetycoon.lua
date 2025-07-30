--[[  🏠 Zell Hub – Ultimate House Tycoon  ]]
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({ Title = "🔮 Zell Hub", Author = "Zell Hub", Theme = "Dark" })
local Tab    = Window:Tab({ Title = "Tycoon", Icon = "house" })

repeat task.wait() until game:IsLoaded()
local plr  = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")

local plot = workspace:WaitForChild("Player_Plots_F")[tostring(plr.UserId) .. "_Plot"]
if not plot then
    WindUI:Popup({ Title = "Plot Not Found", Content = "Load plot then re-execute.", Buttons = { { Title = "OK", Callback = function() end } } })
    return
end

local buttonsFolder = plot.Builds_F.Buttons_F
local mailbox       = plot.Mailbox.Main_Censor

--------------------------------------------------
--  STATE  ------------------------------------------------
local autoBuy   = false
local autoClaim = false

--------------------------------------------------
--  THREADS  ---------------------------------------------
task.spawn(function()
    while true do
        if autoBuy then
            for _, b in ipairs(buttonsFolder:GetChildren()) do
                local tp = b:FindFirstChild("Touch_P")
                if tp then
                    hrp.CFrame = tp.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.3)
                end
            end
        else
            task.wait(0.2) -- idle
        end
    end
end)

task.spawn(function()
    while true do
        if autoClaim then
            hrp.CFrame = mailbox.CFrame + Vector3.new(0, 2, 0)
        end
        task.wait(1.5)
    end
end)

--------------------------------------------------
--  TOGGLES  ---------------------------------------------
Tab:Toggle({
    Title    = "🏗 Auto Purchase",
    Icon     = "hammer",
    Type     = "Switch",
    Default  = false,
    Callback = function(v) autoBuy   = v end
})

Tab:Toggle({
    Title    = "💰 Auto Collect",
    Icon     = "mail",
    Type     = "Switch",
    Default  = false,
    Callback = function(v) autoClaim = v end
})

print("[Zell Hub] Ready – toggles active!")
