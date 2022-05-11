local RunService = game:GetService("RunService")
local package = script.Parent
local packages = package.Parent
local Signal = require(packages:WaitForChild("signal"))
local Isotope = require(packages:WaitForChild("isotope"))

local Track = {}
Track.__index = Track
setmetatable(Track, Isotope)

-- function Track:Destroy()
-- 	if self._IsAlive ~= true then return end
-- 	-- print("Destroying track")
-- 	self.Destroying:Fire()
-- 	self.Instances = nil
-- 	Isotope.Destroy(self)
-- end

function Track:Destroy()
	if self._IsAlive ~= true then return end
	self._IsAlive = false
	self:Disable()
	if self.Duration and self.Speed and self.Duration._destroyed == false and self.Speed._destroyed == false then
		task.delay(self.Duration:Get()*self.Speed:Get(), function()
			self.Destroying:Fire()
			self.Instances = nil
			Isotope.Destroy(self)
		end)
	end
end

function Track:Play()
	-- print("Playing")
	-- self.StartTick:Set(tick())
	self.Alpha:Set(0)
	self.OnPlay:Fire()
	self.IsPlaying:Set(true)
end

function Track:Stop()
	self.Alpha:Set(0)
	-- self.StopTick:Set(tick())
	self.OnStop:Fire()
	self.IsPlaying:Set(false)
end

function Track:Resume()
	self.OnResume:Fire()
	self.IsPlaying:Set(true)
end

function Track:Pause()
	self.OnPause:Fire()
	self.IsPlaying:Set(false)
end

function Track:Fire()
	self._Maid:GiveTask(self.OnComplete:Connect(function()
		self:Destroy()
	end))
end

function Track:Bind(otherAlpha, otherEnvelope)
	self._IsBound = true
	self._Maid:GiveTask(otherAlpha:Connect(function(current, prev)
		self.Alpha:Set(otherAlpha:Get())
	end))
	self._Maid:GiveTask(otherEnvelope:Connect(function(current, prev)
		self.EnvelopeWeight:Set(otherEnvelope:Get())
	end))
end

function Track:Enable()
	if self.Enabled.kind == "Value" then
		self.Enabled:Set(true)
	else
		warn("This track cannot be enabled")
	end
end

function Track:Disable()
	if self.Enabled.kind == "Value" then
		self.Enabled:Set(false)
	else
		warn("This track cannot be disabled")
	end
end

function Track.new(config)
	local self = Isotope.new()
	setmetatable(self, Track)

	self._IsBound = false
	self._IsAlive = true

	self.Alpha = config.Alpha
	self.EnvelopeWeight = config.EnvelopeWeight
	self.Speed = self:Import(config.Speed, 0)
	self.Enabled = self:Import(config.Enabled, 1)
	self.Duration = self:Import(config.Duration, 1)
	self.Looped = self:Import(config.Looped, false)
	self.Flipped = self:Import(config.Flipped, false)
	self.Speed = self:Import(config.Speed, 1)
	self.Scale = self:Import(config.Scale, 1)
	self.RefreshRate = self:Import(config.RefreshRate, 1/60)

	self.DeltaTime = self._Fuse.Value(1/60)
	self.IsPlaying = self._Fuse.Value(false)

	self.OnPlay = Signal.new()
	self.OnStop = Signal.new()
	self.OnPause = Signal.new()
	self.OnComplete = Signal.new()
	self.OnLoop = Signal.new()
	self.OnResume = Signal.new()
	self.Destroying = Signal.new()
	self.Random = Random.new(tick())

	local lastRefreshTick = tick()
	if self.Alpha.kind == "Value" then
		self._Maid:GiveTask(RunService.Heartbeat:Connect(function(dt)
			if self._IsBound then return end
			if self._IsAlive ~= true then return end

			local isPlaying = self.IsPlaying:Get()
			if not isPlaying then return end

			local refresh = self.RefreshRate:Get()
			if refresh > tick() - lastRefreshTick then return end
			lastRefreshTick = tick()

			if self.EnvelopeWeight:Get() == nil then
				self.EnvelopeWeight:Set(self.Random:NextNumber())
			end

			local dur = self.Duration:Get()
			local spd = self.Speed:Get()
			local curAlpha = self.Alpha:Get()
			local deltaAlpha = dt/(dur/spd)
			local isLooping = self.Looped:Get()
			local isFlipped = self.Flipped:Get()
			local alpha
			if isFlipped == true then
				alpha = math.clamp(curAlpha - deltaAlpha, 0, 1)
				if alpha == 0 then
					self.OnComplete:Fire()
					if isLooping then
						self.EnvelopeWeight:Set(self.Random:NextNumber())
						self.OnLoop:Fire()
						alpha = 1
					else
						self.IsPlaying:Set(false)
					end
				end
			else
				alpha = math.clamp(curAlpha + deltaAlpha, 0, 1)
				if alpha == 1 then
					self.OnComplete:Fire()
					if isLooping then
						self.EnvelopeWeight:Set(self.Random:NextNumber())
						self.OnLoop:Fire()
						alpha = 0
					else
						self.IsPlaying:Set(false)
					end
				end
			end
			-- print("Alpha", alpha)
			self.DeltaTime:Set(dt)
			self.Alpha:Set(alpha)
		end))
	end
	return self
end

return Track