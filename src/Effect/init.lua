local package = script.Parent
local packages = package.Parent
local Signal = require(packages:WaitForChild("signal"))
local ColdFusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))

local Sequence = require(package:WaitForChild("Sequence"))

local Effect = {}
Effect.__index = Effect
setmetatable(Effect, Isotope)

function Effect:Destroy()
	Isotope.Destroy(self)
end

function Effect:Fire()
	local sequence = Sequence.new(self)

end

function Effect:Play()

end

function Effect:Pause()

end

function Effect:Resume()

end

function Effect:Stop()

end

function Effect:Step(alpha) --renders instance at specific point

end

function Effect:GetMarkerReachedSignal(markerName: string)
	local signal = Signal.new()
	self._Maid:GiveTask(signal)

	return signal
end


function Effect.new(config)
	config = config or {}
	local self = Isotope.new()
	setmetatable(self, Effect)

	self.IsPlaying = ColdFusion.Value(false)
	self.Name = Isotope.import(config.Name, "Effect")
	self.Parent = Isotope.import(config.Parent, nil)
	self.Duration = Isotope.import(config.Duration, 0)
	self.Looped = Isotope.import(config.Looped, false)
	self.Speed = Isotope.import(config.Parent, 1)
	self.Scale = Isotope.import(config.Scale, 1)
	self.FadeIn = Isotope.import(config.FadeIn, 0.1)
	self.FadeOut = Isotope.import(config.FadeOut, 0.1)
	self.Children = Isotope.import(config.Children, {})
	self.Size = Isotope.import(config.Size, Vector3.new(1,1,1)*5)
	self.CFrame = Isotope.import(ColdFusion.CFrame, CFrame.new(0,0,0))
	self.RefreshRate = Isotope.import(ColdFusion.RefreshRate, 30)
	self.KeyFrames = Isotope.import(config.Keyframes, {})
	self.OnFinished = Signal.new()

	return self
end

return Effect