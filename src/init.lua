local package = script

local packages = package.Parent
local Signal = require(packages:WaitForChild("signal"))
local ColdFusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local KeyFrame = require(packages:WaitForChild("KeyFrame"))

local effectModule = script:WaitForChild("Effect")
local Service = {}

local constructors = {
	Effect = require(effectModule).new,
	-- Sound = require(effectModule:WaitForChild("Sound")).new,
	-- Particle = require(effectModule:WaitForChild("Particle")).new,
	Light = require(effectModule:WaitForChild("Light")).new,
}

function Service.KeyFrame(...)
	return KeyFrame(...)
end

function Service.register(effectName: string, effectConstructor)
	if constructors[effectName] then error("The effect name "..tostring(effectName).." is already taken") end
	constructors[effectName] = effectConstructor
end

function Service.new(effectName)
	assert(constructors[effectName] ~= nil, "Bad effect name")
	return constructors[effectName]
end

return Service