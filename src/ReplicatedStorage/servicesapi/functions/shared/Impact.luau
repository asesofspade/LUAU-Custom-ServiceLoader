local Impulse = {}
local RunService = game:GetService("RunService")

function Impulse.Apply(target, force, duration)
    duration = duration or 0.2

    if target:IsA("Model") and target.PrimaryPart then
        target = target.PrimaryPart
    elseif not target:IsA("BasePart") then
        return
    end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = force -- usar directamente
    bv.P = 1250
    bv.Parent = target

    task.delay(duration, function()
        if bv and bv.Parent then
            bv:Destroy()
        end
    end)
end


return Impulse
