-- FEEDER OTOMATIS - TANPA RAYFIELD
loadstring([[
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Remote
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then return print("❌ Remotes tidak ditemukan") end

local SubmitWord = remotes:FindFirstChild("SubmitWord")
local BillboardUpdate = remotes:FindFirstChild("BillboardUpdate")
local TypeSound = remotes:FindFirstChild("TypeSound")
local MatchUI = remotes:FindFirstChild("MatchUI")

-- State
local matchActive = false
local isMyTurn = false

-- Auto Join dengan Proximity
local function autoJoin()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            pcall(function()
                obj.PromptTriggered:Fire(LocalPlayer)
                obj.Triggered:Fire(LocalPlayer)
            end)
            return true
        end
    end
    return false
end

-- Loop auto join tiap 5 detik
spawn(function()
    while true do
        if not matchActive then
            autoJoin()
        end
        wait(5)
    end
end)

-- Fungsi ketik xxx
local function ketikXxx()
    if not isMyTurn then return end
    if not SubmitWord or not BillboardUpdate or not TypeSound then return end
    
    local word = "xxx"
    local current = ""
    
    for i = 1, #word do
        current = current .. word:sub(i, i)
        pcall(function()
            TypeSound:FireServer()
            BillboardUpdate:FireServer(current)
        end)
        wait(0.1)
    end
    
    wait(0.2)
    pcall(function()
        SubmitWord:FireServer(word)
    end)
    print("✅ xxx terkirim")
end

-- Match event
if MatchUI then
    MatchUI.OnClientEvent:Connect(function(cmd)
        if cmd == "ShowMatchUI" then
            matchActive = true
            isMyTurn = false
        elseif cmd == "HideMatchUI" then
            matchActive = false
            isMyTurn = false
        elseif cmd == "StartTurn" then
            isMyTurn = true
            wait(0.3)
            ketikXxx()
        elseif cmd == "EndTurn" then
            isMyTurn = false
        end
    end)
end

-- GUI SEDERHANA (custom)
local gui = Instance.new("ScreenGui")
gui.Name = "FeederGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "🍼 FEEDER AUTO"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0, 35)
status.BackgroundTransparency = 1
status.Text = "Status: " .. (matchActive and "Dalam Match" or "Mencari")
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Parent = frame

local joinBtn = Instance.new("TextButton")
joinBtn.Size = UDim2.new(0.9, 0, 0, 30)
joinBtn.Position = UDim2.new(0.05, 0, 0, 60)
joinBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
joinBtn.Text = "JOIN MANUAL (F3)"
joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
joinBtn.Font = Enum.Font.GothamBold
joinBtn.TextSize = 12
joinBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 5)
btnCorner.Parent = joinBtn

joinBtn.MouseButton1Click:Connect(autoJoin)

-- Update status
spawn(function()
    while true do
        status.Text = "Status: " .. (matchActive and "✅ Dalam Match" or "⏳ Mencari Match")
        wait(1)
    end
end)

-- Shortcut F3
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F3 then
        autoJoin()
    end
end)

print("✅ FEEDER READY - Tekan F3 untuk join manual")
]])
