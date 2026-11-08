--[[
	Athena UI · Components/Slider
	Thin track with a white fill, a live value pill and smooth dragging.
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

	local height = options.Description and 74 or 62
	local row = section:_Row({
		Name = options.Name or options.Title or "Slider",
		Description = options.Description,
		Height = height,
		ControlWidth = 74,
		TextOffset = -5,
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
	}, Slider)

	local valuePill = Util.Create("Frame", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, -5),
		Size = UDim2.fromOffset(62, 20),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Parent = row.Row,
	})
	Util.Corner(valuePill, 6)
	Util.Stroke(valuePill, theme.BorderSoft, 1)

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
		Position = UDim2.fromOffset(0, height - 22),
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = row.Row,
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
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = theme.TrackFill,
		BorderSizePixel = 0,
		Parent = hit,
	})
	Util.Corner(knob, 6)
	Util.Stroke(knob, theme.Window, 1, 0.55)

	self.Track = track
	self.Fill = fill
	self.Knob = knob

	local function formatValue(value)
		return Util.FormatNumber(value) .. suffix
	end

	function Slider:_Paint()
		local alpha = 0
		if self.Max ~= self.Min then
			alpha = (self.Value - self.Min) / (self.Max - self.Min)
		end
		alpha = math.clamp(alpha, 0, 1)

		self.Fill.Size = UDim2.new(alpha, 0, 0, 4)
		self.Knob.Position = UDim2.new(alpha, 0, 0.5, 0)
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
		self:_Paint()

		if changed and not silent and self.Options.Callback then
			Util.Safe(self.Options.Callback, number)
		end
	end

	function Slider:Get()
		return self.Value
	end

	local dragging = false

	local function setFromX(x)
		local hitWidth = hit.AbsoluteSize.X
		if hitWidth <= 0 then
			return
		end
		local alpha = math.clamp((x - hit.AbsolutePosition.X) / hitWidth, 0, 1)
		local raw = self.Min + (self.Max - self.Min) * alpha
		self:Set(raw, false)
	end

	self.Maid:Add(hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			setFromX(input.Position.X)
		end
	end))

	self.Maid:Add(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
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
			dragging = false
		end
	end))

	self.Maid:Add(hit.MouseEnter:Connect(function()
		Util.Tween(knob, { Size = UDim2.fromOffset(14, 14) }, 0.12)
		Util.Tween(track, { BackgroundColor3 = theme.SurfaceHover }, 0.12)
	end))
	self.Maid:Add(hit.MouseLeave:Connect(function()
		if not dragging then
			Util.Tween(knob, { Size = UDim2.fromOffset(12, 12) }, 0.12)
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
