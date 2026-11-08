--[[
	Athena UI · Core/Util
	Small, dependency free helpers shared by every component.
]]

local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Util = {}

--------------------------------------------------------------------------------
-- Lifetime
--------------------------------------------------------------------------------

local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Add(item)
	if item == nil then
		return item
	end
	if typeof(item) == "RBXScriptConnection" then
		table.insert(self._tasks, function()
			item:Disconnect()
		end)
	elseif typeof(item) == "Instance" then
		table.insert(self._tasks, function()
			item:Destroy()
		end)
	elseif type(item) == "table" and type(item.Destroy) == "function" then
		table.insert(self._tasks, function()
			item:Destroy()
		end)
	elseif type(item) == "function" then
		table.insert(self._tasks, item)
	elseif type(item) == "thread" then
		table.insert(self._tasks, function()
			task.cancel(item)
		end)
	end
	return item
end

function Maid:Clean()
	for index = #self._tasks, 1, -1 do
		local worker = self._tasks[index]
		self._tasks[index] = nil
		pcall(worker)
	end
end

Maid.Destroy = Maid.Clean

Util.Maid = Maid

--------------------------------------------------------------------------------
-- Instance creation
--------------------------------------------------------------------------------

function Util.Create(className, properties, children)
	local instance = Instance.new(className)
	local parent = nil

	if properties then
		for key, value in pairs(properties) do
			if key == "Parent" then
				parent = value
			else
				instance[key] = value
			end
		end
	end

	if children then
		for _, child in ipairs(children) do
			if child then
				child.Parent = instance
			end
		end
	end

	if parent then
		instance.Parent = parent
	end

	return instance
end

function Util.Corner(parent, radius)
	local corner = Instance.new("UICorner")
	if typeof(radius) == "UDim" then
		corner.CornerRadius = radius
	else
		corner.CornerRadius = UDim.new(0, radius or 0)
	end
	corner.Parent = parent
	return corner
end

function Util.Stroke(parent, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.new(1, 1, 1)
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

function Util.Padding(parent, top, right, bottom, left)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingRight = UDim.new(0, right or 0)
	padding.PaddingBottom = UDim.new(0, bottom or 0)
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.Parent = parent
	return padding
end

function Util.List(parent, padding, horizontalAlignment)
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, padding or 0)
	layout.HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Center
	layout.Parent = parent
	return layout
end

function Util.RowList(parent, padding)
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, padding or 0)
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = parent
	return layout
end

function Util.Clip(parent)
	parent.ClipsDescendants = true
	return parent
end

--------------------------------------------------------------------------------
-- Motion
--------------------------------------------------------------------------------

function Util.Tween(instance, properties, duration, style, direction, callback)
	local info = TweenInfo.new(
		duration or 0.15,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(instance, info, properties)
	if callback then
		tween.Completed:Once(callback)
	end
	tween:Play()
	return tween
end

--- Runs a user callback, reporting mistakes without breaking the interface.
function Util.Safe(callback, ...)
	if type(callback) ~= "function" then
		return
	end
	local ok, err = pcall(callback, ...)
	if not ok then
		warn("[Athena] " .. tostring(err))
	end
end

--- Subtle row highlight used by interactive rows.
function Util.RowHover(row, maid, theme)
	row.BackgroundColor3 = theme.SurfaceHover
	row.BackgroundTransparency = 1

	maid:Add(row.MouseEnter:Connect(function()
		Util.Tween(row, { BackgroundTransparency = 0.55 }, 0.12)
	end))
	maid:Add(row.MouseLeave:Connect(function()
		Util.Tween(row, { BackgroundTransparency = 1 }, 0.12)
	end))
	maid:Add(row.MouseButton1Down:Connect(function()
		Util.Tween(row, { BackgroundTransparency = 0.35 }, 0.06)
	end))
	maid:Add(row.MouseButton1Up:Connect(function()
		Util.Tween(row, { BackgroundTransparency = 0.55 }, 0.1)
	end))
end

--------------------------------------------------------------------------------
-- Text & numbers
--------------------------------------------------------------------------------

function Util.Measure(text, size, font, width)
	return TextService:GetTextSize(text, size, font, Vector2.new(width or 100000, 100000))
end

function Util.Round(value, step)
	if not step or step <= 0 then
		return value
	end
	local quotient = value / step
	local rounded = quotient >= 0 and math.floor(quotient + 0.5) or math.ceil(quotient - 0.5)
	return rounded * step
end

function Util.Clamp(value, minimum, maximum)
	return math.clamp(value, minimum, maximum)
end

function Util.FormatNumber(value)
	if value ~= value or value == math.huge or value == -math.huge then
		return "0"
	end
	local rounded = math.round(value * 1000) / 1000
	if rounded % 1 == 0 then
		return tostring(math.floor(rounded))
	end
	local text = string.format("%.3f", rounded)
	text = text:gsub("0+$", "")
	text = text:gsub("%.$", "")
	return text
end

function Util.DecimalsFor(step)
	if not step or step >= 1 then
		return 0
	end
	local text = tostring(step)
	local dot = text:find(".", 1, true)
	if dot then
		return math.min(#text - dot, 3)
	end
	return 0
end

--------------------------------------------------------------------------------
-- Colours
--------------------------------------------------------------------------------

function Util.ColorToHex(color)
	local r = math.round(math.clamp(color.R, 0, 1) * 255)
	local g = math.round(math.clamp(color.G, 0, 1) * 255)
	local b = math.round(math.clamp(color.B, 0, 1) * 255)
	return string.format("#%02X%02X%02X", r, g, b)
end

function Util.HexToColor(hex)
	if type(hex) ~= "string" then
		return nil
	end
	local cleaned = hex:gsub("#", "")
	if #cleaned == 3 then
		cleaned = cleaned:sub(1, 1):rep(2) .. cleaned:sub(2, 2):rep(2) .. cleaned:sub(3, 3):rep(2)
	end
	if #cleaned ~= 6 or cleaned:match("%X") then
		return nil
	end
	local r = tonumber(cleaned:sub(1, 2), 16)
	local g = tonumber(cleaned:sub(3, 4), 16)
	local b = tonumber(cleaned:sub(5, 6), 16)
	if not r or not g or not b then
		return nil
	end
	return Color3.fromRGB(r, g, b)
end

--- Returns a readable text colour for a given background.
function Util.ReadableOn(color)
	local h, s, v = color:ToHSV()
	if v > 0.62 and s < 0.7 then
		return Color3.fromRGB(14, 15, 18)
	end
	return Color3.fromRGB(255, 255, 255)
end

--------------------------------------------------------------------------------
-- Screen
--------------------------------------------------------------------------------

function Util.Viewport()
	local camera = workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

function Util.ComputeScale(viewport)
	local vp = viewport or Util.Viewport()
	return math.clamp(math.min(vp.X / 1440, vp.Y / 810), 0.72, 1.12)
end

function Util.Round2(value)
	return math.round(value * 2) / 2
end

function Util.SetTimeout(seconds, callback)
	local thread = task.delay(seconds, callback)
	return thread
end

function Util.FocusLost(textbox)
	textbox:ReleaseFocus()
end

function Util.IsTyping()
	return UserInputService:GetFocusedTextBox() ~= nil
end

function Util.Heartbeat()
	return RunService.Heartbeat
end

return Util
