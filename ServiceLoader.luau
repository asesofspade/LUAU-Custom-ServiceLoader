local ServicesLoader = {}

local ObjectOrientedService = Instance.new("Folder")
ObjectOrientedService.Name = "ObjectOrientedService"
ObjectOrientedService.Parent = game

local Action = Instance.new("BindableEvent")
Action.Name = "Action"
Action.Parent = ObjectOrientedService

export type MovableInstance = BasePart | Model
export type InstancesInput = MovableInstance | { MovableInstance }

export type MoveToData = {
    target: CFrame | Vector3 | BasePart,
    speed: number,
    alignGround: boolean?
}

export type TpData = {
    target: CFrame
}

export type AnimationData = {
    animType: "Play" | "Stop",
    animId: string?,
    looped: boolean?
}

export type ActionData = MoveToData | TpData | AnimationData

function ServicesLoader:Create(data)
    self.LerpPart = data.modules.LerpPart
    self.Pathfinding = data.modules._pathFinding
    self.Animations = data.modules.Animations

    if self.Animations and self.Animations.Create then
        self.Animations:Create(data)
    end
end

local function normalize(instances: InstancesInput): {MovableInstance}
    if typeof(instances) == "table" then
        return instances
    end
    return { instances }
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

local function moveInstance(self, inst: MovableInstance, data: MoveToData)
    if inst:IsA("BasePart") then
        local cf = getTargetCFrame(data.target)
        if not cf then return end

        self.LerpPart.Move(
            inst,
            cf,
            data.speed or 20,
            data.alignGround
        )

    elseif inst:IsA("Model") then
        local humanoid = inst:FindFirstChildOfClass("Humanoid")
        local root = inst.PrimaryPart
        if humanoid and root then
            self.Pathfinding:MoveTo(
                humanoid,
                root,
                data.target
            )
        end
    end
end

local function teleportInstance(inst: MovableInstance, data: TpData)
    if inst:IsA("BasePart") then
        inst.CFrame = data.target
    elseif inst:IsA("Model") then
        inst:PivotTo(data.target)
    end
end

local function animateInstance(self, inst: MovableInstance, data: AnimationData)
    if not self.Animations then return end
    if not inst:IsA("Model") then return end

    if data.animType == "Play" and data.animId then
        self.Animations:_playAnimation(inst, data.animId, data.looped)

    elseif data.animType == "Stop" then
        self.Animations:_stopAllTracks()
    end
end

Action.Event:Connect(function(
    instances: InstancesInput,
    action: "MoveTo" | "Tp" | "Animation",
    data: ActionData
)
    if not instances or not action or not data then return end

    for _, inst in ipairs(normalize(instances)) do
        if action == "MoveTo" then
            moveInstance(ServicesLoader, inst, data :: MoveToData)

        elseif action == "Tp" then
            teleportInstance(inst, data :: TpData)

        elseif action == "Animation" then
            animateInstance(ServicesLoader, inst, data :: AnimationData)
        end
    end
end)

return ServicesLoader
