--[[
	Athena · Core/Icons
	Icons are drawn from primitives so the library needs no image assets.
	Every icon is a normalised spec (0-1 coordinates) rendered into a square.
]]

local Icons = {}

-- Holders are square unless the mark needs a wider canvas.
local ASPECT = {
	athena = 1.52,
}

-- Each part: bar = rounded rectangle, ring = stroked circle,
-- tri = right pointing triangle built from a clipped rotated square.
local SPECS = {
	close = {
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.74, h = 0.115, rot = 45 },
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.74, h = 0.115, rot = -45 },
	},
	plus = {
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.7, h = 0.115 },
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.115, h = 0.7 },
	},
	minus = {
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.7, h = 0.115 },
	},
	maximize = {
		{ kind = "ring", x = 0.5, y = 0.5, w = 0.66, h = 0.66, thickness = 0.1, corner = 0.16 },
	},
	check = {
		{ kind = "bar", x = 0.31, y = 0.55, w = 0.34, h = 0.13, rot = 45 },
		{ kind = "bar", x = 0.63, y = 0.43, w = 0.58, h = 0.13, rot = -48 },
	},
	chevronDown = {
		{ kind = "bar", x = 0.33, y = 0.52, w = 0.4, h = 0.115, rot = 45 },
		{ kind = "bar", x = 0.67, y = 0.52, w = 0.4, h = 0.115, rot = -45 },
	},
	chevronUp = {
		{ kind = "bar", x = 0.33, y = 0.48, w = 0.4, h = 0.115, rot = -45 },
		{ kind = "bar", x = 0.67, y = 0.48, w = 0.4, h = 0.115, rot = 45 },
	},
	chevronRight = {
		{ kind = "bar", x = 0.44, y = 0.34, w = 0.4, h = 0.115, rot = 45 },
		{ kind = "bar", x = 0.44, y = 0.66, w = 0.4, h = 0.115, rot = -45 },
	},
	chevronLeft = {
		{ kind = "bar", x = 0.56, y = 0.34, w = 0.4, h = 0.115, rot = -45 },
		{ kind = "bar", x = 0.56, y = 0.66, w = 0.4, h = 0.115, rot = 45 },
	},
	search = {
		{ kind = "ring", x = 0.43, y = 0.43, w = 0.62, h = 0.62, thickness = 0.1 },
		{ kind = "bar", x = 0.79, y = 0.79, w = 0.3, h = 0.11, rot = 45 },
	},
	bell = {
		{ kind = "bar", x = 0.5, y = 0.4, w = 0.5, h = 0.44, corner = 0.6 },
		{ kind = "bar", x = 0.5, y = 0.64, w = 0.72, h = 0.11 },
		{ kind = "bar", x = 0.5, y = 0.8, w = 0.16, h = 0.16 },
	},
	home = {
		{ kind = "bar", x = 0.3, y = 0.33, w = 0.38, h = 0.11, rot = 45 },
		{ kind = "bar", x = 0.7, y = 0.33, w = 0.38, h = 0.11, rot = -45 },
		{ kind = "bar", x = 0.5, y = 0.65, w = 0.52, h = 0.36, corner = 0.14 },
	},
	code = {
		{ kind = "bar", x = 0.3, y = 0.35, w = 0.32, h = 0.11, rot = 45 },
		{ kind = "bar", x = 0.3, y = 0.65, w = 0.32, h = 0.11, rot = -45 },
		{ kind = "bar", x = 0.7, y = 0.35, w = 0.32, h = 0.11, rot = -45 },
		{ kind = "bar", x = 0.7, y = 0.65, w = 0.32, h = 0.11, rot = 45 },
	},
	grid = {
		{ kind = "bar", x = 0.29, y = 0.29, w = 0.34, h = 0.34, corner = 0.14 },
		{ kind = "bar", x = 0.71, y = 0.29, w = 0.34, h = 0.34, corner = 0.14 },
		{ kind = "bar", x = 0.29, y = 0.71, w = 0.34, h = 0.34, corner = 0.14 },
		{ kind = "bar", x = 0.71, y = 0.71, w = 0.34, h = 0.34, corner = 0.14 },
	},
	gamepad = {
		{ kind = "ring", x = 0.5, y = 0.52, w = 0.92, h = 0.58, thickness = 0.1, corner = 0.3 },
		{ kind = "bar", x = 0.28, y = 0.52, w = 0.22, h = 0.1 },
		{ kind = "bar", x = 0.28, y = 0.52, w = 0.1, h = 0.22 },
		{ kind = "bar", x = 0.72, y = 0.44, w = 0.12, h = 0.12 },
		{ kind = "bar", x = 0.72, y = 0.62, w = 0.12, h = 0.12 },
	},
	pulse = {
		{ kind = "bar", x = 0.26, y = 0.62, w = 0.12, h = 0.3 },
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.12, h = 0.56 },
		{ kind = "bar", x = 0.74, y = 0.58, w = 0.12, h = 0.4 },
	},
	bolt = {
		{ kind = "bar", x = 0.42, y = 0.3, w = 0.42, h = 0.12, rot = 42 },
		{ kind = "bar", x = 0.58, y = 0.7, w = 0.42, h = 0.12, rot = 42 },
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.12, h = 0.42 },
	},
	gear = {
		{ kind = "ring", x = 0.5, y = 0.5, w = 0.56, h = 0.56, thickness = 0.11 },
		{ kind = "bar", x = 0.5, y = 0.11, w = 0.16, h = 0.18, corner = 0.3 },
		{ kind = "bar", x = 0.5, y = 0.89, w = 0.16, h = 0.18, corner = 0.3 },
		{ kind = "bar", x = 0.11, y = 0.5, w = 0.18, h = 0.16, corner = 0.3 },
		{ kind = "bar", x = 0.89, y = 0.5, w = 0.18, h = 0.16, corner = 0.3 },
		{ kind = "bar", x = 0.22, y = 0.22, w = 0.16, h = 0.16, rot = 45, corner = 0.3 },
		{ kind = "bar", x = 0.78, y = 0.22, w = 0.16, h = 0.16, rot = 45, corner = 0.3 },
		{ kind = "bar", x = 0.22, y = 0.78, w = 0.16, h = 0.16, rot = 45, corner = 0.3 },
		{ kind = "bar", x = 0.78, y = 0.78, w = 0.16, h = 0.16, rot = 45, corner = 0.3 },
	},
	clock = {
		{ kind = "ring", x = 0.5, y = 0.5, w = 0.82, h = 0.82, thickness = 0.1 },
		{ kind = "bar", x = 0.5, y = 0.4, w = 0.09, h = 0.26 },
		{ kind = "bar", x = 0.58, y = 0.52, w = 0.09, h = 0.2, rot = 90 },
	},
	dot = {
		{ kind = "bar", x = 0.5, y = 0.5, w = 0.5, h = 0.5 },
	},
	pause = {
		{ kind = "bar", x = 0.33, y = 0.5, w = 0.16, h = 0.62, corner = 0.2 },
		{ kind = "bar", x = 0.67, y = 0.5, w = 0.16, h = 0.62, corner = 0.2 },
	},
	play = {
		{ kind = "tri", x = 0.24, y = 0.5, w = 0.56, h = 0.7 },
	},
	refresh = {
		{ kind = "ring", x = 0.5, y = 0.5, w = 0.68, h = 0.68, thickness = 0.1 },
		{ kind = "bar", x = 0.76, y = 0.24, w = 0.22, h = 0.12, rot = 30 },
		{ kind = "bar", x = 0.76, y = 0.24, w = 0.12, h = 0.2, rot = 30 },
	},
	info = {
		{ kind = "ring", x = 0.5, y = 0.5, w = 0.84, h = 0.84, thickness = 0.1 },
		{ kind = "bar", x = 0.5, y = 0.3, w = 0.13, h = 0.13 },
		{ kind = "bar", x = 0.5, y = 0.6, w = 0.1, h = 0.32 },
	},
	warning = {
		{ kind = "bar", x = 0.5, y = 0.48, w = 0.62, h = 0.11, rot = -60 },
		{ kind = "bar", x = 0.5, y = 0.48, w = 0.62, h = 0.11, rot = 60 },
		{ kind = "bar", x = 0.5, y = 0.3, w = 0.62, h = 0.11 },
		{ kind = "bar", x = 0.5, y = 0.68, w = 0.09, h = 0.14 },
	},
	trash = {
		{ kind = "bar", x = 0.5, y = 0.24, w = 0.72, h = 0.1 },
		{ kind = "bar", x = 0.5, y = 0.45, w = 0.54, h = 0.4, corner = 0.12 },
		{ kind = "bar", x = 0.5, y = 0.17, w = 0.26, h = 0.1, corner = 0.2 },
	},
	athena = {
		-- The two legs of the A meet at the apex.
		{ kind = "bar", x = 0.362, y = 0.505, w = 0.095, h = 1.12, rot = 30 },
		{ kind = "bar", x = 0.638, y = 0.505, w = 0.095, h = 1.12, rot = -30 },
		-- Wings sweeping out from the crossbar, as in getathena.gg/logo.png.
		{ kind = "bar", x = 0.17, y = 0.395, w = 0.36, h = 0.16, rot = 23 },
		{ kind = "bar", x = 0.83, y = 0.395, w = 0.36, h = 0.16, rot = -23 },
		-- Lower blades that frame the counter.
		{ kind = "bar", x = 0.305, y = 0.625, w = 0.1, h = 0.24, rot = 38 },
		{ kind = "bar", x = 0.695, y = 0.625, w = 0.1, h = 0.24, rot = -38 },
	},
}

Icons.Names = {}
for name in pairs(SPECS) do
	table.insert(Icons.Names, name)
end
table.sort(Icons.Names)

local function newPart(holder, spec, size, color, zIndex)
	local part
	if spec.kind == "ring" then
		part = Instance.new("Frame")
		part.BackgroundTransparency = 1
		part.Size = UDim2.fromScale(spec.w, spec.h)
		part.Position = UDim2.fromScale(spec.x, spec.y)
		part.AnchorPoint = Vector2.new(0.5, 0.5)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(spec.corner or 1, 0)
		corner.Parent = part
		local stroke = Instance.new("UIStroke")
		stroke.Color = color
		stroke.Thickness = math.max(1, (spec.thickness or 0.1) * size)
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = part
		part.ZIndex = zIndex
		part.Parent = holder
		return part
	elseif spec.kind == "tri" then
		local clip = Instance.new("Frame")
		clip.BackgroundTransparency = 1
		clip.ClipsDescendants = true
		clip.Size = UDim2.fromScale(spec.w, spec.h)
		clip.Position = UDim2.fromScale(spec.x, spec.y)
		clip.AnchorPoint = Vector2.new(0.5, 0.5)
		clip.ZIndex = zIndex
		clip.Parent = holder

		local diamond = Instance.new("Frame")
		diamond.Size = UDim2.fromScale(0.72, 0.72)
		diamond.AnchorPoint = Vector2.new(0.5, 0.5)
		diamond.Position = UDim2.fromScale(0, 0.5)
		diamond.Rotation = 45
		diamond.BackgroundColor3 = color
		diamond.BorderSizePixel = 0
		diamond.ZIndex = zIndex
		diamond.Parent = clip
		return clip
	end

	part = Instance.new("Frame")
	part.BackgroundColor3 = color
	part.BorderSizePixel = 0
	part.Size = UDim2.fromScale(spec.w, spec.h)
	part.Position = UDim2.fromScale(spec.x, spec.y)
	part.AnchorPoint = Vector2.new(0.5, 0.5)
	part.Rotation = spec.rot or 0
	part.ZIndex = zIndex
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(spec.corner or 1, 0)
	corner.Parent = part
	part.Parent = holder
	return part
end

--- Renders an icon into a new holder frame.
function Icons.New(name, size, color, parent, zIndex)
	size = size or 14
	color = color or Color3.new(1, 1, 1)

	local holder = Instance.new("Frame")
	holder.Name = "Icon_" .. tostring(name)
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromOffset(size * (ASPECT[name] or 1), size)
	holder.ZIndex = zIndex or 1
	holder.Parent = parent

	local spec = SPECS[name]
	local parts = {}
	if spec then
		for _, partSpec in ipairs(spec) do
			table.insert(parts, newPart(holder, partSpec, size, color, zIndex or 1))
		end
	end

	local icon = {
		Frame = holder,
		Name = name,
		Size = size,
		Color = color,
	}

	function icon:SetColor(newColor)
		self.Color = newColor
		for _, part in ipairs(parts) do
			if part:IsA("Frame") then
				local stroke = part:FindFirstChildOfClass("UIStroke")
				if stroke then
					stroke.Color = newColor
				end
				if part.BackgroundTransparency < 1 then
					part.BackgroundColor3 = newColor
				end
				for _, child in ipairs(part:GetChildren()) do
					if child:IsA("Frame") then
						child.BackgroundColor3 = newColor
					end
				end
			end
		end
	end

	function icon:Destroy()
		holder:Destroy()
	end

	return icon
end

return Icons
