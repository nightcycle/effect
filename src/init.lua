local package = script

local packages = package.Parent
local Signal = require(packages:WaitForChild("signal"))
local Isotope = require(packages:WaitForChild("isotope"))

local effectModule = script:WaitForChild("Effect")
local Service = {}

local constructors = {
	Effect = require(effectModule).new,
}
for i, effectMod in ipairs(effectModule:GetChildren()) do
	if string.find(effectMod.Name, "story") == nil then
		constructors[effectMod.Name] = require(effectMod).new
	end
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