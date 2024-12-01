local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera

-- GUI setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.IgnoreGuiInset = true

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Position = UDim2.new(0.5, -50, 0.05, 0)
Frame.Size = UDim2.new(0, 100, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.5

local Label = Instance.new("TextLabel")
Label.Parent = Frame
Label.Size = UDim2.new(1, 0, 0.5, 0)
Label.Text = "Aimbot"
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.TextSize = 20
Label.BackgroundTransparency = 1

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Frame
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Position = UDim2.new(1, -40, 0.5, -15)
ToggleButton.Text = ""
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red
ToggleButton.BorderSizePixel = 0

local aimbotEnabled = false
local targetPlayer = nil
local initialTargetHealth = nil

-- Function to determine the player's team
local function getTeam(plr)
    if plr.Team then
        return plr.Team.Name
    elseif plr:GetAttribute("Team") then
        return plr:GetAttribute("Team")
    end
    return "No Team"
end

-- Function to check if a player is valid for targeting
local function isValidTarget(player)
    local localTeam = getTeam(LocalPlayer)
    local targetTeam = getTeam(player)

    if localTeam == "Civilians" then
        return false
    elseif localTeam == "Cowboys" and (targetTeam == "Cowboys" or targetTeam == "Civilians") then
        return false
    elseif localTeam == "Outlaws" and targetTeam == "Civilians" then
        return false
    end
    return true
end

-- Function to find the nearest valid player
local function getNearestPlayer()
    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and isValidTarget(player) then
            local distance = (Camera.CFrame.Position - player.Character.Head.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestPlayer = player
            end
        end
    end
    return nearestPlayer
end

-- Aimbot functionality
local function updateAimbot()
    if aimbotEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local targetHead = targetPlayer.Character.Head
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
    end
end

-- Function to lock onto a damaged player
local function trackDamagedPlayer()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = targetPlayer.Character.Humanoid
        if humanoid.Health < initialTargetHealth then
            -- Continue tracking this player as they have taken damage
            return true
        end
    end
    return false
end

-- Toggle aimbot on/off
ToggleButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green
        print("Aimbot enabled")
        targetPlayer = getNearestPlayer()
        if targetPlayer and targetPlayer.Character then
            initialTargetHealth = targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Health or 100
        end
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red
        targetPlayer = nil
        print("Aimbot disabled")
    end
end)

-- Update the target player and aimbot every frame
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        if not trackDamagedPlayer() then
            targetPlayer = getNearestPlayer()
            if targetPlayer and targetPlayer.Character then
                initialTargetHealth = targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Health or 100
            end
        end
        updateAimbot()
    end
end)

-- Ensure the GUI persists after death
LocalPlayer.CharacterAdded:Connect(function()
    aimbotEnabled = false
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red
    targetPlayer = nil
    initialTargetHealth = nil
    print("Aimbot disabled due to death/reset")
end)
