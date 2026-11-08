--!nolint
--[[
	Athena · full showcase
	Recreates Athena's desktop client and exercises every component in the library.

	Use as a LocalScript in StarterPlayerScripts, or paste it into an executor.
	Press RightShift to hide or show the window.
]]

local LIBRARY_URL = "https://raw.githubusercontent.com/Wiiffies/Athena-UI-lib/main/dist/Athena.luau"

local Athena = loadstring(game:HttpGet(LIBRARY_URL))()

local Window = Athena:CreateWindow({
	Title = "Athena",
	Theme = "Athena",
	Size = UDim2.fromOffset(880, 600),
	ToggleKey = Enum.KeyCode.RightShift,
})

local function toast(title, text, tone)
	Window:Notify({ Title = title, Text = text, Tone = tone or "Info" })
end

Window:Notify({
	Title = "Athena",
	Text = "Press RightShift to hide or show the interface.",
	Tone = "Accent",
	Duration = 6,
})

--------------------------------------------------------------------------------
-- Tabs (matching Athena's navigation)
--------------------------------------------------------------------------------

local Home = Window:CreateTab({ Title = "Home", Icon = "home" })
local Editor = Window:CreateTab({ Title = "Editor", Icon = "code" })
local Hub = Window:CreateTab({ Title = "Hub", Icon = "grid" })
local Games = Window:CreateTab({ Title = "Games", Icon = "gamepad" })
local Automation = Window:CreateTab({ Title = "Automation", Icon = "bolt", Badge = 1 })
local Settings = Window:CreateTab({ Title = "Settings", Icon = "gear" })

--------------------------------------------------------------------------------
-- Home
--------------------------------------------------------------------------------

Home:CreateBanner({
	Text = "Welcome back.",
	Description = "A complete Athena interface built with the public API.",
	Icon = "home",
	Tone = "Accent",
})

local Overview = Home:CreateSection({ Title = "Overview", Icon = "pulse", Count = 2 })

Overview:CreateLabel({
	Text = "Athena",
	Description = "Desktop automation client · recreated in Luau.",
	Value = "v" .. Athena.Version,
})
Overview:CreateLabel({ Text = "Theme", Value = "Athena" })

Overview:CreateToggle({
	Name = "Launch on startup",
	Description = "Start Athena with the system.",
	Default = true,
	Callback = function(value)
		print("[Athena] Launch on startup:", value)
	end,
})

Overview:CreateSlider({
	Name = "Refresh interval",
	Description = "How often the dashboard polls.",
	Min = 1,
	Max = 30,
	Default = 5,
	Suffix = " s",
	Callback = function(value)
		print("[Athena] Refresh interval:", value)
	end,
})

Overview:CreateButton({
	Name = "Send a test notification",
	Description = "Shows a toast and records it in the bell panel.",
	ButtonText = "Notify",
	Icon = "bell",
	Callback = function()
		toast("Test notification", "Toasts stack in the top right corner.", "Info")
	end,
})

Overview:CreateButton({
	Name = "Queue three notifications",
	Description = "Fills the bell panel and pulses its unread badge.",
	ButtonText = "Send 3",
	Icon = "bell",
	Style = "Secondary",
	Callback = function()
		toast("Queued task 1", "The first client is ready.", "Info")
		toast("Queued task 2", "Waiting for a free slot.", "Warning")
		toast("Queued task 3", "Everything finished successfully.", "Success")
	end,
})

local Quick = Home:CreateSection({ Title = "Quick actions", Icon = "bolt" })

Quick:CreateButton({
	Name = "Open the hub",
	ButtonText = "Hub",
	Style = "Secondary",
	Callback = function()
		Window:SelectTab(Hub)
	end,
})

Quick:CreateButton({
	Name = "Open automation",
	ButtonText = "Automation",
	Style = "Secondary",
	Callback = function()
		Window:SelectTab(Automation)
	end,
})

Quick:CreateButton({
	Name = "Minimize to the corner pill",
	ButtonText = "Minimize",
	Style = "Secondary",
	Callback = function()
		Window:Minimize()
	end,
})

--------------------------------------------------------------------------------
-- Editor
--------------------------------------------------------------------------------

Editor:AddAction({
	Name = "Format",
	Icon = "refresh",
	Style = "Secondary",
	Callback = function()
		toast("Formatted", "The current buffer was formatted.", "Success")
	end,
})

Editor:AddAction({
	Name = "Execute",
	Icon = "play",
	Style = "Primary",
	Callback = function()
		toast("Executed", "player_esp.lua is running.", "Success")
	end,
})

Editor:CreateBanner({
	Text = "player_esp.lua",
	Description = "boxes, names and tracers for every other player",
	Icon = "code",
	Tone = "Neutral",
})

local ScriptSection = Editor:CreateSection({ Title = "Script", Icon = "code" })

local fileBox = ScriptSection:CreateTextbox({
	Name = "File name",
	Description = "Saved to the Athena workspace.",
	Default = "player_esp.lua",
	Placeholder = "script.lua",
})

local language = ScriptSection:CreateDropdown({
	Name = "Language",
	Options = { "Luau", "Lua" },
	Default = "Luau",
	Callback = function(value)
		print("[Athena] Language:", value)
	end,
})

ScriptSection:CreateKeybind({
	Name = "Execute shortcut",
	Default = Enum.KeyCode.X,
	Callback = function(key)
		toast("Keybind", "Pressed " .. key.Name .. " to execute.", "Info")
	end,
})

ScriptSection:CreateToggle({
	Name = "Auto-save",
	Description = "Save after two seconds of inactivity.",
	Default = true,
})

ScriptSection:CreateSlider({
	Name = "Font size",
	Min = 10,
	Max = 24,
	Default = 13,
	Step = 1,
	Callback = function(value)
		print("[Athena] Font size:", value)
	end,
})

ScriptSection:CreateButton({
	Name = "Run script",
	Description = "Executes the current buffer.",
	ButtonText = "Execute",
	Icon = "play",
	Callback = function()
		toast("Executed", fileBox:Get() .. " is running.", "Success")
	end,
})

ScriptSection:CreateSeparator({ Text = "Editor appearance" })

ScriptSection:CreateColorPicker({
	Name = "Selection color",
	Default = Color3.fromRGB(61, 123, 255),
	Callback = function(color)
		print("[Athena] Selection color:", Athena.Util.ColorToHex(color))
	end,
})

ScriptSection:CreateLabel({ Text = "Buffer", Value = "248 lines" })

--------------------------------------------------------------------------------
-- Hub
--------------------------------------------------------------------------------

Hub:CreateBanner({
	Text = "3 scripts available.",
	Description = "Curated by the community and ready to run.",
	Icon = "grid",
})

Hub:CreateCard({
	Name = "Player ESP",
	Description = "Boxes, names and tracers for every other player.",
	Tags = { "esp", "visuals", "1 script" },
	Status = "Updated today",
	Actions = {
		{
			Name = "Edit",
			Style = "Ghost",
			Callback = function()
				toast("Player ESP", "Opening the editor.", "Info")
			end,
		},
		{
			Name = "Run",
			Style = "Primary",
			Icon = "play",
			Callback = function()
				toast("Player ESP", "Script injected.", "Success")
			end,
		},
	},
	Toggle = {
		Default = true,
		Callback = function(value)
			print("[Athena] Player ESP enabled:", value)
		end,
	},
})

Hub:CreateCard({
	Name = "Aimbot",
	Description = "Smooth camera lock with team checks.",
	Tags = { "combat", "camera", "1 script" },
	Status = "Stable",
	Actions = {
		{
			Name = "Edit",
			Style = "Ghost",
			Callback = function()
				toast("Aimbot", "Opening the editor.", "Info")
			end,
		},
		{
			Name = "Run",
			Style = "Primary",
			Icon = "play",
			Callback = function()
				toast("Aimbot", "Script injected.", "Success")
			end,
		},
	},
	Toggle = {
		Default = false,
		Callback = function(value)
			print("[Athena] Aimbot enabled:", value)
		end,
	},
})

Hub:CreateCard({
	Name = "Auto farm",
	Description = "Collects rewards and rejoins when idle.",
	Tags = { "farm", "loop", "2 scripts" },
	Status = "Needs an update",
	Actions = {
		{
			Name = "Edit",
			Style = "Ghost",
			Callback = function()
				toast("Auto farm", "Opening the editor.", "Info")
			end,
		},
	},
	Toggle = {
		Default = false,
		Callback = function(value)
			print("[Athena] Auto farm enabled:", value)
		end,
	},
})

local Installed = Hub:CreateSection({ Title = "Installed", Icon = "check", Count = 3 })

Installed:CreateLabel({
	Text = "player_esp.lua",
	Description = "Updated 2 minutes ago",
	Value = "Enabled",
})
Installed:CreateLabel({
	Text = "aimbot.lua",
	Description = "Updated yesterday",
	Value = "Enabled",
})
Installed:CreateLabel({
	Text = "auto_farm.lua",
	Description = "Disabled by the user",
	Value = "Off",
})

--------------------------------------------------------------------------------
-- Games
--------------------------------------------------------------------------------

Games:CreateBanner({
	Text = "2 clients available.",
	Description = "Join a game with the selected client.",
	Icon = "gamepad",
})

local Target = Games:CreateSection({ Title = "Target", Icon = "gamepad" })

Target:CreateDropdown({
	Name = "Game",
	Options = { "Adopt Me!", "Jailbreak", "Murder Mystery 2", "Blox Fruits" },
	Default = "Adopt Me!",
	Callback = function(value)
		print("[Athena] Game:", value)
	end,
})

Target:CreateTextbox({
	Name = "Account",
	Description = "Leave empty to use the current account.",
	Placeholder = "username",
})

Target:CreateSlider({
	Name = "Join delay",
	Min = 0,
	Max = 30,
	Default = 3,
	Suffix = " s",
})

Target:CreateToggle({
	Name = "Private server",
	Default = false,
})

Target:CreateKeybind({
	Name = "Launch shortcut",
	Default = Enum.KeyCode.L,
	Callback = function(key)
		toast("Launch", "Pressed " .. key.Name .. " to join.", "Info")
	end,
})

Target:CreateButton({
	Name = "Launch client",
	Description = "Starts a new client and joins the game.",
	ButtonText = "Launch",
	Icon = "play",
	Callback = function()
		toast("Launching", "Opening 1 client in Adopt Me!.", "Success")
	end,
})

local Clients = Games:CreateSection({ Title = "Clients", Icon = "pulse", Count = 2 })

Clients:CreateLabel({
	Text = "Athena · account one",
	Description = "Connected to Adopt Me!",
	Value = "Online",
})
Clients:CreateLabel({
	Text = "Athena · account two",
	Description = "Waiting for a free slot",
	Value = "Idle",
})

Clients:CreateSlider({
	Name = "FPS cap",
	Min = 30,
	Max = 240,
	Default = 115,
	Step = 5,
	Suffix = " fps",
	Callback = function(value)
		print("[Athena] FPS cap:", value)
	end,
})

--------------------------------------------------------------------------------
-- Automation (the reference screen)
--------------------------------------------------------------------------------

Automation:AddAction({
	Name = "Pause all",
	Icon = "pause",
	Style = "Secondary",
	Callback = function()
		toast("Paused", "All automations were paused.", "Warning")
	end,
})

Automation:AddAction({
	Name = "New automation",
	Icon = "plus",
	Style = "Primary",
	Callback = function()
		toast("New automation", "The creation flow would open here.", "Accent")
	end,
})

Automation:CreateBanner({ Text = "1 automation is running.", Icon = "dot" })

Automation:CreateCard({
	Name = "Adopt Me farm",
	Description = "[UPD] Adopt Me! · Every day 00:00 to 23:59",
	Tags = { "devscripts", "1 script" },
	Status = "Opening clients",
	Actions = {
		{
			Name = "Edit",
			Style = "Ghost",
			Callback = function()
				toast("Adopt Me farm", "Editing the automation.", "Info")
			end,
		},
		{
			Name = "Run",
			Style = "Primary",
			Icon = "play",
			Callback = function()
				toast("Adopt Me farm", "Started, opening 1 client in Adopt Me!.", "Success")
			end,
		},
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
		{
			Name = "Edit",
			Style = "Ghost",
			Callback = function()
				toast("Jailbreak nights", "Editing the automation.", "Info")
			end,
		},
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
		{
			Name = "Edit",
			Style = "Ghost",
			Callback = function()
				toast("MM2 grind", "Editing the automation.", "Info")
			end,
		},
		{
			Name = "Run",
			Style = "Primary",
			Icon = "play",
			Callback = function()
				toast("MM2 grind", "Started, opening 1 client in Murder Mystery 2.", "Success")
			end,
		},
	},
})

local RunSettings = Automation:CreateSection({ Title = "Run settings", Icon = "gear" })

RunSettings:CreateSlider({
	Name = "Concurrent clients",
	Description = "How many clients can run at the same time.",
	Min = 1,
	Max = 8,
	Default = 3,
	Step = 1,
	Callback = function(value)
		print("[Athena] Concurrent clients:", value)
	end,
})

RunSettings:CreateDropdown({
	Name = "Execution mode",
	Description = "Choose how aggressive the scheduler should be.",
	Options = { "Balanced", "Fast", "Safe" },
	Default = "Balanced",
	Callback = function(value)
		print("[Athena] Execution mode:", value)
	end,
})

RunSettings:CreateButton({
	Name = "Run the selected automation",
	Description = "Starts it with the settings above.",
	ButtonText = "Run",
	Icon = "play",
	Callback = function()
		toast("Automation", "Started with the current run settings.", "Success")
	end,
})

local Activity = Automation:CreateSection({ Title = "Activity", Icon = "clock", Count = 1 })

Activity:CreateLabel({
	Text = "14:51 · Adopt Me farm",
	Description = "Started, opening 1 client in [UPD] Adopt Me!",
})

--------------------------------------------------------------------------------
-- Settings · every component
--------------------------------------------------------------------------------

local General = Settings:CreateSection({ Title = "General", Icon = "gear" })

General:CreateButton({
	Name = "Example Button",
	Description = "Runs the callback below.",
	ButtonText = "Run",
	Icon = "play",
	Callback = function()
		toast("Button", "Clicked at " .. os.date("%H:%M:%S") .. ".", "Info")
	end,
})

local demoToggle = General:CreateToggle({
	Name = "Example Toggle",
	Description = "A simple on/off switch.",
	Default = false,
	Callback = function(value)
		print("[Athena] Toggle:", value)
	end,
})

local demoSlider = General:CreateSlider({
	Name = "Walk speed",
	Description = "Drag the track or click anywhere on it.",
	Min = 16,
	Max = 200,
	Default = 32,
	Step = 1,
	Suffix = " spd",
	Callback = function(value)
		print("[Athena] Slider:", value)
	end,
})

local demoDropdown = General:CreateDropdown({
	Name = "Region",
	Description = "Pick one of the available regions.",
	Options = { "Automatic", "Europe", "North America", "Asia" },
	Default = "Automatic",
	Callback = function(value, text)
		print("[Athena] Dropdown:", value, text)
	end,
})

local demoKeybind = General:CreateKeybind({
	Name = "Quick action",
	Description = "Click the pill and press a key. Backspace clears.",
	Default = Enum.KeyCode.G,
	Callback = function(key)
		toast("Keybind", "Pressed " .. key.Name .. ".", "Info")
	end,
})

local demoTextbox = General:CreateTextbox({
	Name = "Display name",
	Description = "Committed with Enter or focus loss.",
	Placeholder = "Type a name",
	Default = "",
	Callback = function(text, entered)
		print("[Athena] Textbox:", text, entered)
	end,
})

General:CreateColorPicker({
	Name = "Accent color",
	Description = "HSV canvas, hue strip and hex field.",
	Default = Color3.fromRGB(242, 85, 90),
	Callback = function(color)
		print("[Athena] Color:", Athena.Util.ColorToHex(color))
	end,
})

General:CreateSeparator({ Text = "Read only" })

General:CreateLabel({
	Text = "Athena v" .. Athena.Version,
	Description = "Labels wrap automatically and can also show a right-hand value.",
})

General:CreateLabel({ Text = "Theme", Value = "Athena" })
General:CreateLabel({ Text = "Preset", Value = "Athena / Light" })

--------------------------------------------------------------------------------
-- Settings · driving components from code
--------------------------------------------------------------------------------

local ApiSection = Settings:CreateSection({ Title = "Drive components from code", Icon = "code" })

ApiSection:CreateButton({
	Name = "Turn the toggle on",
	ButtonText = "Set true",
	Style = "Secondary",
	Callback = function()
		demoToggle:Set(true)
	end,
})

ApiSection:CreateButton({
	Name = "Set the slider to 75",
	ButtonText = "Set 75",
	Style = "Secondary",
	Callback = function()
		demoSlider:Set(75)
	end,
})

ApiSection:CreateButton({
	Name = "Select Asia",
	ButtonText = "Asia",
	Style = "Secondary",
	Callback = function()
		demoDropdown:Set("Asia")
	end,
})

ApiSection:CreateButton({
	Name = "Bind the keybind to G",
	ButtonText = "Bind G",
	Style = "Secondary",
	Callback = function()
		demoKeybind:Set(Enum.KeyCode.G)
	end,
})

ApiSection:CreateButton({
	Name = "Write to the textbox",
	ButtonText = "Fill",
	Style = "Secondary",
	Callback = function()
		demoTextbox:Set("Athena")
	end,
})

ApiSection:CreateButton({
	Name = "Notification with a custom icon",
	ButtonText = "Show",
	Style = "Secondary",
	Icon = "bell",
	Callback = function()
		Window:Notify({
			Title = "Ping",
			Text = "Custom icons keep the same layout.",
			Icon = "bolt",
			Tone = "Accent",
		})
	end,
})

--------------------------------------------------------------------------------
-- Settings · window controls
--------------------------------------------------------------------------------

local WindowSection = Settings:CreateSection({ Title = "Window", Icon = "gear" })

WindowSection:CreateButton({
	Name = "Go back to Home",
	ButtonText = "Home",
	Style = "Secondary",
	Callback = function()
		Window:SelectTab(Home)
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
	Name = "Expand or restore the window",
	ButtonText = "Toggle",
	Style = "Secondary",
	Callback = function()
		Window:ToggleMaximize()
	end,
})

WindowSection:CreateButton({
	Name = "Center the window",
	ButtonText = "Center",
	Style = "Secondary",
	Callback = function()
		Window:Center()
	end,
})

WindowSection:CreateButton({
	Name = "Close the interface",
	ButtonText = "Close",
	Callback = function()
		Window:Close()
	end,
})
