--[[
	Athena · Window
	The shell: title bar, tab navigation, page host, window controls,
	notification panel, tab search and the popup layer.
]]

local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Core.Theme)
local Util = require(script.Parent.Core.Util)
local Icons = require(script.Parent.Core.Icons)
local Dragger = require(script.Parent.Core.Dragger)
local Popup = require(script.Parent.Core.Popup)
local Tab = require(script.Parent.Tab)
local QuickMenu = require(script.Parent.QuickMenu)
local DynamicIsland = require(script.Parent.DynamicIsland)

local Window = {}
Window.__index = Window

local DEFAULT_SIZE = Vector2.new(880, 600)
local CONTROLS_WIDTH = 178
local BRAND_MIN = 96
local BRAND_MAX = 250
local VERSION_TEXT_SIZE = 9.5
local VERSION_GAP = 5
local BRAND_RIGHT_PAD = 12

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

local function measureBrand(title, theme, version)
	local titleWidth = Util.Measure(title or "Athena", 15, theme.FontBold).X
	local versionText = ""
	if version ~= nil and tostring(version) ~= "" then
		versionText = "v" .. tostring(version)
	end
	local versionWidth = versionText ~= "" and Util.Measure(versionText, VERSION_TEXT_SIZE, theme.Font).X or 0
	local versionGap = versionWidth > 0 and VERSION_GAP or 0
	local width = math.clamp(32 + titleWidth + versionGap + versionWidth + BRAND_RIGHT_PAD, BRAND_MIN, BRAND_MAX)
	local titleSpace = math.max(0, width - 32 - versionGap - versionWidth - BRAND_RIGHT_PAD)
	return width, math.min(titleWidth, titleSpace), versionText, versionWidth, versionGap
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

	-- Sits below the content but above the shell, so blank space, cards and
	-- labels drag the window while real controls keep their normal clicks.
	local dragSurface = Util.Create("TextButton", {
		Name = "WindowDrag",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Active = true,
		ZIndex = 0,
		Parent = frame,
	})
	self.WindowDragSurface = dragSurface

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

	local function setWindowDragState(active)
		Util.Tween(topbar, { BackgroundTransparency = active and 0.72 or 1 }, 0.14)
		Util.Tween(shellStroke, { Transparency = active and 0 or 0.05 }, 0.14)

		if active then
			self:_HideTooltip()
			if self._buttonFadeStates then
				return
			end
			self._buttonFadeStates = {}
			for _, root in ipairs({ self.Content, self.Nav, self.Controls, self.Underline }) do
				for _, state in ipairs(Util.CaptureFade(root, { WindowDrag = true })) do
					table.insert(self._buttonFadeStates, state)
				end
			end
			Util.FadeButtonStates(self._buttonFadeStates, true, 0.14)
		elseif self._buttonFadeStates then
			Util.FadeButtonStates(self._buttonFadeStates, false, 0.18)
			self._buttonFadeStates = nil
		end
	end

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

	local brandWidth, brandTitleWidth, versionText, versionWidth, versionGap =
		measureBrand(self.Title, theme, library.Version)

	local logo = Util.Create("Frame", {
		Name = "Brand",
		Position = UDim2.fromOffset(18, 0),
		Size = UDim2.fromOffset(brandWidth, theme.TopbarHeight),
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
		Size = UDim2.new(0, brandTitleWidth, 1, 0),
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = theme.FontBold,
		TextSize = 15,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = logo,
	})
	local versionLabel
	if versionText ~= "" then
		versionLabel = Util.Create("TextLabel", {
			Name = "Version",
			Position = UDim2.fromOffset(32 + brandTitleWidth + versionGap, 0),
			Size = UDim2.new(0, versionWidth, 1, 0),
			BackgroundTransparency = 1,
			Text = versionText,
			Font = theme.Font,
			TextSize = VERSION_TEXT_SIZE,
			TextColor3 = theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = logo,
		})
	end

	self.BrandLabel = brand
	self.BrandVersion = versionLabel
	self.BrandMark = mark
	self.Brand = logo

	Dragger.Attach(frame, logo, self.Maid, {
		Threshold = 4,
		Margin = 8,
		TopMargin = 44,
		OnDragBegin = function()
			setWindowDragState(true)
		end,
		OnDrag = function()
			self:_ClosePopups(nil, true)
		end,
		OnDragEnd = function()
			setWindowDragState(false)
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

	local navLeft = 18 + brandWidth + 10
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

	local footerText = options.Footer
	if footerText == true then
		footerText = "Info"
	end

	local content = Util.Create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(0, theme.TopbarHeight),
		Size = UDim2.new(1, 0, 1, -theme.TopbarHeight),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Parent = frame,
	})
	self.Content = content

	if footerText then
		local footer = Util.Create("Frame", {
			Name = "Footer",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -80),
			Size = UDim2.new(1, -48, 0, 26),
			BackgroundTransparency = 1,
			ZIndex = 8,
			Parent = frame,
		})
		local infoTab = Util.Create("TextLabel", {
			Name = "InfoTab",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = tostring(footerText),
			Font = theme.Font,
			TextSize = 13,
			TextColor3 = theme.TextMuted,
			TextTransparency = 0.15,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 9,
			Parent = footer,
		})

		self.Footer = footer
		self.FooterLabel = infoTab
	end

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

	Dragger.Attach(frame, dragSurface, self.Maid, {
		Threshold = 4,
		Margin = 8,
		TopMargin = 44,
		OnDragBegin = function()
			setWindowDragState(true)
		end,
		OnDrag = function()
			self:_ClosePopups(nil, true)
		end,
		OnDragEnd = function()
			setWindowDragState(false)
		end,
	})

	Dragger.Attach(frame, topbar, self.Maid, {
		Threshold = 4,
		Margin = 8,
		TopMargin = 44,
		OnDragBegin = function()
			setWindowDragState(true)
		end,
		OnDrag = function()
			self:_ClosePopups(nil, true)
		end,
		OnDragEnd = function()
			setWindowDragState(false)
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
			Dragger.Clamp(frame, 8, self.Maximized and 8 or 44)
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

	if options.DynamicIsland ~= false then
		local islandOptions = type(options.DynamicIsland) == "table" and options.DynamicIsland or {}
		self.DynamicIsland = DynamicIsland.new(self, islandOptions)
		self.Maid:Add(self.DynamicIsland)
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

	local animated = self.Options.Animated ~= false
	for _, other in ipairs(self.Tabs) do
		local active = other == tab
		if active then
			other.Page.Visible = true
			other.Page.GroupTransparency = animated and 1 or 0
			other.Page.Position = animated and UDim2.new(0.5, 0, 0.5, 8) or UDim2.fromScale(0.5, 0.5)
			if other.PageScale then
				other.PageScale.Scale = animated and 0.985 or 1
				if animated then
					Util.Tween(other.Page, { GroupTransparency = 0 }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					Util.Tween(other.Page, { Position = UDim2.fromScale(0.5, 0.5) }, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					Util.Tween(other.PageScale, { Scale = 1 }, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				end
			end
		else
			other.Page.Visible = false
			other.Page.GroupTransparency = 0
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

	-- The palette starts open, before the user has created tabs. Refresh it so
	-- the new jump-to-tab commands appear immediately.
	if self.QuickMenu and not self.QuickMenu.Destroyed then
		self.QuickMenu:_Render(self.QuickMenu.Search.Text)
	end

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
-- Tooltips
--------------------------------------------------------------------------------

function Window:_EnsureTooltip()
	if self._tooltip and self._tooltip.Parent then
		return self._tooltip
	end

	local theme = self.Theme
	local tooltip = Util.Create("TextLabel", {
		Name = "Tooltip",
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Text = "",
		Font = theme.Font,
		TextSize = 10.5,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = false,
		Visible = false,
		ZIndex = 90,
		Parent = self.Frame,
	})
	Util.Corner(tooltip, 6)
	Util.Padding(tooltip, 6, 9, 6, 9)
	Util.Stroke(tooltip, theme.BorderSoft, 1, 0.2)

	self._tooltip = tooltip
	return tooltip
end

function Window:_ShowTooltip(text, target)
	if self.Closed or not text or text == "" or not target or not target.Parent then
		return
	end

	local tooltip = self:_EnsureTooltip()
	tooltip.Text = tostring(text)
	tooltip.Visible = true

	local function place()
		if not tooltip.Visible or not target.Parent then
			return
		end

		local scale = self.Scale.Scale
		if scale <= 0 then
			scale = 1
		end

		local windowPosition = self.Frame.AbsolutePosition
		local targetPosition = target.AbsolutePosition
		local targetSize = target.AbsoluteSize
		local baseX = (targetPosition.X - windowPosition.X) / scale + targetSize.X / (2 * scale)
		local baseY = (targetPosition.Y - windowPosition.Y) / scale
		local baseHeight = targetSize.Y / scale
		local tooltipWidth = tooltip.AbsoluteSize.X / scale
		local tooltipHeight = tooltip.AbsoluteSize.Y / scale
		local windowWidth = self.Frame.Size.X.Offset
		local windowHeight = self.Frame.Size.Y.Offset

		local x = math.clamp(
			baseX,
			tooltipWidth / 2 + 6,
			math.max(tooltipWidth / 2 + 6, windowWidth - tooltipWidth / 2 - 6)
		)
		local y = baseY - 6
		local anchorY = 1
		if y - tooltipHeight < 4 then
			y = baseY + baseHeight + 6
			anchorY = 0
		end
		if anchorY == 1 then
			y = math.clamp(y, tooltipHeight + 4, windowHeight - 4)
		else
			y = math.clamp(y, 4, math.max(4, windowHeight - tooltipHeight - 4))
		end

		tooltip.AnchorPoint = Vector2.new(0.5, anchorY)
		tooltip.Position = UDim2.fromOffset(math.round(x), math.round(y))
	end

	task.defer(place)
end

function Window:_HideTooltip()
	if self._tooltip then
		self._tooltip.Visible = false
	end
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
			Dragger.Clamp(self.Frame, 8, self.Maximized and 8 or 44)
			self:_UpdateUnderline()
		end
	end)
end

function Window:ToggleMaximize()
	self:SetMaximized(not self.Maximized)
end

function Window:_SetQuickMenuOpen(open, instant)
	if not self.QuickMenu or self.QuickMenu.Destroyed then
		return
	end
	if open then
		self.QuickMenu:Open(instant == true)
	else
		self.QuickMenu:Close(instant == true)
	end
end

function Window:Show(instant)
	if self.Closed then
		return
	end
	self.Visible = true
	self.Minimized = false
	self:_SetQuickMenuOpen(true, instant == true)

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
	self:_SetQuickMenuOpen(false, instant == true)
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
	self:_SetQuickMenuOpen(false, true)
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

	local width, titleWidth, versionText, versionWidth, versionGap =
		measureBrand(self.Title, self.Theme, self.Library and self.Library.Version)
	self.Brand.Size = UDim2.fromOffset(width, self.Theme.TopbarHeight)
	self.BrandLabel.Size = UDim2.new(0, titleWidth, 1, 0)
	if self.BrandVersion then
		self.BrandVersion.Position = UDim2.fromOffset(32 + titleWidth + versionGap, 0)
		self.BrandVersion.Size = UDim2.new(0, versionWidth, 1, 0)
		self.BrandVersion.Text = versionText
		self.BrandVersion.Visible = versionText ~= ""
	end

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

function Window:ToggleDynamicIsland()
	if self.DynamicIsland then
		self.DynamicIsland:Toggle()
	end
end

function Window:SetDynamicIslandEnabled(enabled)
	if self.DynamicIsland then
		self.DynamicIsland:SetVisible(enabled)
	end
end

function Window:IsDynamicIslandEnabled()
	return self.DynamicIsland ~= nil and self.DynamicIsland.Enabled == true
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

	if self._buttonFadeStates then
		Util.FadeButtonStates(self._buttonFadeStates, false, 0.08)
		self._buttonFadeStates = nil
	end

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
