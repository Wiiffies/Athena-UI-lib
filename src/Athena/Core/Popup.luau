--[[
	Athena UI · Core/Popup
	Shared floating surface used by dropdowns, colour pickers and panels.
	Handles positioning, clamping, fade/scale animation and outside clicks.
]]

local UserInputService = game:GetService("UserInputService")
local Util = require(script.Parent.Util)

local Popup = {}
Popup.__index = Popup

--- context = { Frame, Overlay, Theme, CloseOthers }
function Popup.New(context, options)
	options = options or {}
	local theme = context.Theme
	local width = options.Width or 220
	local height = options.Height or 200

	local popup = setmetatable({
		Context = context,
		Theme = theme,
		Width = width,
		Height = height,
		Open = false,
		Anchor = nil,
		Options = options,
	}, Popup)

	local catcher = Util.Create("TextButton", {
		Name = "AthenaPopupCatcher",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 55,
		Parent = context.Overlay,
	})

	local frame = Util.Create("CanvasGroup", {
		Name = options.Name or "AthenaPopup",
		AnchorPoint = Vector2.new(0, 0),
		Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = theme.Overlay,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 60,
		Parent = context.Overlay,
	})

	local corner = Util.Corner(frame, theme.CornerSmall)
	corner.CornerRadius = UDim.new(0, theme.CornerSmall)

	local stroke = Util.Stroke(frame, theme.Border, 1)
	stroke.Transparency = 0.05

	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = frame

	local content = Util.Create("Frame", {
		Name = "Content",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 61,
		Parent = frame,
	})
	Util.Padding(content, options.Padding or 6, options.Padding or 6, options.Padding or 6, options.Padding or 6)

	popup.Frame = frame
	popup.Content = content
	popup.Catcher = catcher
	popup.Scale = scale
	popup.Corner = corner
	popup.Stroke = stroke

	popup._maid = Util.Maid.new()
	popup._escapeConnection = nil
	popup._token = 0

	popup._maid:Add(catcher.MouseButton1Click:Connect(function()
		popup:Close()
	end))

	function popup:IsOpen()
		return self.Open
	end

	--- Clears dynamic content while keeping the popup padding.
	function popup:ResetContent()
		for _, child in ipairs(content:GetChildren()) do
			if not child:IsA("UIPadding") then
				child:Destroy()
			end
		end
	end

	function popup:SetSize(newWidth, newHeight)
		self.Width = newWidth or self.Width
		self.Height = newHeight or self.Height
		frame.Size = UDim2.fromOffset(self.Width, self.Height)
	end

	function popup:_Position(anchor)
		if not anchor then
			return
		end

		local windowFrame = context.Frame
		local scaleValue = 1
		local uiScale = windowFrame:FindFirstChildOfClass("UIScale")
		if uiScale then
			scaleValue = uiScale.Scale
		end
		if scaleValue <= 0 then
			scaleValue = 1
		end

		local windowAbs = windowFrame.AbsolutePosition
		local windowSize = windowFrame.AbsoluteSize
		local anchorAbs = anchor.AbsolutePosition
		local anchorSize = anchor.AbsoluteSize

		local relativeX = (anchorAbs.X - windowAbs.X) / scaleValue
		local relativeY = (anchorAbs.Y - windowAbs.Y) / scaleValue
		local anchorWidth = anchorSize.X / scaleValue
		local anchorHeight = anchorSize.Y / scaleValue
		local windowWidth = windowFrame.Size.X.Offset
		local windowHeight = windowFrame.Size.Y.Offset
		local gap = options.Gap or 6
		local edge = options.Edge or 8

		local x = relativeX
		local y = relativeY + anchorHeight + gap

		if options.Align == "Right" then
			x = relativeX + anchorWidth - self.Width
		elseif options.Align == "Center" then
			x = relativeX + (anchorWidth - self.Width) / 2
		end

		local maxX = math.max(edge, windowWidth - self.Width - edge)
		local maxY = math.max(edge, windowHeight - self.Height - edge)

		if y > maxY then
			local above = relativeY - self.Height - gap
			if above >= edge then
				y = above
			end
		end

		x = math.clamp(x, edge, maxX)
		y = math.clamp(y, edge, maxY)

		frame.Position = UDim2.fromOffset(math.round(x), math.round(y))
	end

	function popup:OpenAt(anchor)
		if not anchor or not frame.Parent then
			return
		end
		if context.CloseOthers then
			context.CloseOthers(self)
		end

		self._token = self._token + 1
		local token = self._token
		self.Anchor = anchor
		self.Open = true

		frame.Visible = true
		catcher.Visible = true
		scale.Scale = options.StartScale or 0.97
		frame.GroupTransparency = 1
		self:_Position(anchor)

		Util.Tween(frame, { GroupTransparency = 0 }, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		Util.Tween(scale, { Scale = 1 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		if self.Options.OnOpen then
			local ok, err = pcall(self.Options.OnOpen, self)
			if not ok then
				warn("[Athena] popup OnOpen failed: " .. tostring(err))
			end
		end

		if self._escapeConnection then
			self._escapeConnection:Disconnect()
			self._escapeConnection = nil
		end
		self._escapeConnection = UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Escape and self.Open then
				self:Close()
			end
		end)
	end

	function popup:Close(instant)
		if not self.Open and not instant then
			return
		end
		self.Open = false
		self._token = self._token + 1
		local token = self._token

		if self._escapeConnection then
			self._escapeConnection:Disconnect()
			self._escapeConnection = nil
		end

		if self.Options.OnClose then
			pcall(self.Options.OnClose, self)
		end

		if instant then
			frame.Visible = false
			catcher.Visible = false
			frame.GroupTransparency = 1
			return
		end

		Util.Tween(frame, { GroupTransparency = 1 }, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		Util.Tween(scale, { Scale = 0.98 }, 0.1)
		task.delay(0.11, function()
			if self._token == token then
				frame.Visible = false
				catcher.Visible = false
			end
		end)
	end

	function popup:Toggle(anchor)
		if self.Open then
			self:Close()
		else
			self:OpenAt(anchor)
		end
	end

	function popup:Destroy()
		self._maid:Clean()
		if self._escapeConnection then
			self._escapeConnection:Disconnect()
			self._escapeConnection = nil
		end
		frame:Destroy()
		catcher:Destroy()
	end

	return popup
end

return Popup
