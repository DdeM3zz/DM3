local function applyAnimation(humanoid)
    if not humanoid then
        warn("Error: Humanoid df")
        return
    end

    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    local success, err = pcall(function()
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://90153493344280"
        local track = animator:LoadAnimation(animation)
        if track then
            track.Looped = true
            track:Play()
            warn("Anim 90153493344280 cl")
        else
            warn("Error: AnimationTrack dc")
        end
    end)
    if not success then
        warn("df 90153493344280: " .. tostring(err))
        -- Резервная анимация
        local defaultAnimation = Instance.new("Animation")
        defaultAnimation.AnimationId = "rbxassetid://507766666"
        local track = animator:LoadAnimation(defaultAnimation)
        if track then
            track.Looped = true
            track:Play()
            warn("add rAnim")
        else
            warn("df rAnim")
        end
    end
end

return applyAnimation
