--[[
	Athena · Section
	A titled card that groups rows. Every component is built from the same
	deterministic row so spacing stays consistent at any width.
]]

local Util = require(script.Parent.Core.Util)
local Icons = require(script.Parent.Core.Icons)
local Button = require(script.Parent.Components.Button)
local Toggle = require(script.Parent.Components.Toggle)
local Slider = require(script.Parent.Components.Slider)
local Dropdown = require(script.Parent.Components.Dropdown)
local Keybind = require(script.Parent.Components.Keybind)
local Textbox = require(script.Parent.Components.Textbox)
local Label = require(script.Parent.Components.Label)
local Separator = require(script.Parent.Components.Separator)
local ColorPicker = require(script.Parent.Components.ColorPicker)

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
