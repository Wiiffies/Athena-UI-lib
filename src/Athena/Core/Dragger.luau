--[[
	Athena UI · Core/Dragger
	Mouse and touch dragging with viewport clamping, aware of UIScale.
]]

local UserInputService = game:GetService("UserInputService")
local Util = require(script.Parent.Util)

local Dragger = {}

local function parentOrigin(frame)
	local parent = frame.Parent
	if parent and parent:IsA("GuiObject") then
		return parent.AbsolutePosition
	end
	return Vector2.zero
end

function Dragger.Attach(frame, handle, maid, options)
	options = options or {}
	local threshold = options.Threshold or 4
	local margin = options.Margin or 0

	local dragging = false
	local moved = false
	local startInput = Vector2.zero
	local startCenter = Vector2.zero

	local function viewport()
		return options.Viewport and options.Viewport() or Util.Viewport()
	end

	local function applyCenter(center)
		local origin = parentOrigin(frame)
		frame.Position = UDim2.fromOffset(
			math.round(center.X - origin.X),
			math.round(center.Y - origin.Y)
		)
	end

	local function clampCenter(center)
		local view = viewport()
		local half = frame.AbsoluteSize / 2
		local x = math.clamp(center.X, half.X + margin, math.max(half.X + margin, view.X - half.X - margin))
		local y = math.clamp(center.Y, half.Y + margin, math.max(half.Y + margin, view.Y - half.Y - margin))
		return Vector2.new(x, y)
	end

	handle.Active = true

	maid:Add(handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		dragging = true
		moved = false
		startInput = Vector2.new(input.Position.X, input.Position.Y)
		startCenter = frame.AbsolutePosition + frame.AbsoluteSize / 2
		if options.OnDragStart then
			options.OnDragStart()
		end
	end))

	maid:Add(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local delta = Vector2.new(input.Position.X, input.Position.Y) - startInput
		if not moved then
			if delta.Magnitude < threshold then
				return
			end
			moved = true
		end

		applyCenter(clampCenter(startCenter + delta))
		if options.OnDrag then
			options.OnDrag()
		end
	end))

	maid:Add(UserInputService.InputEnded:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		dragging = false
		if options.OnDragEnd then
			options.OnDragEnd(moved)
		end
	end))
end

--- Re-clamps a frame's centre into the viewport (used after resizing).
function Dragger.Clamp(frame, margin)
	margin = margin or 0
	local view = Util.Viewport()
	local half = frame.AbsoluteSize / 2
	local origin = parentOrigin(frame)
	local center = frame.AbsolutePosition + half

	local x = math.clamp(center.X, half.X + margin, math.max(half.X + margin, view.X - half.X - margin))
	local y = math.clamp(center.Y, half.Y + margin, math.max(half.Y + margin, view.Y - half.Y - margin))

	frame.Position = UDim2.fromOffset(
		math.round(x - origin.X),
		math.round(y - origin.Y)
	)
end

return Dragger
