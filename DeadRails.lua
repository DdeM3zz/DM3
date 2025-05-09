local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local gui = nil
local AimBotEnabled = false
local ESPEnabled = false
local NoclipEnabled = false
local NoclipConnection = nil
local AimBotButton, ESPButton, NoclipButton, BondFarmButton = nil, nil, nil, nil

local Settings = {
    MaxDistance = 100
}

local ESPHighlights = {}
local ESPBillboards = {}
local LastTargetUpdate = 0
local TargetUpdateInterval = 0.1
local LastESPUpdate = 0
local ESPUpdateInterval = 1.5
local Target = nil

local function Notify(text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Dead Rails DM3",
            Text = text,
            Duration = 5
        })
    end)
end

local function playSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

local function CreateTempPlatform(Position)
    local Platform = Instance.new("Part")
    Platform.Size = Vector3.new(10, 1, 10)
    Platform.Position = Position - Vector3.new(0, 6, 0)
    Platform.Anchored = true
    Platform.CanCollide = true
    Platform.Transparency = 1
    Platform.Parent = Workspace

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

local function FindTarget()
    local closestTarget = nil
    local minDistance = math.huge
    local playerPos = HumanoidRootPart.Position

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= Character then
            if obj.Name == "Model_Horse" or obj.Name == "Model_Unicorn" then
                continue
            end

            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local isCorpse = false
                local parentFolder = obj
                while parentFolder do
                    if parentFolder.Name == "RuntimeItems" then
                        isCorpse = true
                        break
                    end
                    parentFolder = parentFolder.Parent
                end

                if not isCorpse then
                    local head = obj:FindFirstChild("Head")
                    if head and head:IsA("BasePart") then
                        local distance = (head.Position - playerPos).Magnitude
                        if distance < minDistance and distance < Settings.MaxDistance then
                            minDistance = distance
                            closestTarget = head
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

local function UpdateAim()
    if not AimBotEnabled or not Character or not Character.Parent then return end

    local currentTime = tick()
    if currentTime - LastTargetUpdate >= TargetUpdateInterval then
        Target = FindTarget()
        LastTargetUpdate = currentTime
    end

    if Target then
        local cameraPos = HumanoidRootPart.Position + Vector3.new(0, 2, 0)
        local targetPos = Target.Position
        local distance = (targetPos - cameraPos).Magnitude
        if distance > Settings.MaxDistance then
            Target = nil
            Camera.CameraType = Enum.CameraType.Custom
            return
        end

        local newCFrame = CFrame.new(cameraPos, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.5)
    else
        Camera.CameraType = Enum.CameraType.Custom
    end
end

local function UpdateESP()
    local currentTime = tick()
    if currentTime - LastESPUpdate < ESPUpdateInterval then return end
    LastESPUpdate = currentTime

    for _, highlight in pairs(ESPHighlights) do
        highlight:Destroy()
    end
    ESPHighlights = {}

    for _, billboard in pairs(ESPBillboards) do
        billboard:Destroy()
    end
    ESPBillboards = {}

    if not ESPEnabled then return end

    local runtimeItemsFolder = Workspace:FindFirstChild("RuntimeItems")
    if runtimeItemsFolder then
        for _, item in pairs(runtimeItemsFolder:GetChildren()) do
            if item:IsA("BasePart") or item:IsA("Model") then
                local targetPart = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
                if targetPart then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 100, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Adornee = targetPart
                    billboard.Parent = targetPart

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = item.Name
                    label.TextColor3 = item.Name == "Coal" and Color3.fromRGB(0, 0, 0) or
                                    item.Name == "Bond" and Color3.fromRGB(245, 245, 220) or
                                    (item.Name == "BrainJar" or item.Name == "Vampire Knife") and Color3.fromRGB(139, 0, 0) or
                                    item.Name == "BankCombo" and Color3.fromRGB(0, 255, 0) or
                                    Color3.fromRGB(255, 255, 255)
                    label.TextStrokeTransparency = 0
                    label.TextScaled = true
                    label.Font = Enum.Font.SourceSansBold
                    label.Parent = billboard

                    table.insert(ESPBillboards, billboard)
                end
            end
        end
    end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= Character then
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local isCorpse = false
                local parentFolder = obj
                while parentFolder do
                    if parentFolder.Name == "RuntimeItems" then
                        isCorpse = true
                        break
                    end
                    parentFolder = parentFolder.Parent
                end

                if not isCorpse then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = obj
                    highlight.Parent = obj
                    table.insert(ESPHighlights, highlight)
                end
            end
        end
    end
end

local function ToggleNoclip()
    NoclipEnabled = not NoclipEnabled
    NoclipButton.Text = "👻 Noclip: " .. (NoclipEnabled and "ON" or "OFF")
    playSound("12221967")

    if NoclipEnabled and not NoclipConnection then
        NoclipConnection = RunService.Stepped:Connect(function()
            if Character and Character.Parent then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    elseif not NoclipEnabled and NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function BondFarm()
    Notify("Credits: cyberseall")
    playSound("12221967")

    -- Anti-skid: do not repost or claim this script as your own
    -- Discord: if (!bitches) exit(1); or cyberseall
    -- Username: cyberseall

    pcall(function()
        Workspace.StreamingEnabled = false
        if Workspace:FindFirstChild("SimulationRadius") then
            Workspace.SimulationRadius = 999999
        end
    end)

    local Players             = game:GetService("Players")
    local ReplicatedStorage   = game:GetService("ReplicatedStorage")
    local WorkspaceService    = game:GetService("Workspace")

    local cyberseallPlayer    = Players.LocalPlayer
    local cyberseallChar      = cyberseallPlayer.Character or cyberseallPlayer.CharacterAdded:Wait()
    local cyberseallHrp       = cyberseallChar:WaitForChild("HumanoidRootPart")
    local cyberseallHumanoid  = cyberseallChar:WaitForChild("Humanoid")

    local cyberseallExecutor  = "unknown"
    pcall(function()
        if identifyexecutor then
            cyberseallExecutor = identifyexecutor():lower()
        end
    end)
    print("Running on executor:", cyberseallExecutor)

    local cyberseallSuccess, cyberseallQueueCandidate = pcall(function()
        return (syn and syn.queue_on_teleport)
            or queue_on_teleport
            or (fluxus and fluxus.queue_on_teleport)
    end)
    local cyberseallQueueOnTp = cyberseallSuccess and cyberseallQueueCandidate or function(...) end

    local cyberseallRemotesRoot1        = ReplicatedStorage:WaitForChild("Remotes")
    local cyberseallRemotePromiseFolder = ReplicatedStorage
        :WaitForChild("Shared")
        :WaitForChild("Network")
        :WaitForChild("RemotePromise")
    local cyberseallRemotesRoot2        = cyberseallRemotePromiseFolder:WaitForChild("Remotes")

    local cyberseallEndDecisionRemote   = cyberseallRemotesRoot1:WaitForChild("EndDecision")

    local cyberseallHasPromise = true
    local cyberseallRemotePromiseMod
    do
        local ok, mod = pcall(function()
            return require(cyberseallRemotePromiseFolder)
        end)
        if ok and mod then
            cyberseallRemotePromiseMod = mod
        else
            cyberseallHasPromise = false
            warn("RemotePromise not available – using direct remotes")
        end
    end

    if cyberseallExecutor:find("swift") then
        cyberseallHasPromise = false
        warn("Swift detected – disabling RemotePromise support")
    end

    local cyberseallPossibleNames = { "C_ActivateObject", "S_C_ActivateObject" }
    local cyberseallActivateName, cyberseallActivateRemote
    for _, name in ipairs(cyberseallPossibleNames) do
        local candidate = cyberseallRemotesRoot2:FindFirstChild(name)
                       or cyberseallRemotesRoot1:FindFirstChild(name)
        if candidate then
            cyberseallActivateName   = name
            cyberseallActivateRemote = candidate
            print("Found remote:", name)
            break
        end
    end
    assert(cyberseallActivateRemote,
           "No Remote '" .. table.concat(cyberseallPossibleNames, ", ") .. "' found")

    local cyberseallActivate
    if cyberseallHasPromise and cyberseallRemotesRoot2:FindFirstChild(cyberseallActivateName) then
        cyberseallActivate = cyberseallRemotePromiseMod.new(cyberseallActivateName)
    else
        if cyberseallActivateRemote:IsA("RemoteFunction") then
            cyberseallActivate = {
                InvokeServer = function(_, ...) return cyberseallActivateRemote:InvokeServer(...) end
            }
        elseif cyberseallActivateRemote:IsA("RemoteEvent") then
            cyberseallActivate = {
                InvokeServer = function(_, ...) return cyberseallActivateRemote:FireServer(...) end
            }
        else
            error(cyberseallActivateName .. " is not a RemoteFunction or RemoteEvent!")
        end
    end

    local cyberseallBondData = {}
    local cyberseallSeenKeys  = {}

    local function cyberseallRecordBonds()
        local runtime = WorkspaceService:WaitForChild("RuntimeItems")
        for _, item in ipairs(runtime:GetChildren()) do
            if item.Name:match("Bond") then
                local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if part then
                    local key = ("%.1f_%.1f_%.1f"):format(
                        part.Position.X, part.Position.Y, part.Position.Z
                    )
                    if not cyberseallSeenKeys[key] then
                        cyberseallSeenKeys[key] = true
                        table.insert(cyberseallBondData, { item = item, pos = part.Position })
                        print("Found bond at:", part.Position)
                    end
                end
            end
        end
        print("Total bonds found:", #cyberseallBondData)
    end

    local cyberseallScanTarget = CFrame.new(-424.448975, 26.055481, -49040.6562)
    local cyberseallScanSteps  = 50
    for i = 1, cyberseallScanSteps do
        cyberseallHrp.CFrame = cyberseallHrp.CFrame:Lerp(cyberseallScanTarget, i/cyberseallScanSteps)
        task.wait(0.3)
        cyberseallRecordBonds()
        task.wait(0.1)
    end
    cyberseallHrp.CFrame = cyberseallScanTarget
    task.wait(0.3)
    cyberseallRecordBonds()

    if #cyberseallBondData == 0 then
        print("No bonds found – check RuntimeItems")
        return
    end

    local cyberseallChair = WorkspaceService:WaitForChild("RuntimeItems"):FindFirstChild("Chair")
    if cyberseallChair and cyberseallChair:FindFirstChild("Seat") then
        local cyberseallSeat = cyberseallChair.Seat
        cyberseallSeat:Sit(cyberseallHumanoid)
        task.wait(0.2)
        local cyberseallSeatWorks = (cyberseallHumanoid.SeatPart == cyberseallSeat)
        if not cyberseallSeatWorks then
            print("Seat failed, using HRP movement")
        end
    else
        print("Chair or Seat not found, using HRP movement")
    end

    for index, cyberseallEntry in ipairs(cyberseallBondData) do
        local targetPos = cyberseallEntry.pos + Vector3.new(0, 2, 0)
        if cyberseallChair and cyberseallChair:FindFirstChild("Seat") and cyberseallHumanoid.SeatPart then
            cyberseallChair.Seat:PivotTo(CFrame.new(targetPos))
            task.wait(0.1)
            if cyberseallHumanoid.SeatPart ~= cyberseallChair.Seat then
                cyberseallChair.Seat:Sit(cyberseallHumanoid)
                task.wait(0.1)
            end
        else
            cyberseallHrp.CFrame = CFrame.new(targetPos)
            task.wait(0.1)
        end

        local ok, err = pcall(function()
            cyberseallActivate:InvokeServer(cyberseallEntry.item)
        end)
        if not ok then
            warn("InvokeServer failed:", err)
        else
            print("Invoked server for bond at:", cyberseallEntry.pos)
        end

        task.wait(0.5)

        if not cyberseallEntry.item.Parent then
            Notify("Bond " .. index .. "/" .. #cyberseallBondData .. " collected!")
            playSound("12221967")
        else
            print("Bond at", cyberseallEntry.pos, "not collected – timeout or invalid path?")
        end
    end

    cyberseallHumanoid:TakeDamage(999999)
    cyberseallEndDecisionRemote:FireServer(false)
    cyberseallQueueOnTp("PUT YOUR SCRIPT HERE")
end

local function makeSlider(name, min, max, val, parent, callback)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Text = name .. ": " .. val
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.BackgroundTransparency = 1

    local bar = Instance.new("TextButton", parent)
    bar.Size = UDim2.new(1, -20, 0, 20)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bar.Text = ""

    local fill = Instance.new("Frame", bar)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
    fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
    fill.BorderSizePixel = 0

    local dragging = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    bar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
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
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.MouseButton1Click:Connect(callback)
    return b
end

local function createUI()
    gui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
    gui.Name = "DeadRailsUI"
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 250, 0, 400)
    main.Position = UDim2.new(0, 20, 0.5, -200)
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

    UserInputService.InputChanged:Connect(function(input)
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
    title.Text = '<font color="rgb(255,255,255)">Dead Rails </font><font color="rgb(255,255,255)">DM3</font>'
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.RichText = true
    title.BackgroundTransparency = 1

    AimBotButton = makeButton("🎯 AimBot: OFF", main, function()
        AimBotEnabled = not AimBotEnabled
        AimBotButton.Text = "🎯 AimBot: " .. (AimBotEnabled and "ON" or "OFF")
        if AimBotEnabled then
            playSound("12221967")
            Camera.CameraType = Enum.CameraType.Scriptable
            RunService.RenderStepped:Connect(UpdateAim)
        else
            playSound("12221967")
            Camera.CameraType = Enum.CameraType.Custom
            Target = nil
        end
    end)

    ESPButton = makeButton("👁️ ESP: OFF", main, function()
        ESPEnabled = not ESPEnabled
        ESPButton.Text = "👁️ ESP: " .. (ESPEnabled and "ON" or "OFF")
        if ESPEnabled then
            playSound("12221967")
            UpdateESP()
            task.spawn(function()
                while ESPEnabled do
                    UpdateESP()
                    task.wait(ESPUpdateInterval)
                end
            end)
            Workspace.RuntimeItems.ChildAdded:Connect(UpdateESP)
            Workspace.RuntimeItems.ChildRemoved:Connect(UpdateESP)
        else
            playSound("12221967")
            UpdateESP()
        end
    end)

    NoclipButton = makeButton("👻 Noclip: OFF", main, function()
        ToggleNoclip()
    end)

    BondFarmButton = makeButton("💰 Bond Farm", main, function()
        BondFarm()
    end)

    makeSlider("AimBot Distance", 10, 500, Settings.MaxDistance, main, function(v)
        Settings.MaxDistance = v
    end)

    makeButton("❌ Unload Script", main, function()
        AimBotEnabled = false
        ESPEnabled = false
        NoclipEnabled = false
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
        if gui then gui:Destroy() end
    end)
end

-- Toggle AimBot with X key
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X then
        AimBotEnabled = not AimBotEnabled
        if AimBotButton then
            AimBotButton.Text = "🎯 AimBot: " .. (AimBotEnabled and "ON" or "OFF")
        end
        if AimBotEnabled then
            playSound("12221967")
            Camera.CameraType = Enum.CameraType.Scriptable
            RunService.RenderStepped:Connect(UpdateAim)
        else
            playSound("12221967")
            Camera.CameraType = Enum.CameraType.Custom
            Target = nil
        end
    end
end)

local function main()
    local char = Player.Character or Player.CharacterAdded:Wait()
    char:WaitForChild("HumanoidRootPart")
    createUI()
    Player.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        if AimBotEnabled then
            Camera.CameraType = Enum.CameraType.Scriptable
        end
        if ESPEnabled then
            UpdateESP()
        end
        if NoclipEnabled and not NoclipConnection then
            ToggleNoclip()
        end
    end)
end

main()
