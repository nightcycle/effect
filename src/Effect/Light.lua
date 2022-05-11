local EffectModule = script.Parent
local package = EffectModule.Parent
local packages = package.Parent
local ColdFusion = require(packages:WaitForChild("coldfusion"))
local Maid = require(packages:WaitForChild("maid"))
local Isotope = require(packages:WaitForChild("isotope"))
local Effect = require(EffectModule)
local ValueSequence = require(packages:WaitForChild("valuesequence"))

local Light = {}
Light.__index = Light
setmetatable(Light, Effect)

function Light:Load(config)
	config = config or {}
	local maid = Maid.new()
	local fuse = ColdFusion.fuse(maid)
	config.Enabled = self:Import(config.Enabled, true)
	config.Alpha = fuse.Value(0)
	config.EnvelopeWeight = fuse.Value(nil)
	config.Duration = self:Import(config.Duration, 1)

	config.EnableTween = fuse.Computed(config.Enabled, function(enab)
		return if enab then 1 else 0
	end):Tween(config.Duration:Get())

	local Brightness = fuse.Computed(
		config.EnableTween,
		self:SequenceState(fuse, config.Alpha, config.EnvelopeWeight, self.Brightness), 
		function(weight, brightness)
			-- print("Brightness", brightness, config.Alpha:Get())
			return weight * brightness
		end
	)

	local Range = fuse.Computed(
		config.EnableTween,
		self:SequenceState(fuse, config.Alpha, config.EnvelopeWeight, self.Range), 
		function(weight, range)
			return weight * range
		end
	)
	for i, face in ipairs({"Front", "Back", "Top", "Bottom", "Left", "Right"}) do
		fuse.new "SurfaceLight" {
			Name = face,
			Parent = self.Parent,
			Face = face,
			Brightness = Brightness,
			Color = self:SequenceState(fuse, config.Alpha, config.EnvelopeWeight, self.Color),
			Range = Range,
			Angle = 90,
			Shadows = self.Shadows,
		}
	end
	return self:_Load(config, maid, fuse)
end

function Light.new(config)
	local self = Effect.new(config)
	setmetatable(self, Light)
	-- print("Build light", self)
	self.Name = self:Import(config.Name, script.Name)
	self.Color = self:Import(config.Color, Color3.fromHSV(0,0,1))
	self.Shadows = self:Import(config.Shadows, true)
	self.Brightness = self:Import(config.Brightness, 1)
	self.Range = self:Import(config.Range, 18)

	return self
end

return Light