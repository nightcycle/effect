local EffectModule = script.Parent
local package = EffectModule.Parent
local packages = package.Parent
local ColdFusion = require(packages:WaitForChild("coldfusion"))
local Maid = require(packages:WaitForChild("maid"))
local Isotope = require(packages:WaitForChild("isotope"))
local Effect = require(EffectModule)
local ValueSequence = require(packages:WaitForChild("valuesequence"))

local Sound = {}
Sound.__index = Sound
setmetatable(Sound, Effect)

function Sound:Load(config)
	config = config or {}
	local maid = Maid.new()
	local fuse = ColdFusion.fuse(maid)
	config.Enabled = self:Import(config.Enabled, true)
	config.Alpha = fuse.Value(0)
	config.EnvelopeWeight = fuse.Value(nil)
	config.Duration = self:Import(config.Duration, 1)
	config.Speed = self:Import(config.Speed, 1)
	config.EnableTween = fuse.Computed(config.Enabled, function(enab)
		return if enab then 1 else 0
	end):Tween(config.Duration:Get())
	local soundInst
	soundInst = fuse.new "Sound" {
		Name = self.Name,
		Parent = self.Parent,
		SoundId = self.SoundId,
		SoundGroup = self.SoundGroup,
		RollOffMaxDistance = self.RollOffMaxDistance,
		RollOffMinDistance = self.RollOffMinDistance,
		RollOffMode = self.RollOffMode,
		Volume = fuse.Computed(config.EnableTween, self.Volume, function(enab, vol)
			return enab * vol
		end),
		Pitch = config.Speed, 
		Looped = true,
	}
	-- config.Alpha:Connect(function(alpha)
	-- 	if not soundInst then return 0 end
	-- 	soundInst.TimePosition = soundInst.TimeLength * alpha * config.Speed:Get()
	-- 	if soundInst.IsPlaying == false then
	soundInst:Play()
		-- end
	-- end)

	return self:_Load(config, maid, fuse)
end

function Sound.new(config)
	local self = Effect.new(config)
	setmetatable(self, Sound)
	-- print("Build light", self)
	self.Name = self:Import(config.Name, script.Name)
	self.SoundId = self:Import(config.SoundId, Color3.fromHSV(0,0,1))
	self.SoundGroup = self:Import(config.SoundGroup, nil)
	self.RollOffMaxDistance = self:Import(config.RollOffMaxDistance, 10000)
	self.RollOffMinDistance = self:Import(config.RollOffMinDistance, 10)
	self.RollOffMode = self:Import(config.RollOffMode, Enum.RollOffMode.Inverse)
	self.Volume = self:Import(config.Volume, 0.5)

	return self
end

return Sound