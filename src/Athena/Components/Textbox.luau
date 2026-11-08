--[[
	Athena UI · Components/Textbox
	Inline text input with a commit callback on Enter or focus loss.
]]

local Util = require(script.Parent.Parent.Core.Util)

local Textbox = {}
Textbox.__index = Textbox

function Textbox.new(section, options)
	options = options or {}
	local theme = section.Theme

	local row = section:_Row({
		Name = options.Name or options.Title or "Textbox",
		Description = options.Description,
		Height = options.Description and 58 or 48,
		ControlWidth = 150,
	})

	local self = setmetatable({
		Section = section,
		Theme = theme,
		Options = options,
		Instance = row.Row,
		Maid = Util.Maid.new(),
	}, Textbox)

	local field = Util.Create("Frame", {
		Name = "Field",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Parent = row.Control,
	})
	Util.Corner(field, 8)
	local stroke = Util.Stroke(field, theme.Border, 1)
	Util.Padding(field, 0, 10, 0, 10)

	local textbox = Util.Create("TextBox", {
		Name = "Input",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = tostring(options.Default or ""),
		PlaceholderText = options.Placeholder or "",
		PlaceholderColor3 = theme.TextFaint,
		Font = theme.Font,
		TextSize = 11.5,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ClearTextOnFocus = false,
		Parent = field,
	})

	self.Field = field
	self.Textbox = textbox
	self.Stroke = stroke

	function self:Get()
		return textbox.Text
	end

	function self:Set(text, silent)
		textbox.Text = tostring(text or "")
		if not silent and self.Options.Callback then
			Util.Safe(self.Options.Callback, textbox.Text, false)
		end
	end

	local function commit(enterPressed)
		if self.Options.Callback then
			Util.Safe(self.Options.Callback, textbox.Text, enterPressed)
		end
	end

	self.Maid:Add(textbox.Focused:Connect(function()
		Util.Tween(stroke, { Color = theme.SurfaceActive, Transparency = 0 }, 0.12)
		Util.Tween(field, { BackgroundColor3 = theme.SurfaceHover }, 0.12)
	end))

	self.Maid:Add(textbox.FocusLost:Connect(function(enterPressed)
		Util.Tween(stroke, { Color = theme.Border, Transparency = 0 }, 0.12)
		Util.Tween(field, { BackgroundColor3 = theme.SurfaceAlt }, 0.12)
		commit(enterPressed)
	end))

	self.Maid:Add(textbox.MouseEnter:Connect(function()
		if not textbox:IsFocused() then
			Util.Tween(stroke, { Color = theme.SurfaceActive }, 0.12)
		end
	end))
	self.Maid:Add(textbox.MouseLeave:Connect(function()
		if not textbox:IsFocused() then
			Util.Tween(stroke, { Color = theme.Border }, 0.12)
		end
	end))

	if options.Numeric then
		self.Maid:Add(textbox:GetPropertyChangedSignal("Text"):Connect(function()
			local cleaned = textbox.Text:gsub("[^%d%-%.]", "")
			if cleaned ~= textbox.Text then
				local cursor = textbox.CursorPosition
				textbox.Text = cleaned
				textbox.CursorPosition = math.min(cursor, #cleaned + 1)
			end
		end))
	end

	function self:Destroy()
		self.Maid:Clean()
		row.Row:Destroy()
	end

	return self
end

return Textbox
