--[[
	Athena UI · v1.0.0
	A close recreation of the Athena client interface for Roblox.

	Load it in a LocalScript:

		local Athena = loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/Wiiffies/Athena-UI-lib/main/dist/Athena.luau"
		))()

		local Window = Athena:CreateWindow({ Title = "My Application", Theme = "Athena" })
		local Tab = Window:CreateTab("Main")
		local Section = Tab:CreateSection("General")

		Section:CreateButton({
			Name = "Example Button",
			Callback = function()
				print("Clicked!")
			end,
		})

	Documentation: docs/API.md
	This file is generated from src/Athena by build.py. Do not edit by hand.
]]

local __modules = {}
local __cache = {}

local function __require(name)
	local cached = __cache[name]
	if cached ~= nil then
		return cached
	end

	local loader = __modules[name]
	if not loader then
		error("[Athena] Unknown module: " .. tostring(name), 2)
	end

	local module = loader(__require)
	__cache[name] = module
	return module
end

__modules["Components.Banner"] = function(require)
--[[
	Athena · Components/Banner
	Full width status strip used for "1 automation is running." style notes.
]]

local Util = require("Core.Util")
local Icons = require("Core.Icons")

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
end

__modules["Components.Button"] = function(require)
--[[
	Athena · Components/Button
	A row with a light pill action, matching Athena's "Run" / "Edit" controls.
]]

local Util = require("Core.Util")
local Icons = require("Core.Icons")

local Button = {}
Button.__index = Button

function Button.new(section, options)
	options = options or {}
	local theme = section.Theme

	local name = options.Name or options.Title or "Button"
	local description = options.Description
	local pillLabel = options.ButtonText or options.Text or "Run"
	local style = options.Style or "Primary"
	local iconName = options.Icon
	if iconName == nil then
		local lowered = string.lower(tostring(pillLabel))
		if lowered == "run" or lowered == "execute" then
			iconName = "play"
		end
	end

	local textWidth = Util.Measure(pillLabel, 11.5, theme.FontMedium).X
	local pillWidth = math.ceil(math.clamp(textWidth + (iconName and 44 or 32), 64, 156))

	local row = section:_Row({
		Name = name,
		Description = description,
		Height = description and 58 or 52,
		ControlWidth = pillWidth,
		ControlHeight = 32,
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
		BackgroundColor3 = style == "Primary" and theme.Primary or theme.SurfaceAlt,
		BackgroundTransparency = style == "Ghost" and 1 or 0,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = row.Control,
	})
	Util.Corner(pill, 8)
	local pillScale = Instance.new("UIScale")
	pillScale.Scale = 1
	pillScale.Parent = pill

	local shadow
	if style == "Primary" then
		shadow = Util.Create("Frame", {
			Name = "Shadow",
			Position = UDim2.fromOffset(0, 2),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = theme.Scrim,
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			ZIndex = 0,
			Parent = pill,
		})
		Util.Corner(shadow, 9)
		pill.ZIndex = 1
	end

	self.Pill = pill
	self.PillScale = pillScale
	self.Shadow = shadow

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

	local label = Util.Create("TextLabel", {
		Name = "Label",
		Position = UDim2.fromOffset(iconName and 27 or 0, 0),
		Size = UDim2.new(1, iconName and -34 or -12, 1, 0),
		BackgroundTransparency = 1,
		Text = pillLabel,
		Font = theme.FontMedium,
		TextSize = 11.5,
		TextColor3 = textColor,
		TextXAlignment = iconName and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 2,
		Parent = pill,
	})
	self.Label = label

	local function setBaseColor(hovered)
		if not self.Enabled then
			return
		end
		if style == "Primary" then
			Util.Tween(pill, { BackgroundColor3 = hovered and theme.PrimaryHover or theme.Primary }, 0.12)
			if shadow then
				Util.Tween(shadow, { BackgroundTransparency = hovered and 0.4 or 0.55 }, 0.12)
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
		if self.Enabled then
			Util.Tween(pillScale, { Scale = 1.02 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
	end))
	self.Maid:Add(pill.MouseLeave:Connect(function()
		hovered = false
		setBaseColor(false)
		Util.Tween(pillScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))
	self.Maid:Add(pill.MouseButton1Down:Connect(function()
		if self.Enabled then
			Util.Tween(pillScale, { Scale = 0.95 }, 0.07)
		end
	end))
	self.Maid:Add(pill.MouseButton1Up:Connect(function()
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
end

__modules["Components.Card"] = function(require)
--[[
	Athena · Components/Card
	The automation card from Athena: artwork, title, subtitle, chips,
	status line, ghost/primary actions and an inline switch.
]]

local Util = require("Core.Util")
local Icons = require("Core.Icons")

local Card = {}
Card.__index = Card

local function normalizeActions(actions)
	local list = {}
	for _, action in ipairs(actions or {}) do
		if type(action) == "string" then
			table.insert(list, { Name = action, Style = "Ghost" })
		elseif type(action) == "table" then
			table.insert(list, action)
		end
	end
	return list
end

function Card.new(tab, options)
	options = options or {}
	local theme = tab.Theme

	local tags = {}
	for _, tag in ipairs(options.Tags or {}) do
		table.insert(tags, tostring(tag))
	end
	local actions = normalizeActions(options.Actions)

	local hasTags = #tags > 0
	local height = options.Height or (hasTags and 100 or (options.Description and 86 or 74))
	local rightWidth = 196
	local left = 78

	local card = Util.Create("Frame", {
		Name = "Card_" .. tostring(options.Name or options.Title or "Card"),
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		LayoutOrder = tab:_NextOrder(),
		Parent = tab.Scroll,
	})
	Util.Corner(card, theme.CornerCard)
	Util.Stroke(card, theme.Border, 1)

	--------------------------------------------------------------------------------
	-- Artwork
	--------------------------------------------------------------------------------

	local artwork = Util.Create("Frame", {
		Name = "Artwork",
		Position = UDim2.fromOffset(14, 14),
		Size = UDim2.fromOffset(50, 50),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Parent = card,
	})
	Util.Corner(artwork, 10)

	local image = options.Image or options.Thumbnail
	if image ~= nil then
		if type(image) == "number" then
			image = "rbxassetid://" .. tostring(image)
		end
		local imageLabel = Util.Create("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = tostring(image),
			ScaleType = Enum.ScaleType.Crop,
			Parent = artwork,
		})
		Util.Corner(imageLabel, 10)
	else
		local title = options.Name or options.Title or "?"
		Util.Create("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = string.upper(string.sub(title, 1, 1)),
			Font = theme.FontBold,
			TextSize = 18,
			TextColor3 = theme.TextSoft,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Parent = artwork,
		})
	end

	Util.Stroke(artwork, theme.Highlight, 1, 0.88)

	--------------------------------------------------------------------------------
	-- Copy
	--------------------------------------------------------------------------------

	local textWidth = math.max(140, tab:_ContentWidth() - left - rightWidth - 14)

	local titleLabel = Util.Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(left, 15),
		Size = UDim2.new(0, textWidth, 0, 18),
		BackgroundTransparency = 1,
		Text = options.Name or options.Title or "Untitled",
		Font = theme.FontMedium,
		TextSize = 14,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})

	local descriptionLabel
	if options.Description then
		descriptionLabel = Util.Create("TextLabel", {
			Name = "Description",
			Position = UDim2.fromOffset(left, 34),
			Size = UDim2.new(0, textWidth, 0, 15),
			BackgroundTransparency = 1,
			Text = options.Description,
			Font = theme.Font,
			TextSize = 11,
			TextColor3 = theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = card,
		})
	end

	--------------------------------------------------------------------------------
	-- Chips
	--------------------------------------------------------------------------------

	if hasTags then
		local chipRow = Util.Create("Frame", {
			Name = "Tags",
			Position = UDim2.fromOffset(left, height - 14 - 18),
			Size = UDim2.fromOffset(textWidth, 18),
			BackgroundTransparency = 1,
			Parent = card,
		})
		Util.RowList(chipRow, 6)

		local used = 0
		for _, tagText in ipairs(tags) do
			local textSize = Util.Measure(tagText, 9.5, theme.Font).X
			local chipWidth = math.ceil(textSize + 24)
			if used + chipWidth <= textWidth then
				used = used + chipWidth + 6

				local chip = Util.Create("Frame", {
					Size = UDim2.fromOffset(chipWidth, 18),
					BackgroundColor3 = theme.Chip,
					BorderSizePixel = 0,
					Parent = chipRow,
				})
				Util.Corner(chip, theme.CornerChip)
				Util.Stroke(chip, theme.BorderSoft, 1, 0.4)

				local dot = Util.Create("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 7, 0.5, 0),
					Size = UDim2.fromOffset(4, 4),
					BackgroundColor3 = theme.TextFaint,
					BorderSizePixel = 0,
					Parent = chip,
				})
				Util.Corner(dot, 2)

				Util.Create("TextLabel", {
					Position = UDim2.fromOffset(16, 0),
					Size = UDim2.new(1, -20, 1, 0),
					BackgroundTransparency = 1,
					Text = tagText,
					Font = theme.Font,
					TextSize = 9.5,
					TextColor3 = theme.TextMuted,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Parent = chip,
				})
			end
		end
	end

	--------------------------------------------------------------------------------
	-- Right column
	--------------------------------------------------------------------------------

	local right = Util.Create("Frame", {
		Name = "Meta",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 14),
		Size = UDim2.fromOffset(rightWidth, height - 28),
		BackgroundTransparency = 1,
		Parent = card,
	})

	local statusLabel = Util.Create("TextLabel", {
		Name = "Status",
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		Text = options.Status or "",
		Font = theme.Font,
		TextSize = 10.5,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = right,
	})

	local footer = Util.Create("Frame", {
		Name = "Footer",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Parent = right,
	})
	local footerLayout = Util.RowList(footer, 8)
	footerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

	local self = setmetatable({
		Tab = tab,
		Theme = theme,
		Options = options,
		Instance = card,
		TitleLabel = titleLabel,
		DescriptionLabel = descriptionLabel,
		StatusLabel = statusLabel,
		Actions = {},
		Maid = Util.Maid.new(),
	}, Card)

	local function makeAction(action)
		local label = action.Name or action.Text or "Action"
		local style = action.Style or "Ghost"
		local textWidth = Util.Measure(label, 11.5, theme.FontMedium).X
		local iconSpace = action.Icon and 20 or 0
		local width = math.ceil(textWidth + iconSpace + (style == "Primary" and 30 or 22))

		local button = Util.Create("TextButton", {
			Name = "CardAction_" .. label,
			LayoutOrder = #self.Actions + 1,
			Size = UDim2.fromOffset(width, 32),
			BackgroundColor3 = style == "Primary" and theme.Primary or theme.SurfaceHover,
			BackgroundTransparency = style == "Primary" and 0 or 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = footer,
		})
		Util.Corner(button, 8)

		local shadow
		if style == "Primary" then
			shadow = Util.Create("Frame", {
				Name = "Shadow",
				Position = UDim2.fromOffset(0, 2),
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = theme.Scrim,
				BackgroundTransparency = 0.55,
				BorderSizePixel = 0,
				ZIndex = 0,
				Parent = button,
			})
			Util.Corner(shadow, 9)
			button.ZIndex = 1
		end

		local textColor = style == "Primary" and theme.PrimaryText or theme.TextSoft

		local icon
		if action.Icon then
			icon = Icons.New(action.Icon, 12, textColor, button)
			icon.Frame.AnchorPoint = Vector2.new(0, 0.5)
			icon.Frame.Position = UDim2.new(0, 11, 0.5, 0)
		end

		Util.Create("TextLabel", {
			Position = UDim2.fromOffset(iconSpace + 11, 0),
			Size = UDim2.new(1, -(iconSpace + 20), 1, 0),
			BackgroundTransparency = 1,
			Text = label,
			Font = theme.FontMedium,
			TextSize = 11.5,
			TextColor3 = textColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 2,
			Parent = button,
		})

		self.Maid:Add(button.MouseEnter:Connect(function()
			if style == "Primary" then
				Util.Tween(button, { BackgroundColor3 = theme.PrimaryHover }, 0.12)
				if shadow then
					Util.Tween(shadow, { BackgroundTransparency = 0.4 }, 0.12)
				end
			else
				Util.Tween(button, { BackgroundTransparency = 0.5 }, 0.12)
			end
		end))
		self.Maid:Add(button.MouseLeave:Connect(function()
			if style == "Primary" then
				Util.Tween(button, { BackgroundColor3 = theme.Primary }, 0.12)
				if shadow then
					Util.Tween(shadow, { BackgroundTransparency = 0.55 }, 0.12)
				end
			else
				Util.Tween(button, { BackgroundTransparency = 1 }, 0.12)
			end
		end))
		self.Maid:Add(button.MouseButton1Click:Connect(function()
			if action.Callback then
				Util.Safe(action.Callback)
			end
		end))

		table.insert(self.Actions, button)
		return button
	end

	for _, action in ipairs(actions) do
		makeAction(action)
	end

	local toggleEnabled = options.Toggle
	if toggleEnabled then
		local toggleOptions = type(toggleEnabled) == "table" and toggleEnabled or {}
		local state = toggleOptions.Default == true

		local track = Util.Create("Frame", {
			Name = "Toggle",
			LayoutOrder = #actions + 1,
			Size = UDim2.fromOffset(34, 20),
			BackgroundColor3 = state and theme.ToggleOn or theme.ToggleOff,
			BorderSizePixel = 0,
			Parent = footer,
		})
		Util.Corner(track, 10)
		local trackStroke = Util.Stroke(track, theme.Border, 1, state and 1 or 0.35)

		local knob = Util.Create("Frame", {
			Name = "Knob",
			Position = UDim2.fromOffset(state and 17 or 2, 2),
			Size = UDim2.fromOffset(15, 15),
			BackgroundColor3 = state and theme.KnobOn or theme.Knob,
			BorderSizePixel = 0,
			Parent = track,
		})
		Util.Corner(knob, 8)
		Util.Stroke(knob, theme.Window, 1, 0.72)

		local button = Util.Create("TextButton", {
			Name = "ToggleHit",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Parent = track,
		})

		local function paint(animated)
			local targetPosition = UDim2.fromOffset(state and 17 or 2, 2)
			local trackColor = state and theme.ToggleOn or theme.ToggleOff
			local knobColor = state and theme.KnobOn or theme.Knob
			if animated then
				Util.Tween(knob, { Position = targetPosition, BackgroundColor3 = knobColor }, 0.2, Enum.EasingStyle.Quint)
				Util.Tween(track, { BackgroundColor3 = trackColor }, 0.2)
				Util.Tween(trackStroke, { Transparency = state and 1 or 0.35 }, 0.2)
			else
				knob.Position = targetPosition
				knob.BackgroundColor3 = knobColor
				track.BackgroundColor3 = trackColor
				trackStroke.Transparency = state and 1 or 0.35
			end
		end

		function self:SetToggle(value, silent)
			state = value == true
			paint(true)
			if not silent and toggleOptions.Callback then
				Util.Safe(toggleOptions.Callback, state)
			end
		end

		function self:GetToggle()
			return state
		end

		self.Maid:Add(button.MouseButton1Click:Connect(function()
			state = not state
			paint(true)
			if toggleOptions.Callback then
				Util.Safe(toggleOptions.Callback, state)
			end
		end))

		paint(false)
		self.Toggle = track
	end

	if options.Callback then
		card.Active = true
		self.Maid:Add(card.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				Util.Safe(options.Callback)
			end
		end))
	end

	function self:SetStatus(value)
		statusLabel.Text = value
	end

	function self:SetTitle(value)
		titleLabel.Text = value
	end

	function self:SetDescription(value)
		if descriptionLabel then
			descriptionLabel.Text = value
		end
	end

	function self:Destroy()
		self.Maid:Clean()
		card:Destroy()
	end

	return self
end

return Card
end

__modules["Components.ColorPicker"] = function(require)
--[[
	Athena · Components/ColorPicker
	HSV canvas, hue strip, hex field and live swatch.
]]

local UserInputService = game:GetService("UserInputService")
local Util = require("Core.Util")
local Icons = require("Core.Icons")

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
end

__modules["Components.Dropdown"] = function(require)
--[[
	Athena · Components/Dropdown
	A compact selector with a floating option list.
]]

local Util = require("Core.Util")
local Icons = require("Core.Icons")

local Dropdown = {}
Dropdown.__index = Dropdown

local function normalizeOptions(list)
	local items = {}
	for _, option in ipairs(list or {}) do
		if type(option) == "string" then
			table.insert(items, { Name = option, Value = option })
		elseif type(option) == "table" then
			local name = option.Name or option.Title or tostring(option.Value)
			table.insert(items, {
				Name = name,
				Value = option.Value ~= nil and option.Value or name,
				Icon = option.Icon,
			})
		end
	end
	return items
end

function Dropdown.new(section, options)
	options = options or {}
	local theme = section.Theme

	local row = section:_Row({
		Name = options.Name or options.Title or "Dropdown",
		Description = options.Description,
		Height = options.Description and 58 or 48,
		ControlWidth = 150,
	})

	local self = setmetatable({
		Section = section,
		Theme = theme,
		Options = options,
		Instance = row.Row,
		Items = normalizeOptions(options.Options),
		Selected = nil,
		_open = false,
		Placeholder = options.Placeholder or "Select...",
		Maid = Util.Maid.new(),
	}, Dropdown)

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
	local stroke = Util.Stroke(pill, theme.Border, 1)
	Util.Padding(pill, 0, 26, 0, 10)

	local label = Util.Create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = self.Placeholder,
		Font = theme.Font,
		TextSize = 11.5,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = pill,
	})

	local chevron = Icons.New("chevronDown", 11, theme.TextMuted, pill)
	chevron.Frame.AnchorPoint = Vector2.new(0, 0.5)
	chevron.Frame.Position = UDim2.new(1, -21, 0.5, 0)

	self.Pill = pill
	self.Label = label
	self.Chevron = chevron
	self.Stroke = stroke

	self.Popup = section.Window:_CreatePopup({
		Name = "Dropdown",
		Width = 150,
		Height = 120,
		Padding = 5,
		OnClose = function()
			self._open = false
			Util.Tween(chevron.Frame, { Rotation = 0 }, 0.16)
			Util.Tween(stroke, { Color = theme.Border }, 0.16)
		end,
	})

	local function refreshLabel()
		if self.Selected then
			label.Text = self.Selected.Name
			label.TextColor3 = theme.Text
		else
			label.Text = self.Placeholder
			label.TextColor3 = theme.TextMuted
		end
	end

	function self:_Build()
		self.Popup:ResetContent()
		local content = self.Popup.Content

		local list = Util.Create("ScrollingFrame", {
			Name = "Options",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = theme.Border,
			ScrollBarImageTransparency = 0.2,
			ClipsDescendants = true,
			Parent = content,
		})
		Util.List(list, 2, Enum.HorizontalAlignment.Center)

		if #self.Items == 0 then
			Util.Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 34),
				BackgroundTransparency = 1,
				Text = "No options",
				Font = theme.Font,
				TextSize = 11,
				TextColor3 = theme.TextFaint,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Parent = list,
			})
			return
		end

		for index, item in ipairs(self.Items) do
			local selected = self.Selected ~= nil and self.Selected.Value == item.Value
			local optionRow = Util.Create("TextButton", {
				Name = "Option_" .. tostring(item.Name),
				LayoutOrder = index,
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = selected and theme.SurfaceHover or theme.Surface,
				BackgroundTransparency = selected and 0.25 or 1,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				Parent = list,
			})
			Util.Corner(optionRow, 6)

			local itemIcon
			if item.Icon then
				itemIcon = Icons.New(item.Icon, 12, selected and theme.Text or theme.TextMuted, optionRow)
				itemIcon.Frame.AnchorPoint = Vector2.new(0, 0.5)
				itemIcon.Frame.Position = UDim2.new(0, 9, 0.5, 0)
			end

			Util.Create("TextLabel", {
				Position = UDim2.fromOffset(item.Icon and 27 or 10, 0),
				Size = UDim2.new(1, (item.Icon and 27 or 10) + 28, 1, 0),
				BackgroundTransparency = 1,
				Text = item.Name,
				Font = theme.Font,
				TextSize = 11.5,
				TextColor3 = selected and theme.Text or theme.TextSoft,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = optionRow,
			})

			if selected then
				local check = Icons.New("check", 11, theme.Accent, optionRow)
				check.Frame.AnchorPoint = Vector2.new(1, 0.5)
				check.Frame.Position = UDim2.new(1, -10, 0.5, 0)
			end

			optionRow.MouseEnter:Connect(function()
				if not selected then
					Util.Tween(optionRow, { BackgroundTransparency = 0.6 }, 0.1)
				end
			end)
			optionRow.MouseLeave:Connect(function()
				if not selected then
					Util.Tween(optionRow, { BackgroundTransparency = 1 }, 0.1)
				end
			end)
			optionRow.MouseButton1Click:Connect(function()
				self:Set(item.Value)
				self:Close()
			end)
		end
	end

	function self:_Measure()
		local width = 150
		for _, item in ipairs(self.Items) do
			local textWidth = Util.Measure(item.Name, 11.5, theme.Font).X
			width = math.max(width, textWidth + (item.Icon and 27 or 10) + 40)
		end
		width = math.min(width, 290)

		local height = #self.Items > 0 and (#self.Items * 32 + 10) or 50
		height = math.min(height, 248)

		self.Popup:SetSize(math.ceil(width), math.ceil(height))
	end

	function self:Set(value, silent)
		local found = nil
		for _, item in ipairs(self.Items) do
			if item.Value == value or item.Name == value then
				found = item
				break
			end
		end
		if not found then
			return
		end

		local changed = self.Selected == nil or self.Selected.Value ~= found.Value
		self.Selected = found
		refreshLabel()

		if changed and not silent and self.Options.Callback then
			Util.Safe(self.Options.Callback, found.Value, found.Name)
		end
	end

	function self:Get()
		return self.Selected and self.Selected.Value or nil
	end

	function self:GetSelected()
		return self.Selected
	end

	function self:SetOptions(list)
		local previous = self.Selected and self.Selected.Value or nil
		self.Items = normalizeOptions(list)
		self.Selected = nil

		if previous ~= nil then
			for _, item in ipairs(self.Items) do
				if item.Value == previous then
					self.Selected = item
					break
				end
			end
		end
		if not self.Selected and #self.Items > 0 then
			self.Selected = self.Items[1]
		end
		refreshLabel()
		if self._open then
			self:_Measure()
			self:_Build()
		end
	end

	function self:OpenMenu()
		if self._open then
			return
		end
		self._open = true
		self:_Measure()
		self:_Build()
		self.Popup:OpenAt(self.Pill)
		Util.Tween(chevron.Frame, { Rotation = 180 }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Util.Tween(stroke, { Color = theme.SurfaceActive }, 0.16)
	end

	function self:Open()
		self:OpenMenu()
	end

	function self:Close()
		if self.Popup:IsOpen() then
			self.Popup:Close()
		end
	end

	function self:Toggle()
		if self.Popup:IsOpen() then
			self:Close()
		else
			self:OpenMenu()
		end
	end

	function self:SetEnabled(enabled)
		pill.Active = enabled
		label.TextTransparency = enabled and 0 or 0.45
	end

	function self:Destroy()
		self.Maid:Clean()
		if self.Popup then
			self.Popup:Destroy()
		end
		row.Row:Destroy()
	end

	refreshLabel()

	self.Maid:Add(pill.MouseButton1Click:Connect(function()
		self:Toggle()
	end))
	self.Maid:Add(pill.MouseEnter:Connect(function()
		Util.Tween(pill, { BackgroundColor3 = theme.SurfaceHover }, 0.12)
		Util.Tween(stroke, { Color = theme.SurfaceActive }, 0.12)
		chevron:SetColor(theme.Text)
	end))
	self.Maid:Add(pill.MouseLeave:Connect(function()
		if not self.Popup:IsOpen() then
			Util.Tween(pill, { BackgroundColor3 = theme.SurfaceAlt }, 0.12)
			Util.Tween(stroke, { Color = theme.Border }, 0.12)
			chevron:SetColor(theme.TextMuted)
		end
	end))

	local default = options.Default
	local initial = nil
	if default ~= nil then
		for _, item in ipairs(self.Items) do
			if item.Value == default or item.Name == default then
				initial = item
				break
			end
		end
	end
	if not initial and #self.Items > 0 then
		initial = self.Items[1]
	end
	if initial then
		self.Selected = initial
		refreshLabel()
	end

	return self
end

return Dropdown
end

__modules["Components.Keybind"] = function(require)
--[[
	Athena · Components/Keybind
	Click to listen, then press a key or mouse button. Backspace clears.
]]

local UserInputService = game:GetService("UserInputService")
local Util = require("Core.Util")

local Keybind = {}
Keybind.__index = Keybind

local function keyName(key)
	if key == nil then
		return "None"
	end
	if typeof(key) == "EnumItem" then
		if key == Enum.UserInputType.MouseButton1 then
			return "MB1"
		elseif key == Enum.UserInputType.MouseButton2 then
			return "MB2"
		elseif key == Enum.UserInputType.MouseButton3 then
			return "MB3"
		end
		return key.Name
	end
	return tostring(key)
end

local function isBindable(key)
	if typeof(key) ~= "EnumItem" then
		return false
	end
	if key.EnumType == Enum.KeyCode then
		return true
	end
	if key.EnumType == Enum.UserInputType then
		return key == Enum.UserInputType.MouseButton1
			or key == Enum.UserInputType.MouseButton2
			or key == Enum.UserInputType.MouseButton3
	end
	return false
end

function Keybind.new(section, options)
	options = options or {}
	local theme = section.Theme

	local row = section:_Row({
		Name = options.Name or options.Title or "Keybind",
		Description = options.Description,
		Height = options.Description and 58 or 48,
		ControlWidth = 96,
	})

	local self = setmetatable({
		Section = section,
		Theme = theme,
		Options = options,
		Instance = row.Row,
		Key = nil,
		Listening = false,
		_ignoreUntil = 0,
		Maid = Util.Maid.new(),
	}, Keybind)

	local pill = Util.Create("TextButton", {
		Name = "Key",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = row.Control,
	})
	Util.Corner(pill, 8)
	local stroke = Util.Stroke(pill, theme.Border, 1)

	local label = Util.Create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "None",
		Font = theme.FontMono,
		TextSize = 11,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = pill,
	})

	self.Pill = pill
	self.Label = label
	self.Stroke = stroke

	local listenConnection = nil

	local function stopListening()
		self.Listening = false
		if listenConnection then
			listenConnection:Disconnect()
			listenConnection = nil
		end
	end

	local function paint()
		if self.Listening then
			label.Text = "Press a key"
			label.TextColor3 = theme.Accent
			Util.Tween(stroke, { Color = theme.Accent, Transparency = 0 }, 0.12)
			Util.Tween(pill, { BackgroundColor3 = theme.AccentSoft }, 0.12)
		else
			label.Text = keyName(self.Key)
			label.TextColor3 = self.Key and theme.Text or theme.TextMuted
			Util.Tween(stroke, { Color = theme.Border, Transparency = 0 }, 0.12)
			Util.Tween(pill, { BackgroundColor3 = theme.SurfaceAlt }, 0.12)
		end
	end

	function self:Set(key, silent)
		if key ~= nil and not isBindable(key) then
			return
		end
		local changed = self.Key ~= key
		self.Key = key
		self.Listening = false
		self._ignoreUntil = os.clock() + 0.15
		stopListening()
		paint()
		if changed and not silent and self.Options.OnChanged then
			Util.Safe(self.Options.OnChanged, key)
		end
	end

	function self:Get()
		return self.Key
	end

	function self:Clear()
		self:Set(nil)
	end

	function self:_StartListening()
		if self.Listening then
			return
		end
		self.Listening = true
		paint()

		listenConnection = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					self.Listening = false
					stopListening()
					paint()
					return
				end
				if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
					self:Set(nil)
					return
				end
				self:Set(input.KeyCode)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2
				or input.UserInputType == Enum.UserInputType.MouseButton3
			then
				self:Set(input.UserInputType)
			end
		end)
	end

	self.Maid:Add(pill.MouseButton1Click:Connect(function()
		if self.Listening then
			self.Listening = false
			stopListening()
			paint()
		else
			self:_StartListening()
		end
	end))

	self.Maid:Add(pill.MouseEnter:Connect(function()
		if not self.Listening then
			Util.Tween(pill, { BackgroundColor3 = theme.SurfaceHover }, 0.12)
			Util.Tween(stroke, { Color = theme.SurfaceActive }, 0.12)
		end
	end))
	self.Maid:Add(pill.MouseLeave:Connect(function()
		if not self.Listening then
			Util.Tween(pill, { BackgroundColor3 = theme.SurfaceAlt }, 0.12)
			Util.Tween(stroke, { Color = theme.Border }, 0.12)
		end
	end))

	-- Global press events for the bound key.
	self.Maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or self.Listening or Util.IsTyping() then
			return
		end
		if os.clock() < self._ignoreUntil then
			return
		end
		if self.Key == nil or typeof(self.Key) ~= "EnumItem" then
			return
		end

		local pressed = false
		if self.Key.EnumType == Enum.KeyCode then
			pressed = input.KeyCode == self.Key
		elseif self.Key.EnumType == Enum.UserInputType then
			pressed = input.UserInputType == self.Key
		end

		if pressed and self.Options.Callback then
			Util.Safe(self.Options.Callback, self.Key)
		end
	end))

	self.Maid:Add(function()
		stopListening()
	end)

	function self:Destroy()
		self.Maid:Clean()
		row.Row:Destroy()
	end

	self.Key = options.Default
	paint()

	return self
end

return Keybind
end

__modules["Components.Label"] = function(require)
--[[
	Athena · Components/Label
	Supports a two-column value row or a wrapped paragraph, both measured
	so the card height stays exact at any width.
]]

local Util = require("Core.Util")

local Label = {}
Label.__index = Label

local function normalize(input)
	if type(input) == "string" then
		return { Text = input }
	end
	return input or {}
end

function Label.new(section, input)
	local options = normalize(input)
	local theme = section.Theme

	local self = setmetatable({
		Section = section,
		Theme = theme,
		Options = options,
		Maid = Util.Maid.new(),
	}, Label)

	if options.Value ~= nil then
		local valueText = tostring(options.Value)
		local valueWidth = math.ceil(math.min(Util.Measure(valueText, 11.5, theme.Font).X + 8, 240))

		local row = section:_Row({
			Name = options.Text or options.Name or "",
			Description = options.Description,
			Height = options.Description and 54 or 44,
			ControlWidth = valueWidth,
		})

		local valueLabel = Util.Create("TextLabel", {
			Name = "Value",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = valueText,
			Font = theme.Font,
			TextSize = 11.5,
			TextColor3 = options.ValueColor or theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row.Control,
		})

		self.Instance = row.Row
		self.ValueLabel = valueLabel
		self.NameLabel = row.NameLabel
		self.DescriptionLabel = row.DescriptionLabel

		function self:SetText(text)
			if self.NameLabel then
				self.NameLabel.Text = text
			end
		end

		function self:SetValue(value)
			valueLabel.Text = tostring(value)
		end

		function self:GetValue()
			return valueLabel.Text
		end

		function self:Destroy()
			self.Maid:Clean()
			row.Row:Destroy()
		end

		return self
	end

	local text = options.Text or options.Name or ""
	local description = options.Description or ""

	local frame = Util.Create("Frame", {
		Name = "Label",
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = theme.SurfaceHover,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 0,
		Parent = section.Card,
	})

	local padding = Util.Padding(frame, 13, 14, 13, 14)

	local textLabel = Util.Create("TextLabel", {
		Name = "Text",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = text,
		Font = theme.Font,
		TextSize = 12,
		TextColor3 = options.TextColor or theme.TextSoft,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = frame,
	})

	local descLabel
	if description ~= "" then
		descLabel = Util.Create("TextLabel", {
			Name = "Description",
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 14),
			BackgroundTransparency = 1,
			Text = description,
			Font = theme.Font,
			TextSize = 11,
			TextColor3 = theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Parent = frame,
		})
	end

	self.Instance = frame
	self.TextLabel = textLabel
	self.DescriptionLabel = descLabel

	local function measure()
		local innerWidth = math.max(80, section.Width - 28)
		local textHeight = math.max(15, math.ceil(Util.Measure(textLabel.Text, 12, theme.Font, innerWidth).Y))
		local descHeight = 0
		if descLabel then
			descHeight = math.max(14, math.ceil(Util.Measure(descLabel.Text, 11, theme.Font, innerWidth).Y))
		end

		frame.Size = UDim2.new(1, 0, 0, textHeight + descHeight + (descLabel and 4 or 0) + 26)
		textLabel.Size = UDim2.new(1, 0, 0, textHeight)
		if descLabel then
			descLabel.Position = UDim2.fromOffset(0, textHeight + 4)
			descLabel.Size = UDim2.new(1, 0, 0, descHeight)
		end
	end

	section:_RevealPendingDivider()
	frame.LayoutOrder = section:_NextOrder()
	section:_NewDivider()

	function self:SetText(value)
		textLabel.Text = value
		measure()
	end

	function self:GetText()
		return textLabel.Text
	end

	function self:Destroy()
		self.Maid:Clean()
		frame:Destroy()
	end

	local _ = padding
	measure()

	return self
end

return Label
end

__modules["Components.Separator"] = function(require)
--[[
	Athena · Components/Separator
	A hairline with an optional caption.
]]

local Util = require("Core.Util")

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
end

__modules["Components.Slider"] = function(require)
--[[
	Athena · Components/Slider
	A white Athena-style rail with a centred thumb, a floating value and
	drag feedback that never moves the page or the thumb vertically.
]]

local UserInputService = game:GetService("UserInputService")
local Util = require("Core.Util")

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
		_scroll = section.Tab and section.Tab.Scroll,
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
		BackgroundColor3 = theme.TrackFill,
		BackgroundTransparency = 0.74,
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

	self.Track = track
	self.Fill = fill
	self.Knob = knob

	local function setScrollEnabled(enabled)
		if self._scroll then
			self._scroll.ScrollingEnabled = enabled
		end
	end

	local function expandKnob(expanded)
		Util.Tween(
			knob,
			{ Size = UDim2.fromOffset(expanded and 16 or 14, expanded and 16 or 14) },
			0.14,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		)
	end

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
			setScrollEnabled(false)

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

			expandKnob(true)
			Util.Tween(track, { BackgroundTransparency = 0.6 }, 0.12)
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
			if not self._dragging then
				return
			end
			self._dragging = false
			self._grabOffset = 0
			setScrollEnabled(true)
			expandKnob(false)
			Util.Tween(track, { BackgroundTransparency = 0.74 }, 0.16)
		end
	end))

	self.Maid:Add(hit.MouseEnter:Connect(function()
		if not self._dragging then
			expandKnob(true)
			Util.Tween(track, { BackgroundTransparency = 0.6 }, 0.12)
		end
	end))
	self.Maid:Add(hit.MouseLeave:Connect(function()
		if not self._dragging then
			expandKnob(false)
			Util.Tween(track, { BackgroundTransparency = 0.74 }, 0.12)
		end
	end))

	function self:Destroy()
		setScrollEnabled(true)
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
end

__modules["Components.Textbox"] = function(require)
--[[
	Athena · Components/Textbox
	Inline text input with a commit callback on Enter or focus loss.
]]

local Util = require("Core.Util")

local Textbox = {}
Textbox.__index = Textbox

function Textbox.new(section, options)
	options = options or {}
	local theme = section.Theme

	local row = section:_Row({
		Name = options.Name or options.Title or "Textbox",
		Description = options.Description,
		Height = options.Description and 58 or 48,
		ControlWidth = 150,
	})

	local self = setmetatable({
		Section = section,
		Theme = theme,
		Options = options,
		Instance = row.Row,
		Maid = Util.Maid.new(),
	}, Textbox)

	local field = Util.Create("Frame", {
		Name = "Field",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Parent = row.Control,
	})
	Util.Corner(field, 8)
	local stroke = Util.Stroke(field, theme.Border, 1)
	Util.Padding(field, 0, 10, 0, 10)

	local textbox = Util.Create("TextBox", {
		Name = "Input",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = tostring(options.Default or ""),
		PlaceholderText = options.Placeholder or "",
		PlaceholderColor3 = theme.TextFaint,
		Font = theme.Font,
		TextSize = 11.5,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ClearTextOnFocus = false,
		Parent = field,
	})

	self.Field = field
	self.Textbox = textbox
	self.Stroke = stroke

	function self:Get()
		return textbox.Text
	end

	function self:Set(text, silent)
		textbox.Text = tostring(text or "")
		if not silent and self.Options.Callback then
			Util.Safe(self.Options.Callback, textbox.Text, false)
		end
	end

	local function commit(enterPressed)
		if self.Options.Callback then
			Util.Safe(self.Options.Callback, textbox.Text, enterPressed)
		end
	end

	self.Maid:Add(textbox.Focused:Connect(function()
		Util.Tween(stroke, { Color = theme.SurfaceActive, Transparency = 0 }, 0.12)
		Util.Tween(field, { BackgroundColor3 = theme.SurfaceHover }, 0.12)
	end))

	self.Maid:Add(textbox.FocusLost:Connect(function(enterPressed)
		Util.Tween(stroke, { Color = theme.Border, Transparency = 0 }, 0.12)
		Util.Tween(field, { BackgroundColor3 = theme.SurfaceAlt }, 0.12)
		commit(enterPressed)
	end))

	self.Maid:Add(textbox.MouseEnter:Connect(function()
		if not textbox:IsFocused() then
			Util.Tween(stroke, { Color = theme.SurfaceActive }, 0.12)
		end
	end))
	self.Maid:Add(textbox.MouseLeave:Connect(function()
		if not textbox:IsFocused() then
			Util.Tween(stroke, { Color = theme.Border }, 0.12)
		end
	end))

	if options.Numeric then
		self.Maid:Add(textbox:GetPropertyChangedSignal("Text"):Connect(function()
			local cleaned = textbox.Text:gsub("[^%d%-%.]", "")
			if cleaned ~= textbox.Text then
				local cursor = textbox.CursorPosition
				textbox.Text = cleaned
				textbox.CursorPosition = math.min(cursor, #cleaned + 1)
			end
		end))
	end

	function self:Destroy()
		self.Maid:Clean()
		row.Row:Destroy()
	end

	return self
end

return Textbox
end

__modules["Components.Toggle"] = function(require)
--[[
	Athena · Components/Toggle
	Light track switch with a dark knob, animated with a Quint ease.
]]

local Util = require("Core.Util")

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
end

__modules["Core.Dragger"] = function(require)
--[[
	Athena · Core/Dragger
	Mouse and touch dragging with viewport clamping, aware of UIScale.
]]

local UserInputService = game:GetService("UserInputService")
local Util = require("Core.Util")

local Dragger = {}

local function parentOrigin(frame)
	local parent = frame.Parent
	if parent and parent:IsA("GuiObject") then
		return parent.AbsolutePosition
	end
	return Vector2.zero
end

function Dragger.Attach(frame, handle, maid, options)
	options = options or {}
	local threshold = options.Threshold or 4
	local margin = options.Margin or 0

	local dragging = false
	local moved = false
	local startInput = Vector2.zero
	local startCenter = Vector2.zero

	local function viewport()
		return options.Viewport and options.Viewport() or Util.Viewport()
	end

	local function applyCenter(center)
		local origin = parentOrigin(frame)
		frame.Position = UDim2.fromOffset(
			math.round(center.X - origin.X),
			math.round(center.Y - origin.Y)
		)
	end

	local function clampCenter(center)
		local view = viewport()
		local half = frame.AbsoluteSize / 2
		local x = math.clamp(center.X, half.X + margin, math.max(half.X + margin, view.X - half.X - margin))
		local y = math.clamp(center.Y, half.Y + margin, math.max(half.Y + margin, view.Y - half.Y - margin))
		return Vector2.new(x, y)
	end

	handle.Active = true

	maid:Add(handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		dragging = true
		moved = false
		startInput = Vector2.new(input.Position.X, input.Position.Y)
		startCenter = frame.AbsolutePosition + frame.AbsoluteSize / 2
		if options.OnDragStart then
			options.OnDragStart()
		end
	end))

	maid:Add(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local delta = Vector2.new(input.Position.X, input.Position.Y) - startInput
		if not moved then
			if delta.Magnitude < threshold then
				return
			end
			moved = true
		end

		applyCenter(clampCenter(startCenter + delta))
		if options.OnDrag then
			options.OnDrag()
		end
	end))

	maid:Add(UserInputService.InputEnded:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		dragging = false
		if options.OnDragEnd then
			options.OnDragEnd(moved)
		end
	end))
end

--- Re-clamps a frame's centre into the viewport (used after resizing).
function Dragger.Clamp(frame, margin)
	margin = margin or 0
	local view = Util.Viewport()
	local half = frame.AbsoluteSize / 2
	local origin = parentOrigin(frame)
	local center = frame.AbsolutePosition + half

	local x = math.clamp(center.X, half.X + margin, math.max(half.X + margin, view.X - half.X - margin))
	local y = math.clamp(center.Y, half.Y + margin, math.max(half.Y + margin, view.Y - half.Y - margin))

	frame.Position = UDim2.fromOffset(
		math.round(x - origin.X),
		math.round(y - origin.Y)
	)
end

return Dragger
end

__modules["Core.Icons"] = function(require)
--[[
	Athena · Core/Icons
	Lucide image assets (public Roblox IDs) with a small vector fallback for
	custom marks. Every icon is authored by Lucide, not drawn from primitives.
]]

local TweenService = game:GetService("TweenService")

local Icons = {}

-- Holders are square unless the mark needs a wider canvas.
local ASPECT = {
	athena = 1.52,
}

-- One asset per icon. These are the Lucide Roblox IDs used by Fluent/LucidIcons.
local ASSETS = {
	athena = "rbxassetid://10723417608", -- landmark
	bolt = "rbxassetid://109718589733073", -- zap
	pause = "rbxassetid://10734919336",
	play = "rbxassetid://10734923549",
	refresh = "rbxassetid://10734933222", -- refresh-cw
	gear = "rbxassetid://10734950309", -- settings
	clock = "rbxassetid://10709805144",
	dot = "rbxassetid://10709798174", -- circle
	pulse = "rbxassetid://10709752035", -- activity
	home = "rbxassetid://10723407389",
	code = "rbxassetid://10709807111", -- code-2
	grid = "rbxassetid://10723424838", -- layout-grid
	gamepad = "rbxassetid://10723395215", -- gamepad-2
	search = "rbxassetid://10734943674",
	bell = "rbxassetid://10709775704",
	close = "rbxassetid://10747384394", -- x
	check = "rbxassetid://10709790644",
	plus = "rbxassetid://10734924532",
	minus = "rbxassetid://10734896206",
	maximize = "rbxassetid://10734886496", -- maximize-2
	minimize = "rbxassetid://10734895530", -- minimize-2
	square = "rbxassetid://10734965702",
	chevronDown = "rbxassetid://10709790948",
	chevronUp = "rbxassetid://10709791523",
	chevronRight = "rbxassetid://10709791437",
	chevronLeft = "rbxassetid://102314312897830",
	info = "rbxassetid://10723415903",
	warning = "rbxassetid://10709753149", -- alert-triangle
	trash = "rbxassetid://10747362241", -- trash-2
	terminal = "rbxassetid://10734982144",
	command = "rbxassetid://10709811365",
	keyboard = "rbxassetid://10723416765",
	sliders = "rbxassetid://10734963400", -- sliders-horizontal
	edit = "rbxassetid://10734883598",
	copy = "rbxassetid://10709812159",
	eye = "rbxassetid://10723346959",
	lock = "rbxassetid://10723434711",
	unlock = "rbxassetid://10747366027",
	power = "rbxassetid://10734930466",
	download = "rbxassetid://10723344270",
	upload = "rbxassetid://10747366434",
	save = "rbxassetid://10734941499",
	folder = "rbxassetid://10723387563",
	file = "rbxassetid://10723356507", -- file-code
	image = "rbxassetid://10723415040",
	camera = "rbxassetid://10709789686",
	video = "rbxassetid://10747374938",
	music = "rbxassetid://10734905958",
	server = "rbxassetid://10734949856",
	database = "rbxassetid://10709818996",
	cloud = "rbxassetid://10709806740",
	wifi = "rbxassetid://10747382504",
	bug = "rbxassetid://10709782845",
	gitBranch = "rbxassetid://10723396676",
	globe = "rbxassetid://10723404337",
	map = "rbxassetid://10734886202",
	compass = "rbxassetid://10709811445",
	target = "rbxassetid://10734977012",
	rocket = "rbxassetid://10734934585",
	star = "rbxassetid://10734966248",
	heart = "rbxassetid://10723406885",
	flame = "rbxassetid://10723376114",
	sparkles = "rbxassetid://105634041692696",
	loader = "rbxassetid://10723434070",
	arrowRight = "rbxassetid://10709768347",
	arrowLeft = "rbxassetid://10709768114",
	arrowUp = "rbxassetid://10709768939",
	arrowDown = "rbxassetid://10709767827",
}

Icons.Assets = ASSETS

-- Each part: bar = rounded rectangle, ring = stroked circle,
-- tri = right pointing triangle built from a clipped rotated square.
local SPECS = {
	close = {
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.74, h = 0.115, rot = 45 },
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.74, h = 0.115, rot = -45 },
	},
	plus = {
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.7, h = 0.115 },
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.115, h = 0.7 },
	},
	minus = {
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.7, h = 0.115 },
	},
	maximize = {
		{ kind = "ring", x = 0.5, y = 0.5, w = 0.66, h = 0.66, thickness = 0.1, corner = 0.16 },
	},
	check = {
		{ kind = "bar", x = 0.31, y = 0.55, w = 0.34, h = 0.13, rot = 45 },
		{ kind = "bar", x = 0.63, y = 0.43, w = 0.58, h = 0.13, rot = -48 },
	},
	chevronDown = {
		{ kind = "bar", x = 0.33, y = 0.52, w = 0.4, h = 0.115, rot = 45 },
		{ kind = "bar", x = 0.67, y = 0.52, w = 0.4, h = 0.115, rot = -45 },
	},
	chevronUp = {
		{ kind = "bar", x = 0.33, y = 0.48, w = 0.4, h = 0.115, rot = -45 },
		{ kind = "bar", x = 0.67, y = 0.48, w = 0.4, h = 0.115, rot = 45 },
	},
	chevronRight = {
		{ kind = "bar", x = 0.44, y = 0.34, w = 0.4, h = 0.115, rot = 45 },
		{ kind = "bar", x = 0.44, y = 0.66, w = 0.4, h = 0.115, rot = -45 },
	},
	chevronLeft = {
		{ kind = "bar", x = 0.56, y = 0.34, w = 0.4, h = 0.115, rot = -45 },
		{ kind = "bar", x = 0.56, y = 0.66, w = 0.4, h = 0.115, rot = 45 },
	},
	search = {
		{ kind = "ring", x = 0.43, y = 0.43, w = 0.62, h = 0.62, thickness = 0.1 },
		{ kind = "bar", x = 0.79, y = 0.79, w = 0.3, h = 0.11, rot = 45 },
	},
	bell = {
		-- Outline bell in the same thin style as the search and gear icons.
		{ kind = "ring", x = 0.5, y = 0.12, w = 0.1, h = 0.1, thickness = 0.12 },
		{ kind = "ring", x = 0.5, y = 0.45, w = 0.56, h = 0.6, thickness = 0.1, corner = 1 },
		{ kind = "bar", x = 0.5, y = 0.7, w = 0.78, h = 0.1, corner = 0.5 },
		{ kind = "bar", x = 0.5, y = 0.82, w = 0.16, h = 0.14, corner = 0.6 },
	},
	home = {
		{ kind = "bar", x = 0.3, y = 0.33, w = 0.38, h = 0.11, rot = 45 },
		{ kind = "bar", x = 0.7, y = 0.33, w = 0.38, h = 0.11, rot = -45 },
		{ kind = "bar", x = 0.5, y = 0.65, w = 0.52, h = 0.36, corner = 0.14 },
	},
	code = {
		{ kind = "bar", x = 0.3, y = 0.35, w = 0.32, h = 0.11, rot = 45 },
		{ kind = "bar", x = 0.3, y = 0.65, w = 0.32, h = 0.11, rot = -45 },
		{ kind = "bar", x = 0.7, y = 0.35, w = 0.32, h = 0.11, rot = -45 },
		{ kind = "bar", x = 0.7, y = 0.65, w = 0.32, h = 0.11, rot = 45 },
	},
	grid = {
		{ kind = "bar", x = 0.29, y = 0.29, w = 0.34, h = 0.34, corner = 0.14 },
		{ kind = "bar", x = 0.71, y = 0.29, w = 0.34, h = 0.34, corner = 0.14 },
		{ kind = "bar", x = 0.29, y = 0.71, w = 0.34, h = 0.34, corner = 0.14 },
		{ kind = "bar", x = 0.71, y = 0.71, w = 0.34, h = 0.34, corner = 0.14 },
	},
	gamepad = {
		{ kind = "ring", x = 0.5, y = 0.52, w = 0.92, h = 0.58, thickness = 0.1, corner = 0.3 },
		{ kind = "bar", x = 0.28, y = 0.52, w = 0.22, h = 0.1 },
		{ kind = "bar", x = 0.28, y = 0.52, w = 0.1, h = 0.22 },
		{ kind = "bar", x = 0.72, y = 0.44, w = 0.12, h = 0.12 },
		{ kind = "bar", x = 0.72, y = 0.62, w = 0.12, h = 0.12 },
	},
	pulse = {
		{ kind = "bar", x = 0.26, y = 0.62, w = 0.12, h = 0.3 },
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.12, h = 0.56 },
		{ kind = "bar", x = 0.74, y = 0.58, w = 0.12, h = 0.4 },
	},
	bolt = {
		{ kind = "bar", x = 0.42, y = 0.3, w = 0.42, h = 0.12, rot = 42 },
		{ kind = "bar", x = 0.58, y = 0.7, w = 0.42, h = 0.12, rot = 42 },
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.12, h = 0.42 },
	},
	gear = {
		{ kind = "ring", x = 0.5, y = 0.5, w = 0.56, h = 0.56, thickness = 0.11 },
		{ kind = "bar", x = 0.5, y = 0.11, w = 0.16, h = 0.18, corner = 0.3 },
		{ kind = "bar", x = 0.5, y = 0.89, w = 0.16, h = 0.18, corner = 0.3 },
		{ kind = "bar", x = 0.11, y = 0.5, w = 0.18, h = 0.16, corner = 0.3 },
		{ kind = "bar", x = 0.89, y = 0.5, w = 0.18, h = 0.16, corner = 0.3 },
		{ kind = "bar", x = 0.22, y = 0.22, w = 0.16, h = 0.16, rot = 45, corner = 0.3 },
		{ kind = "bar", x = 0.78, y = 0.22, w = 0.16, h = 0.16, rot = 45, corner = 0.3 },
		{ kind = "bar", x = 0.22, y = 0.78, w = 0.16, h = 0.16, rot = 45, corner = 0.3 },
		{ kind = "bar", x = 0.78, y = 0.78, w = 0.16, h = 0.16, rot = 45, corner = 0.3 },
	},
	clock = {
		{ kind = "ring", x = 0.5, y = 0.5, w = 0.82, h = 0.82, thickness = 0.1 },
		{ kind = "bar", x = 0.5, y = 0.4, w = 0.09, h = 0.26 },
		{ kind = "bar", x = 0.58, y = 0.52, w = 0.09, h = 0.2, rot = 90 },
	},
	dot = {
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.5, h = 0.5 },
	},
	pause = {
		{ kind = "bar", x = 0.33, y = 0.5, w = 0.16, h = 0.62, corner = 0.2 },
		{ kind = "bar", x = 0.67, y = 0.5, w = 0.16, h = 0.62, corner = 0.2 },
	},
	play = {
		{ kind = "tri", x = 0.24, y = 0.5, w = 0.56, h = 0.7 },
	},
	refresh = {
		{ kind = "ring", x = 0.5, y = 0.5, w = 0.68, h = 0.68, thickness = 0.1 },
		{ kind = "bar", x = 0.76, y = 0.24, w = 0.22, h = 0.12, rot = 30 },
		{ kind = "bar", x = 0.76, y = 0.24, w = 0.12, h = 0.2, rot = 30 },
	},
	info = {
		{ kind = "ring", x = 0.5, y = 0.5, w = 0.84, h = 0.84, thickness = 0.1 },
		{ kind = "bar", x = 0.5, y = 0.3, w = 0.13, h = 0.13 },
		{ kind = "bar", x = 0.5, y = 0.6, w = 0.1, h = 0.32 },
	},
	warning = {
		{ kind = "bar", x = 0.5, y = 0.48, w = 0.62, h = 0.11, rot = -60 },
		{ kind = "bar", x = 0.5, y = 0.48, w = 0.62, h = 0.11, rot = 60 },
		{ kind = "bar", x = 0.5, y = 0.3, w = 0.62, h = 0.11 },
		{ kind = "bar", x = 0.5, y = 0.68, w = 0.09, h = 0.14 },
	},
	trash = {
		{ kind = "bar", x = 0.5, y = 0.24, w = 0.72, h = 0.1 },
		{ kind = "bar", x = 0.5, y = 0.45, w = 0.54, h = 0.4, corner = 0.12 },
		{ kind = "bar", x = 0.5, y = 0.17, w = 0.26, h = 0.1, corner = 0.2 },
	},
	athena = {
		-- The two legs of the A meet at the apex.
		{ kind = "bar", x = 0.362, y = 0.505, w = 0.095, h = 1.12, rot = 30 },
		{ kind = "bar", x = 0.638, y = 0.505, w = 0.095, h = 1.12, rot = -30 },
		-- Wings sweeping out from the crossbar, as in getathena.gg/logo.png.
		{ kind = "bar", x = 0.17, y = 0.395, w = 0.36, h = 0.16, rot = 23 },
		{ kind = "bar", x = 0.83, y = 0.395, w = 0.36, h = 0.16, rot = -23 },
		-- Lower blades that frame the counter.
		{ kind = "bar", x = 0.305, y = 0.625, w = 0.1, h = 0.24, rot = 38 },
		{ kind = "bar", x = 0.695, y = 0.625, w = 0.1, h = 0.24, rot = -38 },
	},
}

Icons.Names = {}
for name in pairs(SPECS) do
	table.insert(Icons.Names, name)
end
for name in pairs(ASSETS) do
	if not SPECS[name] then
		table.insert(Icons.Names, name)
	end
end
table.sort(Icons.Names)

local function newPart(holder, spec, size, color, zIndex)
	local part
	if spec.kind == "ring" then
		part = Instance.new("Frame")
		part.BackgroundTransparency = 1
		part.Size = UDim2.fromScale(spec.w, spec.h)
		part.Position = UDim2.fromScale(spec.x, spec.y)
		part.AnchorPoint = Vector2.new(0.5, 0.5)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(spec.corner or 1, 0)
		corner.Parent = part
		local stroke = Instance.new("UIStroke")
		stroke.Color = color
		stroke.Thickness = math.max(1, (spec.thickness or 0.1) * size)
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = part
		part.ZIndex = zIndex
		part.Parent = holder
		return part
	elseif spec.kind == "tri" then
		local clip = Instance.new("Frame")
		clip.BackgroundTransparency = 1
		clip.ClipsDescendants = true
		clip.Size = UDim2.fromScale(spec.w, spec.h)
		clip.Position = UDim2.fromScale(spec.x, spec.y)
		clip.AnchorPoint = Vector2.new(0.5, 0.5)
		clip.ZIndex = zIndex
		clip.Parent = holder

		local diamond = Instance.new("Frame")
		diamond.Size = UDim2.fromScale(0.72, 0.72)
		diamond.AnchorPoint = Vector2.new(0.5, 0.5)
		diamond.Position = UDim2.fromScale(0, 0.5)
		diamond.Rotation = 45
		diamond.BackgroundColor3 = color
		diamond.BorderSizePixel = 0
		diamond.ZIndex = zIndex
		diamond.Parent = clip
		return clip
	end

	part = Instance.new("Frame")
	part.BackgroundColor3 = color
	part.BorderSizePixel = 0
	part.Size = UDim2.fromScale(spec.w, spec.h)
	part.Position = UDim2.fromScale(spec.x, spec.y)
	part.AnchorPoint = Vector2.new(0.5, 0.5)
	part.Rotation = spec.rot or 0
	part.ZIndex = zIndex
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(spec.corner or 1, 0)
	corner.Parent = part
	part.Parent = holder
	return part
end

--- Renders an icon into a new holder frame.
function Icons.New(name, size, color, parent, zIndex)
	size = size or 14
	color = color or Color3.new(1, 1, 1)

	local asset = ASSETS[name]
	local spec = SPECS[name]
	if not asset and not spec then
		asset = ASSETS.dot
	end

	local holder = Instance.new("Frame")
	holder.Name = "Icon_" .. tostring(name)
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromOffset(size * (asset and 1 or (ASPECT[name] or 1)), size)
	holder.ZIndex = zIndex or 1
	holder.Parent = parent

	local iconScale = Instance.new("UIScale")
	iconScale.Name = "IconScale"
	iconScale.Scale = 1
	iconScale.Parent = holder

	local image
	local parts = {}
	if asset then
		image = Instance.new("ImageLabel")
		image.Name = "Asset"
		image.Size = UDim2.fromScale(1, 1)
		image.BackgroundTransparency = 1
		image.BorderSizePixel = 0
		image.Image = asset
		image.ImageColor3 = color
		image.ScaleType = Enum.ScaleType.Fit
		image.ZIndex = zIndex or 1
		image.Parent = holder
	elseif spec then
		for _, partSpec in ipairs(spec) do
			table.insert(parts, newPart(holder, partSpec, size, color, zIndex or 1))
		end
	end

	local icon = {
		Frame = holder,
		Image = image,
		Scale = iconScale,
		Name = name,
		Size = size,
		Color = color,
	}

	function icon:SetColor(newColor)
		self.Color = newColor
		if self.Image then
			self.Image.ImageColor3 = newColor
		end
		for _, part in ipairs(parts) do
			if part:IsA("Frame") then
				local stroke = part:FindFirstChildOfClass("UIStroke")
				if stroke then
					stroke.Color = newColor
				end
				if part.BackgroundTransparency < 1 then
					part.BackgroundColor3 = newColor
				end
				for _, child in ipairs(part:GetChildren()) do
					if child:IsA("Frame") then
						child.BackgroundColor3 = newColor
					end
				end
			end
		end
	end

	function icon:SetTransparency(value)
		value = math.clamp(value or 0, 0, 1)
		if self.Image then
			self.Image.ImageTransparency = value
		end
		for _, part in ipairs(parts) do
			if part:IsA("Frame") then
				part.BackgroundTransparency = value
				local stroke = part:FindFirstChildOfClass("UIStroke")
				if stroke then
					stroke.Transparency = value
				end
			end
		end
	end

	function icon:Pulse(peak, duration)
		if not self.Scale or not self.Scale.Parent then
			return
		end
		peak = peak or 1.16
		duration = duration or 0.22
		self.Scale.Scale = 1
		TweenService:Create(
			self.Scale,
			TweenInfo.new(duration * 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Scale = peak }
		):Play()
		task.delay(duration * 0.35, function()
			if self.Scale and self.Scale.Parent then
				TweenService:Create(
					self.Scale,
					TweenInfo.new(duration * 0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Scale = 1 }
				):Play()
			end
		end)
	end

	function icon:Destroy()
		holder:Destroy()
	end

	-- Every icon inside a button responds to hover and press. Components keep
	-- their own motion; this adds the fine, tactile layer on top.
	if parent and parent:IsA("GuiButton") then
		local function tweenScale(target, duration)
			if not iconScale.Parent then
				return
			end
			TweenService:Create(
				iconScale,
				TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Scale = target }
			):Play()
		end

		local connections = {
			parent.MouseEnter:Connect(function()
				tweenScale(1.14, 0.16)
			end),
			parent.MouseLeave:Connect(function()
				tweenScale(1, 0.16)
			end),
			parent.MouseButton1Down:Connect(function()
				tweenScale(0.88, 0.07)
			end),
			parent.MouseButton1Up:Connect(function()
				tweenScale(1.14, 0.18)
			end),
		}

		holder.Destroying:Once(function()
			for _, connection in ipairs(connections) do
				connection:Disconnect()
			end
		end)
	end

	return icon
end

return Icons
end

__modules["Core.Popup"] = function(require)
--[[
	Athena · Core/Popup
	Shared floating surface used by dropdowns, colour pickers and panels.
	Handles positioning, clamping, fade/scale animation and outside clicks.
]]

local UserInputService = game:GetService("UserInputService")
local Util = require("Core.Util")

local Popup = {}
Popup.__index = Popup

--- context = { Frame, Overlay, Theme, CloseOthers }
function Popup.New(context, options)
	options = options or {}
	local theme = context.Theme
	local width = options.Width or 220
	local height = options.Height or 200

	local popup = setmetatable({
		Context = context,
		Theme = theme,
		Width = width,
		Height = height,
		Open = false,
		Anchor = nil,
		Options = options,
	}, Popup)

	local catcher = Util.Create("TextButton", {
		Name = "AthenaPopupCatcher",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 55,
		Parent = context.Overlay,
	})

	local frame = Util.Create("CanvasGroup", {
		Name = options.Name or "AthenaPopup",
		AnchorPoint = Vector2.new(0, 0),
		Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = theme.Overlay,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 60,
		Parent = context.Overlay,
	})

	local corner = Util.Corner(frame, theme.CornerSmall)
	corner.CornerRadius = UDim.new(0, theme.CornerSmall)

	local stroke = Util.Stroke(frame, theme.Border, 1)
	stroke.Transparency = 0.05

	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = frame

	local content = Util.Create("Frame", {
		Name = "Content",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 61,
		Parent = frame,
	})
	Util.Padding(content, options.Padding or 6, options.Padding or 6, options.Padding or 6, options.Padding or 6)

	popup.Frame = frame
	popup.Content = content
	popup.Catcher = catcher
	popup.Scale = scale
	popup.Corner = corner
	popup.Stroke = stroke

	popup._maid = Util.Maid.new()
	popup._escapeConnection = nil
	popup._token = 0

	popup._maid:Add(catcher.MouseButton1Click:Connect(function()
		popup:Close()
	end))

	function popup:IsOpen()
		return self.Open
	end

	--- Clears dynamic content while keeping the popup padding.
	function popup:ResetContent()
		for _, child in ipairs(content:GetChildren()) do
			if not child:IsA("UIPadding") then
				child:Destroy()
			end
		end
	end

	function popup:SetSize(newWidth, newHeight)
		self.Width = newWidth or self.Width
		self.Height = newHeight or self.Height
		frame.Size = UDim2.fromOffset(self.Width, self.Height)
	end

	function popup:_Position(anchor)
		if not anchor then
			return
		end

		local windowFrame = context.Frame
		local scaleValue = 1
		local uiScale = windowFrame:FindFirstChildOfClass("UIScale")
		if uiScale then
			scaleValue = uiScale.Scale
		end
		if scaleValue <= 0 then
			scaleValue = 1
		end

		local windowAbs = windowFrame.AbsolutePosition
		local windowSize = windowFrame.AbsoluteSize
		local anchorAbs = anchor.AbsolutePosition
		local anchorSize = anchor.AbsoluteSize

		local relativeX = (anchorAbs.X - windowAbs.X) / scaleValue
		local relativeY = (anchorAbs.Y - windowAbs.Y) / scaleValue
		local anchorWidth = anchorSize.X / scaleValue
		local anchorHeight = anchorSize.Y / scaleValue
		local windowWidth = windowFrame.Size.X.Offset
		local windowHeight = windowFrame.Size.Y.Offset
		local gap = options.Gap or 6
		local edge = options.Edge or 8

		local x = relativeX
		local y = relativeY + anchorHeight + gap

		if options.Align == "Right" then
			x = relativeX + anchorWidth - self.Width
		elseif options.Align == "Center" then
			x = relativeX + (anchorWidth - self.Width) / 2
		end

		local maxX = math.max(edge, windowWidth - self.Width - edge)
		local maxY = math.max(edge, windowHeight - self.Height - edge)

		if y > maxY then
			local above = relativeY - self.Height - gap
			if above >= edge then
				y = above
			end
		end

		x = math.clamp(x, edge, maxX)
		y = math.clamp(y, edge, maxY)

		frame.Position = UDim2.fromOffset(math.round(x), math.round(y))
	end

	function popup:OpenAt(anchor)
		if not anchor or not frame.Parent then
			return
		end
		if context.CloseOthers then
			context.CloseOthers(self)
		end

		self._token = self._token + 1
		local token = self._token
		self.Anchor = anchor
		self.Open = true

		frame.Visible = true
		catcher.Visible = true
		scale.Scale = options.StartScale or 0.97
		frame.GroupTransparency = 1
		self:_Position(anchor)

		Util.Tween(frame, { GroupTransparency = 0 }, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		Util.Tween(scale, { Scale = 1 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		if self.Options.OnOpen then
			local ok, err = pcall(self.Options.OnOpen, self)
			if not ok then
				warn("[Athena] popup OnOpen failed: " .. tostring(err))
			end
		end

		if self._escapeConnection then
			self._escapeConnection:Disconnect()
			self._escapeConnection = nil
		end
		self._escapeConnection = UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Escape and self.Open then
				self:Close()
			end
		end)
	end

	function popup:Close(instant)
		if not self.Open and not instant then
			return
		end
		self.Open = false
		self._token = self._token + 1
		local token = self._token

		if self._escapeConnection then
			self._escapeConnection:Disconnect()
			self._escapeConnection = nil
		end

		if self.Options.OnClose then
			pcall(self.Options.OnClose, self)
		end

		if instant then
			frame.Visible = false
			catcher.Visible = false
			frame.GroupTransparency = 1
			return
		end

		Util.Tween(frame, { GroupTransparency = 1 }, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		Util.Tween(scale, { Scale = 0.98 }, 0.1)
		task.delay(0.11, function()
			if self._token == token then
				frame.Visible = false
				catcher.Visible = false
			end
		end)
	end

	function popup:Toggle(anchor)
		if self.Open then
			self:Close()
		else
			self:OpenAt(anchor)
		end
	end

	function popup:Destroy()
		self._maid:Clean()
		if self._escapeConnection then
			self._escapeConnection:Disconnect()
			self._escapeConnection = nil
		end
		frame:Destroy()
		catcher:Destroy()
	end

	return popup
end

return Popup
end

__modules["Core.Theme"] = function(require)
--[[
	Athena · Core/Theme
	Design tokens recreated from the Athena client (dark neutral surfaces,
	hairline borders, light primary pills, monochrome accents).
]]

local Theme = {}

local function font(names, fallback)
	for _, name in ipairs(names) do
		local ok, value = pcall(function()
			return Enum.Font[name]
		end)
		if ok and value then
			return value
		end
	end
	return fallback
end

local Gotham = font({ "Gotham", "SourceSans" }, Enum.Font.SourceSans)
local GothamMedium = font({ "GothamMedium", "Gotham", "SourceSansSemibold" }, Gotham)
local GothamBold = font({ "GothamBold", "Gotham", "SourceSansBold" }, Gotham)
local Mono = font({ "RobotoMono", "Code" }, Enum.Font.Code)

Theme.Presets = {
	Athena = {
		Name = "Athena",

		-- Surfaces
		Window = Color3.fromRGB(19, 20, 22),
		WindowTop = Color3.fromRGB(21, 22, 25),
		Surface = Color3.fromRGB(26, 27, 30),
		SurfaceAlt = Color3.fromRGB(32, 34, 38),
		SurfaceHover = Color3.fromRGB(39, 41, 46),
		SurfaceActive = Color3.fromRGB(45, 47, 53),
		Overlay = Color3.fromRGB(23, 24, 27),

		-- Lines
		Border = Color3.fromRGB(44, 46, 51),
		BorderSoft = Color3.fromRGB(33, 35, 39),
		Highlight = Color3.fromRGB(255, 255, 255),

		-- Type
		Text = Color3.fromRGB(237, 238, 240),
		TextSoft = Color3.fromRGB(163, 163, 168),
		TextMuted = Color3.fromRGB(122, 127, 135),
		TextFaint = Color3.fromRGB(96, 100, 107),

		-- Monochrome accents (white on dark, black on light)
		Accent = Color3.fromRGB(238, 240, 242),
		AccentText = Color3.fromRGB(14, 15, 18),
		AccentSoft = Color3.fromRGB(32, 34, 38),
		Success = Color3.fromRGB(238, 240, 242),
		Warning = Color3.fromRGB(238, 240, 242),
		Error = Color3.fromRGB(238, 240, 242),
		Info = Color3.fromRGB(238, 240, 242),

		-- Controls
		Primary = Color3.fromRGB(238, 240, 242),
		PrimaryHover = Color3.fromRGB(255, 255, 255),
		PrimaryText = Color3.fromRGB(14, 15, 18),
		Track = Color3.fromRGB(48, 50, 56),
		TrackFill = Color3.fromRGB(238, 240, 242),
		ToggleOn = Color3.fromRGB(238, 240, 242),
		ToggleOff = Color3.fromRGB(41, 43, 48),
		Knob = Color3.fromRGB(148, 152, 160),
		KnobOn = Color3.fromRGB(14, 15, 18),
		Chip = Color3.fromRGB(34, 36, 40),
		Scrim = Color3.fromRGB(5, 5, 6),

		-- Type settings
		Font = Gotham,
		FontMedium = GothamMedium,
		FontBold = GothamBold,
		FontMono = Mono,
		TextSize = 13,
		TextSizeSmall = 11,
		TextSizeTitle = 30,

		-- Metrics
		Corner = 14,
		CornerCard = 12,
		CornerSmall = 9,
		CornerChip = 6,
		TopbarHeight = 56,

		-- Motion
		Speed = 0.15,
		SpeedSlow = 0.3,
	},

	Light = {
		Name = "Light",

		Window = Color3.fromRGB(247, 247, 249),
		WindowTop = Color3.fromRGB(250, 250, 252),
		Surface = Color3.fromRGB(255, 255, 255),
		SurfaceAlt = Color3.fromRGB(242, 243, 246),
		SurfaceHover = Color3.fromRGB(234, 236, 240),
		SurfaceActive = Color3.fromRGB(226, 228, 233),
		Overlay = Color3.fromRGB(252, 252, 253),

		Border = Color3.fromRGB(222, 224, 230),
		BorderSoft = Color3.fromRGB(233, 235, 239),
		Highlight = Color3.fromRGB(0, 0, 0),

		Text = Color3.fromRGB(22, 23, 26),
		TextSoft = Color3.fromRGB(84, 88, 96),
		TextMuted = Color3.fromRGB(116, 121, 130),
		TextFaint = Color3.fromRGB(142, 146, 154),

		Accent = Color3.fromRGB(22, 23, 26),
		AccentText = Color3.fromRGB(247, 247, 249),
		AccentSoft = Color3.fromRGB(242, 243, 246),
		Success = Color3.fromRGB(22, 23, 26),
		Warning = Color3.fromRGB(22, 23, 26),
		Error = Color3.fromRGB(22, 23, 26),
		Info = Color3.fromRGB(22, 23, 26),

		Primary = Color3.fromRGB(22, 23, 26),
		PrimaryHover = Color3.fromRGB(38, 40, 45),
		PrimaryText = Color3.fromRGB(247, 247, 249),
		Track = Color3.fromRGB(216, 219, 225),
		TrackFill = Color3.fromRGB(22, 23, 26),
		ToggleOn = Color3.fromRGB(22, 23, 26),
		ToggleOff = Color3.fromRGB(226, 228, 233),
		Knob = Color3.fromRGB(150, 154, 162),
		KnobOn = Color3.fromRGB(250, 250, 252),
		Chip = Color3.fromRGB(242, 243, 246),
		Scrim = Color3.fromRGB(255, 255, 255),
	},
}

--- Resolves a preset name (or a custom table) into a complete theme.
function Theme.Resolve(input, overrides)
	local base = Theme.Presets.Athena
	if type(input) == "string" then
		base = Theme.Presets[input] or base
	elseif type(input) == "table" then
		base = input
	end

	local resolved = {}
	for key, value in pairs(Theme.Presets.Athena) do
		resolved[key] = value
	end
	for key, value in pairs(base) do
		resolved[key] = value
	end
	if type(overrides) == "table" then
		for key, value in pairs(overrides) do
			resolved[key] = value
		end
	end

	resolved.Name = resolved.Name or "Athena"
	return resolved
end

return Theme
end

__modules["Core.Util"] = function(require)
--[[
	Athena · Core/Util
	Small, dependency free helpers shared by every component.
]]

local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Util = {}

--------------------------------------------------------------------------------
-- Lifetime
--------------------------------------------------------------------------------

local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Add(item)
	if item == nil then
		return item
	end
	if typeof(item) == "RBXScriptConnection" then
		table.insert(self._tasks, function()
			item:Disconnect()
		end)
	elseif typeof(item) == "Instance" then
		table.insert(self._tasks, function()
			item:Destroy()
		end)
	elseif type(item) == "table" and type(item.Destroy) == "function" then
		table.insert(self._tasks, function()
			item:Destroy()
		end)
	elseif type(item) == "function" then
		table.insert(self._tasks, item)
	elseif type(item) == "thread" then
		table.insert(self._tasks, function()
			task.cancel(item)
		end)
	end
	return item
end

function Maid:Clean()
	for index = #self._tasks, 1, -1 do
		local worker = self._tasks[index]
		self._tasks[index] = nil
		pcall(worker)
	end
end

Maid.Destroy = Maid.Clean

Util.Maid = Maid

--------------------------------------------------------------------------------
-- Instance creation
--------------------------------------------------------------------------------

function Util.Create(className, properties, children)
	local instance = Instance.new(className)
	local parent = nil

	if properties then
		for key, value in pairs(properties) do
			if key == "Parent" then
				parent = value
			else
				instance[key] = value
			end
		end
	end

	if children then
		for _, child in ipairs(children) do
			if child then
				child.Parent = instance
			end
		end
	end

	if parent then
		instance.Parent = parent
	end

	return instance
end

function Util.Corner(parent, radius)
	local corner = Instance.new("UICorner")
	if typeof(radius) == "UDim" then
		corner.CornerRadius = radius
	else
		corner.CornerRadius = UDim.new(0, radius or 0)
	end
	corner.Parent = parent
	return corner
end

function Util.Stroke(parent, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.new(1, 1, 1)
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

function Util.Padding(parent, top, right, bottom, left)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingRight = UDim.new(0, right or 0)
	padding.PaddingBottom = UDim.new(0, bottom or 0)
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.Parent = parent
	return padding
end

function Util.List(parent, padding, horizontalAlignment)
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, padding or 0)
	layout.HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Center
	layout.Parent = parent
	return layout
end

function Util.RowList(parent, padding)
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, padding or 0)
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = parent
	return layout
end

function Util.Clip(parent)
	parent.ClipsDescendants = true
	return parent
end

--------------------------------------------------------------------------------
-- Motion
--------------------------------------------------------------------------------

function Util.Tween(instance, properties, duration, style, direction, callback)
	local info = TweenInfo.new(
		duration or 0.15,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(instance, info, properties)
	if callback then
		tween.Completed:Once(callback)
	end
	tween:Play()
	return tween
end

--- Runs a user callback, reporting mistakes without breaking the interface.
function Util.Safe(callback, ...)
	if type(callback) ~= "function" then
		return
	end
	local ok, err = pcall(callback, ...)
	if not ok then
		warn("[Athena] " .. tostring(err))
	end
end

--- Subtle row highlight used by interactive rows.
function Util.RowHover(row, maid, theme)
	row.BackgroundColor3 = theme.SurfaceHover
	row.BackgroundTransparency = 1

	maid:Add(row.MouseEnter:Connect(function()
		Util.Tween(row, { BackgroundTransparency = 0.55 }, 0.12)
	end))
	maid:Add(row.MouseLeave:Connect(function()
		Util.Tween(row, { BackgroundTransparency = 1 }, 0.12)
	end))
	maid:Add(row.MouseButton1Down:Connect(function()
		Util.Tween(row, { BackgroundTransparency = 0.35 }, 0.06)
	end))
	maid:Add(row.MouseButton1Up:Connect(function()
		Util.Tween(row, { BackgroundTransparency = 0.55 }, 0.1)
	end))
end

--------------------------------------------------------------------------------
-- Text & numbers
--------------------------------------------------------------------------------

function Util.Measure(text, size, font, width)
	return TextService:GetTextSize(text, size, font, Vector2.new(width or 100000, 100000))
end

function Util.Round(value, step)
	if not step or step <= 0 then
		return value
	end
	local quotient = value / step
	local rounded = quotient >= 0 and math.floor(quotient + 0.5) or math.ceil(quotient - 0.5)
	return rounded * step
end

function Util.Clamp(value, minimum, maximum)
	return math.clamp(value, minimum, maximum)
end

function Util.FormatNumber(value)
	if value ~= value or value == math.huge or value == -math.huge then
		return "0"
	end
	local rounded = math.round(value * 1000) / 1000
	if rounded % 1 == 0 then
		return tostring(math.floor(rounded))
	end
	local text = string.format("%.3f", rounded)
	text = text:gsub("0+$", "")
	text = text:gsub("%.$", "")
	return text
end

function Util.DecimalsFor(step)
	if not step or step >= 1 then
		return 0
	end
	local text = tostring(step)
	local dot = text:find(".", 1, true)
	if dot then
		return math.min(#text - dot, 3)
	end
	return 0
end

--------------------------------------------------------------------------------
-- Colours
--------------------------------------------------------------------------------

function Util.ColorToHex(color)
	local r = math.round(math.clamp(color.R, 0, 1) * 255)
	local g = math.round(math.clamp(color.G, 0, 1) * 255)
	local b = math.round(math.clamp(color.B, 0, 1) * 255)
	return string.format("#%02X%02X%02X", r, g, b)
end

function Util.HexToColor(hex)
	if type(hex) ~= "string" then
		return nil
	end
	local cleaned = hex:gsub("#", "")
	if #cleaned == 3 then
		cleaned = cleaned:sub(1, 1):rep(2) .. cleaned:sub(2, 2):rep(2) .. cleaned:sub(3, 3):rep(2)
	end
	if #cleaned ~= 6 or cleaned:match("%X") then
		return nil
	end
	local r = tonumber(cleaned:sub(1, 2), 16)
	local g = tonumber(cleaned:sub(3, 4), 16)
	local b = tonumber(cleaned:sub(5, 6), 16)
	if not r or not g or not b then
		return nil
	end
	return Color3.fromRGB(r, g, b)
end

--- Returns a readable text colour for a given background.
function Util.ReadableOn(color)
	local h, s, v = color:ToHSV()
	if v > 0.62 and s < 0.7 then
		return Color3.fromRGB(14, 15, 18)
	end
	return Color3.fromRGB(255, 255, 255)
end

--------------------------------------------------------------------------------
-- Screen
--------------------------------------------------------------------------------

function Util.Viewport()
	local camera = workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

function Util.ComputeScale(viewport)
	local vp = viewport or Util.Viewport()
	return math.clamp(math.min(vp.X / 1440, vp.Y / 810), 0.72, 1.12)
end

function Util.Round2(value)
	return math.round(value * 2) / 2
end

function Util.SetTimeout(seconds, callback)
	local thread = task.delay(seconds, callback)
	return thread
end

function Util.FocusLost(textbox)
	textbox:ReleaseFocus()
end

function Util.IsTyping()
	return UserInputService:GetFocusedTextBox() ~= nil
end

function Util.Heartbeat()
	return RunService.Heartbeat
end

return Util
end

__modules["Notifications"] = function(require)
--[[
	Athena · Notifications
	Stacked toasts (top right) plus the history used by the bell panel.
]]

local Util = require("Core.Util")
local Icons = require("Core.Icons")

local Notifications = {}
Notifications.__index = Notifications

local TOAST_WIDTH = 320
local MAX_TOASTS = 4
local MAX_HISTORY = 30

local TONE_ICONS = {
	Info = "info",
	Success = "check",
	Warning = "warning",
	Error = "close",
	Accent = "bolt",
}

function Notifications.new(library, gui, theme)
	local self = setmetatable({
		Library = library,
		Gui = gui,
		Theme = theme,
		History = {},
		Unread = 0,
		_toasts = {},
		_listeners = {},
		_counter = 0,
		Maid = Util.Maid.new(),
	}, Notifications)

	local container = Util.Create("Frame", {
		Name = "AthenaNotifications",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 54),
		Size = UDim2.new(0, TOAST_WIDTH, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 200,
		Parent = gui,
	})
	Util.List(container, 10, Enum.HorizontalAlignment.Center)

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = Util.ComputeScale()
	uiScale.Parent = container

	self.Container = container
	self.UIScale = uiScale

	local function refreshScale()
		uiScale.Scale = Util.ComputeScale()
	end

	self.Maid:Add(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		local camera = workspace.CurrentCamera
		if camera then
			self.Maid:Add(camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshScale))
			refreshScale()
		end
	end))
	local camera = workspace.CurrentCamera
	if camera then
		self.Maid:Add(camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshScale))
	end

	return self
end

function Notifications:_ToneColor(tone)
	local theme = self.Theme
	if tone == "Success" then
		return theme.Success
	elseif tone == "Warning" then
		return theme.Warning
	elseif tone == "Error" then
		return theme.Error
	elseif tone == "Accent" then
		return theme.Accent
	end
	return theme.Info
end

function Notifications:_NotifyListeners()
	for _, listener in ipairs(self._listeners) do
		pcall(listener)
	end
end

function Notifications:OnChanged(callback)
	table.insert(self._listeners, callback)
	return function()
		for index, listener in ipairs(self._listeners) do
			if listener == callback then
				table.remove(self._listeners, index)
				break
			end
		end
	end
end

function Notifications:MarkRead()
	if self.Unread == 0 then
		return
	end
	self.Unread = 0
	self:_NotifyListeners()
end

function Notifications:Clear()
	self.History = {}
	self.Unread = 0
	self:_NotifyListeners()
end

function Notifications:GetHistory()
	return self.History
end

function Notifications:_Dismiss(toast, instant)
	if toast._closed then
		return
	end
	toast._closed = true

	local function remove()
		for index, entry in ipairs(self._toasts) do
			if entry == toast then
				table.remove(self._toasts, index)
				break
			end
		end
		if toast.Instance then
			toast.Instance:Destroy()
		end
	end

	if instant or not toast.Instance or not toast.Instance.Parent then
		remove()
		return
	end

	Util.Tween(toast.Instance, { GroupTransparency = 1 }, 0.14)
	Util.Tween(toast.Scale, { Scale = 0.97 }, 0.14)
	task.delay(0.15, remove)
end

function Notifications:Notify(options)
	if type(options) == "string" then
		options = { Title = options }
	end
	options = options or {}

	local theme = self.Theme
	local title = options.Title or options.Name or "Notification"
	local text = options.Text or options.Description or ""
	local duration = options.Duration
	if duration == nil then
		duration = 5
	end
	local tone = options.Tone or "Info"
	local toneColor = self:_ToneColor(tone)
	local iconName = options.Icon or TONE_ICONS[tone] or "info"

	local bodyWidth = TOAST_WIDTH - 54 - 16
	local bodyHeight = 0
	if text ~= "" then
		bodyHeight = math.ceil(Util.Measure(text, 11, theme.Font, bodyWidth).Y)
	end
	local height = math.max(58, 14 + 16 + (bodyHeight > 0 and (4 + bodyHeight) or 0) + 14)

	if #self._toasts >= MAX_TOASTS then
		self:_Dismiss(self._toasts[1], false)
	end

	self._counter = self._counter + 1

	local toast = Util.Create("CanvasGroup", {
		Name = "Toast",
		Size = UDim2.fromOffset(TOAST_WIDTH, height),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		GroupTransparency = 1,
		LayoutOrder = -self._counter,
		ZIndex = 201,
		Parent = self.Container,
	})
	Util.Corner(toast, theme.CornerCard)
	local stroke = Util.Stroke(toast, theme.Border, 1)
	stroke.Transparency = 0.15

	local toastScale = Instance.new("UIScale")
	toastScale.Scale = 0.97
	toastScale.Parent = toast

	local iconHolder = Util.Create("Frame", {
		Name = "IconHolder",
		Position = UDim2.fromOffset(14, 14),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = toneColor,
		BackgroundTransparency = 0.86,
		BorderSizePixel = 0,
		Parent = toast,
	})
	Util.Corner(iconHolder, 8)
	local icon = Icons.New(iconName, 14, toneColor, iconHolder)
	icon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Frame.Position = UDim2.fromScale(0.5, 0.5)

	Util.Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(54, 14),
		Size = UDim2.new(1, -54 - 34, 0, 16),
		BackgroundTransparency = 1,
		Text = title,
		Font = theme.FontMedium,
		TextSize = 12,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 202,
		Parent = toast,
	})

	if bodyHeight > 0 then
		Util.Create("TextLabel", {
			Name = "Body",
			Position = UDim2.fromOffset(54, 34),
			Size = UDim2.new(1, -54 - 16, 0, bodyHeight),
			BackgroundTransparency = 1,
			Text = text,
			Font = theme.Font,
			TextSize = 11,
			TextColor3 = theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			ZIndex = 202,
			Parent = toast,
		})
	end

	local closeButton = Util.Create("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 10),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = theme.SurfaceHover,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 203,
		Parent = toast,
	})
	Util.Corner(closeButton, 6)
	local closeIcon = Icons.New("close", 10, theme.TextFaint, closeButton, 204)
	closeIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	closeIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)

	closeButton.MouseEnter:Connect(function()
		Util.Tween(closeButton, { BackgroundTransparency = 0.4 }, 0.1)
		closeIcon:SetColor(theme.Text)
	end)
	closeButton.MouseLeave:Connect(function()
		Util.Tween(closeButton, { BackgroundTransparency = 1 }, 0.1)
		closeIcon:SetColor(theme.TextFaint)
	end)

	local progress = Util.Create("Frame", {
		Name = "Progress",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = theme.TextFaint,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		ZIndex = 202,
		Parent = toast,
	})

	local record = {
		Instance = toast,
		Scale = toastScale,
	}
	table.insert(self._toasts, record)

	closeButton.MouseButton1Click:Connect(function()
		self:_Dismiss(record)
	end)

	toast.GroupTransparency = 1
	Util.Tween(toast, { GroupTransparency = 0 }, 0.18)
	Util.Tween(toastScale, { Scale = 1 }, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	if duration > 0 then
		Util.Tween(progress, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		task.delay(duration, function()
			self:_Dismiss(record)
		end)
	end

	table.insert(self.History, 1, {
		Title = title,
		Text = text,
		Time = os.date("%H:%M"),
		Tone = tone,
	})
	while #self.History > MAX_HISTORY do
		table.remove(self.History)
	end

	self.Unread = self.Unread + 1
	self:_NotifyListeners()

	return {
		Close = function()
			self:_Dismiss(record)
		end,
	}
end

function Notifications:Destroy()
	self.Maid:Clean()
	for _, toast in ipairs(self._toasts) do
		if toast.Instance then
			toast.Instance:Destroy()
		end
	end
	self._toasts = {}
	if self.Container then
		self.Container:Destroy()
	end
end

return Notifications
end

__modules["QuickMenu"] = function(require)
--[[
	Athena · QuickMenu
	A small bottom-right command palette inspired by executor command bars.
	Press K (or click the grid button) to open it, then search for an action.
]]

local UserInputService = game:GetService("UserInputService")

local Util = require("Core.Util")
local Icons = require("Core.Icons")

local QuickMenu = {}
QuickMenu.__index = QuickMenu

local MARGIN = 20
local PANEL_WIDTH = 344
local PANEL_HEIGHT = 356
local TRIGGER_SIZE = 44

local function lower(value)
	return string.lower(tostring(value or ""))
end

local function offsetPosition(base, dy)
	return UDim2.new(base.X.Scale, base.X.Offset, base.Y.Scale, base.Y.Offset + (dy or 0))
end

function QuickMenu.new(window, options)
	options = options or {}
	local theme = window.Theme
	local key = options.Key
	if key == nil then
		key = Enum.KeyCode.K
	end

	local self = setmetatable({
		Window = window,
		Theme = theme,
		Options = options,
		Key = key,
		_open = false,
		Destroyed = false,
		Maid = Util.Maid.new(),
		_animToken = 0,
		_results = {},
	}, QuickMenu)

	local root = Util.Create("Frame", {
		Name = "AthenaQuickMenu",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 200,
		Parent = window.Gui,
	})
	root.Active = false
	self.Root = root

	-- Clicking outside the panel dismisses it, just like a popup.
	local catcher = Util.Create("TextButton", {
		Name = "Dismiss",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 205,
		Parent = root,
	})
	self.Catcher = catcher

	local ring = Util.Create("Frame", {
		Name = "TriggerPulse",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -(MARGIN + TRIGGER_SIZE / 2), 1, -(MARGIN + TRIGGER_SIZE / 2)),
		Size = UDim2.fromOffset(TRIGGER_SIZE, TRIGGER_SIZE),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 209,
		Parent = root,
	})
	Util.Corner(ring, 14)
	local ringStroke = Util.Stroke(ring, theme.Primary, 1, 1)
	self.Ring = ring
	self.RingStroke = ringStroke

	local trigger = Util.Create("TextButton", {
		Name = "QuickMenuButton",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -MARGIN, 1, -MARGIN),
		Size = UDim2.fromOffset(TRIGGER_SIZE, TRIGGER_SIZE),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 211,
		Parent = root,
	})
	Util.Corner(trigger, 14)
	local triggerStroke = Util.Stroke(trigger, theme.Border, 1)
	local triggerScale = Instance.new("UIScale")
	triggerScale.Scale = 1
	triggerScale.Parent = trigger

	local triggerIcon = Icons.New("grid", 16, theme.TextSoft, trigger, 213)
	triggerIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	triggerIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)

	local keyName = ""
	if self.Key then
		keyName = tostring(self.Key.Name or self.Key)
	end
	local keyChip = Util.Create("Frame", {
		Name = "KeyHint",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -5, 0, 5),
		Size = UDim2.fromOffset(15, 15),
		BackgroundColor3 = theme.Chip,
		BorderSizePixel = 0,
		Visible = self.Key ~= false and keyName ~= "",
		ZIndex = 214,
		Parent = trigger,
	})
	Util.Corner(keyChip, 4)
	local keyLabel = Util.Create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = keyName,
		Font = theme.FontBold,
		TextSize = 8,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 215,
		Parent = keyChip,
	})

	self.Trigger = trigger
	self.TriggerScale = triggerScale
	self.TriggerIcon = triggerIcon
	self.TriggerStroke = triggerStroke
	self.KeyChip = keyChip
	self.KeyLabel = keyLabel

	-- The menu itself.
	local panel = Util.Create("CanvasGroup", {
		Name = "Panel",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -MARGIN, 1, -(MARGIN + 52)),
		Size = UDim2.fromOffset(PANEL_WIDTH, PANEL_HEIGHT),
		BackgroundColor3 = theme.Overlay,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 220,
		Parent = root,
	})
	Util.Corner(panel, 13)
	local panelStroke = Util.Stroke(panel, theme.Border, 1, 0.05)
	panelStroke.Transparency = 0.05
	local panelScale = Instance.new("UIScale")
	panelScale.Scale = 1
	panelScale.Parent = panel
	self.Panel = panel
	self.PanelScale = panelScale
	self.PanelStroke = panelStroke
	self.PanelBase = panel.Position

	local header = Util.Create("Frame", {
		Name = "Header",
		Position = UDim2.fromOffset(14, 12),
		Size = UDim2.new(1, -28, 0, 38),
		BackgroundTransparency = 1,
		ZIndex = 222,
		Parent = panel,
	})

	local headerIcon = Util.Create("Frame", {
		Name = "Glyph",
		Position = UDim2.fromOffset(0, 3),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		ZIndex = 223,
		Parent = header,
	})
	Util.Corner(headerIcon, 8)
	Util.Stroke(headerIcon, theme.BorderSoft, 1, 0.4)
	local glyph = Icons.New("grid", 13, theme.Text, headerIcon, 224)
	glyph.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	glyph.Frame.Position = UDim2.fromScale(0.5, 0.5)
	self.HeaderIcon = glyph

	Util.Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(38, 1),
		Size = UDim2.new(1, -120, 0, 17),
		BackgroundTransparency = 1,
		Text = options.Title or "Quick menu",
		Font = theme.FontBold,
		TextSize = 12.5,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 223,
		Parent = header,
	})

	Util.Create("TextLabel", {
		Name = "Subtitle",
		Position = UDim2.fromOffset(38, 18),
		Size = UDim2.new(1, -120, 0, 13),
		BackgroundTransparency = 1,
		Text = options.Subtitle or "Search or run a command",
		Font = theme.Font,
		TextSize = 9.5,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 223,
		Parent = header,
	})

	local closeButton = Util.Create("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 3),
		Size = UDim2.fromOffset(25, 25),
		BackgroundColor3 = theme.SurfaceHover,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 224,
		Parent = header,
	})
	Util.Corner(closeButton, 6)
	local closeIcon = Icons.New("close", 10, theme.TextMuted, closeButton, 225)
	closeIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	closeIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)

	local shortcut = Util.Create("Frame", {
		Name = "Shortcut",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -31, 0, 6),
		Size = UDim2.fromOffset(22, 19),
		BackgroundColor3 = theme.Chip,
		BorderSizePixel = 0,
		ZIndex = 223,
		Parent = header,
	})
	Util.Corner(shortcut, 5)
	Util.Create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = keyName ~= "" and keyName or "—",
		Font = theme.FontBold,
		TextSize = 8.5,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 224,
		Parent = shortcut,
	})

	local searchShell = Util.Create("Frame", {
		Name = "SearchShell",
		Position = UDim2.fromOffset(14, 56),
		Size = UDim2.new(1, -28, 0, 36),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		ZIndex = 222,
		Parent = panel,
	})
	Util.Corner(searchShell, 9)
	local searchStroke = Util.Stroke(searchShell, theme.Border, 1)
	local searchIcon = Icons.New("search", 11, theme.TextMuted, searchShell, 223)
	searchIcon.Frame.AnchorPoint = Vector2.new(0, 0.5)
	searchIcon.Frame.Position = UDim2.new(0, 11, 0.5, 0)

	local searchBox = Util.Create("TextBox", {
		Name = "Search",
		Position = UDim2.fromOffset(29, 0),
		Size = UDim2.new(1, -58, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = options.Placeholder or "Search commands...",
		PlaceholderColor3 = theme.TextFaint,
		Font = theme.Font,
		TextSize = 11.5,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ClearTextOnFocus = false,
		ZIndex = 223,
		Parent = searchShell,
	})
	self.Search = searchBox

	local clearButton = Util.Create("TextButton", {
		Name = "Clear",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -7, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = theme.SurfaceHover,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 224,
		Parent = searchShell,
	})
	Util.Corner(clearButton, 5)
	local clearIcon = Icons.New("close", 8, theme.TextMuted, clearButton, 225)
	clearIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	clearIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)
	self.ClearButton = clearButton
	self.CloseIcon = closeIcon
	self.SearchIcon = searchIcon
	self.ClearIcon = clearIcon

	Util.Create("Frame", {
		Name = "Divider",
		Position = UDim2.fromOffset(14, 100),
		Size = UDim2.new(1, -28, 0, 1),
		BackgroundColor3 = theme.BorderSoft,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		ZIndex = 221,
		Parent = panel,
	})

	local scroll = Util.Create("ScrollingFrame", {
		Name = "Commands",
		Position = UDim2.fromOffset(10, 108),
		Size = UDim2.new(1, -20, 1, -120),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = theme.Border,
		ScrollBarImageTransparency = 0.25,
		ClipsDescendants = true,
		ZIndex = 221,
		Parent = panel,
	})
	Util.List(scroll, 3, Enum.HorizontalAlignment.Center)
	Util.Padding(scroll, 0, 4, 8, 0)
	self.Scroll = scroll

	local function setSearchFocused(focused)
		Util.Tween(searchShell, { BackgroundColor3 = focused and theme.SurfaceHover or theme.SurfaceAlt }, 0.12)
		Util.Tween(searchStroke, { Color = focused and theme.Primary or theme.Border }, 0.12)
		searchIcon:SetColor(focused and theme.Text or theme.TextMuted)
		if focused then
			searchIcon:Pulse(1.22, 0.26)
		end
	end

	self.Maid:Add(searchBox.Focused:Connect(function()
		setSearchFocused(true)
	end))
	self.Maid:Add(searchBox.FocusLost:Connect(function(enterPressed)
		setSearchFocused(false)
		if enterPressed and self._open and self._results[1] then
			self:_Run(self._results[1])
		end
	end))
	self.Maid:Add(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = searchBox.Text
		clearButton.Visible = text ~= ""
		self:_Render(text)
	end))
	self.Maid:Add(clearButton.MouseButton1Click:Connect(function()
		searchBox.Text = ""
		searchBox:CaptureFocus()
	end))
	self.Maid:Add(clearButton.MouseEnter:Connect(function()
		Util.Tween(clearButton, { BackgroundTransparency = 0.55 }, 0.1)
		clearIcon:SetColor(theme.Text)
		Util.Tween(clearIcon.Frame, { Rotation = 90 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))
	self.Maid:Add(clearButton.MouseLeave:Connect(function()
		Util.Tween(clearButton, { BackgroundTransparency = 1 }, 0.1)
		clearIcon:SetColor(theme.TextMuted)
		Util.Tween(clearIcon.Frame, { Rotation = 0 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))

	self.Maid:Add(closeButton.MouseButton1Click:Connect(function()
		self:Close()
	end))
	self.Maid:Add(closeButton.MouseEnter:Connect(function()
		Util.Tween(closeButton, { BackgroundTransparency = 0.45 }, 0.1)
		closeIcon:SetColor(theme.Text)
		Util.Tween(closeIcon.Frame, { Rotation = 90 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))
	self.Maid:Add(closeButton.MouseLeave:Connect(function()
		Util.Tween(closeButton, { BackgroundTransparency = 1 }, 0.1)
		closeIcon:SetColor(theme.TextMuted)
		Util.Tween(closeIcon.Frame, { Rotation = 0 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))
	self.Maid:Add(catcher.MouseButton1Click:Connect(function()
		self:Close()
	end))

	local hovered = false
	self.Maid:Add(trigger.MouseEnter:Connect(function()
		hovered = true
		if not self._open then
			Util.Tween(trigger, { BackgroundColor3 = theme.SurfaceHover }, 0.12)
			Util.Tween(triggerScale, { Scale = 1.06 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			triggerIcon:SetColor(theme.Text)
		end
	end))
	self.Maid:Add(trigger.MouseLeave:Connect(function()
		hovered = false
		if not self._open then
			Util.Tween(trigger, { BackgroundColor3 = theme.Surface }, 0.12)
			Util.Tween(triggerScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			triggerIcon:SetColor(theme.TextSoft)
		end
	end))
	self.Maid:Add(trigger.MouseButton1Down:Connect(function()
		Util.Tween(triggerScale, { Scale = 0.93 }, 0.07)
	end))
	self.Maid:Add(trigger.MouseButton1Up:Connect(function()
		Util.Tween(triggerScale, { Scale = hovered and (self._open and 1 or 1.06) or 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))
	self.Maid:Add(trigger.MouseButton1Click:Connect(function()
		self:Toggle()
	end))

	if self.Key then
		self.Maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == self.Key and not gameProcessed and not Util.IsTyping() then
				self:Toggle()
			elseif input.KeyCode == Enum.KeyCode.Escape and self._open and not gameProcessed then
				self:Close()
			end
		end))
	end

	self:_SetTriggerOpen(false, true)
	self.Panel.Visible = false
	self.Panel.GroupTransparency = 1
	self.Catcher.Visible = false

	-- A slow halo makes the closed trigger feel alive without drawing attention away from the window.
	self.Maid:Add(task.spawn(function()
		while root.Parent and not self.Destroyed do
			if not self._open then
				ring.Visible = true
				ring.Size = UDim2.fromOffset(40, 40)
				ringStroke.Transparency = 0.8
				Util.Tween(ring, { Size = UDim2.fromOffset(58, 58) }, 1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				Util.Tween(ringStroke, { Transparency = 1 }, 1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			end
			task.wait(2.8)
		end
	end))

	return self
end

function QuickMenu:_SetTriggerOpen(open, instant)
	local theme = self.Theme
	if open then
		self.Ring.Visible = false
		if instant then
			self.Trigger.BackgroundColor3 = theme.Primary
			self.TriggerStroke.Transparency = 1
		else
			Util.Tween(self.Trigger, { BackgroundColor3 = theme.Primary }, 0.16)
			Util.Tween(self.TriggerStroke, { Transparency = 1 }, 0.16)
		end
		self.TriggerIcon:SetColor(theme.PrimaryText)
		self.KeyChip.BackgroundColor3 = theme.SurfaceAlt
		self.KeyLabel.TextColor3 = theme.TextSoft
		self.TriggerScale.Scale = instant and 1 or 0.9
		if not instant then
			Util.Tween(self.TriggerScale, { Scale = 1 }, 0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			self.TriggerIcon:Pulse(1.18, 0.26)
		end
		Util.Tween(self.TriggerIcon.Frame, { Rotation = 45 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	else
		if instant then
			self.Trigger.BackgroundColor3 = theme.Surface
			self.TriggerStroke.Transparency = 0
		else
			Util.Tween(self.Trigger, { BackgroundColor3 = theme.Surface }, 0.16)
			Util.Tween(self.TriggerStroke, { Transparency = 0 }, 0.16)
		end
		self.TriggerIcon:SetColor(theme.TextSoft)
		self.KeyChip.BackgroundColor3 = theme.Chip
		self.KeyLabel.TextColor3 = theme.TextMuted
		self.TriggerScale.Scale = 1
		self.Ring.Visible = true
		if not instant then
			self.TriggerIcon:Pulse(1.1, 0.2)
		end
		Util.Tween(self.TriggerIcon.Frame, { Rotation = 0 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end
end

function QuickMenu:Open()
	if self.Destroyed or self._open then
		return
	end
	self._open = true
	self._animToken += 1
	self.Catcher.Visible = true
	self.Panel.Visible = true
	self.Panel.GroupTransparency = 1
	self.PanelScale.Scale = 0.92
	self.Panel.Position = offsetPosition(self.PanelBase, 12)
	self:_SetTriggerOpen(true)
	self.HeaderIcon:Pulse(1.16, 0.3)
	Util.Tween(self.PanelStroke, { Transparency = 0.02 }, 0.2)

	if self.Search.Text ~= "" then
		self.Search.Text = ""
	else
		self:_Render("")
	end

	Util.Tween(self.Panel, { GroupTransparency = 0 }, 0.18)
	Util.Tween(self.PanelScale, { Scale = 1 }, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	Util.Tween(self.Panel, { Position = self.PanelBase }, 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end

function QuickMenu:Close(instant)
	if self.Destroyed then
		return
	end
	local wasOpen = self._open
	self._open = false
	self._animToken += 1
	local token = self._animToken
	self.Catcher.Visible = false
	if self.Search:IsFocused() then
		self.Search:ReleaseFocus()
	end
	self:_SetTriggerOpen(false)
	Util.Tween(self.PanelStroke, { Transparency = 0.05 }, 0.18)

	if not wasOpen or instant then
		self.Panel.Visible = false
		self.Panel.GroupTransparency = 1
		return
	end

	Util.Tween(self.Panel, { GroupTransparency = 1 }, 0.14)
	Util.Tween(self.PanelScale, { Scale = 0.94 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	Util.Tween(self.Panel, { Position = offsetPosition(self.PanelBase, 10) }, 0.16)
	task.delay(0.17, function()
		if not self.Destroyed and not self._open and token == self._animToken then
			self.Panel.Visible = false
		end
	end)
end

function QuickMenu:Toggle()
	if self._open then
		self:Close()
	else
		self:Open()
	end
end

function QuickMenu:_PulseTrigger()
	if self.Destroyed then
		return
	end
	self.Ring.Visible = true
	self.Ring.Size = UDim2.fromOffset(TRIGGER_SIZE, TRIGGER_SIZE)
	self.RingStroke.Transparency = 0.65
	Util.Tween(self.Ring, { Size = UDim2.fromOffset(64, 64) }, 0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	Util.Tween(self.RingStroke, { Transparency = 1 }, 0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	self.TriggerScale.Scale = 1.1
	Util.Tween(self.TriggerScale, { Scale = 1 }, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	task.delay(0.42, function()
		if not self.Destroyed and not self._open then
			self.Ring.Visible = true
		end
	end)
end

function QuickMenu:_Commands()
	local window = self.Window
	local commands = {}
	local function add(title, description, icon, callback, keywords)
		table.insert(commands, {
			Title = title,
			Description = description,
			Icon = icon or "dot",
			Run = callback,
			Keywords = keywords or "",
		})
	end

	add("Center window", "Bring the interface back to the middle.", "maximize", function()
		window:Center()
	end)

	if window.Minimized then
		add("Restore window", "Open the window from its floating pill.", "maximize", function()
			window:Restore()
		end)
	else
		add("Minimise window", "Tuck the window into its floating pill.", "minus", function()
			window:Minimize()
		end)
	end

	if window.Visible then
		add("Hide window", "Hide the window without closing it.", "minus", function()
			window:Hide()
		end)
	else
		add("Show window", "Bring the hidden window back.", "maximize", function()
			window:Show()
		end)
	end

	add("Send a test notification", "Check the toast and bell animation.", "bell", function()
		window:Notify({
			Title = "Quick menu",
			Text = "Command palette is wired up.",
			Tone = "Info",
		})
	end)

	add("Clear notifications", "Remove the notification history and badge.", "trash", function()
		local notifications = window.Library and window.Library._notifications
		if notifications then
			notifications:Clear()
		end
	end)

	for _, tab in ipairs(window.Tabs or {}) do
		local icon = tab._navConfig and tab._navConfig.Icon or "chevronRight"
		add("Open " .. tostring(tab.Title), "Jump to the " .. tostring(tab.Title) .. " tab.", icon, function()
			if window.Minimized then
				window:Restore()
			elseif not window.Visible then
				window:Show()
			end
			window:SelectTab(tab)
		end, tab.Title)
	end

	return commands
end

function QuickMenu:_Run(command)
	if not command then
		return
	end
	self:Close()
	task.delay(0.04, function()
		self:_PulseTrigger()
	end)
	Util.Safe(command.Run)
end

function QuickMenu:_BuildRow(command, index)
	local theme = self.Theme

	local row = Util.Create("TextButton", {
		Name = "Command_" .. tostring(command.Title),
		LayoutOrder = index,
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = theme.SurfaceAlt,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 222,
		Parent = self.Scroll,
	})
	Util.Corner(row, 8)
	local rowScale = Instance.new("UIScale")
	rowScale.Scale = 0.94
	rowScale.Parent = row

	local iconTile = Util.Create("Frame", {
		Name = "Glyph",
		Position = UDim2.fromOffset(9, 8),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 223,
		Parent = row,
	})
	Util.Corner(iconTile, 7)
	local icon = Icons.New(command.Icon, 12, theme.TextSoft, iconTile, 224)
	icon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Frame.Position = UDim2.fromScale(0.5, 0.5)

	Util.Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(47, 5),
		Size = UDim2.new(1, -82, 0, 15),
		BackgroundTransparency = 1,
		Text = command.Title,
		Font = theme.FontMedium,
		TextSize = 11.5,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 223,
		Parent = row,
	})
	Util.Create("TextLabel", {
		Name = "Description",
		Position = UDim2.fromOffset(47, 20),
		Size = UDim2.new(1, -82, 0, 13),
		BackgroundTransparency = 1,
		Text = command.Description,
		Font = theme.Font,
		TextSize = 9,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 223,
		Parent = row,
	})
	local chevron = Icons.New("chevronRight", 9, theme.TextFaint, row, 223)
	chevron.Frame.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Frame.Position = UDim2.new(1, -10, 0.5, 0)

	local rowMaid = Util.Maid.new()
	row.Destroying:Once(function()
		rowMaid:Clean()
	end)

	rowMaid:Add(row.MouseEnter:Connect(function()
		Util.Tween(row, { BackgroundTransparency = 0.55 }, 0.1)
		Util.Tween(rowScale, { Scale = 1.01 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		icon:SetColor(theme.Text)
		chevron:SetColor(theme.TextSoft)
		icon:Pulse(1.12, 0.2)
		Util.Tween(chevron.Frame, { Position = UDim2.new(1, -6, 0.5, 0) }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))
	rowMaid:Add(row.MouseLeave:Connect(function()
		Util.Tween(row, { BackgroundTransparency = 1 }, 0.12)
		Util.Tween(rowScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		icon:SetColor(theme.TextSoft)
		chevron:SetColor(theme.TextFaint)
		Util.Tween(chevron.Frame, { Position = UDim2.new(1, -10, 0.5, 0) }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))
	rowMaid:Add(row.MouseButton1Down:Connect(function()
		Util.Tween(rowScale, { Scale = 0.97 }, 0.06)
		icon:Pulse(0.88, 0.1)
	end))
	rowMaid:Add(row.MouseButton1Up:Connect(function()
		Util.Tween(rowScale, { Scale = 1.01 }, 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))
	rowMaid:Add(row.MouseButton1Click:Connect(function()
		self:_Run(command)
	end))

	task.delay((index - 1) * 0.022, function()
		if row.Parent and self._open then
			Util.Tween(rowScale, { Scale = 1 }, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
	end)
end

function QuickMenu:_Render(query)
	if self.Destroyed then
		return
	end
	self.Scroll.CanvasPosition = Vector2.new(0, 0)
	for _, child in ipairs(self.Scroll:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local needle = lower(query)
	local results = {}
	for _, command in ipairs(self:_Commands()) do
		local haystack = lower(command.Title .. " " .. command.Description .. " " .. command.Keywords)
		if needle == "" or string.find(haystack, needle, 1, true) then
			table.insert(results, command)
		end
	end
	self._results = results

	if #results == 0 then
		local empty = Util.Create("Frame", {
			Name = "Empty",
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 76),
			BackgroundTransparency = 1,
			ZIndex = 222,
			Parent = self.Scroll,
		})
		local icon = Icons.New("search", 18, self.Theme.TextFaint, empty, 223)
		icon.Frame.AnchorPoint = Vector2.new(0.5, 0)
		icon.Frame.Position = UDim2.new(0.5, 0, 0, 9)
		icon:Pulse(1.14, 0.28)
		Util.Create("TextLabel", {
			Position = UDim2.fromOffset(0, 34),
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			Text = "No commands match",
			Font = self.Theme.FontMedium,
			TextSize = 11,
			TextColor3 = self.Theme.TextSoft,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 223,
			Parent = empty,
		})
		Util.Create("TextLabel", {
			Position = UDim2.fromOffset(0, 50),
			Size = UDim2.new(1, 0, 0, 14),
			BackgroundTransparency = 1,
			Text = "Try a different word or open a tab.",
			Font = self.Theme.Font,
			TextSize = 9.5,
			TextColor3 = self.Theme.TextFaint,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 223,
			Parent = empty,
		})
		return
	end

	for index, command in ipairs(results) do
		self:_BuildRow(command, index)
	end
end

function QuickMenu:Destroy()
	if self.Destroyed then
		return
	end
	self.Destroyed = true
	self._open = false
	self.Maid:Clean()
	if self.Root then
		self.Root:Destroy()
	end
end

return QuickMenu
end

__modules["Section"] = function(require)
--[[
	Athena · Section
	A titled card that groups rows. Every component is built from the same
	deterministic row so spacing stays consistent at any width.
]]

local Util = require("Core.Util")
local Icons = require("Core.Icons")
local Button = require("Components.Button")
local Toggle = require("Components.Toggle")
local Slider = require("Components.Slider")
local Dropdown = require("Components.Dropdown")
local Keybind = require("Components.Keybind")
local Textbox = require("Components.Textbox")
local Label = require("Components.Label")
local Separator = require("Components.Separator")
local ColorPicker = require("Components.ColorPicker")

local Section = {}
Section.__index = Section

function Section.new(tab, input)
	local config = input
	if type(config) == "string" then
		config = { Title = config }
	end
	config = config or {}

	local theme = tab.Theme
	local bare = config.Bare == true
	local title = config.Title or config.Name or "Section"

	local self = setmetatable({
		Tab = tab,
		Window = tab.Window,
		Theme = theme,
		Title = title,
		Icon = config.Icon,
		Count = config.Count,
		Bare = bare,
		Width = tab:_ContentWidth(),
		Components = {},
		Maid = Util.Maid.new(),
		_order = 0,
		_pendingDivider = nil,
	}, Section)

	local frame = Util.Create("Frame", {
		Name = "Section_" .. tostring(title),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = tab.Scroll,
	})
	Util.List(frame, bare and 0 or 8, Enum.HorizontalAlignment.Center)
	self.Frame = frame

	if not bare then
		local header = Util.Create("Frame", {
			Name = "Header",
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			LayoutOrder = 0,
			Parent = frame,
		})
		self.Header = header

		local iconSpace = 0
		if config.Icon then
			local icon = Icons.New(config.Icon, 12, theme.TextSoft, header)
			icon.Frame.AnchorPoint = Vector2.new(0, 0.5)
			icon.Frame.Position = UDim2.new(0, 0, 0.5, 0)
			iconSpace = 20
		end

		self.TitleLabel = Util.Create("TextLabel", {
			Name = "Title",
			Position = UDim2.fromOffset(iconSpace, 0),
			Size = UDim2.new(1, -(iconSpace + 60), 1, 0),
			BackgroundTransparency = 1,
			Text = title,
			Font = theme.FontMedium,
			TextSize = 12.5,
			TextColor3 = theme.TextSoft,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})

		if config.Count ~= nil then
			Util.Create("TextLabel", {
				Name = "Count",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(60, 16),
				BackgroundTransparency = 1,
				Text = tostring(config.Count),
				Font = theme.Font,
				TextSize = 11,
				TextColor3 = theme.TextFaint,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = header,
			})
		end
	end

	local card = Util.Create("Frame", {
		Name = "Card",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = bare and 1 or 0,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		LayoutOrder = 1,
		Parent = frame,
	})
	Util.Corner(card, theme.CornerCard)
	if not bare then
		Util.Stroke(card, theme.Border, 1)
	end
	Util.List(card, 0, Enum.HorizontalAlignment.Center)
	self.Card = card

	return self
end

function Section:_NextOrder()
	self._order = self._order + 1
	return self._order
end

function Section:_RevealPendingDivider()
	if self._pendingDivider then
		self._pendingDivider.Size = UDim2.new(1, -28, 0, 1)
		self._pendingDivider.Visible = true
		self._pendingDivider = nil
	end
end

function Section:_NewDivider()
	local divider = Util.Create("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, -28, 0, 0),
		BackgroundColor3 = self.Theme.BorderSoft,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Visible = false,
		LayoutOrder = self:_NextOrder(),
		Parent = self.Card,
	})
	self._pendingDivider = divider
	return divider
end

--- Builds a standard row. Components use this so every row shares metrics.
function Section:_Row(options)
	options = options or {}
	local theme = self.Theme
	local height = options.Height or 48
	local controlWidth = options.ControlWidth or 0
	local description = options.Description

	self:_RevealPendingDivider()

	local rowProperties = {
		Name = options.Name and ("Row_" .. tostring(options.Name)) or "Row",
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = theme.SurfaceHover,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = self:_NextOrder(),
		Parent = self.Card,
	}
	if options.Clickable then
		rowProperties.AutoButtonColor = false
		rowProperties.Text = ""
	end
	local row = Util.Create(options.Clickable and "TextButton" or "Frame", rowProperties)
	row.ClipsDescendants = false

	Util.Padding(row, 0, 14, 0, 14)

	local left = Util.Create("Frame", {
		Name = "Left",
		Size = UDim2.new(1, -(controlWidth + 12), 1, 0),
		BackgroundTransparency = 1,
		Parent = row,
	})

	local textOffset = options.TextOffset or 0

	local nameLabel
	if options.Name then
		local nameY = (description and -8 or 0) + textOffset
		nameLabel = Util.Create("TextLabel", {
			Name = "Name",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, nameY),
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			Text = options.Name,
			Font = theme.FontMedium,
			TextSize = options.NameSize or 13,
			TextColor3 = options.NameColor or theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = left,
		})
	end

	local descLabel
	if description then			descLabel = Util.Create("TextLabel", {
			Name = "Description",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 9 + textOffset),
			Size = UDim2.new(1, 0, 0, 14),
			BackgroundTransparency = 1,
			Text = description,
			Font = theme.Font,
			TextSize = 11,
			TextColor3 = theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = left,
		})
	end

	local control = Util.Create("Frame", {
		Name = "Control",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(controlWidth, options.ControlHeight or 28),
		BackgroundTransparency = 1,
		Parent = row,
	})

	self:_NewDivider()

	return {
		Row = row,
		Left = left,
		Control = control,
		NameLabel = nameLabel,
		DescriptionLabel = descLabel,
	}
end

function Section:_Make(component, options)
	table.insert(self.Components, component)
	return component
end

function Section:CreateButton(options)
	return self:_Make(Button.new(self, options))
end

function Section:CreateToggle(options)
	return self:_Make(Toggle.new(self, options))
end

function Section:CreateSlider(options)
	return self:_Make(Slider.new(self, options))
end

function Section:CreateDropdown(options)
	return self:_Make(Dropdown.new(self, options))
end

function Section:CreateKeybind(options)
	return self:_Make(Keybind.new(self, options))
end

function Section:CreateTextbox(options)
	return self:_Make(Textbox.new(self, options))
end

function Section:CreateLabel(options)
	return self:_Make(Label.new(self, options))
end

function Section:CreateSeparator(options)
	return self:_Make(Separator.new(self, options))
end

function Section:CreateColorPicker(options)
	return self:_Make(ColorPicker.new(self, options))
end

function Section:SetTitle(title)
	self.Title = title
	if self.TitleLabel then
		self.TitleLabel.Text = title
	end
end

function Section:Destroy()
	for _, component in ipairs(self.Components) do
		if component.Destroy then
			pcall(component.Destroy, component)
		end
	end
	self.Components = {}
	self.Maid:Clean()
	if self.Frame then
		self.Frame:Destroy()
	end
end

return Section
end

__modules["Tab"] = function(require)
--[[
	Athena · Tab
	A page inside the window: large title, header actions, scrolling content.
]]

local Util = require("Core.Util")
local Icons = require("Core.Icons")
local Section = require("Section")
local Banner = require("Components.Banner")
local Card = require("Components.Card")

local Tab = {}
Tab.__index = Tab

local HEADER_HEIGHT = 78

function Tab.new(window, config)
	local theme = window.Theme

	local self = setmetatable({
		Window = window,
		Theme = theme,
		Title = config.Title,
		Description = config.Description,
		Icon = config.Icon,
		Badge = config.Badge,
		Sections = {},
		Elements = {},
		Actions = {},
		_order = 0,
		Maid = Util.Maid.new(),
		Config = config,
	}, Tab)

	local page = Util.Create("Frame", {
		Name = "Page_" .. tostring(config.Title),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 1,
		Parent = window.Content,
	})
	page.AnchorPoint = Vector2.new(0.5, 0.5)
	page.Position = UDim2.fromScale(0.5, 0.5)
	local pageScale = Instance.new("UIScale")
	pageScale.Scale = 1
	pageScale.Parent = page
	self.Page = page
	self.PageScale = pageScale

	local headerHeight = config.Description and HEADER_HEIGHT + 16 or HEADER_HEIGHT

	local header = Util.Create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, headerHeight),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Parent = page,
	})
	self.Header = header

	local title = Util.Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(24, config.Description and 18 or 24),
		Size = UDim2.new(1, -340, 0, 36),
		BackgroundTransparency = 1,
		Text = config.Title,
		Font = theme.FontBold,
		TextSize = theme.TextSizeTitle,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})
	self.TitleLabel = title

	if config.Description then
		Util.Create("TextLabel", {
			Name = "Description",
			Position = UDim2.fromOffset(24, 52),
			Size = UDim2.new(1, -340, 0, 16),
			BackgroundTransparency = 1,
			Text = config.Description,
			Font = theme.Font,
			TextSize = 12,
			TextColor3 = theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})
	end

	local actionBar = Util.Create("Frame", {
		Name = "Actions",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -24, 0, config.Description and 20 or 26),
		Size = UDim2.new(0, 0, 0, 34),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = header,
	})
	Util.RowList(actionBar, 8)
	self.ActionBar = actionBar

	local scroll = Util.Create("ScrollingFrame", {
		Name = "Scroll",
		Position = UDim2.fromOffset(0, headerHeight),
		Size = UDim2.new(1, 0, 1, -headerHeight),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme.Border,
		ScrollBarImageTransparency = 0.25,
		ScrollingEnabled = true,
		ClipsDescendants = true,
		ZIndex = 1,
		Parent = page,
	})
	Util.Padding(scroll, 4, 24, 22, 24)
	Util.List(scroll, 12, Enum.HorizontalAlignment.Center)
	self.Scroll = scroll

	return self
end

function Tab:_ContentWidth()
	return self.Window.BaseWidth - 52
end

function Tab:_NextOrder()
	self._order = self._order + 1
	return self._order
end

function Tab:_OnSelected()
	self.Window:_UpdateUnderline()
	if self.Config.OnSelected then
		Util.Safe(self.Config.OnSelected, self)
	end
end

function Tab:Select()
	self.Window:SelectTab(self)
end

function Tab:SetTitle(title)
	self.Title = title
	self.TitleLabel.Text = title
end

function Tab:SetBadge(value)
	self.Badge = value
	self.Window:_UpdateBadge(self)
end

function Tab:AddAction(input)
	local config = input
	if type(config) == "string" then
		config = { Name = config }
	end
	config = config or {}

	local theme = self.Theme
	local label = config.Name or config.Text or "Action"
	local style = config.Style or "Secondary"
	local textWidth = Util.Measure(label, 11.5, theme.FontMedium).X
	local iconSpace = config.Icon and 20 or 0
	local width = math.ceil(textWidth + iconSpace + 28)

	local button = Util.Create("TextButton", {
		Name = "Action_" .. label,
		Size = UDim2.fromOffset(width, 34),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = #self.Actions + 1,
		Parent = self.ActionBar,
	})
	Util.Corner(button, 9)

	local stroke
	if style == "Secondary" then
		stroke = Util.Stroke(button, theme.Border, 1)
		stroke.Transparency = 0
	elseif style == "Primary" then
		button.BackgroundColor3 = theme.Primary
	else
		button.BackgroundColor3 = theme.Surface
		button.BackgroundTransparency = 1
	end

	local textColor = theme.Text
	if style == "Primary" then
		textColor = theme.PrimaryText
	elseif style == "Ghost" then
		textColor = theme.TextMuted
	end

	local icon
	if config.Icon then
		icon = Icons.New(config.Icon, 13, textColor, button)
		icon.Frame.AnchorPoint = Vector2.new(0, 0.5)
		icon.Frame.Position = UDim2.new(0, 12, 0.5, 0)
	end

	local text = Util.Create("TextLabel", {
		Position = UDim2.fromOffset(12 + iconSpace, 0),
		Size = UDim2.new(1, -(12 + iconSpace + 12), 1, 0),
		BackgroundTransparency = 1,
		Text = label,
		Font = theme.FontMedium,
		TextSize = 11.5,
		TextColor3 = textColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = button,
	})

	self.Maid:Add(button.MouseEnter:Connect(function()
		if style == "Primary" then
			Util.Tween(button, { BackgroundColor3 = theme.PrimaryHover }, 0.12)
		elseif style == "Ghost" then
			Util.Tween(button, { BackgroundTransparency = 0.5 }, 0.12)
			text.TextColor3 = theme.Text
			if icon then
				icon:SetColor(theme.Text)
			end
		else
			Util.Tween(button, { BackgroundColor3 = theme.SurfaceHover }, 0.12)
		end
	end))
	self.Maid:Add(button.MouseLeave:Connect(function()
		if style == "Primary" then
			Util.Tween(button, { BackgroundColor3 = theme.Primary }, 0.12)
		elseif style == "Ghost" then
			Util.Tween(button, { BackgroundTransparency = 1 }, 0.12)
			text.TextColor3 = theme.TextMuted
			if icon then
				icon:SetColor(theme.TextMuted)
			end
		else
			Util.Tween(button, { BackgroundColor3 = theme.SurfaceAlt }, 0.12)
		end
	end))
	self.Maid:Add(button.MouseButton1Click:Connect(function()
		if config.Callback then
			Util.Safe(config.Callback)
		end
	end))

	local action = {
		Instance = button,
		Label = text,
		Icon = icon,
	}

	function action:SetText(value)
		text.Text = value
	end

	function action:Destroy()
		button:Destroy()
	end

	table.insert(self.Actions, action)
	return action
end

function Tab:CreateSection(input)
	local section = Section.new(self, input)
	section.Frame.LayoutOrder = self:_NextOrder()
	table.insert(self.Sections, section)
	return section
end

function Tab:CreateBanner(input)
	local banner = Banner.new(self, input)
	table.insert(self.Elements, banner)
	return banner
end

function Tab:CreateCard(input)
	local card = Card.new(self, input)
	table.insert(self.Elements, card)
	return card
end

function Tab:CreateLabel(input)
	local host = self:CreateSection({ Bare = true })
	local label = host:CreateLabel(input)
	label._hostSection = host
	return label
end

function Tab:Destroy()
	local elements = self.Elements
	self.Elements = {}
	for _, element in ipairs(elements) do
		if element.Destroy then
			pcall(element.Destroy, element)
		end
	end

	local sections = self.Sections
	self.Sections = {}
	for _, section in ipairs(sections) do
		section:Destroy()
	end

	local window = self.Window
	for index, tab in ipairs(window.Tabs) do
		if tab == self then
			table.remove(window.Tabs, index)
			break
		end
	end

	if self._nav then
		self._nav:Destroy()
		self._nav = nil
	end

	self.Maid:Clean()
	if self.Page then
		self.Page:Destroy()
		self.Page = nil
	end

	if window.ActiveTab == self then
		window.ActiveTab = nil
		if window.Tabs[1] then
			window:SelectTab(window.Tabs[1])
		end
	end
end

return Tab
end

__modules["Window"] = function(require)
--[[
	Athena · Window
	The shell: title bar, tab navigation, page host, window controls,
	notification panel, tab search and the popup layer.
]]

local UserInputService = game:GetService("UserInputService")

local Theme = require("Core.Theme")
local Util = require("Core.Util")
local Icons = require("Core.Icons")
local Dragger = require("Core.Dragger")
local Popup = require("Core.Popup")
local Tab = require("Tab")
local QuickMenu = require("QuickMenu")

local Window = {}
Window.__index = Window

local DEFAULT_SIZE = Vector2.new(880, 600)
local CONTROLS_WIDTH = 178
local BRAND_MIN = 96
local BRAND_MAX = 250

local function sizeToVector(size)
	if typeof(size) == "Vector2" then
		return Vector2.new(size.X, size.Y)
	elseif typeof(size) == "UDim2" then
		return Vector2.new(size.X.Offset, size.Y.Offset)
	end
	return nil
end

local function normalizeTabConfig(input, extra)
	local config = {}
	if type(input) == "string" then
		config.Title = input
	elseif type(input) == "table" then
		for key, value in pairs(input) do
			config[key] = value
		end
	end
	if type(extra) == "table" then
		for key, value in pairs(extra) do
			if config[key] == nil then
				config[key] = value
			end
		end
	end
	config.Title = config.Title or config.Name
	return config
end

--------------------------------------------------------------------------------
-- Construction
--------------------------------------------------------------------------------

local function measureBrandWidth(title, theme)
	local textWidth = Util.Measure(title or "Athena", 15, theme.FontBold).X
	return math.clamp(32 + textWidth + 14, BRAND_MIN, BRAND_MAX)
end

function Window.new(library, options)
	options = options or {}
	local theme = Theme.Resolve(options.Theme, options.ThemeOverrides)
	if typeof(options.Accent) == "Color3" then
		theme.Accent = options.Accent
	end

	local baseSize = sizeToVector(options.Size) or DEFAULT_SIZE
	baseSize = Vector2.new(math.max(baseSize.X, 620), math.max(baseSize.Y, 420))

	local self = setmetatable({
		Library = library,
		Options = options,
		Theme = theme,
		Title = options.Title or "Athena",
		Tabs = {},
		Popups = {},
		Maid = Util.Maid.new(),
		Visible = true,
		Minimized = false,
		Closed = false,
		BaseWidth = baseSize.X,
		BaseHeight = baseSize.Y,
		BaseScale = Util.ComputeScale(),
	}, Window)

	local gui = library:_EnsureGui()
	self.Gui = gui

	--------------------------------------------------------------------------------
	-- Shell
	--------------------------------------------------------------------------------

	local frame = Util.Create("CanvasGroup", {
		Name = "Athena",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(self.BaseWidth, self.BaseHeight),
		BackgroundColor3 = theme.Window,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		GroupTransparency = options.Animated == false and 0 or 1,
		ZIndex = 10,
		Parent = gui,
	})
	Util.Corner(frame, theme.Corner)
	local shellStroke = Util.Stroke(frame, theme.Border, 1)
	shellStroke.Transparency = 0.05

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = self.BaseScale
	uiScale.Parent = frame

	self.Frame = frame
	self.Scale = uiScale

	local topbar = Util.Create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, theme.TopbarHeight),
		BackgroundColor3 = theme.WindowTop,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = frame,
	})
	self.Topbar = topbar

	Util.Create("Frame", {
		Name = "TopbarLine",
		Position = UDim2.new(0, 0, 0, theme.TopbarHeight - 1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = theme.BorderSoft,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = frame,
	})

	--------------------------------------------------------------------------------
	-- Brand
	--------------------------------------------------------------------------------

	local logo = Util.Create("Frame", {
		Name = "Brand",
		Position = UDim2.fromOffset(18, 0),
		Size = UDim2.fromOffset(measureBrandWidth(self.Title, theme), theme.TopbarHeight),
		BackgroundTransparency = 1,
		Parent = topbar,
	})
	logo.Active = true

	local mark
	if options.Logo ~= nil then
		local source = options.Logo
		if type(source) == "number" then
			source = "rbxassetid://" .. tostring(source)
		end
		mark = Util.Create("ImageLabel", {
			Name = "Logo",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(24, 18),
			BackgroundTransparency = 1,
			Image = tostring(source),
			ScaleType = Enum.ScaleType.Fit,
			Parent = logo,
		})
	else
		mark = Icons.New("athena", 16, theme.Text, logo)
		mark.Frame.AnchorPoint = Vector2.new(0, 0.5)
		mark.Frame.Position = UDim2.new(0, 0, 0.5, 0)
	end

	local brand = Util.Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -32, 1, 0),
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = theme.FontBold,
		TextSize = 15,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = logo,
	})
	self.BrandLabel = brand
	self.BrandMark = mark
	self.Brand = logo

	Dragger.Attach(frame, logo, self.Maid, {
		Threshold = 4,
		OnDrag = function()
			self:_ClosePopups(nil, true)
		end,
	})

	local lastBrandClick = 0
	local function registerBrandClick()
		local now = os.clock()
		if now - lastBrandClick <= 0.35 then
			lastBrandClick = 0
			self:ToggleMaximize()
		else
			lastBrandClick = now
		end
	end
	self.Maid:Add(logo.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			registerBrandClick()
		end
	end))
	self.Maid:Add(topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			registerBrandClick()
		end
	end))

	--------------------------------------------------------------------------------
	-- Navigation
	--------------------------------------------------------------------------------

	local navLeft = 18 + measureBrandWidth(self.Title, theme) + 10
	local nav = Util.Create("ScrollingFrame", {
		Name = "Nav",
		Position = UDim2.fromOffset(navLeft, 0),
		Size = UDim2.new(1, -(navLeft + CONTROLS_WIDTH + 14), 0, theme.TopbarHeight),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		ScrollingEnabled = true,
		ClipsDescendants = true,
		ZIndex = 3,
		Parent = topbar,
	})
	self.Nav = nav
	self.NavLeft = navLeft

	local navInner = Util.Create("Frame", {
		Name = "NavInner",
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = nav,
	})
	local navLayout = Util.RowList(navInner, 2)
	navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	self.NavInner = navInner

	self.Maid:Add(nav.MouseWheelForward:Connect(function()
		nav.CanvasPosition = Vector2.new(math.min(nav.AbsoluteCanvasSize.X, nav.CanvasPosition.X + 90), 0)
	end))
	self.Maid:Add(nav.MouseWheelBackward:Connect(function()
		nav.CanvasPosition = Vector2.new(math.max(0, nav.CanvasPosition.X - 90), 0)
	end))

	local underline = Util.Create("Frame", {
		Name = "NavUnderline",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 0, theme.TopbarHeight),
		Size = UDim2.fromOffset(20, 2),
		BackgroundColor3 = theme.Primary,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 5,
		Parent = topbar,
	})
	Util.Corner(underline, 1)
	self.Underline = underline

	self.Maid:Add(nav:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:_UpdateUnderline()
	end))

	--------------------------------------------------------------------------------
	-- Window controls
	--------------------------------------------------------------------------------

	local controls = Util.Create("Frame", {
		Name = "Controls",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 0),
		Size = UDim2.fromOffset(CONTROLS_WIDTH - 4, theme.TopbarHeight),
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = topbar,
	})
	self.Controls = controls

	local function makeControl(iconName, x, danger)
		local button = Util.Create("TextButton", {
			Name = iconName,
			Position = UDim2.fromOffset(x, 14),
			Size = UDim2.fromOffset(28, 28),
			BackgroundColor3 = theme.SurfaceHover,
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 4,
			Parent = controls,
		})
		Util.Corner(button, 7)
		local buttonScale = Instance.new("UIScale")
		buttonScale.Scale = 1
		buttonScale.Parent = button
		local icon = Icons.New(iconName, 14, theme.TextMuted, button, 5)
		icon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Frame.Position = UDim2.fromScale(0.5, 0.5)

		self.Maid:Add(button.MouseEnter:Connect(function()
			Util.Tween(button, {
				BackgroundColor3 = danger and theme.Primary or theme.SurfaceHover,
				BackgroundTransparency = danger and 0 or 0.55,
			}, 0.12)
			Util.Tween(buttonScale, { Scale = 1.08 }, 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			icon:SetColor(danger and theme.PrimaryText or theme.Text)
			if danger then
				Util.Tween(icon.Frame, { Rotation = 90 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			end
		end))
		self.Maid:Add(button.MouseLeave:Connect(function()
			Util.Tween(button, { BackgroundColor3 = theme.SurfaceHover, BackgroundTransparency = 1 }, 0.12)
			Util.Tween(buttonScale, { Scale = 1 }, 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			icon:SetColor(theme.TextMuted)
			if danger then
				Util.Tween(icon.Frame, { Rotation = 0 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			end
		end))
		self.Maid:Add(button.MouseButton1Down:Connect(function()
			Util.Tween(buttonScale, { Scale = 0.92 }, 0.06)
		end))
		self.Maid:Add(button.MouseButton1Up:Connect(function()
			Util.Tween(buttonScale, { Scale = 1.03 }, 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end))

		return button, icon
	end

	local searchButton = makeControl("search", 0)
	local bellButton, bellIcon = makeControl("bell", 30)
	Util.Create("Frame", {
		Name = "ControlDivider",
		Position = UDim2.fromOffset(68, 19),
		Size = UDim2.fromOffset(1, 18),
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = controls,
	})
	local minimizeButton = makeControl("minus", 80)
	local maximizeButton = makeControl("maximize", 110)
	local closeButton = makeControl("close", 142, true)

	local bellBadge = Util.Create("Frame", {
		Name = "Unread",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -4, 0, 4),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 6,
		Parent = bellButton,
	})
	Util.Corner(bellBadge, 8)
	Util.Stroke(bellBadge, theme.Window, 1, 0.15)

	local bellBadgeScale = Instance.new("UIScale")
	bellBadgeScale.Scale = 1
	bellBadgeScale.Parent = bellBadge

	local bellBadgeLabel = Util.Create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Font = theme.FontBold,
		TextSize = 8.5,
		TextColor3 = theme.AccentText,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 7,
		Parent = bellBadge,
	})
	self.BellButton = bellButton
	self.BellIcon = bellIcon
	self.BellBadge = bellBadge
	self.BellBadgeLabel = bellBadgeLabel
	self.BellBadgeScale = bellBadgeScale

	--------------------------------------------------------------------------------
	-- Content
	--------------------------------------------------------------------------------

	local content = Util.Create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(0, theme.TopbarHeight),
		Size = UDim2.new(1, 0, 1, -theme.TopbarHeight),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Parent = frame,
	})
	self.Content = content

	local overlay = Util.Create("Frame", {
		Name = "Overlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 50,
		Parent = frame,
	})
	self.Overlay = overlay

	--------------------------------------------------------------------------------
	-- Interaction wiring
	--------------------------------------------------------------------------------

	Dragger.Attach(frame, topbar, self.Maid, {
		Threshold = 4,
		OnDrag = function()
			self:_ClosePopups(nil, true)
		end,
	})

	self.Maid:Add(searchButton.MouseButton1Click:Connect(function()
		self:_ToggleSearch(searchButton)
	end))
	self.Maid:Add(bellButton.MouseButton1Click:Connect(function()
		self:_ToggleNotifications(bellButton)
	end))
	self.Maid:Add(minimizeButton.MouseButton1Click:Connect(function()
		self:Minimize()
	end))
	self.Maid:Add(maximizeButton.MouseButton1Click:Connect(function()
		self:ToggleMaximize()
	end))
	self.Maid:Add(closeButton.MouseButton1Click:Connect(function()
		self:Close()
	end))

	local toggleKey = options.ToggleKey
	if toggleKey == nil then
		toggleKey = Enum.KeyCode.RightShift
	end
	self:SetToggleKey(toggleKey)

	--------------------------------------------------------------------------------
	-- Response to viewport changes
	--------------------------------------------------------------------------------

	local function updateViewport()
		if self.Closed then
			return
		end
		self.BaseScale = Util.ComputeScale()
		if self.Visible then
			uiScale.Scale = self:_TargetScale()
			Dragger.Clamp(frame, 6)
			self:_UpdateUnderline()
			self:_ClosePopups(nil, true)
		end
	end

	self.Maid:Add(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		local camera = workspace.CurrentCamera
		if camera then
			self.Maid:Add(camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateViewport))
			updateViewport()
		end
	end))

	local camera = workspace.CurrentCamera
	if camera then
		self.Maid:Add(camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateViewport))
	end

	--------------------------------------------------------------------------------
	-- Notifications state
	--------------------------------------------------------------------------------

	if library._notifications then
		library._notifications.Theme = theme
		local lastUnread = 0

		local function pulseBell()
			if not bellIcon or not bellIcon.Frame or not bellIcon.Frame.Parent then
				return
			end
			local target = bellIcon.Frame
			target.Rotation = 0
			Util.Tween(target, { Rotation = -12 }, 0.07)
			task.delay(0.08, function()
				if not target.Parent then
					return
				end
				Util.Tween(target, { Rotation = 9 }, 0.1)
				task.delay(0.11, function()
					if target.Parent then
						Util.Tween(target, { Rotation = 0 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					end
				end)
			end)
		end

		local function updateDot()
			local count = library._notifications.Unread or 0
			local increased = count > lastUnread
			lastUnread = count

			if count <= 0 then
				bellBadge.Visible = false
				return
			end

			local text = count > 9 and "9+" or tostring(count)
			bellBadgeLabel.Text = text
			bellBadge.Size = UDim2.fromOffset(
				math.max(16, math.ceil(Util.Measure(text, 8.5, theme.FontBold).X + 8)),
				16
			)
			bellBadge.Visible = true
			bellBadgeScale.Scale = 0.7
			Util.Tween(bellBadgeScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

			if increased then
				pulseBell()
			end
		end
		updateDot()
		self.Maid:Add(library._notifications:OnChanged(updateDot))
	end

	--------------------------------------------------------------------------------
	-- Intro animation
	--------------------------------------------------------------------------------

	if options.Animated ~= false then
		uiScale.Scale = self.BaseScale * 0.965
		Util.Tween(frame, { GroupTransparency = 0 }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		Util.Tween(uiScale, { Scale = self.BaseScale }, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end

	if options.QuickMenu ~= false then
		local quickOptions = options.QuickMenuOptions
		if type(options.QuickMenu) == "table" then
			quickOptions = options.QuickMenu
		end
		if type(quickOptions) ~= "table" then
			quickOptions = {}
		end
		if quickOptions.Key == nil and options.QuickMenuKey ~= nil then
			quickOptions.Key = options.QuickMenuKey
		end
		self.QuickMenu = QuickMenu.new(self, quickOptions)
		self.Maid:Add(self.QuickMenu)
	end

	return self
end

--------------------------------------------------------------------------------
-- Navigation
--------------------------------------------------------------------------------

function Window:_RevealNavTab(navButton)
	if not navButton or not self.Nav or self.Closed then
		return
	end

	local scaleValue = self.Scale.Scale
	if scaleValue <= 0 then
		scaleValue = 1
	end

	local nav = self.Nav
	local viewWidth = nav.AbsoluteSize.X / scaleValue
	if viewWidth <= 0 then
		return
	end

	local current = nav.CanvasPosition.X
	local tabLeft = (navButton.AbsolutePosition.X - nav.AbsolutePosition.X) / scaleValue + current
	local tabWidth = navButton.AbsoluteSize.X / scaleValue
	local target = current
	local edge = 8

	if tabLeft < current + edge then
		target = tabLeft - edge
	elseif tabLeft + tabWidth > current + viewWidth - edge then
		target = tabLeft + tabWidth - viewWidth + edge
	end

	-- AbsoluteCanvasSize is in scaled screen pixels; viewWidth is topbar-local.
	local maxScroll = math.max(0, nav.AbsoluteCanvasSize.X / scaleValue - viewWidth)
	target = math.clamp(target, 0, maxScroll)
	if math.abs(target - current) > 0.5 then
		Util.Tween(
			nav,
			{ CanvasPosition = Vector2.new(math.round(target), 0) },
			0.18,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		)
	end
end

function Window:_UpdateUnderline()
	local active = self.ActiveTab
	if not active or not active._nav or not active._nav.Parent then
		self.Underline.Visible = false
		return
	end

	local scaleValue = self.Scale.Scale
	if scaleValue <= 0 then
		scaleValue = 1
	end

	local navButton = active._nav
	local navAbs = self.Nav.AbsolutePosition
	local buttonAbs = navButton.AbsolutePosition
	local topbarAbs = self.Topbar.AbsolutePosition

	-- Absolute positions include UIScale. Convert back to topbar-local pixels before
	-- positioning the underline, otherwise it drifts away from the active tab.
	local localNavLeft = (navAbs.X - topbarAbs.X) / scaleValue
	local localTabLeft = (buttonAbs.X - topbarAbs.X) / scaleValue
	local width = math.max(20, navButton.AbsoluteSize.X / scaleValue - 20)

	-- The nav clips its content; hide the indicator when the tab is scrolled out of view.
	local visibleLeft = localNavLeft
	local visibleRight = localNavLeft + self.Nav.AbsoluteSize.X / scaleValue
	if localTabLeft + width < visibleLeft or localTabLeft > visibleRight then
		self.Underline.Visible = false
		return
	end

	self.Underline.Visible = true
	Util.Tween(self.Underline, {
		Position = UDim2.fromOffset(math.round(localTabLeft + 10), self.Theme.TopbarHeight),
		Size = UDim2.fromOffset(width, 2),
	}, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end

function Window:_CreateNavButton(tab, config)
	local theme = self.Theme
	local iconName = config.Icon
	local label = config.NavLabel or tab.Title
	local textWidth = Util.Measure(label, 12, theme.FontMedium).X
	local hasBadge = config.Badge ~= nil
	local badgeText = hasBadge and tostring(config.Badge) or ""
	local badgeWidth = hasBadge and math.max(17, Util.Measure(badgeText, 9, theme.FontBold).X + 9) or 0
	local iconSpace = iconName and 20 or 0
	local reserve = hasBadge and (badgeWidth + 6) or 0
	local width = math.max(54, 20 + iconSpace + textWidth + reserve)

	local button = Util.Create("TextButton", {
		Name = "Nav_" .. tab.Title,
		LayoutOrder = #self.Tabs,
		Size = UDim2.fromOffset(math.ceil(width), 32),
		BackgroundColor3 = theme.SurfaceAlt,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 3,
		Parent = self.NavInner,
	})
	Util.Corner(button, 8)

	local icon
	if iconName then
		icon = Icons.New(iconName, 14, theme.TextMuted, button, 4)
		icon.Frame.AnchorPoint = Vector2.new(0, 0.5)
		icon.Frame.Position = UDim2.new(0, 10, 0.5, 0)
	end

	local labelFrame = Util.Create("TextLabel", {
		Name = "Label",
		Position = UDim2.fromOffset(10 + iconSpace, 0),
		Size = UDim2.new(1, -(iconSpace + 20 + reserve), 1, 0),
		BackgroundTransparency = 1,
		Text = label,
		Font = theme.FontMedium,
		TextSize = 12,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 4,
		Parent = button,
	})

	local badge = Util.Create("Frame", {
		Name = "Badge",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(math.ceil(math.max(badgeWidth, 17)), 16),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Visible = hasBadge,
		ZIndex = 4,
		Parent = button,
	})
	Util.Corner(badge, 5)
	local badgeLabel = Util.Create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = badgeText,
		Font = theme.FontBold,
		TextSize = 9,
		TextColor3 = theme.AccentText,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 5,
		Parent = badge,
	})
	tab._navBadgeLabel = badgeLabel

	local function paint(active)
		labelFrame.TextColor3 = active and theme.Text or theme.TextMuted
		if icon then
			icon:SetColor(active and theme.Text or theme.TextMuted)
		end
	end

	paint(false)

	self.Maid:Add(button.MouseEnter:Connect(function()
		if self.ActiveTab ~= tab then
			Util.Tween(button, { BackgroundTransparency = 0.6 }, 0.12)
			labelFrame.TextColor3 = theme.TextSoft
			if icon then
				icon:SetColor(theme.TextSoft)
			end
		end
	end))
	self.Maid:Add(button.MouseLeave:Connect(function()
		if self.ActiveTab ~= tab then
			Util.Tween(button, { BackgroundTransparency = 1 }, 0.12)
			paint(false)
		end
	end))
	self.Maid:Add(button.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end))

	tab._nav = button
	tab._navLabel = labelFrame
	tab._navIcon = icon
	tab._navBadge = badge
	tab._navPaint = paint
	tab._navConfig = config

	return button
end

function Window:_UpdateBadge(tab)
	local badge = tab._navBadge
	local count = tab.Badge

	if count == nil or count == 0 then
		if badge then
			badge.Visible = false
		end
		return
	end

	if not badge then
		return
	end

	badge.Visible = true
	local label = tab._navBadgeLabel or badge:FindFirstChildOfClass("TextLabel")
	if label then
		label.Text = tostring(count)
		badge.Size = UDim2.fromOffset(
			math.max(17, math.ceil(Util.Measure(tostring(count), 9, self.Theme.FontBold).X + 9)),
			16
		)
	end
end

function Window:SelectTab(target)
	if self.Closed then
		return
	end

	local tab = target
	if type(target) == "number" then
		tab = self.Tabs[target]
	end
	if not tab then
		return
	end

	self:_ClosePopups(nil, true)

	for _, other in ipairs(self.Tabs) do
		local active = other == tab
		other.Page.Visible = active
		if active and other.PageScale then
			other.PageScale.Scale = 0.985
			Util.Tween(other.PageScale, { Scale = 1 }, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
		if other._navPaint then
			other._navPaint(active)
		end
		if other._nav then
			other._nav.BackgroundTransparency = 1
		end
	end

	self.ActiveTab = tab
	self:_RevealNavTab(tab._nav)
	tab:_OnSelected()
	self:_UpdateUnderline()
	task.defer(function()
		if not self.Closed and self.ActiveTab == tab then
			self:_RevealNavTab(tab._nav)
			self:_UpdateUnderline()
		end
	end)
end

function Window:CreateTab(input, extra)
	local config = normalizeTabConfig(input, extra)
	self.TabCount = (self.TabCount or 0) + 1
	config.Title = config.Title or ("Tab " .. tostring(self.TabCount))

	local tab = Tab.new(self, config)
	table.insert(self.Tabs, tab)
	self:_CreateNavButton(tab, config)

	if #self.Tabs == 1 or config.Selected then
		self:SelectTab(tab)
	elseif self.ActiveTab == tab then
		self:SelectTab(tab)
	end

	return tab
end

function Window:GetTabs()
	return self.Tabs
end

--------------------------------------------------------------------------------
-- Popups
--------------------------------------------------------------------------------

function Window:_RegisterPopup(popup)
	table.insert(self.Popups, popup)
end

function Window:_ClosePopups(except, instant)
	for _, popup in ipairs(self.Popups) do
		if popup ~= except and popup:IsOpen() then
			popup:Close(instant)
		end
	end
end

function Window:_CreatePopup(options)
	local popup = Popup.New({
		Frame = self.Frame,
		Overlay = self.Overlay,
		Theme = self.Theme,
		CloseOthers = function(except)
			self:_ClosePopups(except)
		end,
	}, options)
	self:_RegisterPopup(popup)
	return popup
end

--------------------------------------------------------------------------------
-- Notification panel
--------------------------------------------------------------------------------

function Window:_ToggleNotifications(anchor)
	if self._notificationPopup and self._notificationPopup:IsOpen() then
		self._notificationPopup:Close()
		return
	end

	if self.Library._notifications then
		self.Library._notifications:MarkRead()
	end

	if not self._notificationPopup then
		self._notificationPopup = self:_CreatePopup({
				Width = 344,
				Height = 386,
			Align = "Right",
			Name = "Notifications",
			Padding = 0,
			OnOpen = function(popup)
				self:_FillNotifications(popup)
			end,
		})
	end

	self._notificationPopup:OpenAt(anchor)
end

function Window:_FillNotifications(popup)
	local theme = self.Theme
	popup:ResetContent()
	local content = popup.Content
	local notifications = self.Library._notifications
	local history = notifications and notifications:GetHistory() or {}

	local header = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundTransparency = 1,
		Parent = content,
	})
	Util.Padding(header, 0, 12, 0, 12)

	local headerIcon = Util.Create("Frame", {
		Position = UDim2.fromOffset(12, 16),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Parent = header,
	})
	Util.Corner(headerIcon, 9)
	Util.Stroke(headerIcon, theme.BorderSoft, 1, 0.35)

	local bell = Icons.New("bell", 15, theme.TextSoft, headerIcon)
	bell.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	bell.Frame.Position = UDim2.fromScale(0.5, 0.5)

	Util.Create("TextLabel", {
		Position = UDim2.fromOffset(52, 11),
		Size = UDim2.new(1, -122, 0, 18),
		BackgroundTransparency = 1,
		Text = "Notifications",
		Font = theme.FontMedium,
		TextSize = 13,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	local countText = "You're all caught up"
	if #history == 1 then
		countText = "1 event"
	elseif #history > 1 then
		countText = tostring(#history) .. " events"
	end

	Util.Create("TextLabel", {
		Position = UDim2.fromOffset(52, 29),
		Size = UDim2.new(1, -122, 0, 14),
		BackgroundTransparency = 1,
		Text = countText,
		Font = theme.Font,
		TextSize = 10.5,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	local clear = Util.Create("TextButton", {
		Name = "Clear",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(52, 24),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Text = "Clear",
		Font = theme.FontMedium,
		TextSize = 10,
		TextColor3 = theme.TextMuted,
		AutoButtonColor = false,
		Visible = #history > 0,
		Parent = header,
	})
	Util.Corner(clear, 7)
	Util.Stroke(clear, theme.BorderSoft, 1, 0.35)
	clear.MouseEnter:Connect(function()
		Util.Tween(clear, { BackgroundColor3 = theme.SurfaceHover }, 0.12)
		clear.TextColor3 = theme.Text
	end)
	clear.MouseLeave:Connect(function()
		Util.Tween(clear, { BackgroundColor3 = theme.SurfaceAlt }, 0.12)
		clear.TextColor3 = theme.TextMuted
	end)
	clear.MouseButton1Click:Connect(function()
		if notifications then
			notifications:Clear()
			self:_FillNotifications(popup)
		end
	end)

	Util.Create("Frame", {
		Position = UDim2.fromOffset(0, 62),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = theme.BorderSoft,
		BorderSizePixel = 0,
		Parent = content,
	})

	local scroll = Util.Create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 63),
		Size = UDim2.new(1, 0, 1, -63),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Border,
		ScrollBarImageTransparency = 0.2,
		ClipsDescendants = true,
		Parent = content,
	})
	Util.Padding(scroll, 6, 8, 10, 8)
	Util.List(scroll, 2, Enum.HorizontalAlignment.Center)

	if #history == 0 then
		local empty = Util.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 180),
			BackgroundTransparency = 1,
			Parent = scroll,
		})

		local tile = Util.Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 26),
			Size = UDim2.fromOffset(46, 46),
			BackgroundColor3 = theme.SurfaceAlt,
			BorderSizePixel = 0,
			Parent = empty,
		})
		Util.Corner(tile, 14)
		Util.Stroke(tile, theme.BorderSoft, 1, 0.3)

		local emptyIcon = Icons.New("bell", 18, theme.TextFaint, tile)
		emptyIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		emptyIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)

		Util.Create("TextLabel", {
			Position = UDim2.fromOffset(0, 84),
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Text = "All caught up",
			Font = theme.FontMedium,
			TextSize = 12,
			TextColor3 = theme.TextSoft,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = empty,
		})
		Util.Create("TextLabel", {
			Position = UDim2.fromOffset(0, 103),
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			Text = "Notifications you receive will appear here.",
			Font = theme.Font,
			TextSize = 10.5,
			TextColor3 = theme.TextFaint,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = empty,
		})
		return
	end

	local TONE_ICONS = {
		Info = "info",
		Success = "check",
		Warning = "warning",
		Error = "close",
		Accent = "bolt",
	}

	local function toneColor(tone)
		if tone == "Success" then
			return theme.Success
		elseif tone == "Warning" then
			return theme.Warning
		elseif tone == "Error" then
			return theme.Error
		elseif tone == "Accent" then
			return theme.Accent
		end
		return theme.Info
	end

	for index, entry in ipairs(history) do
		local tone = entry.Tone or "Info"
		local color = toneColor(tone)
		local iconName = TONE_ICONS[tone] or "bell"

		local row = Util.Create("Frame", {
			LayoutOrder = index,
			Size = UDim2.new(1, 0, 0, 68),
			BackgroundColor3 = theme.SurfaceHover,
			BackgroundTransparency = 1,
			Parent = scroll,
		})
		Util.Corner(row, 9)

		local accent = Util.Create("Frame", {
			Position = UDim2.fromOffset(6, 16),
			Size = UDim2.fromOffset(2, 36),
			BackgroundColor3 = color,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Parent = row,
		})
		Util.Corner(accent, 1)

		local tile = Util.Create("Frame", {
			Position = UDim2.fromOffset(16, 12),
			Size = UDim2.fromOffset(30, 30),
			BackgroundColor3 = color,
			BackgroundTransparency = 0.86,
			BorderSizePixel = 0,
			Parent = row,
		})
		Util.Corner(tile, 9)

		local icon = Icons.New(iconName, 14, color, tile)
		icon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Frame.Position = UDim2.fromScale(0.5, 0.5)

		Util.Create("TextLabel", {
			Position = UDim2.fromOffset(54, 10),
			Size = UDim2.new(1, -54 - 58, 0, 16),
			BackgroundTransparency = 1,
			Text = entry.Title or "Notification",
			Font = theme.FontMedium,
			TextSize = 11.5,
			TextColor3 = theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})
		Util.Create("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -10, 0, 11),
			Size = UDim2.fromOffset(44, 14),
			BackgroundTransparency = 1,
			Text = entry.Time or "",
			Font = theme.Font,
			TextSize = 9.5,
			TextColor3 = theme.TextFaint,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = row,
		})
		Util.Create("TextLabel", {
			Position = UDim2.fromOffset(54, 28),
			Size = UDim2.new(1, -54 - 12, 0, 30),
			BackgroundTransparency = 1,
			Text = entry.Text or "",
			Font = theme.Font,
			TextSize = 10.5,
			TextColor3 = theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})

		row.MouseEnter:Connect(function()
			Util.Tween(row, { BackgroundTransparency = 0.65 }, 0.12)
		end)
		row.MouseLeave:Connect(function()
			Util.Tween(row, { BackgroundTransparency = 1 }, 0.12)
		end)
	end
end

--------------------------------------------------------------------------------
-- Tab search
--------------------------------------------------------------------------------

function Window:_ToggleSearch(anchor)
	if self._searchPopup and self._searchPopup:IsOpen() then
		self._searchPopup:Close()
		return
	end

	if not self._searchPopup then
		self._searchPopup = self:_CreatePopup({
			Width = 360,
			Height = 336,
			Align = "Right",
			Name = "Search",
			Padding = 0,
			OnOpen = function(popup)
				self:_FillSearch(popup)
			end,
		})
	end

	self._searchPopup:OpenAt(anchor)
end

function Window:_FillSearch(popup)
	local theme = self.Theme
	popup:ResetContent()
	local content = popup.Content

	local searchFrame = Util.Create("Frame", {
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.new(1, -20, 0, 34),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Parent = content,
	})
	Util.Corner(searchFrame, 8)
	Util.Padding(searchFrame, 0, 28, 0, 10)

	local searchIcon = Icons.New("search", 13, theme.TextFaint, searchFrame)
	searchIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	searchIcon.Frame.Position = UDim2.new(1, -16, 0.5, 0)

	local input = Util.Create("TextBox", {
		Name = "Input",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Search tabs",
		PlaceholderColor3 = theme.TextFaint,
		Font = theme.Font,
		TextSize = 12,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = searchFrame,
	})

	Util.Create("Frame", {
		Position = UDim2.fromOffset(0, 54),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = theme.BorderSoft,
		BorderSizePixel = 0,
		Parent = content,
	})

	local scroll = Util.Create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 55),
		Size = UDim2.new(1, 0, 1, -55),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Border,
		ClipsDescendants = true,
		Parent = content,
	})
	Util.Padding(scroll, 6, 8, 10, 8)
	Util.List(scroll, 2, Enum.HorizontalAlignment.Center)

	local results = {}

	local empty = Util.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		Text = "No matching tabs",
		Font = theme.Font,
		TextSize = 11.5,
		TextColor3 = theme.TextFaint,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Visible = false,
		Parent = scroll,
	})

	local function choose(tab)
		popup:Close()
		self:SelectTab(tab)
	end

	local function render(query)
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		results = {}

		local needle = string.lower(query or "")
		for _, tab in ipairs(self.Tabs) do
			local title = tab.Title or ""
			if needle == "" or string.find(string.lower(title), needle, 1, true) then
				table.insert(results, tab)

				local row = Util.Create("TextButton", {
					LayoutOrder = #results,
					Size = UDim2.new(1, 0, 0, 34),
					BackgroundColor3 = theme.SurfaceHover,
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					Parent = scroll,
				})
				Util.Corner(row, 7)

				local icon
				if tab.Icon then
					icon = Icons.New(tab.Icon, 13, theme.TextMuted, row)
				else
					icon = Icons.New("grid", 13, theme.TextMuted, row)
				end
				icon.Frame.AnchorPoint = Vector2.new(0, 0.5)
				icon.Frame.Position = UDim2.new(0, 10, 0.5, 0)

				Util.Create("TextLabel", {
					Position = UDim2.fromOffset(32, 0),
					Size = UDim2.new(1, -44, 1, 0),
					BackgroundTransparency = 1,
					Text = title,
					Font = theme.FontMedium,
					TextSize = 11.5,
					TextColor3 = theme.TextSoft,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Parent = row,
				})

				row.MouseEnter:Connect(function()
					Util.Tween(row, { BackgroundTransparency = 0.55 }, 0.1)
				end)
				row.MouseLeave:Connect(function()
					Util.Tween(row, { BackgroundTransparency = 1 }, 0.1)
				end)
				row.MouseButton1Click:Connect(function()
					choose(tab)
				end)
			end
		end

		empty.Visible = #results == 0
	end

	input:GetPropertyChangedSignal("Text"):Connect(function()
		render(input.Text)
	end)
	input.FocusLost:Connect(function(entered)
		if entered and results[1] then
			choose(results[1])
		end
	end)

	render("")
	task.defer(function()
		if input.Parent then
			input:CaptureFocus()
		end
	end)
end

--------------------------------------------------------------------------------
-- Visibility
--------------------------------------------------------------------------------

function Window:_EnsurePill()
	if self._pill and self._pill.Parent then
		return self._pill
	end

	local theme = self.Theme
	local pill = Util.Create("CanvasGroup", {
		Name = "AthenaMinimized",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 22, 1, -22),
		Size = UDim2.fromOffset(154, 44),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 20,
		Parent = self.Frame.Parent,
	})
	Util.Corner(pill, 12)
	local stroke = Util.Stroke(pill, theme.Border, 1)
	stroke.Transparency = 0.1
	local pillScale = Instance.new("UIScale")
	pillScale.Scale = self.BaseScale
	pillScale.Parent = pill

	pill.Active = true

	local mark = Icons.New("athena", 15, theme.Text, pill)
	mark.Frame.AnchorPoint = Vector2.new(0, 0.5)
	mark.Frame.Position = UDim2.new(0, 14, 0.5, 0)

	Util.Create("TextLabel", {
		Position = UDim2.fromOffset(36, 0),
		Size = UDim2.new(1, -78, 1, 0),
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = theme.FontMedium,
		TextSize = 12,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = pill,
	})

	local chevron = Icons.New("chevronUp", 11, theme.TextMuted, pill)
	chevron.Frame.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Frame.Position = UDim2.new(1, -14, 0.5, 0)

	local button = Util.Create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 21,
		Parent = pill,
	})

	button.MouseEnter:Connect(function()
		Util.Tween(pill, { BackgroundColor3 = theme.SurfaceAlt }, 0.12)
	end)
	button.MouseLeave:Connect(function()
		Util.Tween(pill, { BackgroundColor3 = theme.Surface }, 0.12)
	end)
	button.MouseButton1Click:Connect(function()
		self:Restore()
	end)

	self.Maid:Add(function()
		pill:Destroy()
	end)

	self._pill = pill
	self._pillScale = pillScale
	return pill
end

function Window:_TargetScale()
	if self.Maximized then
		local viewport = Util.Viewport()
		local scaleValue = math.min(
			(viewport.X - 56) / self.BaseWidth,
			(viewport.Y - 56) / self.BaseHeight
		)
		return math.clamp(scaleValue, self.BaseScale, 2)
	end
	return self.BaseScale
end

function Window:SetMaximized(value)
	if self.Closed then
		return
	end
	value = value == true
	if self.Maximized == value then
		return
	end

	self.Maximized = value
	self:_ClosePopups(nil, true)

	if value then
		self._restorePosition = self.Frame.Position
		local viewport = Util.Viewport()
		self.Frame.Position = UDim2.fromOffset(viewport.X / 2, viewport.Y / 2)
	elseif self._restorePosition then
		self.Frame.Position = self._restorePosition
	end

	Util.Tween(self.Scale, { Scale = self:_TargetScale() }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	task.delay(0.3, function()
		if not self.Closed then
			Dragger.Clamp(self.Frame, 6)
			self:_UpdateUnderline()
		end
	end)
end

function Window:ToggleMaximize()
	self:SetMaximized(not self.Maximized)
end

function Window:Show(instant)
	if self.Closed then
		return
	end
	self.Visible = true
	self.Minimized = false

	if self._pill then
		self._pill.Visible = false
	end

	self.Frame.Visible = true
	self.Scale.Scale = self:_TargetScale()

	if instant then
		self.Frame.GroupTransparency = 0
		self:_UpdateUnderline()
		return
	end

	self.Frame.GroupTransparency = 1
	self.Scale.Scale = self:_TargetScale() * 0.97
	Util.Tween(self.Frame, { GroupTransparency = 0 }, 0.16)
	Util.Tween(self.Scale, { Scale = self:_TargetScale() }, 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	self:_UpdateUnderline()
end

function Window:Hide(instant)
	if self.Closed then
		return
	end
	self.Visible = false
	self:_ClosePopups(nil, true)

	if instant then
		self.Frame.Visible = false
		self.Frame.GroupTransparency = 1
		return
	end

	local target = self.Frame
	Util.Tween(target, { GroupTransparency = 1 }, 0.14)
	Util.Tween(self.Scale, { Scale = self:_TargetScale() * 0.97 }, 0.16)
	task.delay(0.16, function()
		if not self.Visible and not self.Closed then
			target.Visible = false
		end
	end)
end

function Window:Minimize()
	if self.Closed or self.Minimized then
		return
	end
	self.Minimized = true
	self.Visible = false
	self:_ClosePopups(nil, true)

	local pill = self:_EnsurePill()
	pill.Visible = true
	pill.GroupTransparency = 1
	self._pillScale.Scale = self.BaseScale * 0.95

	Util.Tween(pill, { GroupTransparency = 0 }, 0.18)
	Util.Tween(self._pillScale, { Scale = self.BaseScale }, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	Util.Tween(self.Frame, { GroupTransparency = 1 }, 0.14)
	Util.Tween(self.Scale, { Scale = self:_TargetScale() * 0.94 }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	task.delay(0.2, function()
		if self.Minimized and not self.Closed then
			self.Frame.Visible = false
		end
	end)
end

function Window:Restore()
	if self.Closed then
		return
	end

	if self._pill then
		Util.Tween(self._pill, { GroupTransparency = 1 }, 0.12)
		local pill = self._pill
		task.delay(0.13, function()
			if not self.Minimized then
				pill.Visible = false
			end
		end)
	end

	self:Show(false)
end

function Window:Toggle()
	if self.Closed then
		return
	end
	if self.Minimized then
		self:Restore()
	elseif self.Visible then
		self:Hide()
	else
		self:Show(false)
	end
end

function Window:_LayoutHeader()
	if not self.Brand or not self.Nav or not self.Underline then
		return
	end

	local width = measureBrandWidth(self.Title, self.Theme)
	self.Brand.Size = UDim2.fromOffset(width, self.Theme.TopbarHeight)

	local navLeft = 18 + width + 10
	self.NavLeft = navLeft
	self.Nav.Position = UDim2.fromOffset(navLeft, 0)
	self.Nav.Size = UDim2.new(1, -(navLeft + CONTROLS_WIDTH + 14), 0, self.Theme.TopbarHeight)
	self:_UpdateUnderline()
end

function Window:SetTitle(title)
	self.Title = title or self.Title
	self.BrandLabel.Text = self.Title
	self:_LayoutHeader()
	if self._pill then
		local label = self._pill:FindFirstChildOfClass("TextLabel")
		if label then
			label.Text = self.Title
		end
	end
end

function Window:Center(animated)
	if self.Closed then
		return
	end

	local viewport = Util.Viewport()
	local target = UDim2.fromOffset(math.round(viewport.X / 2), math.round(viewport.Y / 2))
	if animated == false then
		self.Frame.Position = target
	else
		Util.Tween(self.Frame, { Position = target }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end
end

function Window:ToggleQuickMenu()
	if self.QuickMenu then
		self.QuickMenu:Toggle()
	end
end

function Window:OpenQuickMenu()
	if self.QuickMenu then
		self.QuickMenu:Open()
	end
end

function Window:CloseQuickMenu()
	if self.QuickMenu then
		self.QuickMenu:Close()
	end
end

function Window:SetToggleKey(key)
	if self._toggleConnection then
		self._toggleConnection:Disconnect()
		self._toggleConnection = nil
	end

	self._toggleKey = key
	if key == false or key == nil then
		return
	end

	self._toggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or Util.IsTyping() then
			return
		end
		if input.KeyCode == key then
			-- The quick menu owns its key. Otherwise K would close the palette
			-- and hide the window at the same time.
			if self.QuickMenu and not self.QuickMenu.Destroyed and self.QuickMenu.Key == key then
				return
			end
			self:Toggle()
		end
	end)
	self.Maid:Add(self._toggleConnection)
end

function Window:Notify(options)
	return self.Library:Notify(options)
end

function Window:Close()
	if self.Closed then
		return
	end
	self.Closed = true

	if self._pill then
		self._pill.Visible = false
	end

	Util.Tween(self.Frame, { GroupTransparency = 1 }, 0.16)
	Util.Tween(self.Scale, { Scale = self:_TargetScale() * 0.96 }, 0.18)
	task.delay(0.18, function()
		self:Destroy()
	end)
end

function Window:Destroy()
	if self.Destroyed then
		return
	end
	self.Destroyed = true
	self.Closed = true

	local tabs = self.Tabs
	self.Tabs = {}
	for _, tab in ipairs(tabs) do
		if tab.Destroy then
			pcall(tab.Destroy, tab)
		end
	end

	for _, popup in ipairs(self.Popups) do
		popup:Destroy()
	end
	self.Popups = {}

	self.Maid:Clean()
	if self.Frame then
		self.Frame:Destroy()
	end
	if self._pill then
		self._pill:Destroy()
	end

	if self.Library then
		self.Library:_RemoveWindow(self)
	end
end

return Window
end

__modules["Athena"] = function(require)
--[[
	Athena
	A close recreation of the Athena client interface for Roblox, written in
	Luau with no dependencies; icons use public Lucide image assets.

	Usage:
		local Athena = loadstring(game:HttpGet("..."))()
		local Window = Athena:CreateWindow({ Title = "My Application" })
		local Tab = Window:CreateTab("Main")
		Tab:CreateSection("General"):CreateButton({ Name = "Example", Callback = print })
]]

local Players = game:GetService("Players")

local Theme = require("Core.Theme")
local Util = require("Core.Util")
local Notifications = require("Notifications")
local Window = require("Window")

local Athena = {}

Athena.Version = "1.0.0"
Athena.Themes = Theme.Presets

Athena._windows = {}
Athena._gui = nil
Athena._parent = nil
Athena._theme = Theme.Resolve("Athena")

local function resolveParent()
	if Athena._parent then
		return Athena._parent
	end

	local player = Players.LocalPlayer
	if player then
		local playerGui = player:FindFirstChildOfClass("PlayerGui")
		if playerGui then
			return playerGui
		end
	end

	local ok, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and coreGui then
		return coreGui
	end

	return nil
end

function Athena:_EnsureGui()
	if self._gui and self._gui.Parent then
		if self._notifications == nil then
			self._notifications = Notifications.new(self, self._gui, self._theme)
		end
		return self._gui
	end

	local parent = resolveParent()
	if not parent then
		error("[Athena] No PlayerGui available. Pass Parent = <instance> to CreateWindow.", 3)
	end

	-- Re-executing an executor script used to leave the previous Athena GUI
	-- behind, including an open quick menu. Remove stale copies before making
	-- this run's GUI.
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "Athena" and child ~= self._gui then
			child:Destroy()
		end
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "Athena"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 999
	gui.Parent = parent

	self._gui = gui

	if self._notifications then
		self._notifications:Destroy()
	end
	self._notifications = Notifications.new(self, gui, self._theme)

	return gui
end

--- Creates a new window. All options are optional.
function Athena:CreateWindow(options)
	options = options or {}
	if options.Parent then
		self._parent = options.Parent
	end

	self:_EnsureGui()

	local window = Window.new(self, options)
	self._windows[window] = true
	return window
end

--- Shows a stacked toast notification and records it in the bell panel.
function Athena:Notify(options)
	self:_EnsureGui()
	return self._notifications:Notify(options)
end

--- Changes the theme used by notifications and windows created afterwards.
function Athena:SetTheme(theme)
	self._theme = Theme.Resolve(theme)
	if self._notifications then
		self._notifications.Theme = self._theme
	end
	return self._theme
end

function Athena:GetWindows()
	local list = {}
	for window in pairs(self._windows) do
		table.insert(list, window)
	end
	return list
end

function Athena:_RemoveWindow(window)
	self._windows[window] = nil

	if next(self._windows) == nil then
		if self._notifications then
			self._notifications:Destroy()
			self._notifications = nil
		end
		if self._gui then
			self._gui:Destroy()
			self._gui = nil
		end
	end
end

--- Removes every window, notification and the ScreenGui.
function Athena:Destroy()
	local windows = {}
	for window in pairs(self._windows) do
		table.insert(windows, window)
	end

	for _, window in ipairs(windows) do
		pcall(function()
			window:Destroy()
		end)
	end
	self._windows = {}

	if self._notifications then
		self._notifications:Destroy()
		self._notifications = nil
	end
	if self._gui then
		self._gui:Destroy()
		self._gui = nil
	end
end

Athena.Util = Util

return Athena
end

return __require("Athena")
