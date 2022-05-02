return function (value: any, easingStyle: string | EnumItem | nil, easingDirection: string | EnumItem | nil)
	if not value then return end
	easingStyle = easingStyle or Enum.EasingStyle.Quad
	easingDirection = easingDirection or Enum.EasingDirection.InOut

	if type(easingStyle) == "string" then
		easingStyle = Enum.EasingStyle[easingStyle]
	end
	if type(easingDirection) == "string" then
		easingDirection = Enum.EasingDirection[easingDirection]
	end
	return {
		Value = value,
		EasingStyle = easingStyle,
		EasingDirection = easingDirection,
	}
end