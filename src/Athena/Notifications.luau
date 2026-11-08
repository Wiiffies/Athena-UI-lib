--[[
	Athena UI · Notifications
	Stacked toasts (top right) plus the history used by the bell panel.
]]

local Util = require(script.Parent.Core.Util)
local Icons = require(script.Parent.Core.Icons)

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
		BackgroundColor3 = toneColor,
		BackgroundTransparency = 0.45,
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
