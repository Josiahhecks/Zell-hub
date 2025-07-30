--[[
    🏠 Zell Hub – Ultimate House Tycoon
    WindUI v1.6+ | 30-Jul-2025
]]

----------------------------------------------------------
-- 1)  Load WindUI (latest release)
----------------------------------------------------------
local WindUI = loadstring(
    game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
)()

----------------------------------------------------------
-- 2)  Optional global tweaks
----------------------------------------------------------
WindUI:SetTheme("Dark")
WindUI:SetNotificationLower(true)

----------------------------------------------------------
-- 3)  Create the main window
----------------------------------------------------------
local Window = WindUI:CreateWindow({
    Title        = "🔮 Zell Hub",
    Icon         = "door-open",
    Author       = "Zell Hub",
    Theme        = "Dark",
    Transparent  = false,
    SideBarWidth = 200,
    ScrollBarEnabled = true
})

----------------------------------------------------------
-- 4)  Create the “Tycoon” tab
----------------------------------------------------------
local Tab = Window:Tab({ Title = "Tycoon", Icon = "house" })

----------------------------------------------------------
-- 5)  Wait for game & player data
----------------------------------------------------------
repeat task.wait() until game:IsLoaded()

local plr  = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")

local plot = workspace:WaitForChild("Player_Plots_F"):FindFirstChild(tostring(plr.UserId) .. "_Plot")
if not plot then
    WindUI:Popup({
        Title   = "Plot Not Found",
        Icon    = "x-circle",
        Content = "Load your plot, then re-execute the script.",
        Buttons = { { Title = "OK", Variant = "Primary", Callback = function() end } }
    })
    return
end

local buttonsFolder = plot:WaitForChild("Builds_F"):WaitForChild("Buttons_F")
local mailbox       = plot:WaitForChild("Mailbox"):WaitForChild("Main_Censor")

----------------------------------------------------------
-- 6)  State toggles (both present!)
----------------------------------------------------------
local autoPurchase = false
local autoCollect  = false

----------------------------------------------------------
-- 7)  Automation loops
----------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if autoPurchase then
            for _, b in ipairs(buttonsFolder:GetChildren()) do
                local tp = b:FindFirstChild("Touch_P")
                if tp and tp:IsA("BasePart") then
                    hrp.CFrame = tp.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.3)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if autoCollect then
            hrp.CFrame = mailbox.CFrame + Vector3.new(0, 2, 0)
        end
    end
end)

----------------------------------------------------------
-- 8)  UI COMPONENTS
----------------------------------------------------------
-- Paragraph
Tab:Paragraph({
    Title = "Welcome to Zell Hub",
    Desc  = "Toggle the switches below to enable automation."
})

-- Auto-Purchase toggle
Tab:Toggle({
    Title    = "🏗 Auto Purchase",
    Desc     = "Auto-buy every button in your plot",
    Icon     = "hammer",
    Type     = "Switch",
    Default  = false,
    Callback = function(v) autoPurchase = v end
})

-- Auto-Collect toggle
Tab:Toggle({
    Title    = "💰 Auto Collect",
    Desc     = "Auto-claim cash from mailbox",
    Icon     = "mail",
    Type     = "Switch",
    Default  = false,
    Callback = function(v) autoCollect = v end
})

-- Just a spacer
Tab:Section({ Title = "Extra Features", TextXAlignment = "Left" })

-- Final button
Tab:Button({
    Title = "✅ Script Loaded",
    Desc  = "Automation is active",
    Callback = function()
        WindUI:Popup({
            Title   = "Zell Hub",
            Icon    = "check-circle",
            Content = "Auto-Purchase and Auto-Collect are ready!",
            Buttons = { { Title = "OK", Variant = "Primary", Callback = function() end } }
        })
    end
})

print("[Zell Hub] Ultimate Tycoon automation is running")
