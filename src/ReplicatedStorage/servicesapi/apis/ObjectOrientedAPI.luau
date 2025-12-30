local ObjectOrientedAPI = {}
local self = ObjectOrientedAPI 

local RunService = game:GetService("RunService")

local function normalize(instances)
    if typeof(instances) == "table" then
        return instances
    end
    return {instances}
end

local function getTargetCFrame(target)
    if typeof(target) == "CFrame" then
        return target
    elseif typeof(target) == "Vector3" then
        return CFrame.new(target)
    elseif typeof(target) == "Instance" and target:IsA("BasePart") then
        return target.CFrame
    end
end

function ObjectOrientedAPI:Init(animations, pathfinding)
    self.Animations = animations
    self.Pathfinding = pathfinding
end

function ObjectOrientedAPI:HandleEvent(instances, data)
    if not instances or not data then return end

    for _, inst in ipairs(normalize(instances)) do
        local stopAnim = function() end

        if data.Animation and self.Animations and inst:IsA("Model") then
            local animData = data.Animation
            if animData.animType == "Play" and animData.animId then
                local track = self.Animations:_playAnimation(inst, animData.animId, animData.looped)
                stopAnim = function()
                    if track and track.IsPlaying then
                        track:Stop()
                        track:Destroy()
                    end
                end
            end
        end

        if data.Tp then
            local tpData = data.Tp
            if inst:IsA("BasePart") then
                inst.CFrame = tpData.target
            elseif inst:IsA("Model") then
                inst:PivotTo(tpData.target)
            end
        end

        if data.MoveTo then
            local moveData = data.MoveTo
            local cf = getTargetCFrame(moveData.target)

            if inst:IsA("BasePart") and cf then
                local conn
                conn = RunService.Heartbeat:Connect(function(dt)
                    local delta = cf.Position - inst.Position
                    local dist = delta.Magnitude
                    if dist <= 0.1 then
                        inst.CFrame = cf
                        conn:Disconnect()
                        stopAnim()
                    else
                        local step = math.min(dist, (moveData.speed or 20) * dt)
                        inst.CFrame += delta.Unit * step
                    end
                end)

            elseif inst:IsA("Model") then
                local humanoid = inst:FindFirstChildOfClass("Humanoid")
                local root = inst.PrimaryPart
                if humanoid and root then
                    self.Pathfinding:MoveTo(humanoid, root, moveData.target, nil, function()
                        stopAnim()
                    end)
                end
            end
        end
    end
end

return ObjectOrientedAPI
