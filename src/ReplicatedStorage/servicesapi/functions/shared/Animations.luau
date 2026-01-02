local Animations = {}
Animations.__index = Animations

function Animations.new()
	local self = setmetatable({}, Animations)
	self.stateTrack = nil
	self.actionTrack = nil
	self.lastStateAnim = nil
	self.Animator = nil
	return self
end

function Animations:_getAnimator(character)
	if self.Animator then return self.Animator end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	self.Animator = animator
	return animator
end

local function loadTrack(animator, id, priority, looped)
	local anim = Instance.new("Animation")
	anim.AnimationId = id
	local track = animator:LoadAnimation(anim)
	track.Priority = priority
	track.Looped = looped
	print("[loadTrack] Loaded animation:", id, "Priority:", priority.Name, "Looped:", looped)
	return track
end

function Animations:_stopAction()
	if self.actionTrack then
		print("[_stopAction] Stopping action animation:", self.actionTrack.Animation.AnimationId)
		self.actionTrack:Stop()
		self.actionTrack = nil
	else
		print("[_stopAction] No actionTrack to stop")
	end

	if self.stateTrack then
		if not self.stateTrack.IsPlaying then
			print("[_stopAction] Resuming state animation:", self.stateTrack.Animation.AnimationId)
			self.stateTrack:Play()
		else
			print("[_stopAction] State animation already playing:", self.stateTrack.Animation.AnimationId)
		end
	end
end


function Animations:PlayState(character, animId)
	if not character or not animId then return end
	if self.actionTrack then
		print("[PlayState] Ignored because actionTrack is active")
		return
	end

	local animator = self:_getAnimator(character)
	if not animator then return end

	if self.lastStateAnim == animId and self.stateTrack then
		if not self.stateTrack.IsPlaying then
			print("[PlayState] Resuming state animation:", animId)
			self.stateTrack:Play()
		else
			print("[PlayState] State animation already playing:", animId)
		end
		return
	end
	if self.stateTrack then
		print("[PlayState] Stopping previous state animation:", self.lastStateAnim)
		self.stateTrack:Stop()
		self.stateTrack:Destroy()
	end

	self.lastStateAnim = animId
	self.stateTrack = loadTrack(animator, animId, Enum.AnimationPriority.Movement, true)
	print("[PlayState] Playing new state animation:", animId)
	self.stateTrack:Play()
end
function Animations:PlayAction(character, animId)
	if not character or not animId then return end

	local animator = self:_getAnimator(character)
	if not animator then return end

	print("[PlayAction] Starting action animation:", animId)
	self:_stopAction()

	if self.stateTrack then
		print("[PlayAction] Stopping state animation before action:", self.stateTrack.Animation.AnimationId)
		self.stateTrack:Stop()
	end

	local track = loadTrack(animator, animId, Enum.AnimationPriority.Action, false)
	self.actionTrack = track
	track:Play()

	track.Stopped:Once(function()
		print("[PlayAction] Action animation stopped:", animId)
		if track then
			track:Destroy()
		end
		if self.actionTrack == track then
			self.actionTrack = nil
		end

		if self.stateTrack then
			print("[PlayAction] Resuming state animation after action:", self.stateTrack.Animation.AnimationId)
			self.stateTrack:Play()
		end
	end)
end


return Animations
