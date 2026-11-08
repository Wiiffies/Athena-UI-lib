--[[
	Athena · DynamicIsland
	A small, draggable status pill that lives above the window.
	It shows who is running the script, how long it has been running,
	and expands into live FPS and ping readouts.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local Util = require(script.Parent.Core.Util)
local Dragger = require(script.Parent.Core.Dragger)

local DynamicIsland = {}
DynamicIsland.__index = DynamicIsland

local COLLAPSED_WIDTH = 236
local COLLAPSED_HEIGHT = 44
local EXPANDED_WIDTH = 312
local EXPANDED_HEIGHT = 112
local SAFE_TOP = 64
local SIDE_MARGIN = 8
local AVATAR_POS = UDim2.fromOffset(9, 8)
local NAME_POS = UDim2.fromOffset(46, 7)
local STATUS_POS = UDim2.fromOffset(46, 22)

local function formatTime(value)
	local seconds = math.max(0, math.floor(tonumber(value) or 0))
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local remainder = seconds % 60
	if hours > 0 then
		return string.format("%d:%02d:%02d", hours, minutes, remainder)
	end
	return string.format("%02d:%02d", minutes, remainder)
end

local function getPing()
	local ok, value = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok and type(value) == "number" then
		return math.max(0, math.floor(value + 0.5))
	end
	return nil
end

function DynamicIsland.new(window, options)
	options = options or {}
	local theme = window.Theme
	local player = Players.LocalPlayer
	local username = player and player.Name or "Player"
	local displayName = player and player.DisplayName or username
	local initialNow = os.clock()

	local self = setmetatable({
		Window = window,
		Theme = theme,
		Options = options,
		Enabled = options.Enabled ~= false,
		Expanded = options.Expanded == true,
		Destroyed = false,
		Dragging = false,
		Maid = Util.Maid.new(),
		StartedAt = initialNow,
		FPS = 0,
		Ping = nil,
		_visToken = 0,
		_expandToken = 0,
	}, DynamicIsland)

	local viewport = Util.Viewport()
	local initialHeight = self.Expanded and EXPANDED_HEIGHT or COLLAPSED_HEIGHT
	local center = Vector2.new(
		math.round(viewport.X / 2),
		math.round(SAFE_TOP + initialHeight / 2)
	)
	self.BaseCenter = center

	local root = Util.Create("Frame", {
		Name = "AthenaDynamicIsland",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 1000,
		Parent = window.Gui,
	})
	root.Active = false
	self.Root = root

	local island = Util.Create("Frame", {
		Name = "Island",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(center.X, center.Y),
		Size = UDim2.fromOffset(self.Expanded and EXPANDED_WIDTH or COLLAPSED_WIDTH, initialHeight),
		BackgroundColor3 = theme.Overlay,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = true,
		ZIndex = 1001,
		Parent = root,
	})
	Util.Corner(island, 22)
	local islandStroke = Util.Stroke(island, theme.Border, 1, 1)
	local islandScale = Instance.new("UIScale")
	islandScale.Scale = 1
	islandScale.Parent = island

	self.Island = island
	self.IslandStroke = islandStroke
	self.IslandScale = islandScale

	-- Avatar + fallback initial.
	local avatar = Util.Create("ImageLabel", {
		Name = "Avatar",
		Position = UDim2.fromOffset(9, 8),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = theme.SurfaceAlt,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Image = "",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 3,
		Parent = island,
	})
	Util.Corner(avatar, 14)
	local avatarScale = Instance.new("UIScale")
	avatarScale.Parent = avatar
	local avatarLetter = Util.Create("TextLabel", {
		Name = "Initial",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = string.upper(string.sub(displayName, 1, 1)),
		Font = theme.FontBold,
		TextSize = 12,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 4,
		Parent = avatar,
	})

	-- A slow orbit dot and ring make the avatar feel alive without distracting from the name.
	local orbit = Util.Create("Frame", {
		Name = "AvatarOrbit",
		Position = UDim2.fromOffset(7, 6),
		Size = UDim2.fromOffset(32, 32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = 2,
		Parent = island,
	})
	Util.Corner(orbit, 16)
	Util.Stroke(orbit, theme.Primary, 1, 0.72)
	local orbitDot = Util.Create("Frame", {
		Name = "OrbitDot",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.fromOffset(3, 3),
		BackgroundColor3 = theme.Primary,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = orbit,
	})
	Util.Corner(orbitDot, 1.5)

	local nameLabel = Util.Create("TextLabel", {
		Name = "Username",
		Position = UDim2.fromOffset(46, 7),
		Size = UDim2.new(1, -96, 0, 15),
		BackgroundTransparency = 1,
		Text = "@" .. username,
		Font = theme.FontBold,
		TextSize = 11.5,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
		Parent = island,
	})
	local nameGradient = Instance.new("UIGradient")
	nameGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.TextSoft),
		ColorSequenceKeypoint.new(0.5, theme.Text),
		ColorSequenceKeypoint.new(1, theme.TextSoft),
	})
	nameGradient.Parent = nameLabel
	self.NameGradient = nameGradient

	local statusLabel = Util.Create("TextLabel", {
		Name = "Status",
		Position = UDim2.fromOffset(46, 22),
		Size = UDim2.new(1, -92, 0, 13),
		BackgroundTransparency = 1,
		Text = "Running 00:00",
		Font = theme.Font,
		TextSize = 9.5,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
		Parent = island,
	})

	local dot = Util.Create("Frame", {
		Name = "LiveDot",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -13, 0.5, 0),
		Size = UDim2.fromOffset(6, 6),
		BackgroundColor3 = theme.Primary,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = island,
	})
	Util.Corner(dot, 3)
	local dotScale = Instance.new("UIScale")
	dotScale.Parent = dot
	local dotRing = Util.Create("Frame", {
		Name = "Pulse",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = dot,
	})
	Util.Corner(dotRing, 3)
	Util.Stroke(dotRing, theme.Primary, 1, 0.45)

	local dotRipple = Util.Create("Frame", {
		Name = "Ripple",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = dot,
	})
	Util.Corner(dotRipple, 3)
	Util.Stroke(dotRipple, theme.Primary, 1, 1)

	local separator = Util.Create("Frame", {
		Name = "Separator",
		Position = UDim2.fromOffset(10, 48),
		Size = UDim2.new(1, -20, 0, 1),
		BackgroundColor3 = theme.Border,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = island,
	})

	local statsFrame = Util.Create("CanvasGroup", {
		Name = "Stats",
		Position = UDim2.fromOffset(10, 54),
		Size = UDim2.new(1, -20, 0, 44),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 2,
		Parent = island,
	})
	local statsLayout = Util.RowList(statsFrame, 6)
	statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local statsScale = Instance.new("UIScale")
	statsScale.Parent = statsFrame

	local function makeStat(title, order)
		local tile = Util.Create("Frame", {
			Name = title,
			LayoutOrder = order,
			Size = UDim2.fromOffset(87, 40),
			BackgroundColor3 = theme.SurfaceAlt,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = statsFrame,
		})
		Util.Corner(tile, 8)
		local tileScale = Instance.new("UIScale")
		tileScale.Parent = tile

		Util.Create("TextLabel", {
			Position = UDim2.fromOffset(8, 4),
			Size = UDim2.new(1, -16, 0, 11),
			BackgroundTransparency = 1,
			Text = title,
			Font = theme.FontBold,
			TextSize = 7,
			TextColor3 = theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 3,
			Parent = tile,
		})
		local value = Util.Create("TextLabel", {
			Position = UDim2.fromOffset(8, 15),
			Size = UDim2.new(1, -16, 0, 18),
			BackgroundTransparency = 1,
			Text = "—",
			Font = theme.FontBold,
			TextSize = 12,
			TextColor3 = theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 3,
			Parent = tile,
		})
		local valueScale = Instance.new("UIScale")
		valueScale.Parent = value
		return tile, tileScale, value, valueScale
	end

	local uptimeTile, uptimeTileScale, uptimeValue, uptimeValueScale = makeStat("UPTIME", 1)
	local fpsTile, fpsTileScale, fpsValue, fpsValueScale = makeStat("FPS", 2)
	local pingTile, pingTileScale, pingValue, pingValueScale = makeStat("PING", 3)

	self.Avatar = avatar
	self.AvatarScale = avatarScale
	self.AvatarLetter = avatarLetter
	self.NameLabel = nameLabel
	self.StatusLabel = statusLabel
	self.Orbit = orbit
	self.OrbitDot = orbitDot
	self.Dot = dot
	self.DotScale = dotScale
	self.DotRing = dotRing
	self.DotRipple = dotRipple
	self.Separator = separator
	self.Stats = statsFrame
	self.StatsScale = statsScale
	self.StatsTiles = {
		{ Frame = uptimeTile, Scale = uptimeTileScale },
		{ Frame = fpsTile, Scale = fpsTileScale },
		{ Frame = pingTile, Scale = pingTileScale },
	}
	self.Values = {
		Uptime = uptimeValue,
		FPS = fpsValue,
		Ping = pingValue,
	}
	self.ValueScales = {
		Uptime = uptimeValueScale,
		FPS = fpsValueScale,
		Ping = pingValueScale,
	}

	-- The drag surface sits above the labels so every part of the pill drags.
	local dragSurface = Util.Create("TextButton", {
		Name = "Drag",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 30,
		Parent = island,
	})
	self.DragSurface = dragSurface

	-- A soft specular sweep across the glass, clipped to the pill.
	local sheen = Util.Create("Frame", {
		Name = "Sheen",
		Position = UDim2.fromOffset(-60, -70),
		Size = UDim2.fromOffset(50, 220),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.82,
		BorderSizePixel = 0,
		Rotation = 16,
		Active = false,
		ZIndex = 20,
		Parent = island,
	})
	local sheenGradient = Instance.new("UIGradient")
	sheenGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.45),
		NumberSequenceKeypoint.new(1, 1),
	})
	sheenGradient.Parent = sheen
	self.Sheen = sheen

	Dragger.Attach(island, dragSurface, self.Maid, {
		Threshold = 4,
		Margin = SIDE_MARGIN,
		TopMargin = SAFE_TOP,
		OnDragStart = function()
			self.Dragging = true
			self.Island.Rotation = 0
			self.IslandScale.Scale = 1.045
			self.IslandStroke.Transparency = 0.25
		end,
		OnDrag = function()
			if not self.Dragging then
				return
			end
			self.IslandScale.Scale = 1.025
		end,
		OnDragEnd = function(moved)
			self.Dragging = false
			self.IslandScale.Scale = 1
			self.IslandStroke.Transparency = 0.8
			Util.Tween(self.Island, { Rotation = 0 }, 0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			Dragger.Clamp(island, SIDE_MARGIN, SAFE_TOP)
			if not moved then
				self:_SetExpanded(not self.Expanded)
			end
		end,
	})

	self.Maid:Add(dragSurface.MouseEnter:Connect(function()
		if self.Dragging then
			return
		end
		Util.Tween(self.IslandScale, { Scale = 1.015 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Util.Tween(self.IslandStroke, { Transparency = 0.35 }, 0.18)
	end))

	self.Maid:Add(dragSurface.MouseLeave:Connect(function()
		if self.Dragging then
			return
		end
		Util.Tween(self.IslandScale, { Scale = 1 }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Util.Tween(self.IslandStroke, { Transparency = 0.8 }, 0.2)
		Util.Tween(self.Island, { Rotation = 0 }, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))

	-- A tiny parallax tilt follows the cursor while the pill is hovered.
	self.Maid:Add(dragSurface.MouseMoved:Connect(function(x, y)
		if self.Dragging or not self.Enabled then
			return
		end
		local size = self.Island.AbsoluteSize
		if size.X <= 1 or size.Y <= 1 then
			return
		end
		local origin = self.Island.AbsolutePosition
		local relativeX = ((x - origin.X) / size.X) - 0.5
		Util.Tween(self.Island, { Rotation = relativeX * 1.1 }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end))

	self.Maid:Add(dragSurface.MouseButton1Down:Connect(function()
		Util.Tween(self.IslandScale, { Scale = 0.985 }, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end))

	self.Maid:Add(dragSurface.MouseButton1Up:Connect(function()
		if not self.Dragging then
			Util.Tween(self.IslandScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
	end))

	-- Load the player's headshot asynchronously, keeping the initial visible until it lands.
	if player then
		task.spawn(function()
			local ok, image = pcall(function()
				return Players:GetUserThumbnailAsync(
					player.UserId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size48x48
				)
			end)
			if self.Destroyed or not ok or not image then
				return
			end
			self.Avatar.Image = image
			self.Avatar.ImageTransparency = 0
			self.Avatar.BackgroundTransparency = 1
			self.AvatarLetter.Visible = false
			self.AvatarScale.Scale = 1.18
			Util.Tween(self.AvatarScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end)
	end

	-- Measure FPS over half-second windows so the readout stays calm.
	local frameCount = 0
	local frameTime = 0
	self.Maid:Add(RunService.RenderStepped:Connect(function(delta)
		frameCount += 1
		frameTime += delta
		if frameTime >= 0.5 then
			self.FPS = math.floor((frameCount / frameTime) + 0.5)
			frameCount = 0
			frameTime = 0
		end
		if self.Orbit then
			self.Orbit.Rotation = (os.clock() * 38) % 360
		end
		if self.NameGradient then
			self.NameGradient.Offset = Vector2.new(math.sin(os.clock() * 0.9) * 0.25, 0)
		end
	end))

	local function pulseValue(scale)
		if not scale or not scale.Parent then
			return
		end
		scale.Scale = 1.1
		Util.Tween(scale, { Scale = 1 }, 0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end

	local lastClock = ""
	local lastFPS = nil
	local lastPing = nil
	local updateThread = task.spawn(function()
		while not self.Destroyed do
			local clock = formatTime(os.clock() - self.StartedAt)
			if clock ~= lastClock then
				lastClock = clock
				self.StatusLabel.Text = "Running " .. clock
				self.Values.Uptime.Text = clock
				pulseValue(self.ValueScales.Uptime)
			end
			if self.FPS ~= lastFPS then
				lastFPS = self.FPS
				self.Values.FPS.Text = tostring(self.FPS)
				pulseValue(self.ValueScales.FPS)
			end
			self.Ping = getPing()
			if self.Ping ~= lastPing then
				lastPing = self.Ping
				self.Values.Ping.Text = self.Ping and (tostring(self.Ping) .. " ms") or "—"
				pulseValue(self.ValueScales.Ping)
			end
			task.wait(0.25)
		end
	end)
	self.Maid:Add(updateThread)

	local function ripple(ring, delay)
		task.delay(delay, function()
			if self.Destroyed or not self.Enabled or not self.Island.Visible then
				return
			end
			ring.Size = UDim2.fromScale(1, 1)
			ring.BackgroundTransparency = 1
			local stroke = ring:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Transparency = 0.35
			end
			Util.Tween(ring, { Size = UDim2.fromScale(2.35, 2.35) }, 0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			if stroke then
				Util.Tween(stroke, { Transparency = 1 }, 0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			end
		end)
	end

	local pulseThread = task.spawn(function()
		while not self.Destroyed do
			if self.Enabled and self.Island.Visible then
				self.Dot.BackgroundTransparency = 0.1
				self.DotScale.Scale = 1
				Util.Tween(self.Dot, { BackgroundTransparency = 0.62 }, 0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				Util.Tween(self.DotScale, { Scale = 1.65 }, 0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				ripple(self.DotRing, 0)
				ripple(self.DotRipple, 0.32)
			end
			task.wait(1.15)
		end
	end)
	self.Maid:Add(pulseThread)

	local sheenThread = task.spawn(function()
		while not self.Destroyed do
			if self.Enabled and self.Island.Visible then
				local width = self.Island.AbsoluteSize.X
				if width < 1 then
					width = COLLAPSED_WIDTH
				end
				self.Sheen.Position = UDim2.fromOffset(-60, -70)
				Util.Tween(self.Sheen, { Position = UDim2.fromOffset(width + 60, -70) }, 1.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				task.wait(3.9)
			else
				task.wait(1)
			end
		end
	end)
	self.Maid:Add(sheenThread)

	-- Keep the busy pill on-screen when the viewport changes.
	local camera = workspace.CurrentCamera
	if camera then
		self.Maid:Add(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			Dragger.Clamp(island, SIDE_MARGIN, SAFE_TOP)
		end))
	end

	if self.Expanded then
		self:_SetExpanded(true, true)
	end

	if self.Enabled then
		self:_PlayIntro()
		-- The island is a plain Frame, so it stays visible even if a tween is interrupted.
		task.delay(0.55, function()
			if self.Destroyed or not self.Enabled then
				return
			end
			self.Island.Visible = true
			self.Island.BackgroundTransparency = 0
		end)
	else
		island.Visible = false
	end

	return self
end

function DynamicIsland:_PlayIntro()
	if self.Destroyed then
		return
	end
	local targetY = self.BaseCenter.Y
	local startY = targetY - 16

	local function resetContent()
		self.Island.BackgroundTransparency = 0
		self.Avatar.Position = AVATAR_POS
		self.AvatarScale.Scale = 1
		self.NameLabel.Position = NAME_POS
		self.NameLabel.TextTransparency = 0
		self.StatusLabel.Position = STATUS_POS
		self.StatusLabel.TextTransparency = 0
		self.Dot.BackgroundTransparency = 0.1
		self.Island.Rotation = 0
	end

	if self.Options.Animated == false then
		self.Island.Visible = true
		self.Island.BackgroundTransparency = 0
		self.IslandScale.Scale = 1
		self.Island.Position = UDim2.fromOffset(self.BaseCenter.X, targetY)
		self.IslandStroke.Transparency = 0.8
		resetContent()
		return
	end

	self.Island.Visible = true
	self.Island.Position = UDim2.fromOffset(self.BaseCenter.X, startY)
	self.Island.BackgroundTransparency = 0
	self.IslandScale.Scale = 0.96
	self.IslandStroke.Transparency = 1
	self.Island.Rotation = 0
	self.Avatar.Position = UDim2.fromOffset(4, 8)
	self.AvatarScale.Scale = 0.55
	self.NameLabel.Position = UDim2.fromOffset(38, 7)
	self.NameLabel.TextTransparency = 1
	self.StatusLabel.Position = UDim2.fromOffset(38, 22)
	self.StatusLabel.TextTransparency = 1
	self.Dot.BackgroundTransparency = 1
	Util.Tween(self.Island, { Position = UDim2.fromOffset(self.BaseCenter.X, targetY) }, 0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	Util.Tween(self.IslandScale, { Scale = 1 }, 0.46, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	Util.Tween(self.IslandStroke, { Transparency = 0.8 }, 0.5)
	task.delay(0.1, function()
		if self.Destroyed then
			return
		end
		Util.Tween(self.Avatar, { Position = AVATAR_POS }, 0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Util.Tween(self.AvatarScale, { Scale = 1 }, 0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		Util.Tween(self.NameLabel, { Position = NAME_POS, TextTransparency = 0 }, 0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Util.Tween(self.StatusLabel, { Position = STATUS_POS, TextTransparency = 0 }, 0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Util.Tween(self.Dot, { BackgroundTransparency = 0.1 }, 0.36, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end)
	task.delay(0.48, function()
		if not self.Destroyed then
			Dragger.Clamp(self.Island, SIDE_MARGIN, SAFE_TOP)
		end
	end)
end

function DynamicIsland:_SetExpanded(expanded, instant)
	if self.Destroyed or (self.Expanded == expanded and not instant) then
		return
	end

	self.Expanded = expanded
	self._expandToken += 1
	local token = self._expandToken
	local targetWidth = expanded and EXPANDED_WIDTH or COLLAPSED_WIDTH
	local targetHeight = expanded and EXPANDED_HEIGHT or COLLAPSED_HEIGHT
	local currentSize = self.Island.AbsoluteSize
	local currentCenter = self.Island.AbsolutePosition + currentSize / 2
	local targetCenter = Vector2.new(
		currentCenter.X,
		currentCenter.Y + (targetHeight - currentSize.Y) / 2
	)

	if expanded then
		self.Stats.Visible = true
		self.Stats.GroupTransparency = 1
		self.StatsScale.Scale = 0.9
		self.Stats.Position = UDim2.fromOffset(10, 60)
		self.Separator.Size = UDim2.new(0, -20, 0, 1)
		for _, tile in ipairs(self.StatsTiles) do
			tile.Scale.Scale = 0.92
		end
	end

	self.Separator.BackgroundTransparency = expanded and 1 or 0.55

	if instant then
		self.Island.Size = UDim2.fromOffset(targetWidth, targetHeight)
		self.Island.Position = UDim2.fromOffset(targetCenter.X, targetCenter.Y)
		self.Stats.GroupTransparency = expanded and 0 or 1
		self.Stats.Visible = expanded
		self.StatsScale.Scale = 1
		self.Stats.Position = UDim2.fromOffset(10, 54)
		self.Separator.BackgroundTransparency = expanded and 0.55 or 1
		self.Separator.Size = UDim2.new(1, -20, 0, 1)
		for _, tile in ipairs(self.StatsTiles) do
			tile.Scale.Scale = 1
		end
		Dragger.Clamp(self.Island, SIDE_MARGIN, SAFE_TOP)
		return
	end

	Util.Tween(self.Island, {
		Size = UDim2.fromOffset(targetWidth, targetHeight),
		Position = UDim2.fromOffset(targetCenter.X, targetCenter.Y),
	}, 0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	Util.Tween(self.Stats, { GroupTransparency = expanded and 0 or 1 }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	Util.Tween(self.StatsScale, { Scale = 1 }, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	Util.Tween(self.Stats, { Position = UDim2.fromOffset(10, 54) }, 0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	Util.Tween(self.Separator, { BackgroundTransparency = expanded and 0.55 or 1 }, 0.24)
	if expanded then
		Util.Tween(self.Separator, { Size = UDim2.new(1, -20, 0, 1) }, 0.36, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end

	if expanded then
		for index, tile in ipairs(self.StatsTiles) do
			task.delay(0.04 + index * 0.035, function()
				if self.Destroyed or token ~= self._expandToken then
					return
				end
				Util.Tween(tile.Scale, { Scale = 1 }, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			end)
		end
	else
		for _, tile in ipairs(self.StatsTiles) do
			Util.Tween(tile.Scale, { Scale = 0.92 }, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		end
		task.delay(0.24, function()
			if self.Destroyed or token ~= self._expandToken then
				return
			end
			self.Stats.Visible = false
		end)
	end

	task.delay(0.36, function()
		if self.Destroyed or token ~= self._expandToken then
			return
		end
		Dragger.Clamp(self.Island, SIDE_MARGIN, SAFE_TOP)
	end)
end

function DynamicIsland:SetExpanded(value)
	self:_SetExpanded(value == true)
end

function DynamicIsland:ToggleExpanded()
	self:_SetExpanded(not self.Expanded)
end

function DynamicIsland:SetVisible(value, instant)
	if self.Destroyed then
		return
	end

	value = value ~= false
	if self.Enabled == value and not instant then
		return
	end

	self.Enabled = value
	self._visToken += 1
	local token = self._visToken

	if value then
		self.Island.Visible = true
		self.Island.BackgroundTransparency = 0
		self.IslandScale.Scale = instant and 1 or 0.94
		if not instant then
			Util.Tween(self.IslandScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	else
		if instant then
			self.Island.Visible = false
			self.IslandScale.Scale = 1
		else
			Util.Tween(self.IslandScale, { Scale = 0.94 }, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			task.delay(0.16, function()
				if self.Destroyed or token ~= self._visToken or self.Enabled then
					return
				end
				self.Island.Visible = false
				self.IslandScale.Scale = 1
			end)
		end
	end
end

function DynamicIsland:Toggle()
	self:SetVisible(not self.Enabled)
end

function DynamicIsland:GetUptime()
	return os.clock() - self.StartedAt
end

function DynamicIsland:Destroy()
	if self.Destroyed then
		return
	end
	self.Destroyed = true
	self.Maid:Clean()
	if self.Root then
		self.Root:Destroy()
		self.Root = nil
	end
end

return DynamicIsland
