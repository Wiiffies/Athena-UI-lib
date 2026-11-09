--[[
	Athena
	A close recreation of the Athena client interface for Roblox, written in
	Luau with no dependencies; icons use public Lucide image assets.

	Usage:
		local Athena = loadstring(game:HttpGet("..."))()
		local Window = Athena:CreateWindow({
			Title = "My Application",
			DynamicIsland = { Enabled = true },
		})
		Window:SetDynamicIslandEnabled(true)
		local Tab = Window:CreateTab("Main")
		Tab:CreateSection("General"):CreateButton({ Name = "Example", Callback = print })
]]

local Players = game:GetService("Players")

local Theme = require(script.Core.Theme)
local Util = require(script.Core.Util)
local Notifications = require(script.Notifications)
local Window = require(script.Window)

local Athena = {}

Athena.Version = "1.2.0"
Athena.Themes = Theme.Presets

Athena._windows = {}
Athena._gui = nil
Athena._parent = nil
Athena._theme = Theme.Resolve("Athena")

local function resolveParent()
	if Athena._parent then
		return Athena._parent
	end

	local player = Players.LocalPlayer
	if player then
		local playerGui = player:FindFirstChildOfClass("PlayerGui")
		if playerGui then
			return playerGui
		end
	end

	local ok, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and coreGui then
		return coreGui
	end

	return nil
end

function Athena:_EnsureGui()
	if self._gui and self._gui.Parent then
		if self._notifications == nil then
			self._notifications = Notifications.new(self, self._gui, self._theme)
		end
		return self._gui
	end

	local parent = resolveParent()
	if not parent then
		error("[Athena] No PlayerGui available. Pass Parent = <instance> to CreateWindow.", 3)
	end

	-- Re-executing an executor script used to leave the previous Athena GUI
	-- behind, including an open quick menu. Remove stale copies before making
	-- this run's GUI.
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "Athena" and child ~= self._gui then
			child:Destroy()
		end
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "Athena"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 999
	gui.Parent = parent

	self._gui = gui

	if self._notifications then
		self._notifications:Destroy()
	end
	self._notifications = Notifications.new(self, gui, self._theme)

	return gui
end

--- Creates a new window. All options are optional.
function Athena:CreateWindow(options)
	options = options or {}
	if options.Parent then
		self._parent = options.Parent
	end

	self:_EnsureGui()

	local window = Window.new(self, options)
	self._windows[window] = true
	return window
end

--- Shows a stacked toast notification and records it in the bell panel.
function Athena:Notify(options)
	self:_EnsureGui()
	return self._notifications:Notify(options)
end

--- Changes the theme used by notifications and windows created afterwards.
function Athena:SetTheme(theme)
	self._theme = Theme.Resolve(theme)
	if self._notifications then
		self._notifications.Theme = self._theme
	end
	return self._theme
end

function Athena:GetWindows()
	local list = {}
	for window in pairs(self._windows) do
		table.insert(list, window)
	end
	return list
end

function Athena:_RemoveWindow(window)
	self._windows[window] = nil

	if next(self._windows) == nil then
		if self._notifications then
			self._notifications:Destroy()
			self._notifications = nil
		end
		if self._gui then
			self._gui:Destroy()
			self._gui = nil
		end
	end
end

--- Removes every window, notification and the ScreenGui.
function Athena:Destroy()
	local windows = {}
	for window in pairs(self._windows) do
		table.insert(windows, window)
	end

	for _, window in ipairs(windows) do
		pcall(function()
			window:Destroy()
		end)
	end
	self._windows = {}

	if self._notifications then
		self._notifications:Destroy()
		self._notifications = nil
	end
	if self._gui then
		self._gui:Destroy()
		self._gui = nil
	end
end

Athena.Util = Util

return Athena
