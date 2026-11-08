--[[
	Athena · Tab
	A page inside the window: large title, header actions, scrolling content.
]]

local Util = require(script.Parent.Core.Util)
local Icons = require(script.Parent.Core.Icons)
local Section = require(script.Parent.Section)
local Banner = require(script.Parent.Components.Banner)
local Card = require(script.Parent.Components.Card)

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

	local page = Util.Create("CanvasGroup", {
		Name = "Page_" .. tostring(config.Title),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = 0,
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
	local isPrimary = style == "Primary"
	local lowered = string.lower(tostring(label))
	local showIcon = config.Icon and not (isPrimary and (lowered == "run" or lowered == "execute"))
	local labelFont = isPrimary and theme.FontBold or theme.FontMedium
	local textWidth = Util.Measure(label, 11.5, labelFont).X
	local iconSpace = showIcon and (isPrimary and 28 or 20) or 0
	local extra = isPrimary and 36 or 28
	local width = math.ceil(math.clamp(textWidth + iconSpace + extra, isPrimary and 74 or 44, 168))

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
	Util.Corner(button, isPrimary and 17 or 9)
	local buttonScale = Instance.new("UIScale")
	buttonScale.Parent = button

	local stroke
	if style == "Secondary" then
		stroke = Util.Stroke(button, theme.Border, 1)
		stroke.Transparency = 0
	elseif isPrimary then
		button.BackgroundColor3 = theme.Primary
	else
		button.BackgroundColor3 = theme.Surface
		button.BackgroundTransparency = 1
	end

	local textColor = theme.Text
	if isPrimary then
		textColor = theme.PrimaryText
	elseif style == "Ghost" then
		textColor = theme.TextMuted
	end

	local icon
	local iconChip
	local iconChipScale
	if showIcon then
		if isPrimary then
			iconChip = Util.Create("Frame", {
				Name = "IconChip",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 6, 0.5, 0),
				Size = UDim2.fromOffset(20, 20),
				BackgroundColor3 = theme.PrimaryText,
				BorderSizePixel = 0,
				ZIndex = 2,
				Parent = button,
			})
			Util.Corner(iconChip, 10)
			iconChipScale = Instance.new("UIScale")
			iconChipScale.Parent = iconChip
			icon = Icons.New(config.Icon, 10, theme.Primary, iconChip, 3)
			icon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Frame.Position = UDim2.fromScale(0.5, 0.5)
		else
			icon = Icons.New(config.Icon, 13, textColor, button)
			icon.Frame.AnchorPoint = Vector2.new(0, 0.5)
			icon.Frame.Position = UDim2.new(0, 9, 0.5, 0)
		end
	end

	local textX
	local textRight
	if showIcon then
		textX = isPrimary and 32 or 25
		textRight = isPrimary and 11 or 9
	else
		textX = 0
		textRight = 12
	end

	local text = Util.Create("TextLabel", {
		Position = UDim2.fromOffset(textX, 0),
		Size = UDim2.new(1, -(textX + textRight), 1, 0),
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
			Util.Tween(buttonScale, { Scale = 1.02 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			if iconChipScale then
				Util.Tween(iconChipScale, { Scale = 1.1 }, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			end
			if icon then
				icon:Pulse(1.12, 0.22)
			end
			text.TextColor3 = theme.PrimaryText
		elseif style == "Ghost" then
			Util.Tween(button, { BackgroundTransparency = 0.5 }, 0.12)
			Util.Tween(buttonScale, { Scale = 1.025 }, 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			text.TextColor3 = theme.Text
			if icon then
				icon:SetColor(theme.Text)
			end
		else
			Util.Tween(button, { BackgroundColor3 = theme.SurfaceHover }, 0.12)
			Util.Tween(buttonScale, { Scale = 1.02 }, 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
	end))
	self.Maid:Add(button.MouseLeave:Connect(function()
		hovered = false
		if isPrimary then
			Util.Tween(button, { BackgroundColor3 = theme.Primary }, 0.12)
			Util.Tween(buttonScale, { Scale = 1 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			if iconChipScale then
				Util.Tween(iconChipScale, { Scale = 1 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			end
		elseif style == "Ghost" then
			Util.Tween(button, { BackgroundTransparency = 1 }, 0.12)
			Util.Tween(buttonScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			text.TextColor3 = theme.TextMuted
			if icon then
				icon:SetColor(theme.TextMuted)
			end
		else
			Util.Tween(button, { BackgroundColor3 = theme.SurfaceAlt }, 0.12)
			Util.Tween(buttonScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
	end))
	self.Maid:Add(button.MouseButton1Down:Connect(function()
		if isPrimary then
			Util.Tween(button, { BackgroundColor3 = theme.PrimaryPressed }, 0.07)
		end
		Util.Tween(buttonScale, { Scale = 0.97 }, 0.07)
		if iconChipScale then
			Util.Tween(iconChipScale, { Scale = 0.9 }, 0.07)
		end
	end))
	self.Maid:Add(button.MouseButton1Up:Connect(function()
		if isPrimary then
			Util.Tween(button, { BackgroundColor3 = hovered and theme.PrimaryHover or theme.Primary }, 0.12)
		end
		Util.Tween(buttonScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		if iconChipScale then
			Util.Tween(iconChipScale, { Scale = 1 }, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
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
