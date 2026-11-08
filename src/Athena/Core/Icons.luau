--[[
	Athena · Core/Icons
	Lucide image assets (public Roblox IDs) for UI glyphs, plus the original
	Athena vector brand mark. UI icons are authored by Lucide, not drawn here.
]]

local TweenService = game:GetService("TweenService")

local Icons = {}

-- Holders are square unless the mark needs a wider canvas.
local ASPECT = {
	athena = 1.52,
}

-- One asset per icon. These are the Lucide Roblox IDs used by Fluent/LucidIcons.
local ASSETS = {
	-- `athena` intentionally stays on the original vector mark; the brand logo
	-- is not a Lucide glyph.
	bolt = "rbxassetid://109718589733073", -- zap
	pause = "rbxassetid://10734919336",
	play = "rbxassetid://10734923549",
	refresh = "rbxassetid://10734933222", -- refresh-cw
	gear = "rbxassetid://10734950309", -- settings
	clock = "rbxassetid://10709805144",
	dot = "rbxassetid://10709798174", -- circle
	pulse = "rbxassetid://10709752035", -- activity
	home = "rbxassetid://10723407389",
	code = "rbxassetid://10709807111", -- code-2
	grid = "rbxassetid://10723424838", -- layout-grid
	gamepad = "rbxassetid://10723395215", -- gamepad-2
	search = "rbxassetid://10734943674",
	bell = "rbxassetid://10709775704",
	close = "rbxassetid://10747384394", -- x
	check = "rbxassetid://10709790644",
	plus = "rbxassetid://10734924532",
	minus = "rbxassetid://10734896206",
	maximize = "rbxassetid://10734886496", -- maximize-2
	minimize = "rbxassetid://10734895530", -- minimize-2
	square = "rbxassetid://10734965702",
	chevronDown = "rbxassetid://10709790948",
	chevronUp = "rbxassetid://10709791523",
	chevronRight = "rbxassetid://10709791437",
	chevronLeft = "rbxassetid://102314312897830",
	info = "rbxassetid://10723415903",
	warning = "rbxassetid://10709753149", -- alert-triangle
	trash = "rbxassetid://10747362241", -- trash-2
	terminal = "rbxassetid://10734982144",
	command = "rbxassetid://10709811365",
	keyboard = "rbxassetid://10723416765",
	sliders = "rbxassetid://10734963400", -- sliders-horizontal
	edit = "rbxassetid://10734883598",
	copy = "rbxassetid://10709812159",
	eye = "rbxassetid://10723346959",
	lock = "rbxassetid://10723434711",
	unlock = "rbxassetid://10747366027",
	power = "rbxassetid://10734930466",
	download = "rbxassetid://10723344270",
	upload = "rbxassetid://10747366434",
	save = "rbxassetid://10734941499",
	folder = "rbxassetid://10723387563",
	file = "rbxassetid://10723356507", -- file-code
	image = "rbxassetid://10723415040",
	camera = "rbxassetid://10709789686",
	video = "rbxassetid://10747374938",
	music = "rbxassetid://10734905958",
	server = "rbxassetid://10734949856",
	database = "rbxassetid://10709818996",
	cloud = "rbxassetid://10709806740",
	wifi = "rbxassetid://10747382504",
	bug = "rbxassetid://10709782845",
	gitBranch = "rbxassetid://10723396676",
	globe = "rbxassetid://10723404337",
	map = "rbxassetid://10734886202",
	compass = "rbxassetid://10709811445",
	target = "rbxassetid://10734977012",
	rocket = "rbxassetid://10734934585",
	star = "rbxassetid://10734966248",
	heart = "rbxassetid://10723406885",
	flame = "rbxassetid://10723376114",
	sparkles = "rbxassetid://105634041692696",
	loader = "rbxassetid://10723434070",
	arrowRight = "rbxassetid://10709768347",
	arrowLeft = "rbxassetid://10709768114",
	arrowUp = "rbxassetid://10709768939",
	arrowDown = "rbxassetid://10709767827",
}

Icons.Assets = ASSETS

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
		-- Outline bell in the same thin style as the search and gear icons.
		{ kind = "ring", x = 0.5, y = 0.12, w = 0.1, h = 0.1, thickness = 0.12 },
		{ kind = "ring", x = 0.5, y = 0.45, w = 0.56, h = 0.6, thickness = 0.1, corner = 1 },
		{ kind = "bar", x = 0.5, y = 0.7, w = 0.78, h = 0.1, corner = 0.5 },
		{ kind = "bar", x = 0.5, y = 0.82, w = 0.16, h = 0.14, corner = 0.6 },
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
for name in pairs(ASSETS) do
	if not SPECS[name] then
		table.insert(Icons.Names, name)
	end
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

	local asset = ASSETS[name]
	local spec = SPECS[name]
	if not asset and not spec then
		asset = ASSETS.dot
	end

	local holder = Instance.new("Frame")
	holder.Name = "Icon_" .. tostring(name)
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromOffset(size * (asset and 1 or (ASPECT[name] or 1)), size)
	holder.ZIndex = zIndex or 1
	holder.Parent = parent

	local iconScale = Instance.new("UIScale")
	iconScale.Name = "IconScale"
	iconScale.Scale = 1
	iconScale.Parent = holder

	local image
	local parts = {}
	if asset then
		image = Instance.new("ImageLabel")
		image.Name = "Asset"
		image.Size = UDim2.fromScale(1, 1)
		image.BackgroundTransparency = 1
		image.BorderSizePixel = 0
		image.Image = asset
		image.ImageColor3 = color
		image.ScaleType = Enum.ScaleType.Fit
		image.ZIndex = zIndex or 1
		image.Parent = holder
	elseif spec then
		for _, partSpec in ipairs(spec) do
			table.insert(parts, newPart(holder, partSpec, size, color, zIndex or 1))
		end
	end

	local icon = {
		Frame = holder,
		Image = image,
		Scale = iconScale,
		Name = name,
		Size = size,
		Color = color,
	}

	function icon:SetColor(newColor)
		self.Color = newColor
		if self.Image then
			self.Image.ImageColor3 = newColor
		end
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

	function icon:SetTransparency(value)
		value = math.clamp(value or 0, 0, 1)
		if self.Image then
			self.Image.ImageTransparency = value
		end
		for _, part in ipairs(parts) do
			if part:IsA("Frame") then
				part.BackgroundTransparency = value
				local stroke = part:FindFirstChildOfClass("UIStroke")
				if stroke then
					stroke.Transparency = value
				end
			end
		end
	end

	function icon:Pulse(peak, duration)
		if not self.Scale or not self.Scale.Parent then
			return
		end
		peak = peak or 1.16
		duration = duration or 0.22
		self.Scale.Scale = 1
		TweenService:Create(
			self.Scale,
			TweenInfo.new(duration * 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Scale = peak }
		):Play()
		task.delay(duration * 0.35, function()
			if self.Scale and self.Scale.Parent then
				TweenService:Create(
					self.Scale,
					TweenInfo.new(duration * 0.65, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Scale = 1 }
				):Play()
			end
		end)
	end

	function icon:Destroy()
		holder:Destroy()
	end

	-- Every icon inside a button responds to hover and press. Components keep
	-- their own motion; this adds the fine, tactile layer on top.
	if parent and parent:IsA("GuiButton") then
		local function tweenScale(target, duration)
			if not iconScale.Parent then
				return
			end
			TweenService:Create(
				iconScale,
				TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Scale = target }
			):Play()
		end

		local connections = {
			parent.MouseEnter:Connect(function()
				tweenScale(1.14, 0.16)
			end),
			parent.MouseLeave:Connect(function()
				tweenScale(1, 0.16)
			end),
			parent.MouseButton1Down:Connect(function()
				tweenScale(0.88, 0.07)
			end),
			parent.MouseButton1Up:Connect(function()
				tweenScale(1.14, 0.18)
			end),
		}

		holder.Destroying:Once(function()
			for _, connection in ipairs(connections) do
				connection:Disconnect()
			end
		end)
	end

	return icon
end

return Icons
