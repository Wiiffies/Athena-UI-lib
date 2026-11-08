--[[
	Athena UI · Components/ColorPicker
	HSV canvas, hue strip, hex field and live swatch.
]]

local UserInputService = game:GetService("UserInputService")
local Util = require(script.Parent.Parent.Core.Util)
local Icons = require(script.Parent.Parent.Core.Icons)

local ColorPicker = {}
ColorPicker.__index = ColorPicker

local HUE_SEQUENCE = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
})

function ColorPicker.new(section, options)
	options = options or {}
	local theme = section.Theme

	local row = section:_Row({
		Name = options.Name or options.Title or "Color",
		Description = options.Description,
		Height = options.Description and 58 or 48,
		ControlWidth = 96,
	})

	local self = setmetatable({
		Section = section,
		Theme = theme,
		Options = options,
		Instance = row.Row,
		Maid = Util.Maid.new(),
		Color = options.Default or Color3.fromRGB(255, 255, 255),
	}, ColorPicker)

	local pill = Util.Create("TextButton", {
		Name = "Selector",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = row.Control,
	})
	Util.Corner(pill, 8)
	local pillStroke = Util.Stroke(pill, theme.Border, 1)
	Util.Padding(pill, 0, 8, 0, 7)

	local swatch = Util.Create("Frame", {
		Name = "Swatch",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 7, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = self.Color,
		BorderSizePixel = 0,
		Parent = pill,
	})
	Util.Corner(swatch, 5)
	Util.Stroke(swatch, theme.Highlight, 1, 0.7)

	local hexLabel = Util.Create("TextLabel", {
		Position = UDim2.fromOffset(30, 0),
		Size = UDim2.new(1, -34, 1, 0),
		BackgroundTransparency = 1,
		Text = Util.ColorToHex(self.Color),
		Font = theme.FontMono,
		TextSize = 10,
		TextColor3 = theme.TextSoft,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = pill,
	})

	self.Pill = pill
	self.PillStroke = pillStroke
	self.Swatch = swatch
	self.HexLabel = hexLabel

	local popup = section.Window:_CreatePopup({
		Name = "ColorPicker",
		Width = 236,
		Height = 266,
		Align = "Right",
		Padding = 12,
		OnClose = function()
			Util.Tween(pillStroke, { Color = theme.Border }, 0.12)
		end,
	})
	self.Popup = popup

	local content = popup.Content

	local sv = Util.Create("Frame", {
		Name = "SaturationValue",
		Size = UDim2.fromOffset(212, 140),
		BackgroundColor3 = self.Color,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = content,
	})
	Util.Corner(sv, 8)
	self.SV = sv

	local white = Util.Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = sv,
	})
	local whiteGradient = Instance.new("UIGradient")
	whiteGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	whiteGradient.Parent = white

	local black = Util.Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Parent = sv,
	})
	local blackGradient = Instance.new("UIGradient")
	blackGradient.Rotation = 90
	blackGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	blackGradient.Parent = black

	local svCursor = Util.Create("Frame", {
		Name = "Cursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(12, 12),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = sv,
	})
	Util.Corner(svCursor, 6)
	Util.Stroke(svCursor, Color3.new(1, 1, 1), 2)
	self.SVCursor = svCursor

	local svHit = Util.Create("TextButton", {
		Name = "Hit",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 4,
		Parent = sv,
	})
	self.SVHit = svHit

	local hue = Util.Create("Frame", {
		Name = "Hue",
		Position = UDim2.fromOffset(0, 152),
		Size = UDim2.fromOffset(212, 12),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = content,
	})
	Util.Corner(hue, 6)
	local hueGradient = Instance.new("UIGradient")
	hueGradient.Color = HUE_SEQUENCE
	hueGradient.Parent = hue
	self.Hue = hue

	local hueCursor = Util.Create("Frame", {
		Name = "Cursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(8, 18),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = hue,
	})
	Util.Corner(hueCursor, 3)
	Util.Stroke(hueCursor, Color3.fromRGB(12, 13, 15), 1, 0.35)
	self.HueCursor = hueCursor

	local hueHit = Util.Create("TextButton", {
		Name = "Hit",
		Position = UDim2.fromOffset(0, 146),
		Size = UDim2.fromOffset(212, 24),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 4,
		Parent = content,
	})
	self.HueHit = hueHit

	local preview = Util.Create("Frame", {
		Name = "Preview",
		Position = UDim2.fromOffset(0, 182),
		Size = UDim2.fromOffset(44, 32),
		BackgroundColor3 = self.Color,
		BorderSizePixel = 0,
		Parent = content,
	})
	Util.Corner(preview, 8)
	Util.Stroke(preview, theme.Highlight, 1, 0.75)
	self.Preview = preview

	local hexField = Util.Create("Frame", {
		Name = "HexField",
		Position = UDim2.fromOffset(52, 182),
		Size = UDim2.fromOffset(86, 32),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Parent = content,
	})
	Util.Corner(hexField, 8)
	local hexStroke = Util.Stroke(hexField, theme.Border, 1)
	Util.Padding(hexField, 0, 8, 0, 8)

	local hexBox = Util.Create("TextBox", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = Util.ColorToHex(self.Color),
		Font = theme.FontMono,
		TextSize = 11,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = hexField,
	})
	self.HexBox = hexBox

	local rgbLabel = Util.Create("TextLabel", {
		Position = UDim2.fromOffset(146, 182),
		Size = UDim2.fromOffset(66, 32),
		BackgroundTransparency = 1,
		Text = "255 255 255",
		Font = theme.FontMono,
		TextSize = 9.5,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = true,
		Parent = content,
	})
	self.RGBLabel = rgbLabel

	local hueValue, saturation, value = self.Color:ToHSV()
	self.HueValue = hueValue
	self.Saturation = saturation
	self.Value = value

	local function paintColor()
		local color = Color3.fromHSV(self.HueValue, self.Saturation, self.Value)
		self.Color = color

		sv.BackgroundColor3 = Color3.fromHSV(self.HueValue, 1, 1)
		svCursor.Position = UDim2.fromScale(self.Saturation, 1 - self.Value)
		hueCursor.Position = UDim2.fromScale(self.HueValue, 0.5)
		preview.BackgroundColor3 = color
		swatch.BackgroundColor3 = color
		hexLabel.Text = Util.ColorToHex(color)

		if not hexBox:IsFocused() then
			hexBox.Text = Util.ColorToHex(color)
		end

		local r = math.round(color.R * 255)
		local g = math.round(color.G * 255)
		local b = math.round(color.B * 255)
		rgbLabel.Text = string.format("%d %d %d", r, g, b)
	end

	local function notify(silent)
		if not silent and self.Options.Callback then
			Util.Safe(self.Options.Callback, self.Color)
		end
	end

	function self:Set(color, silent)
		if typeof(color) ~= "Color3" then
			return
		end
		self.Color = color
		local h, s, v = color:ToHSV()
		self.HueValue = h
		self.Saturation = s
		self.Value = v
		paintColor()
		notify(silent)
	end

	function self:Get()
		return self.Color
	end

	local draggingSV = false
	local draggingHue = false

	local function updateSV(x, y)
		local position = sv.AbsolutePosition
		local size = sv.AbsoluteSize
		if size.X <= 0 or size.Y <= 0 then
			return
		end
		self.Saturation = math.clamp((x - position.X) / size.X, 0, 1)
		self.Value = 1 - math.clamp((y - position.Y) / size.Y, 0, 1)
		paintColor()
		notify(false)
	end

	local function updateHue(x)
		local position = hue.AbsolutePosition
		local size = hue.AbsoluteSize
		if size.X <= 0 then
			return
		end
		self.HueValue = math.clamp((x - position.X) / size.X, 0, 1)
		paintColor()
		notify(false)
	end

	self.Maid:Add(svHit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			draggingSV = true
			updateSV(input.Position.X, input.Position.Y)
		end
	end))

	self.Maid:Add(hueHit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			draggingHue = true
			updateHue(input.Position.X)
		end
	end))

	self.Maid:Add(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		if draggingSV then
			updateSV(input.Position.X, input.Position.Y)
		elseif draggingHue then
			updateHue(input.Position.X)
		end
	end))

	self.Maid:Add(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			draggingSV = false
			draggingHue = false
		end
	end))

	self.Maid:Add(hexBox.FocusLost:Connect(function()
		local parsed = Util.HexToColor(hexBox.Text)
		if parsed then
			self:Set(parsed, false)
		else
			hexBox.Text = Util.ColorToHex(self.Color)
		end
		Util.Tween(hexStroke, { Color = theme.Border }, 0.12)
	end))

	self.Maid:Add(hexBox.Focused:Connect(function()
		Util.Tween(hexStroke, { Color = theme.SurfaceActive }, 0.12)
	end))

	local function toggle()
		if popup:IsOpen() then
			popup:Close()
			return
		end
		popup:OpenAt(pill)
		Util.Tween(pillStroke, { Color = theme.SurfaceActive }, 0.12)
	end

	self.Maid:Add(pill.MouseButton1Click:Connect(toggle))
	self.Maid:Add(pill.MouseEnter:Connect(function()
		Util.Tween(pill, { BackgroundColor3 = theme.SurfaceHover }, 0.12)
	end))
	self.Maid:Add(pill.MouseLeave:Connect(function()
		Util.Tween(pill, { BackgroundColor3 = theme.SurfaceAlt }, 0.12)
	end))

	function self:Destroy()
		self.Maid:Clean()
		popup:Destroy()
		row.Row:Destroy()
	end

	paintColor()

	return self
end

return ColorPicker
