local ObjectOrientedAPI = {}
local self = ObjectOrientedAPI

local RunService = game:GetService("RunService")

function ObjectOrientedAPI:Init(services)
    self.Animations = services.Animations
    self.Pathfinding = services._pathFinding
    self.Trails = services.Trails
    self.Impulse = services.Impulse
    self.CustomCamera = services.CustomCamera
    self.GroundImpact = services.GroundImpact
    self.StatesMachine = services.StatesMachine

    if not self.Animations then
        warn("[ObjectOrientedAPI] Animations not found")
    end
end

local function normalize(v)
    return typeof(v) == "table" and v or { v }
end

local function getCFrame(target)
    if typeof(target) == "CFrame" then
        return target
    elseif typeof(target) == "Vector3" then
        return CFrame.new(target)
    elseif typeof(target) == "Instance" and target:IsA("BasePart") then
        return target.CFrame
    end
end

function ObjectOrientedAPI:HandleEvent(instances, data)
    if not instances or not data then return end

    for _, inst in ipairs(normalize(instances)) do
        local stopAnim = function() end

        if data.Animation and self.Animations and inst:IsA("Model") then
            local a = data.Animation

            if a.isState then
                self.Animations:PlayState(inst, a.animId)
            else
                self.Animations:PlayAction(inst, a.animId)
            end
        end

        if data.Tp then
            if inst:IsA("Model") then
                inst:PivotTo(data.Tp.target)
            elseif inst:IsA("BasePart") then
                inst.CFrame = data.Tp.target
            end
        end

        if data.MoveTo then
            local cf = getCFrame(data.MoveTo.target)
            if not cf then return end

            if inst:IsA("BasePart") then
                local conn
                conn = RunService.Heartbeat:Connect(function(dt)
                    local delta = cf.Position - inst.Position
                    if delta.Magnitude < 0.1 then
                        inst.CFrame = cf
                        conn:Disconnect()
                        stopAnim()
                    else
                        inst.CFrame += delta.Unit * (data.MoveTo.speed or 20) * dt
                    end
                end)

            elseif inst:IsA("Model") and self.Pathfinding then
                local hum = inst:FindFirstChildOfClass("Humanoid")
                local root = inst.PrimaryPart
                if hum and root then
                    self.Pathfinding:MoveTo(hum, root, cf.Position, nil, stopAnim)
                end
            end
        end
        if data.RigTrail and inst:IsA("Model") and self.Trails then
            local opts = data.RigTrail
            if typeof(opts) ~= "table" then
                opts = {}
            end

            local applyData = {
                value = opts.value or 0.5,
                color = opts.color or Color3.new(1,1,1),
                duration = opts.duration or 1
            }

            self.Trails.RigTrail(inst, applyData)
        end

        if data.AppyImpulse and self.Impulse then
            local opts = data.AppyImpulse
            local force = opts.force or Vector3.new(0, 50, 0)
            local duration = opts.duration or 0.2
            self.Impulse.Apply(inst, force, duration)
        end

        if data.ChangeFOV and self.CustomCamera then
            local fovData = data.ChangeFOV
            local camera = workspace.CurrentCamera
            local originalFOV = camera.FieldOfView

            self.CustomCamera:_setFOV(fovData.targetFOV, fovData.speed or 5)

            task.delay(fovData.duration or 0.3, function()
                self.CustomCamera:_setFOV(originalFOV, fovData.speed or 5)
            end)
        end

        if data.ApplyShake and self.CustomCamera then
            local shakeData = data.ApplyShake
            self.CustomCamera:_shake(
                shakeData.amount or 0.5,
                shakeData.duration or 0.2,
                shakeData.smoothness or 0.2,
                shakeData.direction or Vector3.new(0,1,0),
                shakeData.speed or 1,
                shakeData.distance or 1,
                shakeData.oscillate or true
            )
        end
        if data.GroundImpact and self.GroundImpact then
            local impactData = data.GroundImpact
            local targetPart = inst:FindFirstChild(impactData.partName) or inst.PrimaryPart
            if not targetPart then return end

            local count = impactData.count or 8
            local radius = impactData.radius or 2
            local options = impactData.options or {
                color = Color3.new(0.5,0.5,0.5),
                size = Vector3.new(1,1,1),
                duration = 4
            }
            local delayTime = impactData.delay or 0
            local offset = options.offset or Vector3.new(0,0,0)

            task.delay(delayTime, function()
                local spawnCFrame = targetPart.CFrame * CFrame.new(offset)
                self.GroundImpact:SpawnAroundCFrame(spawnCFrame, count, radius, options)
            end)
        end


        if data.StateMachine and self.StatesMachine then
            local stateName = data.StateMachine.state
            if stateName and self.StatesMachine.SetState then
                self.StatesMachine.SetState(stateName)
            end
        end
    end
end

return ObjectOrientedAPI
