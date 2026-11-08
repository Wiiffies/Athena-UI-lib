--[[
	Athena · Components/Slider
	A light Athena-style rail with a white fill, a floating value and a thumb
	that stays on the rail's centre line while it is dragged.
]]

local UserInputService = game:GetService("UserInputService")
local Util = require(script.Parent.Parent.Core.Util)

local Slider = {}
Slider.__index = Slider

function Slider.new(section, options)
	options = options or {}
	local theme = section.Theme

	local min = tonumber(options.Min) or 0
	local max = tonumber(options.Max) or 100
	if max < min then
		min, max = max, min
	end
	local step = tonumber(options.Step) or 1
	if step <= 0 then
		step = 1
	end
	local suffix = options.Suffix or ""

	local height = options.Description and 76 or 64
	local row = section:_Row({
		Name = options.Name or options.Title or "Slider",
		Description = options.Description,
		Height = height,
		ControlWidth = 76,
		TextOffset = -6,
	})

	local self = setmetatable({
		Section = section,
		Theme = theme,
		Options = options,
		Instance = row.Row,
		Min = min,
		Max = max,
		Step = step,
		Suffix = suffix,
		Value = min,
		Maid = Util.Maid.new(),
		_dragging = false,
		_grabOffset = 0,
	}, Slider)

	local area = Util.Create("Frame", {
		Name = "SliderArea",
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -28, 1, 0),
		BackgroundTransparency = 1,
		Parent = row.Row,
	})

	local valuePill = Util.Create("Frame", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, -6),
		Size = UDim2.fromOffset(64, 20),
		BackgroundColor3 = theme.Chip,
		BorderSizePixel = 0,
		Parent = area,
	})
	Util.Corner(valuePill, 6)
	Util.Stroke(valuePill, theme.BorderSoft, 1, 0.55)

	local valueLabel = Util.Create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Font = theme.FontMedium,
		TextSize = 10.5,
		TextColor3 = theme.TextSoft,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = valuePill,
	})
	self.ValuePill = valuePill
	self.ValueLabel = valueLabel

	local hit = Util.Create("TextButton", {
		Name = "Hit",
		Position = UDim2.fromOffset(0, height - 26),
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = area,
	})
	self.Hit = hit

	local track = Util.Create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = theme.Track,
		BorderSizePixel = 0,
		Parent = hit,
	})
	Util.Corner(track, 2)

	local fill = Util.Create("Frame", {
		Name = "Fill",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 4),
		BackgroundColor3 = theme.TrackFill,
		BorderSizePixel = 0,
		Parent = hit,
	})
	Util.Corner(fill, 2)

	local knob = Util.Create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = theme.TrackFill,
		BorderSizePixel = 0,
		Parent = hit,
	})
	Util.Corner(knob, 7)
	Util.Stroke(knob, theme.Window, 1, 0.45)

	local knobScale = Instance.new("UIScale")
	knobScale.Scale = 1
	knobScale.Parent = knob

	self.Track = track
	self.Fill = fill
	self.Knob = knob
	self.KnobScale = knobScale

	local function formatValue(value)
		return Util.FormatNumber(value) .. suffix
	end

	function Slider:_Paint(animated)
		local alpha = 0
		if self.Max ~= self.Min then
			alpha = (self.Value - self.Min) / (self.Max - self.Min)
		end
		alpha = math.clamp(alpha, 0, 1)

		local fillSize = UDim2.new(alpha, 0, 0, 4)
		local knobPosition = UDim2.new(alpha, 0, 0.5, 0)

		if animated and not self._dragging then
			Util.Tween(self.Fill, { Size = fillSize }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			Util.Tween(self.Knob, { Position = knobPosition }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		else
			self.Fill.Size = fillSize
			self.Knob.Position = knobPosition
		end

		self.ValueLabel.Text = formatValue(self.Value)
	end

	function Slider:Set(value, silent)
		local number = tonumber(value)
		if not number then
			return
		end
		number = math.clamp(number, self.Min, self.Max)
		number = Util.Round(number, self.Step)
		number = math.clamp(number, self.Min, self.Max)

		local changed = number ~= self.Value
		self.Value = number
		self:_Paint(true)

		if changed and not silent and self.Options.Callback then
			Util.Safe(self.Options.Callback, number)
		end
	end

	function Slider:Get()
		return self.Value
	end

	local function setFromX(x)
		local hitWidth = hit.AbsoluteSize.X
		if hitWidth <= 0 then
			return
		end
		local alpha = math.clamp((x + self._grabOffset - hit.AbsolutePosition.X) / hitWidth, 0, 1)
		local raw = self.Min + (self.Max - self.Min) * alpha
		self:Set(raw, false)
	end

	self.Maid:Add(hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self._dragging = true
			local x = input.Position.X
			local center = knob.AbsolutePosition.X + knob.AbsoluteSize.X / 2
			local radius = math.max(8, knob.AbsoluteSize.X / 2 + 2)

			-- Grabbing the thumb keeps its current value instead of snapping the
			-- centre to the pointer, which made the value jump on press.
			if math.abs(x - center) <= radius then
				self._grabOffset = center - x
			else
				self._grabOffset = 0
				setFromX(x)
			end

			Util.Tween(knobScale, { Scale = 1.18 }, 0.12)
			Util.Tween(track, { BackgroundColor3 = theme.SurfaceHover }, 0.12)
		end
	end))

	self.Maid:Add(UserInputService.InputChanged:Connect(function(input)
		if not self._dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			setFromX(input.Position.X)
		end
	end))

	self.Maid:Add(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self._dragging = false
			self._grabOffset = 0
			Util.Tween(knobScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			Util.Tween(track, { BackgroundColor3 = theme.Track }, 0.16)
		end
	end))

	self.Maid:Add(hit.MouseEnter:Connect(function()
		if not self._dragging then
			Util.Tween(knobScale, { Scale = 1.1 }, 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			Util.Tween(track, { BackgroundColor3 = theme.SurfaceHover }, 0.12)
		end
	end))
	self.Maid:Add(hit.MouseLeave:Connect(function()
		if not self._dragging then
			Util.Tween(knobScale, { Scale = 1 }, 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			Util.Tween(track, { BackgroundColor3 = theme.Track }, 0.12)
		end
	end))

	function self:Destroy()
		self.Maid:Clean()
		row.Row:Destroy()
	end

	local default = options.Default
	if default == nil then
		default = min + (max - min) * 0.5
	end
	self:Set(default, true)

	return self
end

return Slider
