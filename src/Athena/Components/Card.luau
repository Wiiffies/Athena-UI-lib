--[[
	Athena · Components/Card
	The automation card from Athena: artwork, title, subtitle, chips,
	status line, ghost/primary actions and an inline switch.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Icons = require(script.Parent.Parent.Core.Icons)

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
		local isPrimary = style == "Primary"
		local showIcon = action.Icon and not isPrimary
		local labelFont = isPrimary and theme.FontBold or theme.FontMedium
		local textWidth = Util.Measure(label, 11.5, labelFont).X
		local extra = isPrimary and 36 or (showIcon and 32 or 24)
		local width = math.ceil(math.clamp(textWidth + extra, isPrimary and 70 or 50, 150))

		local button = Util.Create("TextButton", {
			Name = "CardAction_" .. label,
			LayoutOrder = #self.Actions + 1,
			Size = UDim2.fromOffset(width, 32),
			BackgroundColor3 = isPrimary and theme.Primary or theme.SurfaceHover,
			BackgroundTransparency = isPrimary and 0 or 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = footer,
		})
		Util.Corner(button, 16)
		local buttonScale = Instance.new("UIScale")
		buttonScale.Parent = button

		local textColor = isPrimary and theme.PrimaryText or theme.TextSoft

		local icon
		if showIcon then
			icon = Icons.New(action.Icon, 12, textColor, button)
			icon.Frame.AnchorPoint = Vector2.new(0, 0.5)
			icon.Frame.Position = UDim2.new(0, 9, 0.5, 0)
		end

		local labelX = showIcon and 25 or 0
		local labelRight = 12

		local labelLabel = Util.Create("TextLabel", {
			Position = UDim2.fromOffset(labelX, 0),
			Size = UDim2.new(1, -(labelX + labelRight), 1, 0),
			BackgroundTransparency = 1,
			Text = label,
			Font = labelFont,
			TextSize = 11.5,
			TextColor3 = textColor,
			TextXAlignment = showIcon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 3,
			Parent = button,
		})

		local hovered = false
		self.Maid:Add(button.MouseEnter:Connect(function()
			hovered = true
			if isPrimary then
				Util.Tween(button, { BackgroundColor3 = theme.PrimaryHover }, 0.12)
				Util.Tween(buttonScale, { Scale = 1.025 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				if icon then
					icon:Pulse(1.12, 0.22)
				end
				labelLabel.TextColor3 = theme.PrimaryText
			else
				Util.Tween(button, { BackgroundTransparency = 0.5 }, 0.12)
				Util.Tween(buttonScale, { Scale = 1.025 }, 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			end
		end))
		self.Maid:Add(button.MouseLeave:Connect(function()
			hovered = false
			if isPrimary then
				Util.Tween(button, { BackgroundColor3 = theme.Primary }, 0.12)
				Util.Tween(buttonScale, { Scale = 1 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			else
				Util.Tween(button, { BackgroundTransparency = 1 }, 0.12)
				Util.Tween(buttonScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			end
		end))
		self.Maid:Add(button.MouseButton1Down:Connect(function()
			if isPrimary then
				Util.Tween(button, { BackgroundColor3 = theme.PrimaryPressed }, 0.07)
			end
			Util.Tween(buttonScale, { Scale = 0.97 }, 0.07)
		end))
		self.Maid:Add(button.MouseButton1Up:Connect(function()
			if isPrimary then
				Util.Tween(button, { BackgroundColor3 = hovered and theme.PrimaryHover or theme.Primary }, 0.12)
			end
			Util.Tween(buttonScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
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
