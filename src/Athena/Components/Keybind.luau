--[[
	Athena · Components/Keybind
	Click to listen, then press a key or mouse button. Backspace clears.
]]

local UserInputService = game:GetService("UserInputService")
local Util = require(script.Parent.Parent.Core.Util)

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
