local RunService = game:GetService("RunService")
local package = script.Parent
local packages = package.Parent
local Signal = require(packages:WaitForChild("signal"))
local ColdFusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))

local Sequence = {}
Sequence.__index = {}
setmetatable(Sequence, Isotope)

function Sequence:Destroy()
	Isotope.Destroy(self)
end

function Sequence:Start()
	self.StartTick:Set(tick())
end

function Sequence:Stop()
	self.StopTick:Set(tick())
end

function Sequence.new(effect)
	local self = {}
	self.Effect = effect
	setmetatable(self, Sequence)
	self.IsPlaying = ColdFusion.Value(false)
	self.Alpha = ColdFusion.Value(nil)
	self.CurrentTick = ColdFusion.Value(nil)
	self.Steps = ColdFusion.Computed(self.Effect.Children, function(children)
		local steps = {}
		for fx, alpha in pairs(children) do
			steps[alpha] = steps[alpha] or {}
			table.insert(steps[alpha], fx)
		end
		return steps
	end)
	self.StepOrder = ColdFusion.Computed(self.Steps, function(steps)
		local alphas = {}
		for alpha, fxTable in pairs(steps) do
			table.insert(alphas, alpha)
		end
		table.sort(alphas, function(a,b)
			return a < b
		end)
		return alphas
	end)
	self.NextAlpha = ColdFusion.Computed(self.Alpha, self.StepOrder, function(curAlpha, alphas)
		local nextAlpha = math.huge
		for i, alpha in ipairs(alphas) do
			if alpha > curAlpha and alpha < nextAlpha then
				nextAlpha = alpha
			end
		end
		return nextAlpha
	end)
	self.StartTick = ColdFusion.Computed(self.CurrentTick, self.Effect.Duration, self.Alpha, function(current, duration, alpha)
		if not current or not duration or not alpha then return nil end
		return current - alpha * duration
	end)
	self.NextAlphaTick = ColdFusion.Computed(self.StartTick, self.Effect.Duration, self.NextAlpha, function(start, dur, alpha)
		if not start or not dur or not alpha then return end
		return start + dur * alpha
	end)
	self.FinishTick = ColdFusion.Computed(self.StartTick, self.Effect.Duration, function(start, duration)
		if not start or not duration then return end
		return start + duration
	end)
	self._Maid:GiveTask(ColdFusion.Computed(self.StartTick, self.FinishTick, self.IsPlaying, function(start, finish, isPlaying)
		self._Maid._updateLoop = nil
		if not isPlaying or not start or not finish then return end
		self._Maid._updateLoop = RunService.Heartbeat:Connect(function(dt)
			local nextTick = self.NextAlphaTick:Get()
			if not nextTick then return end
			if tick() >= nextTick then
				self.Alpha:Set(self.NextAlpha:Get())
				self.CurrentTick:Set(tick())
				local currentAlpha = self.Alpha:Get()
				local steps = self.Steps:Get()
				local fxList = steps[currentAlpha] or {}
				for i, fx in ipairs(fxList) do
					fx:Play()
				end
			end
		end)
	end))

	return self
end

return Sequence