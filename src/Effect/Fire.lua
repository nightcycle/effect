local EffectModule = script.Parent
local package = EffectModule.Parent
local packages = package.Parent
local ColdFusion = require(packages:WaitForChild("coldfusion"))
local Maid = require(packages:WaitForChild("maid"))
local Isotope = require(packages:WaitForChild("isotope"))
local ValueSequence = require(packages:WaitForChild("valuesequence"))
local Effect = require(EffectModule)

local Fire = {}
Fire.__index = Fire
setmetatable(Fire, Effect)

function Fire:Load(config)
	config = config or {}
	local maid = Maid.new()
	local fuse = ColdFusion.fuse(maid)
	config.Enabled = fuse.Value(true)
	config.Alpha = self._Fuse.Value(0)
	config.EnvelopeWeight = self._Fuse.Value(nil)
	config.Duration = self:Import(config.Duration, 1)

	local flames1 = fuse.new "ParticleEmitter" {
		Name = "Flames1",
		Parent = self.Parent,
		Color = fuse.Computed(self.Color, function(col)
			return ColorSequence.new(col)
		end),
		Orientation = Enum.ParticleOrientation.FacingCamera,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 4),
			NumberSequenceKeypoint.new(0.8, 2),
			NumberSequenceKeypoint.new(1, 0),
		}),
		LightEmission = 1,
		LightInfluence = 1,
		Texture = "http://www.roblox.com/asset/?id=4976779930",
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.6),
			NumberSequenceKeypoint.new(0.3, 0.7),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Lifetime = NumberRange.new(0.5,1),
		Rate = fuse.Computed(self.Area, function(area)
			return math.round(area*0.2)
		end),
		Rotation = NumberRange.new(-90,90),
		RotSpeed = NumberRange.new(0,10),
		Speed = NumberRange.new(7,10),
		SpreadAngle = Vector2.new(-10,10),
		Enabled = config.Enabled,
		ZOffset = 1,
		TimeScale = config.Speed,
	}

	local sparks1 = fuse.new "ParticleEmitter" {
		Name = "Sparks1",
		Parent = self.Parent,
		Color = ColorSequence.new(Color3.new(1,1,1)),
		-- Color = fuse.Computed(self.Color, function(col)
		-- 	return ColorSequence.new(col)
		-- end),
		Orientation = Enum.ParticleOrientation.FacingCamera,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0),
		}),
		LightEmission = 1,
		LightInfluence = 1,
		Texture = "rbxassetid://7216849703",
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.2, 0.3),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Lifetime = NumberRange.new(1,4),
		Rate = fuse.Computed(self.Area, function(area)
			return math.round(area*0.4)
		end),
		Rotation = NumberRange.new(-10,10),
		RotSpeed = NumberRange.new(0,10),
		Speed = NumberRange.new(7,10),
		SpreadAngle = Vector2.new(-80,80),
		Enabled = config.Enabled,
		ZOffset = 1,
		TimeScale = config.Speed,
	}

	local smoke1 = fuse.new "ParticleEmitter" {
		Name = "Smoke1",
		Parent = self.Parent,
		Color = ColorSequence.new(Color3.fromHSV(0,0,0.2)),
		Orientation = Enum.ParticleOrientation.FacingCamera,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 5),
			NumberSequenceKeypoint.new(1, 10),
		}),
		LightEmission = 0,
		LightInfluence = 1,
		Texture = "rbxassetid://1946917526",
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.7),
			NumberSequenceKeypoint.new(0.3, 0.8),
			NumberSequenceKeypoint.new(1, 1),
		}),
		TimeScale = config.Speed,
		Lifetime = NumberRange.new(3,10),
		Rate = fuse.Computed(self.Area, function(area)
			return math.round(area*0.1)
		end),
		Rotation = NumberRange.new(-10,10),
		RotSpeed = NumberRange.new(0,10),
		Speed = NumberRange.new(2,4),
		Enabled = config.Enabled,
	}

	local lightTrack = self.Light:Load({
		Enabled = config.Enabled,
		Duration = config.Duration,
		-- Looped = true,
	})

	local soundTrack = self.Sound:Load({
		Enabled = config.Enabled,
		Duration = 1,
		Speed = 1/6,
		-- Looped = true,
	})

	maid:GiveTask(lightTrack)
	lightTrack:Bind(config.Alpha, config.EnvelopeWeight)
	soundTrack:Bind(config.Alpha, config.EnvelopeWeight)

	return self:_Load(config, maid, fuse)
end

function Fire.new(config)
	local self = Effect.new(config)
	setmetatable(self, Fire)

	self.Name = self:Import(config.Name, script.Name)
	self.Color = self:Import(config.Color, Color3.fromHSV(0.07,1,1))
	self.Area = ColdFusion.Computed(self._Fuse.Property(self.Parent, "Size"), function(size)
		if not size then return 0 end
		return size.X * size.Z
	end)
	self.Light = require(script.Parent:WaitForChild("Light")).new({
		Parent = self.Parent,
		Color = self.Color,
		Brightness = self._Fuse.Value(ValueSequence.new({
			ValueSequence.keypoint(0,	1),
			ValueSequence.keypoint(0.125,	0.75),
			ValueSequence.keypoint(0.25,	0.85),
			ValueSequence.keypoint(0.375,	1.1),
			ValueSequence.keypoint(0.5,	0.9),
			ValueSequence.keypoint(0.625,	1.15),
			ValueSequence.keypoint(0.75,	1.05),
			ValueSequence.keypoint(0.875,	0.85),
			ValueSequence.keypoint(1,	1)
		})),
		Range = self._Fuse.Computed(self.Area, function(area)
			if not area then return 0 end
			return (area^0.5)*0.5
		end),
	})
	self.Sound = require(script.Parent:WaitForChild("Sound")).new({
		Parent = self.Parent,
		SoundId = "rbxassetid://158853971",
	})

	self._Maid:GiveTask(self.Light)


	return self
end

return Fire