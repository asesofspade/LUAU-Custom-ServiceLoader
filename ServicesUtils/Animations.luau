local Animations = {}
local self = Animations

self.plr = game.Players.LocalPlayer
self.Tracks = {}

self.MarkerSignals = {
    Freeze = function(track)
        track:AdjustSpeed(0)
    end,
    ResetSpeed = function(track)
        track:AdjustSpeed(1)
    end,
}

function self:Create(data)
    self.data = {
        broadcast = data.remotes.broadcast
    }
end

function self:_registerANIMS()
    return
end

function self:_playAnimation(target: Instance, ID: string, looped: boolean)
    if not target then return end

    local Character = target:IsA("Player") and workspace:FindFirstChild(target.Name) or target
    if not Character then return end

    local Animator
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local AnimationController = Character:FindFirstChildOfClass("AnimationController")

    if Humanoid then
        Animator = Humanoid:FindFirstChildOfClass("Animator")
        if not Animator then
            Animator = Instance.new("Animator")
            Animator.Parent = Humanoid
        end
    elseif AnimationController then
        Animator = AnimationController:FindFirstChildOfClass("Animator")
        if not Animator then
            Animator = Instance.new("Animator")
            Animator.Parent = AnimationController
        end
    else
        local tempController = Instance.new("AnimationController")
        tempController.Parent = Character
        Animator = Instance.new("Animator")
        Animator.Parent = tempController
    end

    -- Detener tracks activos que no sean esta animación
    for i = #self.Tracks, 1, -1 do
        local t = self.Tracks[i]
        if t.IsPlaying and t.Animation.AnimationId ~= ID then
            t:Stop()
            t:Destroy()
            table.remove(self.Tracks, i)
        elseif not t.IsPlaying then
            t:Destroy()
            table.remove(self.Tracks, i)
        end
    end

    -- Revisar si ya hay un track con la misma animación
    for _, t in ipairs(self.Tracks) do
        if t.Animation.AnimationId == ID then
            return t
        end
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = ID

    local track = Animator:LoadAnimation(animation)
    track.Looped = looped or false
    track:Play()

    for markerName, callback in pairs(self.MarkerSignals) do
        track:GetMarkerReachedSignal(markerName):Connect(function(paramString)
            callback(track)
        end)
    end

    table.insert(self.Tracks, track)

    if self.data and self.data.broadcast then
        local playerName = target:IsA("Player") and target.Name or target.Name
        local payload = {
            type = "replicateAnimation",
            playerName = playerName,
            animationId = ID
        }
        self.data.broadcast:FireServer(payload)
    end

    return track
end



function self:_replicateAnimation()
    self.data.broadcast.OnClientEvent:Connect(function(payload)
        if payload.type == "replicateAnimation" then
            local player = game.Players:FindFirstChild(payload.playerName)
            if player then
                self:_playAnimation(player, payload.animationId, false)
            end
        end
    end)
end

function self:_stopAllTracks()
    for _, track in ipairs(self.Tracks) do
        if track.IsPlaying then
            track:Stop()
        end
    end
    self.Tracks = {}
end

return self
