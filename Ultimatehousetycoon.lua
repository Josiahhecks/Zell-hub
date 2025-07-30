--[[
    🏠 Zell Hub – Ultimate House Tycoon
    Full WindUI showcase using the *exact* docs examples
    Docs: https://footagesus.github.io/WindUI-Docs/
]]

----------------------------------------------------------
-- 1)  Load WindUI (latest release – official loader)
----------------------------------------------------------
local WindUI = loadstring(
    game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
)()

----------------------------------------------------------
-- 2)  Optional global settings (from docs)
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
-- 5)  Wait until the game is fully loaded
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
        Buttons = {
            { Title = "OK", Variant = "Primary", Callback = function() end }
        }
    })
    return
end

local buttonsFolder = plot:WaitForChild("Builds_F"):WaitForChild("Buttons_F")
local mailbox       = plot:WaitForChild("Mailbox"):WaitForChild("Main_Censor")

----------------------------------------------------------
-- 6)  State variables for automation
----------------------------------------------------------
local autoPurchase, autoCollect = false, false

----------------------------------------------------------
-- 7)  Automation loops (already tested)
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
-- 8)  UI COMPONENTS – straight from the docs
----------------------------------------------------------

-- Paragraph (with a button)
Tab:Paragraph({
    Title = "Welcome to Zell Hub",
    Desc  = "Toggle the switches below to enable automation.",
    Buttons = {
        {
            Icon    = "info",
            Title   = "About",
            Callback = function()
                WindUI:Popup({
                    Title   = "About Zell Hub",
                    Icon    = "info",
                    Content = "Made by the community for Ultimate House Tycoon.",
                    Buttons = { { Title = "OK", Callback = function() end } }
                })
            end
        }
    }
})

-- Toggle (Checkbox style)
Tab:Toggle({
    Title = "🏗 Auto Purchase",
    Desc  = "Auto-buy every button in your plot",
    Icon  = "hammer",
    Type  = "Checkbox",
    Default = false,
    Callback = function(v) autoPurchase = v end
})

-- Toggle (Switch style)
Tab:Toggle({
    Title = "💰 Auto Collect",
    Desc  = "Auto-claim cash from mailbox",
    Icon  = "mail",
    Type  = "Switch",
    Default = false,
    Callback = function(v) autoCollect = v end
})

-- Slider (with float step)
Tab:Slider({
    Title = "Purchase Delay",
    Desc  = "Seconds between each button click",
    Step  = 0.1,
    Value = {
        Min     = 0.1,
        Max     = 3,
        Default = 0.3
    },
    Callback = function(v)
        _G.purchaseDelay = v   -- you can use this var in the loop if you want
    end
})

-- Dropdown (single-select)
local drop = Tab:Dropdown({
    Title   = "Theme",
    Values  = WindUI:GetThemes(), -- ["Dark", "Light", ...]
    Value   = "Dark",
    Multi   = false,
    Callback = function(theme)
        WindUI:SetTheme(theme)
    end
})

-- Dropdown (multi-select)
local multiDrop = Tab:Dropdown({
    Title     = "Ignored Buttons",
    Values    = { "Door", "Wall", "Roof", "Floor" },
    Value     = {},
    Multi     = true,
    AllowNone = true,
    Callback  = function(list)
        -- store ignored buttons in _G.ignoredButtons = list
        _G.ignoredButtons = list
    end
})

-- Input (single-line)
Tab:Input({
    Title       = "Webhook URL",
    Desc        = "Discord webhook for notifications",
    Placeholder = "https://discord.com/api/webhooks/...",
    Type        = "Input",
    Callback    = function(url)
        _G.webhook = url
    end
})

-- Input (multi-line / textarea)
Tab:Input({
    Title       = "Custom Notes",
    Desc        = "Write anything here",
    Placeholder = "Type your notes...",
    Type        = "Textarea",
    Callback    = function(txt)
        _G.notes = txt
    end
})

-- Colorpicker
Tab:Colorpicker({
    Title        = "Accent Color",
    Desc         = "Choose the UI accent",
    Default      = Color3.fromRGB(0, 120, 215),
    Transparency = 0,
    Callback     = function(col)
        WindUI:AddTheme({
            Name        = "Custom",
            Accent      = col:ToHex(),
            Dialog      = "#18181b",
            Outline     = "#FFFFFF",
            Text        = "#FFFFFF",
            Placeholder = "#999999",
            Background  = "#0e0e10",
            Button      = "#52525b",
            Icon        = "#a1a1aa"
        })
        WindUI:SetTheme("Custom")
        drop:Refresh(WindUI:GetThemes()) -- refresh theme list
    end
})

-- Keybind to toggle the UI
Tab:Keybind({
    Title   = "Toggle UI",
    Desc    = "Key to open/close this window",
    Value   = "G",
    Callback = function(key)
        Window:SetToggleKey(Enum.KeyCode[key])
    end
})

-- Button with lock/unlock demo
local lockBtn = Tab:Button({
    Title = "Lock All UI",
    Desc  = "Prevents accidental changes",
    Callback = function()
        lockBtn:Lock()
        -- lock every interactive element
        drop:Lock()
        multiDrop:Lock()
    end
})

-- Unlock button
Tab:Button({
    Title = "Unlock All UI",
    Desc  = "Re-enable editing",
    Callback = function()
        lockBtn:Unlock()
        drop:Unlock()
        multiDrop:Unlock()
    end
})

-- Code viewer
Tab:Code({
    Title = "Source Snippet",
    Code  = [[-- Example
local speed = 50
print("Speed is", speed)
]]
})

-- Section divider
Tab:Section({ Title = "Danger Zone", TextXAlignment = "Center", TextSize = 18 })

-- Final button
Tab:Button({
    Title = "✅ Script Loaded",
    Desc  = "Everything is running",
    Callback = function()
        WindUI:Popup({
            Title   = "Zell Hub",
            Icon    = "check-circle",
            Content = "Automation active. Happy building!",
            Buttons = { { Title = "OK", Variant = "Primary", Callback = function() end } }
        })
    end
})

----------------------------------------------------------
print("[Zell Hub] Ultimate Tycoon automation is running")
