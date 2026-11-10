--[[
	Athena · KeySystem
	A local license-style activation gate with copyable provider links.
]]

local Players = game:GetService("Players")

local Util = require(script.Parent.Core.Util)
local Icons = require(script.Parent.Core.Icons)

local KeySystem = {}
KeySystem.__index = KeySystem

local function normalizeKeys(value)
	local keys = {}
	if type(value) == "string" then
		if value ~= "" then
			table.insert(keys, value)
		end
	elseif type(value) == "table" then
		for _, key in ipairs(value) do
			if type(key) == "string" and key ~= "" then
				table.insert(keys, key)
			end
		end
	end
	return keys
end

local function normalizeProvider(value)
	if type(value) == "string" then
		return { Name = "provider", Link = value }
	end
	if type(value) == "table" then
		local link = value.Link or value.Url or value.URL
		if type(link) == "string" and link ~= "" then
			return {
				Name = tostring(value.Name or "key"),
				Link = link,
				Icon = value.Icon,
			}
		end
	end
	return nil
end

local function normalizeProviders(value)
	local providers = {}
	if type(value) == "table" then
		for _, provider in ipairs(value) do
			local normalized = normalizeProvider(provider)
			if normalized then
				table.insert(providers, normalized)
			end
		end
	end
	return providers
end

local function environments()
	local list = {}
	local seen = {}

	local function add(env)
		if type(env) == "table" and not seen[env] then
			seen[env] = true
			table.insert(list, env)
		end
	end

	local ok, getgenvFn = pcall(function()
		return getgenv
	end)
	if ok and type(getgenvFn) == "function" then
		local got, env = pcall(getgenvFn)
		if got then
			add(env)
		end
	end

	add(_G)

	local gotShared, sharedEnv = pcall(function()
		return shared
	end)
	if gotShared then
		add(sharedEnv)
	end

	local gotThread, threadEnv = pcall(function()
		return getfenv(0)
	end)
	if gotThread then
		add(threadEnv)
	end

	return list
end

local function copyText(text)
	for _, env in ipairs(environments()) do
		for _, name in ipairs({ "setclipboard", "toclipboard", "copy" }) do
			local fn = env[name]
			if type(fn) == "function" then
				local ok = pcall(fn, text)
				if ok then
					return true
				end
			end
		end
		for _, executorName in ipairs({ "syn", "fluxus", "krnl", "delta", "wave" }) do
			local executor = env[executorName]
			if type(executor) == "table" then
				for _, name in ipairs({ "setclipboard", "toclipboard", "copy" }) do
					local fn = executor[name]
					if type(fn) == "function" then
						local ok = pcall(fn, text)
						if ok then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

local function trimmed(text)
	return (string.gsub(tostring(text or ""), "^%s+", ""):gsub("%s+$", ""))
end

local function defaultUsername()
	local player = Players.LocalPlayer
	if player then
		return player.DisplayName or player.Name
	end
	return "player"
end

function KeySystem.new(athena, options)
	options = options or {}
	local theme = athena._theme
	local username = tostring(options.Username or defaultUsername())
	local self = setmetatable({
		Athena = athena,
		Theme = theme,
		Options = options,
		Keys = normalizeKeys(options.Keys or options.Key),
		Providers = normalizeProviders(options.Providers),
		Unlocked = false,
		Visible = false,
		Destroyed = false,
		Maid = Util.Maid.new(),
		ProviderMaid = Util.Maid.new(),
	}, KeySystem)

	local gui = athena:_EnsureGui()
	local overlay = Util.Create("TextButton", {
		Name = "KeySystem",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(8, 9, 11),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 300,
		Parent = gui,
	})

	local content = Util.Create("Frame", {
		Name = "Content",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(420, 440),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 301,
		Parent = overlay,
	})

	local contentScale = Instance.new("UIScale")
	contentScale.Scale = 0.97
	contentScale.Parent = content

	local logoRow = Util.Create("Frame", {
		Name = "Brand",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.fromOffset(126, 26),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 302,
		Parent = content,
	})

	local brandMark = Icons.New("athena", 22, theme.Text, logoRow, 303)
	brandMark.Frame.Position = UDim2.fromOffset(0, 2)

	Util.Create("TextLabel", {
		Name = "BrandName",
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -32, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Brand or "Athena",
		Font = theme.FontBold,
		TextSize = 18,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 303,
		Parent = logoRow,
	})

	local title = Util.Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(0, 38),
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		Text = options.Title or "Activate Athena",
		Font = theme.FontBold,
		TextSize = 30,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 302,
		Parent = content,
	})

	local signedIn = Util.Create("TextLabel", {
		Name = "SignedIn",
		Position = UDim2.fromOffset(0, 82),
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = options.SignedInText or options.Subtitle or ("Signed in as " .. username),
		Font = theme.Font,
		TextSize = 12,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 302,
		Parent = content,
	})

	local input = Util.Create("TextBox", {
		Name = "LicenseKey",
		Position = UDim2.fromOffset(0, 118),
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = options.Placeholder or "License key",
		PlaceholderColor3 = theme.TextFaint,
		Font = theme.Font,
		TextSize = 13,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ClearTextOnFocus = false,
		ZIndex = 302,
		Parent = content,
	})
	Util.Corner(input, 10)
	local inputStroke = Util.Stroke(input, theme.Border, 1, 0.05)
	Util.Padding(input, 0, 16, 0, 16)

	local status = Util.Create("TextLabel", {
		Name = "Status",
		Position = UDim2.fromOffset(0, 174),
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "",
		Font = theme.Font,
		TextSize = 10.5,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = true,
		ZIndex = 302,
		Parent = content,
	})

	local submit = Util.Create("TextButton", {
		Name = "Activate",
		Position = UDim2.fromOffset(0, 202),
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Text = "Activate",
		Font = theme.FontBold,
		TextSize = 13.5,
		TextColor3 = theme.TextMuted,
		AutoButtonColor = false,
		ZIndex = 302,
		Parent = content,
	})
	Util.Corner(submit, 26)

	local divider = Util.Create("Frame", {
		Name = "Or",
		Position = UDim2.fromOffset(0, 270),
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 302,
		Parent = content,
	})
	Util.Create("Frame", {
		Name = "LeftLine",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromOffset(0, 8),
		Size = UDim2.fromOffset(170, 1),
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		ZIndex = 302,
		Parent = divider,
	})
	Util.Create("Frame", {
		Name = "RightLine",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0, 8),
		Size = UDim2.fromOffset(170, 1),
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		ZIndex = 302,
		Parent = divider,
	})
	Util.Create("TextLabel", {
		Name = "OrLabel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(40, 16),
		BackgroundTransparency = 1,
		Text = "or",
		Font = theme.Font,
		TextSize = 11,
		TextColor3 = theme.TextFaint,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 303,
		Parent = divider,
	})

	local providerList = Util.Create("ScrollingFrame", {
		Name = "Providers",
		Position = UDim2.fromOffset(0, 292),
		Size = UDim2.new(1, 0, 0, 92),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 0,
		ZIndex = 302,
		Parent = content,
	})
	Util.List(providerList, 8, Enum.HorizontalAlignment.Center)

	local footer = Util.Create("Frame", {
		Name = "Footer",
		Position = UDim2.fromOffset(0, 400),
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 302,
		Parent = content,
	})

	local note = Util.Create("TextLabel", {
		Name = "Note",
		Size = UDim2.new(1, -94, 1, 0),
		BackgroundTransparency = 1,
		Text = options.Note or "Keys stack onto whatever time you have left.",
		Font = theme.Font,
		TextSize = 10.5,
		TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 302,
		Parent = footer,
	})

	local signOut = Util.Create("TextButton", {
		Name = "SignOut",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(84, 20),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = options.SignOutText or "Sign out",
		Font = theme.FontBold,
		TextSize = 10.5,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Center,
		AutoButtonColor = false,
		ZIndex = 302,
		Parent = footer,
	})

	self.Overlay = overlay
	self.Content = content
	self.ContentScale = contentScale
	self.TitleLabel = title
	self.SignedInLabel = signedIn
	self.Input = input
	self.InputStroke = inputStroke
	self.Submit = submit
	self.Status = status
	self.ProviderList = providerList
	self.NoteLabel = note
	self.SignOut = signOut

	function self:_SetStatus(text, isError)
		status.Text = text or ""
		status.TextColor3 = isError and Color3.fromRGB(255, 116, 116) or theme.TextMuted
	end

	local function refreshSubmit()
		local hasText = trimmed(input.Text) ~= ""
		submit.BackgroundColor3 = hasText and theme.Primary or theme.SurfaceAlt
		submit.TextColor3 = hasText and theme.PrimaryText or theme.TextMuted
	end

	function self:_RefreshProviders()
		self.ProviderMaid:Clean()
		self.ProviderMaid = Util.Maid.new()
		for _, child in ipairs(providerList:GetChildren()) do
			if child:IsA("TextButton") or child:IsA("TextLabel") then
				child:Destroy()
			end
		end

		if #self.Providers == 0 then
			Util.Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 34),
				BackgroundTransparency = 1,
				Text = "No get-key links configured.",
				Font = theme.Font,
				TextSize = 10.5,
				TextColor3 = theme.TextFaint,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 303,
				Parent = providerList,
			})
			return
		end

		local providerText = options.ProviderText or "Get a free key on %s"
		for index, provider in ipairs(self.Providers) do
			local button = Util.Create("TextButton", {
				Name = "Provider_" .. tostring(index),
				LayoutOrder = index,
				Size = UDim2.new(1, 0, 0, 48),
				BackgroundColor3 = theme.Surface,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 303,
				Parent = providerList,
			})
			Util.Corner(button, 24)
			local stroke = Util.Stroke(button, theme.Border, 1, 0.05)

			local row = Util.Create("Frame", {
				Name = "Row",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 304,
				Parent = button,
			})
			local layout = Instance.new("UIListLayout")
			layout.FillDirection = Enum.FillDirection.Horizontal
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			layout.VerticalAlignment = Enum.VerticalAlignment.Center
			layout.Padding = UDim.new(0, 8)
			layout.Parent = row

			Icons.New(provider.Icon or "messageCircle", 15, theme.TextSoft, row, 304)

			Util.Create("TextLabel", {
				Name = "Label",
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromOffset(0, 20),
				BackgroundTransparency = 1,
				Text = string.format(providerText, provider.Name),
				Font = theme.FontMedium,
				TextSize = 12,
				TextColor3 = theme.TextSoft,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 304,
				Parent = row,
			})

			self.ProviderMaid:Add(button.MouseEnter:Connect(function()
				Util.Tween(button, { BackgroundTransparency = 0.55 }, 0.12)
				Util.Tween(stroke, { Transparency = 0 }, 0.12)
			end))
			self.ProviderMaid:Add(button.MouseLeave:Connect(function()
				Util.Tween(button, { BackgroundTransparency = 1 }, 0.12)
				Util.Tween(stroke, { Transparency = 0.05 }, 0.12)
			end))
			self.ProviderMaid:Add(button.MouseButton1Click:Connect(function()
				if copyText(provider.Link) then
					self:_SetStatus("Copied " .. provider.Name .. " link to the clipboard.")
				else
					self:_SetStatus("Clipboard unavailable. Link: " .. provider.Link, true)
				end
			end))
		end
	end

	function self:Submit()
		if self.Unlocked or self.Destroyed then
			return
		end

		local entered = trimmed(input.Text)
		if entered == "" then
			self:_SetStatus("Enter a key first.", true)
			return
		end
		if #self.Keys == 0 then
			self:_SetStatus("No key has been configured.", true)
			return
		end

		for _, key in ipairs(self.Keys) do
			if entered == key then
				self:Unlock()
				return
			end
		end
		self:_SetStatus("Incorrect key.", true)
	end

	function self:Unlock()
		if self.Unlocked or self.Destroyed then
			return
		end
		self.Unlocked = true
		self:Hide()
		if self.Options.OnSuccess then
			Util.Safe(self.Options.OnSuccess)
		end
	end

	function self:SignOut()
		Util.Safe(self.Options.OnSignOut)
		if self.Destroyed then
			return
		end
		self.Unlocked = false
		input.Text = ""
		refreshSubmit()
		self:_SetStatus("")
		self:Show()
	end

	function self:Show()
		if self.Destroyed then
			return
		end
		self.Visible = true
		overlay.Visible = true
		overlay.BackgroundTransparency = 1
		contentScale.Scale = 0.97
		input.Text = ""
		refreshSubmit()
		self:_SetStatus("")
		Util.Tween(overlay, { BackgroundTransparency = 0.04 }, 0.2)
		Util.Tween(contentScale, { Scale = 1 }, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		task.defer(function()
			if self.Visible and not self.Destroyed then
				input:CaptureFocus()
			end
		end)
	end

	function self:Hide()
		if not self.Visible then
			return
		end
		self.Visible = false
		Util.Tween(overlay, { BackgroundTransparency = 1 }, 0.16)
		Util.Tween(contentScale, { Scale = 0.98 }, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		task.delay(0.18, function()
			if not self.Visible and not self.Destroyed then
				overlay.Visible = false
			end
		end)
	end

	function self:SetKeys(keys)
		self.Keys = normalizeKeys(keys)
	end

	function self:AddKey(key)
		if type(key) == "string" and key ~= "" then
			table.insert(self.Keys, key)
		end
	end

	function self:SetProviders(providers)
		self.Providers = normalizeProviders(providers)
		self:_RefreshProviders()
	end

	function self:AddProvider(provider)
		local normalized = normalizeProvider(provider)
		if not normalized then
			return
		end
		table.insert(self.Providers, normalized)
		self:_RefreshProviders()
	end

	function self:SetSignedIn(text)
		signedIn.Text = tostring(text or "")
	end

	function self:IsUnlocked()
		return self.Unlocked
	end

	function self:Destroy()
		if self.Destroyed then
			return
		end
		self.Destroyed = true
		self.Maid:Clean()
		self.ProviderMaid:Clean()
		if self.Athena and self.Athena._RemoveKeySystem then
			self.Athena:_RemoveKeySystem(self)
		end
		overlay:Destroy()
	end

	self.Maid:Add(input.Focused:Connect(function()
		Util.Tween(inputStroke, { Color = theme.Primary, Transparency = 0.15 }, 0.12)
	end))
	self.Maid:Add(input.FocusLost:Connect(function(enterPressed)
		Util.Tween(inputStroke, { Color = theme.Border, Transparency = 0.05 }, 0.12)
		if enterPressed then
			self:Submit()
		end
	end))
	self.Maid:Add(input.TextChanged:Connect(function()
		refreshSubmit()
	end))
	self.Maid:Add(submit.MouseEnter:Connect(function()
		if trimmed(input.Text) ~= "" then
			Util.Tween(submit, { BackgroundColor3 = theme.PrimaryHover }, 0.12)
		end
	end))
	self.Maid:Add(submit.MouseLeave:Connect(function()
		refreshSubmit()
	end))
	self.Maid:Add(submit.MouseButton1Click:Connect(function()
		self:Submit()
	end))
	self.Maid:Add(signOut.MouseEnter:Connect(function()
		Util.Tween(signOut, { TextColor3 = theme.TextSoft }, 0.12)
	end))
	self.Maid:Add(signOut.MouseLeave:Connect(function()
		Util.Tween(signOut, { TextColor3 = theme.Text }, 0.12)
	end))
	self.Maid:Add(signOut.MouseButton1Click:Connect(function()
		self:SignOut()
	end))

	refreshSubmit()
	self:_RefreshProviders()
	return self
end

return KeySystem
