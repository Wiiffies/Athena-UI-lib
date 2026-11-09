--[[
	Athena · Components/Dropdown
	A compact selector with a floating option list.
]]

local Util = require(script.Parent.Parent.Core.Util)
local Icons = require(script.Parent.Parent.Core.Icons)

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
	Util.Padding(pill, 0, 10, 0, 10)

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

	self.Pill = pill
	self.Label = label
	self.Stroke = stroke

	self.Popup = section.Window:_CreatePopup({
		Name = "Dropdown",
		Width = 150,
		Height = 120,
		Padding = 5,
		OnClose = function()
			self._open = false
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
	end))
	self.Maid:Add(pill.MouseLeave:Connect(function()
		if not self.Popup:IsOpen() then
			Util.Tween(pill, { BackgroundColor3 = theme.SurfaceAlt }, 0.12)
			Util.Tween(stroke, { Color = theme.Border }, 0.12)
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
