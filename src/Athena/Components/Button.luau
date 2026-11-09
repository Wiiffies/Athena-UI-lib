--[[
	Athena · Components/Button
	A row with a light pill action, matching Athena's "Run" / "Edit" controls.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Icons = require(script.Parent.Parent.Core.Icons)

local Button = {}
Button.__index = Button

function Button.new(section, options)
	options = options or {}
	local theme = section.Theme

	local name = options.Name or options.Title or "Button"
	local description = options.Description
	local pillLabel = options.ButtonText or options.Text or "Run"
	local style = options.Style or "Primary"
	local isPrimary = style == "Primary"
	local iconName = options.Icon
	-- Primary pills are flat white text buttons; keep icons for secondary controls.
	if isPrimary then
		iconName = nil
	elseif iconName == nil then
		local lowered = string.lower(tostring(pillLabel))
		if lowered == "run" or lowered == "execute" then
			iconName = "play"
		end
	end

	local labelFont = isPrimary and theme.FontBold or theme.FontMedium
	local textWidth = Util.Measure(pillLabel, 11.5, labelFont).X
	local horizontalPadding
	if isPrimary then
		horizontalPadding = iconName and 58 or 36
	else
		horizontalPadding = iconName and 44 or 32
	end
	local pillWidth = math.ceil(math.clamp(textWidth + horizontalPadding, 70, 176))

	local row = section:_Row({
		Name = name,
		Description = description,
		Height = description and 58 or 52,
		ControlWidth = pillWidth,
		ControlHeight = 34,
		Clickable = true,
	})

	local self = setmetatable({
		Section = section,
		Theme = theme,
		Options = options,
		Instance = row.Row,
		Enabled = options.Enabled ~= false,
		Maid = Util.Maid.new(),
	}, Button)

	local pill = Util.Create("TextButton", {
		Name = "Action",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = isPrimary and theme.Primary or theme.SurfaceAlt,
		BackgroundTransparency = style == "Ghost" and 1 or 0,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = row.Control,
	})
	Util.Corner(pill, 17)
	local pillScale = Instance.new("UIScale")
	pillScale.Scale = 1
	pillScale.Parent = pill

	self.Pill = pill
	self.PillScale = pillScale

	local stroke
	if style == "Secondary" then
		stroke = Util.Stroke(pill, theme.Border, 1)
	end
	if style == "Ghost" then
		stroke = Util.Stroke(pill, theme.Border, 1, 0.6)
	end

	local textColor = theme.PrimaryText
	if style == "Secondary" then
		textColor = theme.Text
	elseif style == "Ghost" then
		textColor = theme.TextSoft
	end

	local icon
	if iconName then
		icon = Icons.New(iconName, 11, textColor, pill, 2)
		icon.Frame.AnchorPoint = Vector2.new(0, 0.5)
		icon.Frame.Position = UDim2.new(0, 11, 0.5, 0)
	end

	local labelX = iconName and 27 or 0
	local labelRight = iconName and 12 or 0

	local label = Util.Create("TextLabel", {
		Name = "Label",
		Position = UDim2.fromOffset(labelX, 0),
		Size = UDim2.new(1, -(labelX + labelRight), 1, 0),
		BackgroundTransparency = 1,
		Text = pillLabel,
		Font = labelFont,
		TextSize = 11.5,
		TextColor3 = textColor,
		TextXAlignment = iconName and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
		Parent = pill,
	})
	self.Label = label
	self.Icon = icon

	local function setBaseColor(hovered)
		if not self.Enabled then
			return
		end
		if isPrimary then
			Util.Tween(pill, { BackgroundColor3 = hovered and theme.PrimaryHover or theme.Primary }, 0.12)
			if label.TextColor3 ~= theme.PrimaryText then
				label.TextColor3 = theme.PrimaryText
			end
		elseif style == "Ghost" then
			Util.Tween(pill, { BackgroundTransparency = hovered and 0.4 or 1 }, 0.12)
		else
			Util.Tween(pill, { BackgroundColor3 = hovered and theme.SurfaceHover or theme.SurfaceAlt }, 0.12)
		end
	end

	self.Maid:Add(row.Row.MouseEnter:Connect(function()
		if stroke then
			Util.Tween(stroke, { Transparency = 0 }, 0.12)
		end
	end))
	self.Maid:Add(row.Row.MouseLeave:Connect(function()
		if stroke then
			Util.Tween(stroke, { Transparency = style == "Ghost" and 0.6 or 0 }, 0.12)
		end
	end))

	local hovered = false
	self.Maid:Add(pill.MouseEnter:Connect(function()
		hovered = true
		setBaseColor(true)
		if not self.Enabled then
			return
		end
		Util.Tween(pillScale, { Scale = 1.02 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		if icon then
			icon:Pulse(1.12, 0.22)
		end
	end))
	self.Maid:Add(pill.MouseLeave:Connect(function()
		hovered = false
		setBaseColor(false)
		Util.Tween(pillScale, { Scale = 1 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))
	self.Maid:Add(pill.MouseButton1Down:Connect(function()
		if self.Enabled then
			if isPrimary then
				Util.Tween(pill, { BackgroundColor3 = theme.PrimaryPressed }, 0.07)
			end
			Util.Tween(pillScale, { Scale = 0.97 }, 0.07)
		end
	end))
	self.Maid:Add(pill.MouseButton1Up:Connect(function()
		if isPrimary then
			Util.Tween(pill, { BackgroundColor3 = hovered and theme.PrimaryHover or theme.Primary }, 0.12)
		end
		Util.Tween(pillScale, { Scale = hovered and 1.02 or 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))

	Util.RowHover(row.Row, self.Maid, theme)

	local function activate()
		if not self.Enabled then
			return
		end
		if options.Callback then
			Util.Safe(options.Callback)
		end
	end

	self.Maid:Add(row.Row.MouseButton1Click:Connect(activate))
	self.Maid:Add(pill.MouseButton1Click:Connect(activate))

	function self:SetText(value)
		label.Text = value
	end

	function self:SetEnabled(enabled)
		self.Enabled = enabled
		label.TextTransparency = enabled and 0 or 0.45
		if icon then
			icon.Frame.Visible = enabled
		end
		pill.BackgroundTransparency = enabled and (style == "Ghost" and 1 or 0) or 0.55
		if not enabled then
			pillScale.Scale = 1
		end
	end

	function self:Destroy()
		self.Maid:Clean()
		row.Row:Destroy()
	end

	if not self.Enabled then
		self:SetEnabled(false)
	end

	return self
end

return Button
