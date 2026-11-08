--[[
	Athena · QuickMenu
	A small bottom-right command palette inspired by executor command bars.
	Press K (or click the grid button) to open it, then search for an action.
]]

local UserInputService = game:GetService("UserInputService")

local Util = require(script.Parent.Core.Util)
local Icons = require(script.Parent.Core.Icons)

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
	end))
	self.Maid:Add(clearButton.MouseLeave:Connect(function()
		Util.Tween(clearButton, { BackgroundTransparency = 1 }, 0.1)
		clearIcon:SetColor(theme.TextMuted)
	end))

	self.Maid:Add(closeButton.MouseButton1Click:Connect(function()
		self:Close()
	end))
	self.Maid:Add(closeButton.MouseEnter:Connect(function()
		Util.Tween(closeButton, { BackgroundTransparency = 0.45 }, 0.1)
		closeIcon:SetColor(theme.Text)
	end))
	self.Maid:Add(closeButton.MouseLeave:Connect(function()
		Util.Tween(closeButton, { BackgroundTransparency = 1 }, 0.1)
		closeIcon:SetColor(theme.TextMuted)
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
	if self.Destroyed or not self._open then
		return
	end
	self._open = false
	self._animToken += 1
	local token = self._animToken
	self.Catcher.Visible = false
	if self.Search:IsFocused() then
		self.Search:ReleaseFocus()
	end
	self:_SetTriggerOpen(false)

	if instant then
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
	end))
	rowMaid:Add(row.MouseLeave:Connect(function()
		Util.Tween(row, { BackgroundTransparency = 1 }, 0.12)
		Util.Tween(rowScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		icon:SetColor(theme.TextSoft)
		chevron:SetColor(theme.TextFaint)
	end))
	rowMaid:Add(row.MouseButton1Down:Connect(function()
		Util.Tween(rowScale, { Scale = 0.97 }, 0.06)
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
