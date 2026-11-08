--[[
	Athena UI · Components/Separator
	A hairline with an optional caption.
]]

local Util = require(script.Parent.Parent.Core.Util)

local Separator = {}
Separator.__index = Separator

function Separator.new(section, input)
	local options = input
	if type(options) == "string" then
		options = { Text = options }
	end
	options = options or {}

	local theme = section.Theme
	local hasText = options.Text ~= nil and options.Text ~= ""

	local self = setmetatable({
		Section = section,
		Theme = theme,
		Options = options,
	}, Separator)

	section:_RevealPendingDivider()

	local frame = Util.Create("Frame", {
		Name = "Separator",
		Size = UDim2.new(1, 0, 0, hasText and 30 or 18),
		BackgroundTransparency = 1,
		LayoutOrder = section:_NextOrder(),
		Parent = section.Card,
	})
	Util.Padding(frame, 0, 14, 0, 14)

	if hasText then
		Util.Create("TextLabel", {
			Position = UDim2.fromOffset(0, 3),
			Size = UDim2.new(1, 0, 0, 12),
			BackgroundTransparency = 1,
			Text = options.Text,
			Font = theme.Font,
			TextSize = 10.5,
			TextColor3 = theme.TextFaint,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = frame,
		})
	end

	Util.Create("Frame", {
		Position = UDim2.fromOffset(0, hasText and 19 or 8),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = theme.BorderSoft,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Parent = frame,
	})

	section:_NewDivider()

	self.Instance = frame

	function self:Destroy()
		frame:Destroy()
	end

	return self
end

return Separator
