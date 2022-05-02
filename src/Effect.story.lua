return function (coreGui)
	local EffectModule = script.Parent
	local packages = EffectModule.Parent
	local Maid = require(packages:WaitForChild("maid"))
	local Isotope = require(packages:WaitForChild("isotope"))
	local maid = Maid.new()
	local success, msg = pcall(function()
		local EffectService = require(EffectModule)
		-- print("Effect")
		-- local function fireConstructor(config)
		-- 	local Effect = EffectService.Effect.new({
		-- 		Parent = Isotope.import(config.Parent, nil),
		-- 		Duration = Isotope.import(config.Duration, 1.5),
		-- 		Looped = Isotope.import(config.Looped, false),
		-- 		Speed = Isotope.import(config.Speed, 1),
		-- 		Scale = Isotope.import(config.Scale, 1),
		-- 		FadeIn = Isotope.import(config.FadeIn, 0.1),
		-- 		FadeOut = Isotope.import(config.FadeOut, 0.1),
		-- 		Name = Isotope.import(config.Name, "Effect"),
		-- 		Character = Isotope.import(config.Character, nil),
		-- 		Children = {

		-- 		},
		-- 	})
		-- end
		-- EffectService.register("Fire", fireConstructor)

		local fireHolder = Instance.new("Part", workspace)
		fireHolder.Anchored = true
		fireHolder.Size = Vector3.new(8,4,8)
		fireHolder.CFrame = CFrame.new(0,4,0)
		fireHolder.Transparency = 0.5
		fireHolder.CanCollide = false
		maid:GiveTask(fireHolder)

		local light = EffectService.new "Light"{
			Parent = fireHolder,
			Brightness = NumberSequence.new(
				
			)
		}
		maid:GiveTask(light)

		local fireFX = EffectService.new "Fire" {
			Parent = fireHolder,
		}

		maid:GiveTask(fireFX)
	end)
	if not success then
		warn(msg)
	end
	return function()
		maid:Destroy()
	end
end