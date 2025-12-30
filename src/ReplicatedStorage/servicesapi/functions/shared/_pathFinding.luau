local Pathfinding = {}
local PathfindingService = game:GetService("PathfindingService")
local PathfindingStates = {}

export type TargetType = Vector3 | BasePart | Attachment

function Pathfinding:MoveTo(humanoid: Humanoid, rootPart: BasePart, target: TargetType, meshpart: BasePart, onFinished: () -> ())
    if not humanoid or not rootPart then return end

    local targetPos
    if typeof(target) == "Instance" then
        if target:IsA("BasePart") then
            targetPos = target.Position
        elseif target:IsA("Attachment") then
            targetPos = target.WorldPosition
        end
    elseif typeof(target) == "Vector3" then
        targetPos = target
    end

    if not targetPos then return end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = humanoid.JumpPower,
        AgentMaxSlope = 45
    })

    path:ComputeAsync(rootPart.Position, targetPos)
    local waypoints = path:GetWaypoints()
    if path.Status ~= Enum.PathStatus.Success or #waypoints == 0 then
        if onFinished then onFinished() end
        return
    end

    local i = 1
    local function goNext()
        if i > #waypoints then
            if meshpart and meshpart:IsA("BasePart") then
                local dir = meshpart.Position - rootPart.Position
                dir = vector.create(dir.X, 0, dir.Z)
                if dir.Magnitude > 0 then
                    rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + dir.Unit)
                end
            end
            if onFinished then onFinished() end
            return
        end

        humanoid:MoveTo(waypoints[i].Position)
        humanoid.MoveToFinished:Wait()
        i += 1
        goNext()
    end

    goNext()
end

function Pathfinding:Stop(humanoid: Humanoid, rootPart: BasePart)
    if humanoid and rootPart then
        humanoid:MoveTo(rootPart.Position)
    end
end

return Pathfinding
