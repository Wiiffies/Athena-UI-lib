--[[
	Athena · Core/Dragger
	Mouse and touch dragging with viewport clamping, aware of anchor points and UIScale.
]]

local UserInputService = game:GetService("UserInputService")
local Util = require(script.Parent.Util)

local Dragger = {}

-- A frame can have more than one handle (for example the brand and the topbar).
-- Only the first handle to receive the press should own that drag.
local activeDrags = setmetatable({}, { __mode = "k" })

local function parentOrigin(frame)
	local parent = frame.Parent
	if parent and parent:IsA("GuiObject") then
		return parent.AbsolutePosition
	end
	return Vector2.zero
end

local function setTopLeft(frame, topLeft)
	local origin = parentOrigin(frame)
	local size = frame.AbsoluteSize
	local anchor = frame.AnchorPoint
	frame.Position = UDim2.fromOffset(
		topLeft.X - origin.X + size.X * anchor.X,
		topLeft.Y - origin.Y + size.Y * anchor.Y
	)
end

local function clampTopLeft(frame, topLeft, margin, topMargin, view)
	local size = frame.AbsoluteSize
	local maxX = math.max(margin, view.X - size.X - margin)
	local maxY = math.max(topMargin, view.Y - size.Y - margin)
	return Vector2.new(
		math.clamp(topLeft.X, margin, maxX),
		math.clamp(topLeft.Y, topMargin, maxY)
	)
end

function Dragger.Attach(frame, handle, maid, options)
	options = options or {}
	local threshold = options.Threshold or 4
	local margin = options.Margin or 0
	local topMargin = options.TopMargin or margin

	local dragging = false
	local moved = false
	local startInput = Vector2.zero
	local startTopLeft = Vector2.zero

	local function viewport()
		return options.Viewport and options.Viewport() or Util.Viewport()
	end

	handle.Active = true

	maid:Add(handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		if activeDrags[frame] then
			return
		end

		activeDrags[frame] = true
		dragging = true
		moved = false
		startInput = Vector2.new(input.Position.X, input.Position.Y)
		startTopLeft = frame.AbsolutePosition
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
			if options.OnDragBegin then
				options.OnDragBegin()
			end
		end

		local target = clampTopLeft(
			frame,
			startTopLeft + delta,
			margin,
			topMargin,
			viewport()
		)
		setTopLeft(frame, target)
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
		activeDrags[frame] = nil
		if options.OnDragEnd then
			options.OnDragEnd(moved)
		end
	end))
end

--- Re-clamps a frame's absolute top-left into the viewport (used after resizing).
function Dragger.Clamp(frame, margin, topMargin)
	margin = margin or 0
	topMargin = topMargin or margin
	local view = Util.Viewport()
	setTopLeft(frame, clampTopLeft(frame, frame.AbsolutePosition, margin, topMargin, view))
end

return Dragger
