return function (coreGui)
	local EffectModule = script.Parent.Parent
	local packages = EffectModule.Parent
	local fireTrack

	local Maid = require(packages:WaitForChild("maid"))
	local ColdFusion = require(packages:WaitForChild("coldfusion"))
	local ValueSequence = require(packages:WaitForChild("valuesequence"))
	local maid = Maid.new()

	task.spawn(function()
		local EffectService = require(EffectModule)
		local fireHolder = Instance.new("Part", workspace)
		fireHolder.Anchored = true
		fireHolder.Size = Vector3.new(32,1,80)
		fireHolder.CFrame = CFrame.new(0,0.5,0)
		fireHolder.Transparency = 1
		fireHolder.CanCollide = false
		maid:GiveTask(fireHolder)

		local fireFuse = ColdFusion.fuse()
		maid:GiveTask(fireFuse)
		local fireSize = fireFuse.Property(fireHolder, "Size")

		local fire = EffectService.new "Fire"{
			Parent = fireHolder,
		}

		fireTrack = fire:Load{
			Parent = fireHolder,
			Looped = fireFuse.Value(true),
			-- Flipped = fireFuse.Value(false),
			Speed = 1,
		}

		fireTrack:Play()

		maid:GiveTask(fire)
		maid:GiveTask(fireHolder)
	end)
	return function()
		if fireTrack then
			fireTrack:Disable()
		end
		task.delay(1, function()
			maid:Destroy()
		end)
	end
end