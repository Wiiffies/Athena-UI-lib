--!nolint
--[[
	Athena UI · Full showcase
	Recreates Athena's Automation screen and exercises every component.

	Use as a LocalScript (StarterPlayerScripts) or paste it into an executor.
	Press RightShift to hide/show the interface.
]]

local LIBRARY_URL = "https://raw.githubusercontent.com/Wiiffies/Athena-UI-lib/main/dist/Athena.luau"

local Athena = loadstring(game:HttpGet(LIBRARY_URL))()

local Window = Athena:CreateWindow({
	Title = "Athena",
	Theme = "Athena",
	Size = UDim2.fromOffset(880, 600),
	ToggleKey = Enum.KeyCode.RightShift,
})

Window:Notify({
	Title = "Athena loaded",
	Text = "Press RightShift to hide or show the interface.",
	Tone = "Accent",
	Duration = 6,
})

--------------------------------------------------------------------------------
-- Tabs
--------------------------------------------------------------------------------

local Automation = Window:CreateTab({ Title = "Automation", Icon = "bolt", Badge = 1 })
local General = Window:CreateTab({ Title = "General", Icon = "home" })
local Interface = Window:CreateTab({ Title = "Interface", Icon = "grid" })

--------------------------------------------------------------------------------
-- Automation · header actions
--------------------------------------------------------------------------------

Automation:AddAction({
	Name = "Pause all",
	Icon = "pause",
	Style = "Secondary",
	Callback = function()
		Window:Notify({ Title = "Paused", Text = "All automations were paused.", Tone = "Warning" })
	end,
})

Automation:AddAction({
	Name = "New automation",
	Icon = "plus",
	Style = "Primary",
	Callback = function()
		Window:Notify({ Title = "New automation", Text = "The creation flow would open here.", Tone = "Success" })
	end,
})

Automation:CreateBanner({ Text = "1 automation is running.", Icon = "dot" })

--------------------------------------------------------------------------------
-- Automation · cards
--------------------------------------------------------------------------------

Automation:CreateCard({
	Name = "Adopt Me farm",
	Description = "[UPD] Adopt Me! · Every day 00:00 to 23:59",
	Tags = { "devscripts", "1 script" },
	Status = "Opening clients",
	Actions = {
		{ Name = "Edit", Style = "Ghost", Callback = print },
	},
	Toggle = {
		Default = true,
		Callback = function(value)
			print("[Athena] Adopt Me farm enabled:", value)
		end,
	},
})

Automation:CreateCard({
	Name = "Jailbreak nights",
	Description = "[Jailbreak (Roblox Event)] · Weekdays 18:00 to 23:00",
	Tags = { "farm_01", "farm_02", "alt_main", "farm_03", "1 script" },
	Status = "Starts today at 18:00",
	Actions = {
		{ Name = "Edit", Style = "Ghost", Callback = print },
	},
	Toggle = {
		Default = true,
		Callback = function(value)
			print("[Athena] Jailbreak nights enabled:", value)
		end,
	},
})

Automation:CreateCard({
	Name = "MM2 grind",
	Description = "Murder Mystery 2 · Manual",
	Tags = { "farm_01", "farm_02", "alt_main", "1 script" },
	Status = "Ready",
	Actions = {
		{ Name = "Edit", Style = "Ghost", Callback = print },
		{
			Name = "Run",
			Style = "Primary",
			Icon = "play",
			Callback = function()
				Window:Notify({
					Title = "MM2 grind",
					Text = "Started, opening 1 client in Murder Mystery 2.",
					Tone = "Success",
				})
			end,
		},
	},
})

--------------------------------------------------------------------------------
-- Automation · activity
--------------------------------------------------------------------------------

local Activity = Automation:CreateSection({ Title = "Activity", Icon = "clock", Count = 1 })

Activity:CreateLabel({
	Text = "14:51  ·  Adopt Me farm",
	Description = "Started, opening 1 client in [UPD] Adopt Me!",
})

--------------------------------------------------------------------------------
-- General · every component
--------------------------------------------------------------------------------

local GeneralSection = General:CreateSection({ Title = "General", Icon = "gear" })

GeneralSection:CreateButton({
	Name = "Example Button",
	Description = "Runs the callback below.",
	ButtonText = "Run",
	Callback = function()
		Window:Notify({ Title = "Button", Text = "Clicked at " .. os.date("%H:%M:%S"), Tone = "Info" })
	end,
})

local toggle = GeneralSection:CreateToggle({
	Name = "Example Toggle",
	Description = "A simple on/off switch.",
	Default = false,
	Callback = function(value)
		print("[Athena] Toggle:", value)
	end,
})

local slider = GeneralSection:CreateSlider({
	Name = "Walk speed",
	Description = "Drag the track or click anywhere on it.",
	Min = 0,
	Max = 100,
	Default = 32,
	Step = 1,
	Callback = function(value)
		print("[Athena] Slider:", value)
	end,
})

local dropdown = GeneralSection:CreateDropdown({
	Name = "Region",
	Description = "Pick one of the available regions.",
	Options = { "Automatic", "Europe", "North America", "Asia" },
	Default = "Automatic",
	Callback = function(value, text)
		print("[Athena] Dropdown:", value, text)
	end,
})

local keybind = GeneralSection:CreateKeybind({
	Name = "Quick action",
	Description = "Press a key to bind it. Backspace clears.",
	Default = Enum.KeyCode.K,
	Callback = function(key)
		Window:Notify({ Title = "Keybind", Text = "Pressed " .. key.Name, Tone = "Info" })
	end,
})

local textbox = GeneralSection:CreateTextbox({
	Name = "Display name",
	Description = "Committed with Enter or focus loss.",
	Placeholder = "Type a name",
	Default = "",
	Callback = function(text, entered)
		print("[Athena] Textbox:", text, entered)
	end,
})

GeneralSection:CreateColorPicker({
	Name = "Accent color",
	Description = "HSV canvas, hue strip and hex field.",
	Default = Color3.fromRGB(242, 85, 90),
	Callback = function(color)
		print("[Athena] Color:", color, Athena.Util.ColorToHex(color))
	end,
})

GeneralSection:CreateSeparator({ Text = "Read only" })

GeneralSection:CreateLabel({
	Text = "Athena UI v" .. Athena.Version,
	Description = "Labels wrap automatically and can also show a right-hand value.",
})

GeneralSection:CreateLabel({ Text = "Theme", Value = "Athena" })
GeneralSection:CreateLabel({ Text = "Toggle state", Value = "off" })

--------------------------------------------------------------------------------
-- General · driving components from code
--------------------------------------------------------------------------------

local ApiSection = General:CreateSection({ Title = "Driving components", Icon = "code" })

ApiSection:CreateButton({
	Name = "Toggle the switch",
	ButtonText = "Set true",
	Style = "Secondary",
	Callback = function()
		toggle:Set(true)
		Window:Notify({ Title = "Toggle", Text = "Value set to true from code.", Tone = "Info" })
	end,
})

ApiSection:CreateButton({
	Name = "Set the slider",
	ButtonText = "Set 75",
	Style = "Secondary",
	Callback = function()
		slider:Set(75)
	end,
})

ApiSection:CreateButton({
	Name = "Set the dropdown",
	ButtonText = "Asia",
	Style = "Secondary",
	Callback = function()
		dropdown:Set("Asia")
	end,
})

ApiSection:CreateButton({
	Name = "Rename this keybind",
	ButtonText = "Bind G",
	Style = "Secondary",
	Callback = function()
		keybind:Set(Enum.KeyCode.G)
	end,
})

ApiSection:CreateButton({
	Name = "Write to the textbox",
	ButtonText = "Fill",
	Style = "Secondary",
	Callback = function()
		textbox:Set("Athena")
	end,
})

--------------------------------------------------------------------------------
-- Interface · notifications and window API
--------------------------------------------------------------------------------

Interface:CreateBanner({
	Text = "Notifications",
	Description = "Toasts appear in the top right and are stored in the bell panel.",
	Icon = "info",
	Tone = "Accent",
})

local NotificationSection = Interface:CreateSection({ Title = "Notifications", Icon = "bell" })

NotificationSection:CreateButton({
	Name = "Success notification",
	ButtonText = "Show",
	Callback = function()
		Window:Notify({ Title = "Saved", Text = "Your configuration was saved.", Tone = "Success" })
	end,
})

NotificationSection:CreateButton({
	Name = "Warning notification",
	ButtonText = "Show",
	Callback = function()
		Window:Notify({ Title = "Slow request", Text = "The server took longer than usual.", Tone = "Warning" })
	end,
})

NotificationSection:CreateButton({
	Name = "Error notification",
	ButtonText = "Show",
	Callback = function()
		Window:Notify({ Title = "Failed", Text = "Could not reach the endpoint.", Tone = "Error", Duration = 8 })
	end,
})

NotificationSection:CreateButton({
	Name = "Notification with a custom icon",
	ButtonText = "Show",
	Icon = "bell",
	Style = "Secondary",
	Callback = function()
		Window:Notify({ Title = "Ping", Text = "Custom icon toasts keep the same layout.", Icon = "bolt", Tone = "Accent" })
	end,
})

local WindowSection = Interface:CreateSection({ Title = "Window", Icon = "settings" })

WindowSection:CreateButton({
	Name = "Go to Automation",
	ButtonText = "Open",
	Style = "Secondary",
	Callback = function()
		Window:SelectTab(Automation)
	end,
})

WindowSection:CreateButton({
	Name = "Minimize to the corner pill",
	ButtonText = "Minimize",
	Style = "Secondary",
	Callback = function()
		Window:Minimize()
	end,
})

WindowSection:CreateButton({
	Name = "Close the interface",
	ButtonText = "Close",
	Callback = function()
		Window:Close()
	end,
})

WindowSection:CreateSeparator({ Text = "Theme" })

WindowSection:CreateLabel({
	Text = "Athena",
	Description = "Dark neutral surfaces, hairline borders, light pills, coral accent.",
})

WindowSection:CreateLabel({ Text = "Palette", Value = "Athena / Light" })
