local package = script.Parent
local packages = package.Parent
local Signal = require(packages:WaitForChild("signal"))
local Isotope = require(packages:WaitForChild("isotope"))
local ValueSequence = require(packages:WaitForChild("valuesequence"))
local Track = require(package:WaitForChild("Track"))


local Effect = {}
Effect.__index = Effect
setmetatable(Effect, Isotope)

function Effect:Destroy()
	Isotope.Destroy(self)
end

function Effect:SequenceState(fuse, alpha, weight, value)
	-- print("F", fuse, alpha, value, weight)
	return fuse.Computed(alpha, value, weight, function(a,v,w)
		local vSeq

		if typeof(v) == "table" and v.Keypoints then
			-- print("A")
			vSeq = v
		else
			-- print("B")
			vSeq = ValueSequence.new({
				ValueSequence.keypoint(0, v),
				ValueSequence.keypoint(1, v),
			})
		end
		local final = vSeq:GetValue(a, w)
		-- print("Final", final, "A", a, "V", v, "W", w)
		return final
	end)
end

function Effect:_Load(config, maid, fuse)
	local Parent = self:Import(config.Parent, nil)
	local track = Track.new(config)
	track._Maid:GiveTask(maid)
	track._Maid._parWatcher = fuse.Computed(Parent, function(parent)
		if parent then
			track._Maid._parDestroySignal = parent.Destroying:Connect(function()
				track:Destroy()
			end)
		end
	end)

	self._Maid:GiveTask(track)
	return track
end

function Effect:Load()
	error("Effect has no load function")
end

function Effect:Build(config)
	error("Effect has no build function")
end

function Effect:Fire()
	local track = self:Load()
	track:Destroy()
end

function Effect:SetMarker(markerName: string, alpha: number)
	self.Markers[markerName] = alpha
	self.MarkerSignals[markerName] = self.MarkerSignals[markerName] or {}
end

function Effect:GetMarkerReachedSignal(markerName: string)
	assert(self.Markers[markerName] ~= nil, "Bad marker")
	local signal = Signal.new()
	self._Maid:GiveTask(signal)
	table.insert(self.MarkerSignals[markerName], signal)
	return signal
end

function Effect.new(config)
	config = config or {}
	local self = Isotope.new()
	setmetatable(self, Effect)

	self.IsPlaying = self._Fuse.Value(false)

	self.Parent = self:Import(config.Parent, nil)

	self.Markers = {}
	self.MarkerSignals = {}
	setmetatable(self.MarkerSignals, {__mode = "k"})

	return self
end

return Effect