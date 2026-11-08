--[[
	Athena · Components/Toggle
	Light track switch with a dark knob, animated with a Quint ease.
]]

local Util = require(script.Parent.Parent.Core.Util)

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(section, options)
	options = options or {}
	local theme = section.Theme

	local row = section:_Row({
		Name = options.Name or options.Title or "Toggle",
		Description = options.Description,
		Height = options.Description and 58 or 48,
		ControlWidth = 36,
		Clickable = true,
	})

	local self = setmetatable({
		Section = section,
		Theme = theme,
		Options = options,
		Instance = row.Row,
		Value = options.Default == true,
		Enabled = options.Enabled ~= false,
		Maid = Util.Maid.new(),
	}, Toggle)

	local track = Util.Create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(36, 20),
		BackgroundColor3 = theme.ToggleOff,
		BorderSizePixel = 0,
		Parent = row.Control,
	})
	Util.Corner(track, 10)
	local stroke = Util.Stroke(track, theme.Border, 1, 0.35)

	local knob = Util.Create("Frame", {
		Name = "Knob",
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = theme.Knob,
		BorderSizePixel = 0,
		Parent = track,
	})
	Util.Corner(knob, 8)
	Util.Stroke(knob, theme.Window, 1, 0.72)

	self.Track = track
	self.Knob = knob
	self.Stroke = stroke

	local function paint(animated)
		local on = self.Value
		local targetPosition = UDim2.fromOffset(on and 18 or 2, 2)
		local trackColor = on and theme.ToggleOn or theme.ToggleOff
		local knobColor = on and theme.KnobOn or theme.Knob

		if animated then
			Util.Tween(knob, {
				Position = targetPosition,
				BackgroundColor3 = knobColor,
			}, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			Util.Tween(track, { BackgroundColor3 = trackColor }, 0.2)
			Util.Tween(stroke, { Transparency = on and 1 or 0.35 }, 0.2)
		else
			knob.Position = targetPosition
			knob.BackgroundColor3 = knobColor
			track.BackgroundColor3 = trackColor
			stroke.Transparency = on and 1 or 0.35
		end
	end

	function self:Set(value, silent)
		value = value == true
		if value == self.Value then
			return
		end
		self.Value = value
		paint(true)
		if not silent and self.Options.Callback then
			Util.Safe(self.Options.Callback, value)
		end
	end

	function self:Get()
		return self.Value
	end

	function self:Toggle()
		self:Set(not self.Value)
	end

	function self:SetEnabled(enabled)
		self.Enabled = enabled
		track.BackgroundTransparency = enabled and 0 or 0.5
		knob.BackgroundTransparency = enabled and 0 or 0.5
	end

	function self:Destroy()
		self.Maid:Clean()
		row.Row:Destroy()
	end

	paint(false)

	Util.RowHover(row.Row, self.Maid, theme)
	self.Maid:Add(row.Row.MouseButton1Click:Connect(function()
		if self.Enabled then
			self:Toggle()
		end
	end))

	self.Maid:Add(track.MouseEnter:Connect(function()
		if self.Enabled then
			Util.Tween(stroke, { Transparency = self.Value and 1 or 0.1 }, 0.12)
		end
	end))
	self.Maid:Add(track.MouseLeave:Connect(function()
		if self.Enabled then
			Util.Tween(stroke, { Transparency = self.Value and 1 or 0.35 }, 0.12)
		end
	end))

	if not self.Enabled then
		self:SetEnabled(false)
	end

	return self
end

return Toggle
