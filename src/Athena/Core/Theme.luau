--[[
	Athena · Core/Theme
	Design tokens recreated from the Athena client (dark neutral surfaces,
	hairline borders, light primary pills, monochrome accents).
]]

local Theme = {}

local function font(names, fallback)
	for _, name in ipairs(names) do
		local ok, value = pcall(function()
			return Enum.Font[name]
		end)
		if ok and value then
			return value
		end
	end
	return fallback
end

local Gotham = font({ "Gotham", "SourceSans" }, Enum.Font.SourceSans)
local GothamMedium = font({ "GothamMedium", "Gotham", "SourceSansSemibold" }, Gotham)
local GothamBold = font({ "GothamBold", "Gotham", "SourceSansBold" }, Gotham)
local Mono = font({ "RobotoMono", "Code" }, Enum.Font.Code)

Theme.Presets = {
	Athena = {
		Name = "Athena",

		-- Surfaces
		Window = Color3.fromRGB(19, 20, 22),
		WindowTop = Color3.fromRGB(21, 22, 25),
		Surface = Color3.fromRGB(26, 27, 30),
		SurfaceAlt = Color3.fromRGB(32, 34, 38),
		SurfaceHover = Color3.fromRGB(39, 41, 46),
		SurfaceActive = Color3.fromRGB(45, 47, 53),
		Overlay = Color3.fromRGB(23, 24, 27),

		-- Lines
		Border = Color3.fromRGB(44, 46, 51),
		BorderSoft = Color3.fromRGB(33, 35, 39),
		Highlight = Color3.fromRGB(255, 255, 255),

		-- Type
		Text = Color3.fromRGB(237, 238, 240),
		TextSoft = Color3.fromRGB(163, 163, 168),
		TextMuted = Color3.fromRGB(122, 127, 135),
		TextFaint = Color3.fromRGB(96, 100, 107),

		-- Monochrome accents (white on dark, black on light)
		Accent = Color3.fromRGB(238, 240, 242),
		AccentText = Color3.fromRGB(14, 15, 18),
		AccentSoft = Color3.fromRGB(32, 34, 38),
		Success = Color3.fromRGB(238, 240, 242),
		Warning = Color3.fromRGB(238, 240, 242),
		Error = Color3.fromRGB(238, 240, 242),
		Info = Color3.fromRGB(238, 240, 242),

		-- Controls
		Primary = Color3.fromRGB(238, 240, 242),
		PrimaryHover = Color3.fromRGB(255, 255, 255),
		PrimaryText = Color3.fromRGB(14, 15, 18),
		Track = Color3.fromRGB(48, 50, 56),
		TrackFill = Color3.fromRGB(238, 240, 242),
		ToggleOn = Color3.fromRGB(238, 240, 242),
		ToggleOff = Color3.fromRGB(41, 43, 48),
		Knob = Color3.fromRGB(148, 152, 160),
		KnobOn = Color3.fromRGB(14, 15, 18),
		Chip = Color3.fromRGB(34, 36, 40),
		Scrim = Color3.fromRGB(5, 5, 6),

		-- Type settings
		Font = Gotham,
		FontMedium = GothamMedium,
		FontBold = GothamBold,
		FontMono = Mono,
		TextSize = 13,
		TextSizeSmall = 11,
		TextSizeTitle = 30,

		-- Metrics
		Corner = 14,
		CornerCard = 12,
		CornerSmall = 9,
		CornerChip = 6,
		TopbarHeight = 56,

		-- Motion
		Speed = 0.15,
		SpeedSlow = 0.3,
	},

	Light = {
		Name = "Light",

		Window = Color3.fromRGB(247, 247, 249),
		WindowTop = Color3.fromRGB(250, 250, 252),
		Surface = Color3.fromRGB(255, 255, 255),
		SurfaceAlt = Color3.fromRGB(242, 243, 246),
		SurfaceHover = Color3.fromRGB(234, 236, 240),
		SurfaceActive = Color3.fromRGB(226, 228, 233),
		Overlay = Color3.fromRGB(252, 252, 253),

		Border = Color3.fromRGB(222, 224, 230),
		BorderSoft = Color3.fromRGB(233, 235, 239),
		Highlight = Color3.fromRGB(0, 0, 0),

		Text = Color3.fromRGB(22, 23, 26),
		TextSoft = Color3.fromRGB(84, 88, 96),
		TextMuted = Color3.fromRGB(116, 121, 130),
		TextFaint = Color3.fromRGB(142, 146, 154),

		Accent = Color3.fromRGB(22, 23, 26),
		AccentText = Color3.fromRGB(247, 247, 249),
		AccentSoft = Color3.fromRGB(242, 243, 246),
		Success = Color3.fromRGB(22, 23, 26),
		Warning = Color3.fromRGB(22, 23, 26),
		Error = Color3.fromRGB(22, 23, 26),
		Info = Color3.fromRGB(22, 23, 26),

		Primary = Color3.fromRGB(22, 23, 26),
		PrimaryHover = Color3.fromRGB(38, 40, 45),
		PrimaryText = Color3.fromRGB(247, 247, 249),
		Track = Color3.fromRGB(216, 219, 225),
		TrackFill = Color3.fromRGB(22, 23, 26),
		ToggleOn = Color3.fromRGB(22, 23, 26),
		ToggleOff = Color3.fromRGB(226, 228, 233),
		Knob = Color3.fromRGB(150, 154, 162),
		KnobOn = Color3.fromRGB(250, 250, 252),
		Chip = Color3.fromRGB(242, 243, 246),
		Scrim = Color3.fromRGB(255, 255, 255),
	},
}

--- Resolves a preset name (or a custom table) into a complete theme.
function Theme.Resolve(input, overrides)
	local base = Theme.Presets.Athena
	if type(input) == "string" then
		base = Theme.Presets[input] or base
	elseif type(input) == "table" then
		base = input
	end

	local resolved = {}
	for key, value in pairs(Theme.Presets.Athena) do
		resolved[key] = value
	end
	for key, value in pairs(base) do
		resolved[key] = value
	end
	if type(overrides) == "table" then
		for key, value in pairs(overrides) do
			resolved[key] = value
		end
	end

	resolved.Name = resolved.Name or "Athena"
	return resolved
end

return Theme
