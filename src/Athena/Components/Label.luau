--[[
	Athena · Components/Label
	Supports a two-column value row or a wrapped paragraph, both measured
	so the card height stays exact at any width.
]]

local Util = require(script.Parent.Parent.Core.Util)

local Label = {}
Label.__index = Label

local function normalize(input)
	if type(input) == "string" then
		return { Text = input }
	end
	return input or {}
end

function Label.new(section, input)
	local options = normalize(input)
	local theme = section.Theme

	local self = setmetatable({
		Section = section,
		Theme = theme,
		Options = options,
		Maid = Util.Maid.new(),
	}, Label)

	if options.Value ~= nil then
		local valueText = tostring(options.Value)
		local valueWidth = math.ceil(math.min(Util.Measure(valueText, 11.5, theme.Font).X + 8, 240))

		local row = section:_Row({
			Name = options.Text or options.Name or "",
			Description = options.Description,
			Height = options.Description and 54 or 44,
			ControlWidth = valueWidth,
		})

		local valueLabel = Util.Create("TextLabel", {
			Name = "Value",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = valueText,
			Font = theme.Font,
			TextSize = 11.5,
			TextColor3 = options.ValueColor or theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row.Control,
		})

		self.Instance = row.Row
		self.ValueLabel = valueLabel
		self.NameLabel = row.NameLabel
		self.DescriptionLabel = row.DescriptionLabel

		function self:SetText(text)
			if self.NameLabel then
				self.NameLabel.Text = text
			end
		end

		function self:SetValue(value)
			valueLabel.Text = tostring(value)
		end

		function self:GetValue()
			return valueLabel.Text
		end

		function self:Destroy()
			self.Maid:Clean()
			row.Row:Destroy()
		end

		return self
	end

	local text = options.Text or options.Name or ""
	local description = options.Description or ""

	local frame = Util.Create("Frame", {
		Name = "Label",
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = theme.SurfaceHover,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 0,
		Parent = section.Card,
	})

	local padding = Util.Padding(frame, 13, 14, 13, 14)

	local textLabel = Util.Create("TextLabel", {
		Name = "Text",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = text,
		Font = theme.Font,
		TextSize = 12,
		TextColor3 = options.TextColor or theme.TextSoft,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = frame,
	})

	local descLabel
	if description ~= "" then
		descLabel = Util.Create("TextLabel", {
			Name = "Description",
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 14),
			BackgroundTransparency = 1,
			Text = description,
			Font = theme.Font,
			TextSize = 11,
			TextColor3 = theme.TextMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Parent = frame,
		})
	end

	self.Instance = frame
	self.TextLabel = textLabel
	self.DescriptionLabel = descLabel

	local function measure()
		local innerWidth = math.max(80, section.Width - 28)
		local textHeight = math.max(15, math.ceil(Util.Measure(textLabel.Text, 12, theme.Font, innerWidth).Y))
		local descHeight = 0
		if descLabel then
			descHeight = math.max(14, math.ceil(Util.Measure(descLabel.Text, 11, theme.Font, innerWidth).Y))
		end

		frame.Size = UDim2.new(1, 0, 0, textHeight + descHeight + (descLabel and 4 or 0) + 26)
		textLabel.Size = UDim2.new(1, 0, 0, textHeight)
		if descLabel then
			descLabel.Position = UDim2.fromOffset(0, textHeight + 4)
			descLabel.Size = UDim2.new(1, 0, 0, descHeight)
		end
	end

	section:_RevealPendingDivider()
	frame.LayoutOrder = section:_NextOrder()
	section:_NewDivider()

	function self:SetText(value)
		textLabel.Text = value
		measure()
	end

	function self:GetText()
		return textLabel.Text
	end

	function self:Destroy()
		self.Maid:Clean()
		frame:Destroy()
	end

	local _ = padding
	measure()

	return self
end

return Label
