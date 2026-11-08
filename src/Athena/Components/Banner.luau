--[[
	Athena UI · Components/Banner
	Full width status strip used for "1 automation is running." style notes.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Icons = require(script.Parent.Parent.Core.Icons)

local Banner = {}
Banner.__index = Banner

local TONES = {
	Neutral = "TextMuted",
	Accent = "Accent",
	Success = "Success",
	Warning = "Warning",
	Error = "Error",
	Info = "Info",
}

function Banner.new(tab, input)
	local options = input
	if type(options) == "string" then
		options = { Text = options }
	end
	options = options or {}

	local theme = tab.Theme
	local tone = options.Tone or "Neutral"
	local color = theme[TONES[tone] or "TextMuted"] or theme.TextMuted
	local text = options.Text or options.Name or ""
	local description = options.Description
	local hasDescription = description ~= nil and description ~= ""

	local height = hasDescription and 56 or 42

	local frame = Util.Create("Frame", {
		Name = "Banner",
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		LayoutOrder = tab:_NextOrder(),
		Parent = tab.Scroll,
	})
	Util.Corner(frame, theme.CornerSmall)
	Util.Stroke(frame, theme.Border, 1, 0.35)

	local iconX = 14
	local textX = 30

	if options.Icon then
		local icon = Icons.New(options.Icon, 13, color, frame)
		icon.Frame.AnchorPoint = Vector2.new(0, 0.5)
		icon.Frame.Position = UDim2.new(0, iconX, 0.5, 0)
		textX = 38
	else
		local dot = Util.Create("Frame", {
			Name = "Dot",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, iconX + 2, 0.5, 0),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Parent = frame,
		})
		Util.Corner(dot, 3)
	end

	local textLabel = Util.Create("TextLabel", {
		Name = "Text",
		Position = UDim2.new(0, textX, 0, 0),
		Size = UDim2.new(1, -(textX + (options.Value and 70 or 16)), 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		Font = theme.Font,
		TextSize = 11.5,
		TextColor3 = hasDescription and theme.Text or theme.TextSoft,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = hasDescription and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
		TextWrapped = hasDescription,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	})

	if hasDescription then
		textLabel.Position = UDim2.fromOffset(textX, 11)
		textLabel.Size = UDim2.new(1, -(textX + 16), 0, 30)
		textLabel.TextYAlignment = Enum.TextYAlignment.Top
		Util.Create("TextLabel", {
			Name = "Description",
			Position = UDim2.fromOffset(textX, 33),
			Size = UDim2.new(1, -(textX + 16), 0, 14),
			BackgroundTransparency = 1,
			Text = description,
			Font = theme.Font,
			TextSize = 11,
			TextColor3 = theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = frame,
		})
	end

	local valueLabel
	if options.Value ~= nil then
		valueLabel = Util.Create("TextLabel", {
			Name = "Value",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -14, 0.5, 0),
			Size = UDim2.fromOffset(56, 16),
			BackgroundTransparency = 1,
			Text = tostring(options.Value),
			Font = theme.Font,
			TextSize = 11,
			TextColor3 = theme.TextFaint,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = frame,
		})
	end

	local self = {
		Instance = frame,
		Label = textLabel,
		ValueLabel = valueLabel,
	}

	function self:SetText(value)
		textLabel.Text = value
	end

	function self:SetValue(value)
		if valueLabel then
			valueLabel.Text = tostring(value)
		end
	end

	function self:Destroy()
		frame:Destroy()
	end

	return self
end

return Banner
