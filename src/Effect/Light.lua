local EffectModule = script.Parent
local package = EffectModule.Parent
local packages = package.Parent
local ColdFusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local Effect = require(EffectModule)


local Light = {}
Light.__index = Light
setmetatable(Light, Effect)

function Light.new(config)
	local self = Effect.new()
	setmetatable(self, Light)

	print("Light time")
	self.Instance = ColdFusion.new "PointLight" {
		Parent = Isotope.import(config.Parent, nil),
	}
	print(self)

	return self
end

return Light