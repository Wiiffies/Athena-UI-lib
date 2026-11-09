--[[
	Athena · Core/Executor
	Detects the host executor and records the capabilities that feature gates
	can check without probing or running user code.
]]

local Executor = {}

local KNOWN_PROFILES = {
	["synapse x"] = "Full",
	["script-ware"] = "Full",
	["krnl"] = "Full",
	["fluxus"] = "Full",
	["delta"] = "Full",
	["solara"] = "Full",
	["xeno"] = "Full",
	["wave"] = "Full",
	["arceus x"] = "Limited",
	["hydrogen"] = "Limited",
	["codex"] = "Full",
	["electron"] = "Full",
	["sirhurt"] = "Full",
	["awp"] = "Full",
	["valyse"] = "Full",
	["vega"] = "Full",
	["swift"] = "Limited",
	["bunny"] = "Full",
	["nihon"] = "Full",
}

local function environment()
	local ok, env = pcall(function()
		return getfenv(0)
	end)
	if ok and type(env) == "table" then
		return env
	end
	return _G
end

local function readGlobal(name)
	local env = environment()
	if type(env) == "table" then
		local ok, value = pcall(function()
			return env[name]
		end)
		if ok then
			return value
		end
	end

	local ok, value = pcall(function()
		return _G[name]
	end)
	if ok then
		return value
	end
	return nil
end

local function hasGlobal(name)
	return type(readGlobal(name)) == "function"
end

local function hasMethod(object, name)
	if not object then
		return false
	end
	local ok, value = pcall(function()
		return object[name]
	end)
	return ok and type(value) == "function"
end

local function readName()
	for _, name in ipairs({ "identifyexecutor", "getexecutorname" }) do
		local detect = readGlobal(name)
		if type(detect) == "function" then
			local ok, result = pcall(detect)
			if ok and type(result) == "string" and result ~= "" then
				return result
			end
		end
	end
	return "Unknown"
end

function Executor.normalize(name)
	if type(name) ~= "string" then
		return ""
	end
	local normalized = string.lower(name)
	normalized = string.gsub(normalized, "%s+", " ")
	normalized = string.gsub(normalized, "^%s+", "")
	normalized = string.gsub(normalized, "%s+$", "")
	return normalized
end

local function profileFor(normalized)
	for name, profile in pairs(KNOWN_PROFILES) do
		if normalized == name or string.find(normalized, name, 1, true) ~= nil then
			return profile
		end
	end
	return nil
end

function Executor.Detect()
	local name = readName()
	local normalized = Executor.normalize(name)
	local capabilities = {
		Loadstring = hasGlobal("loadstring"),
		HttpGet = hasMethod(game, "HttpGet") or hasGlobal("httpget"),
		SetClipboard = hasGlobal("setclipboard"),
		WriteFile = hasGlobal("writefile"),
		ReadFile = hasGlobal("readfile"),
		IsFile = hasGlobal("isfile"),
		GetScriptBytecode = hasGlobal("getscriptbytecode"),
		GetHui = hasGlobal("gethui"),
		ProtectGui = hasGlobal("protect_gui"),
		Request = hasGlobal("request") or hasGlobal("http_request"),
		GetGenv = hasGlobal("getgenv"),
		HookFunction = hasGlobal("hookfunction"),
	}

	local knownProfile = profileFor(normalized)
	local profile = knownProfile or (capabilities.Loadstring and "Capability-based" or "Unknown")

	return {
		Name = name,
		Normalized = normalized,
		Known = knownProfile ~= nil,
		Profile = profile,
		Capabilities = capabilities,
		DetectedAt = os.time(),
	}
end

return Executor
