local RunService = game:GetService("RunService")

local LerpPart = {}

export type MoveParams = {
    target: CFrame,
    speed: number,
    alignGround: boolean
}

local function alignToGround(part: BasePart)
    local ray = workspace:Raycast(
        part.Position,
        Vector3.new(0, -1, 0) * 15
    )
    if not ray then return end

    local hitPos = ray.Position
    local normal = ray.Normal

    local yOffset = part.Size.Y / 2 + 0.1
    local pos = hitPos + normal * yOffset

    local lookVec = part.CFrame.LookVector
    local forward = lookVec - lookVec:Dot(normal) * normal
    if forward.Magnitude < 0.01 then return end

    forward = forward.Unit
    local right = normal:Cross(forward).Unit

    part.CFrame = CFrame.fromMatrix(pos, right, normal, forward)
end

function LerpPart.Move(
    part: BasePart,
    target: CFrame,
    speed: number,
    alignGround: boolean
)
    if not part or typeof(part) ~= "Instance" or not part:IsA("BasePart") then return end
    if not target or typeof(target) ~= "CFrame" then return end

    speed = speed or 20

    local conn
    conn = RunService.Heartbeat:Connect(function(dt: number)
        if not part.Parent then
            conn:Disconnect()
            return
        end

        local delta: Vector3 = target.Position - part.Position
        local dist: number = delta.Magnitude

        if dist <= 0.1 then
            part.CFrame = target
            conn:Disconnect()
            return
        end

        local step = math.min(dist, speed * dt)
        part.CFrame += delta.Unit * step

        if alignGround then
            alignToGround(part)
        end
    end)
end

return LerpPart
