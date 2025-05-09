--- Credits to cyberseall
pcall(function()
    workspace.StreamingEnabled = false
    if workspace:FindFirstChild("SimulationRadius") then
        workspace.SimulationRadius = 999999
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
                end
            end
        end
    end
end

print("=== Starting map scan ===")
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

print(("→ %d Bonds found"):format(#cyberseallBondData))
if #cyberseallBondData == 0 then
    warn("No bonds found – check RuntimeItems")
    return
end

local cyberseallChair = WorkspaceService:WaitForChild("RuntimeItems"):FindFirstChild("Chair")
assert(cyberseallChair and cyberseallChair:FindFirstChild("Seat"), "Chair.Seat not found")
local cyberseallSeat = cyberseallChair.Seat

cyberseallSeat:Sit(cyberseallHumanoid)
task.wait(0.2)
local cyberseallSeatWorks = (cyberseallHumanoid.SeatPart == cyberseallSeat)

for index, cyberseallEntry in ipairs(cyberseallBondData) do
    print(("--- Bond %d/%d ---"):format(index, #cyberseallBondData))
    local targetPos = cyberseallEntry.pos + Vector3.new(0, 2, 0)
    if cyberseallSeatWorks then
        cyberseallSeat:PivotTo(CFrame.new(targetPos))
        task.wait(0.1)
        if cyberseallHumanoid.SeatPart ~= cyberseallSeat then
            cyberseallSeat:Sit(cyberseallHumanoid)
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
    end

    task.wait(0.5)

    if not cyberseallEntry.item.Parent then
        print("Bond collected")
    else
        warn("Not collected – timeout? Or check path!")
    end
end

cyberseallHumanoid:TakeDamage(999999)
cyberseallEndDecisionRemote:FireServer(false)
cyberseallQueueOnTp("PYSH")

print("Finished")
