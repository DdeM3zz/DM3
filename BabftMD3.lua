local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local gui = nil
local AutoFarmEnabled = false
local FlyEnabled = false
local FlySpeed = 50
local Camera = workspace.CurrentCamera
local NoclipEnabled = false
local AutoFarmButton, FlyButton, NoclipButton, SilentButton = nil, nil, nil, nil 

local AutoFarmSettings = {
    Enabled = false,
    Silent = false, 
}

local function Notify(text)
end

local function CreateTempPlatform(Position)
    local Platform = Instance.new("Part")
    Platform.Size = Vector3.new(10, 1, 10)
    Platform.Position = Position - Vector3.new(0, 6, 0)
    Platform.Anchored = true
    Platform.CanCollide = true
    Platform.Transparency = 1
    Platform.Parent = workspace

    local SurfaceGui = Instance.new("SurfaceGui")
    SurfaceGui.Face = Enum.NormalId.Top
    SurfaceGui.Parent = Platform
    SurfaceGui.AlwaysOnTop = true

    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Size = UDim2.new(1, 0, 1, 0)
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Text = "DM3"
    LogoLabel.Font = Enum.Font.SourceSansBold
    LogoLabel.TextSize = 100
    LogoLabel.TextTransparency = 0
    LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoLabel.RichText = true
    LogoLabel.Parent = SurfaceGui

    spawn(function()
        task.wait(3)
        Platform:Destroy()
    end)
end

local function AutoFarm()
    if not AutoFarmSettings.Enabled then return end

    local TriggerChest = workspace.BoatStages.NormalStages.TheEnd.GoldenChest.Trigger
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")

    local function TPAF(iteration)
        if not AutoFarmSettings.Enabled then return end

        local newPart = Instance.new("Part")
        newPart.Size = Vector3.new(5, 1, 5)
        newPart.Transparency = 1
        newPart.CanCollide = true
        newPart.Anchored = true
        newPart.Parent = workspace

        if not AutoFarmSettings.Silent then
            if iteration == 5 then
                TriggerChest.CFrame = CFrame.new(-51, 65, 984 + 4 * 770)
                task.delay(0.8, function()
                    workspace.ClaimRiverResultsGold:FireServer()
                end)
                humanoidRootPart.CFrame = CFrame.new(-51, 65, 984 + (iteration - 1) * 770)
            else
                if iteration == 1 then
                    humanoidRootPart.CFrame = CFrame.new(160.16104125976562, 29.595888137817383, 973.813720703125)
                else
                    humanoidRootPart.CFrame = CFrame.new(-51, 65, 984 + (iteration - 1) * 770)
                end
            end
            newPart.Position = humanoidRootPart.Position - Vector3.new(0, 2, 0)

            if iteration == 1 then
                task.wait(2.3)
            else
                repeat
                    task.wait()
                until #tostring(Players.LocalPlayer.OtherData:FindFirstChild("Stage"..(iteration-1)).Value) > 2
            end
            if iteration ~= 4 then
                workspace.ClaimRiverResultsGold:FireServer()
            end
            if iteration == 10 then
                if game:GetService("Lighting").OutdoorAmbient == Color3.fromRGB(200, 200, 200) or game:GetService("Lighting").OutdoorAmbient == Color3.fromRGB(255, 255, 255) then
                    task.wait(0.1)
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position.Z > 7529.08984 then
                        player.Character:BreakJoints()
                    end
                end
            end
        else
            if iteration == 1 then
                humanoidRootPart.CFrame = CFrame.new(160.16104125976562, 29.595888137817383, 973.813720703125)
            elseif iteration == 5 then
                TriggerChest.CFrame = CFrame.new(70.02417755126953, 138.9026336669922, 1371.6341552734375 + 3 * 770)
                task.delay(0.8, function()
                    workspace.ClaimRiverResultsGold:FireServer()
                end)
                humanoidRootPart.CFrame = CFrame.new(70.02417755126953, 138.9026336669922, 1371.6341552734375 + (iteration - 2) * 770)
            else
                humanoidRootPart.CFrame = CFrame.new(70.02417755126953, 138.9026336669922, 1371.6341552734375 + (iteration - 2) * 770)
            end

            newPart.Position = humanoidRootPart.Position - Vector3.new(0, 2, 0)

            if iteration == 1 then
                task.wait(2.3)
            else
                repeat
                    task.wait()
                until #tostring(Players.LocalPlayer.OtherData:FindFirstChild("Stage"..(iteration-1)).Value) > 2
            end
            if iteration ~= 4 then
                workspace.ClaimRiverResultsGold:FireServer()
            end
            if iteration == 10 then
                if game:GetService("Lighting").OutdoorAmbient == Color3.fromRGB(200, 200, 200) or game:GetService("Lighting").OutdoorAmbient == Color3.fromRGB(255, 255, 255) then
                    task.wait(0.1)
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position.Z > 7529.08984 then
                        player.Character:BreakJoints()
                    end
                end
            end
        end
        newPart:Destroy()
    end

    while AutoFarmSettings.Enabled do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            task.wait(0.1)
            character = player.Character
            if character then
                humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            end
            continue
        end

        for i = 1, 10 do
            if not AutoFarmSettings.Enabled then break end
            TPAF(i)
        end

        local Respawned = false
        local Connection
        Connection = player.CharacterAdded:Connect(function()
            Respawned = true
            Connection:Disconnect()
        end)
        repeat task.wait() until Respawned or not AutoFarmSettings.Enabled
        if AutoFarmSettings.Enabled then
            character = player.Character
            humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        end
    end

    if not AutoFarmSettings.Enabled then
        TriggerChest.CFrame = CFrame.new(-55.7065125, -358.739624, 9492.35645, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    end
end

local function StartAutoFarmLoop()
    spawn(function()
        AutoFarm()
    end)
end

local function StartFlying()
    local Character = player.Character
    if not Character or not Character:FindFirstChild("Humanoid") or not Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local Humanoid = Character.Humanoid
    local RootPart = Character.HumanoidRootPart
    Humanoid.PlatformStand = true

    local BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.Parent = RootPart

    local BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    BodyGyro.CFrame = RootPart.CFrame
    BodyGyro.Parent = RootPart

    local flyConnection
    flyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled or not Character or not Character.Parent or not RootPart.Parent or not Humanoid or Humanoid:GetState() == Enum.HumanoidStateType.Dead then
            if BodyVelocity then BodyVelocity:Destroy() end
            if BodyGyro then BodyGyro:Destroy() end
            if Humanoid then Humanoid.PlatformStand = false end
            if flyConnection then flyConnection:Disconnect() end
            return
        end

        local CameraCFrame = Camera.CFrame
        local MoveDirection = Vector3.new(0, 0, 0)

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            MoveDirection = MoveDirection + CameraCFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            MoveDirection = MoveDirection - CameraCFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            MoveDirection = MoveDirection - CameraCFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            MoveDirection = MoveDirection + CameraCFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.E) then
            MoveDirection = MoveDirection + Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then
            MoveDirection = MoveDirection - Vector3.new(0, 1, 0)
        end

        if MoveDirection.Magnitude > 0 then
            MoveDirection = MoveDirection.Unit * FlySpeed
        end
        BodyVelocity.Velocity = MoveDirection
        BodyGyro.CFrame = CFrame.new(RootPart.Position, RootPart.Position + CameraCFrame.LookVector)
    end)

    spawn(function()
        while FlyEnabled do
            task.wait(0.1)
        end
        if BodyVelocity then BodyVelocity:Destroy() end
        if BodyGyro then BodyGyro:Destroy() end
        if Humanoid then Humanoid.PlatformStand = false end
        if flyConnection then flyConnection:Disconnect() end
    end)
end

local function StartNoclip()
    spawn(function()
        while NoclipEnabled and player.Character do
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            task.wait(0.1)
        end

        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end)
end

local function makeSlider(name, min, max, val, parent, callback)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Text = name .. ": " .. val
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.BackgroundTransparency = 1

    local bar = Instance.new("TextButton", parent)
    bar.Size = UDim2.new(1, -20, 0, 20)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bar.Text = ""

    local fill = Instance.new("Frame", bar)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
    fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
    fill.BorderSizePixel = 0

    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    bar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            local v = math.floor(min + rel * (max - min))
            fill.Size = UDim2.new(rel, 0, 1, 0)
            label.Text = name .. ": " .. tostring(v)
            callback(v)
        end
    end)
end

local function makeButton(text, parent, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -20, 0, 28)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.BackgroundTransparency = 0.2
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.MouseButton1Click:Connect(callback)
    return b
end

local function createUI()
    gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "BoatTeleportUI"
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 300, 0, 300)
    main.Position = UDim2.new(0, 20, 0.5, -150)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    main.BackgroundTransparency = 0.2
    main.BorderSizePixel = 0

    local dragging = false
    local dragStart, startPos

    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    local layout = Instance.new("UIListLayout", main)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = '<font color="rgb(255,255,255)">⚓BABFT </font><font color="rgb(255,255,255)">DM3</font>'
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.RichText = true
    title.BackgroundTransparency = 1

    AutoFarmButton = makeButton("🌾 AutoFarm: OFF", main, function()
        AutoFarmSettings.Enabled = not AutoFarmSettings.Enabled
        AutoFarmButton.Text = "🌾 AutoFarm: " .. (AutoFarmSettings.Enabled and "ON" or "OFF")
        if AutoFarmSettings.Enabled then
            StartAutoFarmLoop()
        end
    end)

    SilentButton = makeButton("🔇 Silent Mode: OFF", main, function()
        AutoFarmSettings.Silent = not AutoFarmSettings.Silent
        SilentButton.Text = "🔇 Silent Mode: " .. (AutoFarmSettings.Silent and "ON" or "OFF")
    end)

    FlyButton = makeButton("✈️ Fly: OFF", main, function()
        FlyEnabled = not FlyEnabled
        FlyButton.Text = "✈️ Fly: " .. (FlyEnabled and "ON" or "OFF")
        if FlyEnabled then
            StartFlying()
        end
    end)

    NoclipButton = makeButton("👻 Noclip: OFF", main, function()
        NoclipEnabled = not NoclipEnabled
        NoclipButton.Text = "👻 Noclip: " .. (NoclipEnabled and "ON" or "OFF")
        if NoclipEnabled then
            StartNoclip()
        end
    end)

    makeSlider("Fly Speed", 10, 100, FlySpeed, main, function(v)
        FlySpeed = v
    end)

    makeButton("❌ Unload Script", main, function()
        AutoFarmSettings.Enabled = false
        FlyEnabled = false
        NoclipEnabled = false
        if gui then gui:Destroy() end
    end)
end

local function main()
    local char = player.Character or player.CharacterAdded:Wait()
    char:WaitForChild("HumanoidRootPart")
    createUI()
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if AutoFarmSettings.Enabled then
            StartAutoFarmLoop()
        end
        if FlyEnabled then
            StartFlying()
        end
        if NoclipEnabled then
            StartNoclip()
        end
    end)
end

main()
