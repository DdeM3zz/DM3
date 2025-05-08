local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local clones, gui, updater = {}, nil, nil
local mode = "Line"
local lookMode = "SameDirection"
local spacing, orbitSpeed, orbitRadius, cloneCount = 3, 2, 6, 5

local function clearClones()
    for _, c in ipairs(clones) do if c then c:Destroy() end end
    clones = {}
end

local function cloneChar(original)
    original.Archivable = true
    local c = original:Clone()
    c.Name = "DM3_Clone"
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Anchored = false
            p.CanCollide = false
            p.Transparency = (p.Name == "HumanoidRootPart") and 1 or 0
        end
    end
    c.Parent = workspace
    return c
end

local function updateClones(original)
    clearClones()
    for i = 1, cloneCount do
        local c = cloneChar(original)
        if c then table.insert(clones, c) end
    end

    if updater then updater:Disconnect() end
    updater = RunService.RenderStepped:Connect(function()
        if not original:FindFirstChild("HumanoidRootPart") then return end
        local root = original.HumanoidRootPart
        for i, c in ipairs(clones) do
            if c.PrimaryPart then
                local offset = Vector3.zero
                if mode == "Line" then
                    offset = -root.CFrame.LookVector * ((spacing * i) + 2)
                elseif mode == "Orbit" then
                    local a = tick() * orbitSpeed + (i * 2 * math.pi / cloneCount)
                    offset = Vector3.new(math.cos(a), 0, math.sin(a)) * orbitRadius
                end
                local target = root.Position + offset + Vector3.new(0, 2.5, 0)
                local current = c.PrimaryPart.Position:Lerp(target, 0.15)
                local look = (lookMode == "SameDirection") and (current + root.CFrame.LookVector) or root.Position
                c:SetPrimaryPartCFrame(CFrame.new(current, look))
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
end

local function createUI()
    gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "DM3CloneUI"

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 270, 0, 460)
    main.Position = UDim2.new(0, 20, 0.5, -230)
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
    title.Text = "🧬 DM3 Clone Script"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.BackgroundTransparency = 1

    makeButton("📏 Line Mode", main, function() mode = "Line" end)
    makeButton("🪐 Orbit Mode", main, function() mode = "Orbit" end)
    makeButton("➡️ Same Direction", main, function() lookMode = "SameDirection" end)
    makeButton("🎯 Face Player", main, function() lookMode = "FacePlayer" end)

    makeSlider("👥 Clones", 1, 20, cloneCount, main, function(v)
        cloneCount = v
        if player.Character then updateClones(player.Character) end
    end)
    makeSlider("🛸 Orbit Radius", 3, 20, orbitRadius, main, function(v) orbitRadius = v end)
    makeSlider("⚙️ Orbit Speed", 1, 10, orbitSpeed, main, function(v) orbitSpeed = v end)
    makeSlider("📏 Spacing", 1, 10, spacing, main, function(v) spacing = v end)

    makeButton("❌ Unload Script", main, function()
        if updater then updater:Disconnect() end
        clearClones()
        gui:Destroy()
    end)
end

local function main()
    local char = player.Character or player.CharacterAdded:Wait()
    char:WaitForChild("HumanoidRootPart")
    createUI()
    updateClones(char)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        updateClones(player.Character)
    end)
end

main()
