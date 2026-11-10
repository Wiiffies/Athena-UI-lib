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
	["cryptic"] = "Full",
	["seliware"] = "Full",
	["velocity"] = "Full",
}

local ENV_GETTERS = { "identifyexecutor", "getexecutorname" }
local NAME_KEYS = { "Name", "name", "Executor", "executor", "Title", "title", "Product", "product" }

local MARKER_NAMES = {
	syn = "Synapse X",
	synapse = "Synapse X",
	fluxus = "Fluxus",
	krnl = "KRNL",
	krnl_loaded = "KRNL",
	delta = "Delta",
	wave = "Wave",
	solara = "Solara",
	xeno = "Xeno",
	sirhurt = "SirHurt",
	is_sirhurt_closure = "SirHurt",
	electron = "Electron",
	codex = "Codex",
	valyse = "Valyse",
	vega = "Vega",
	bunny = "Bunny",
	arceus = "Arceus X",
	hydrogen = "Hydrogen",
	swift = "Swift",
	awp = "AWP",
	cryptic = "Cryptic",
	seliware = "Seliware",
	velocity = "Velocity",
}

local function trim(value)
	if type(value) ~= "string" then
		return nil
	end
	local text = string.gsub(value, "^%s+", "")
	text = string.gsub(text, "%s+$", "")
	if text == "" then
		return nil
	end
	return text
end

local function meaningfulName(value)
	local text = trim(value)
	if not text then
		return nil
	end
	local lower = string.lower(text)
	if lower == "unknown" or lower == "n/a" or lower == "none" or lower == "nil" then
		return nil
	end
	return text
end

local function nameFromValue(value)
	if type(value) == "string" then
		return meaningfulName(value)
	end
	if type(value) == "table" then
		for _, key in ipairs(NAME_KEYS) do
			local name = meaningfulName(value[key])
			if name then
				return name
			end
		end
	end
	return nil
end

local function addEnvironment(list, seen, value)
	if type(value) == "table" and not seen[value] then
		seen[value] = true
		table.insert(list, value)
	end
end

local function environments()
	local list = {}
	local seen = {}

	local ok, getgenvFn = pcall(function()
		return getgenv
	end)
	if ok and type(getgenvFn) == "function" then
		local got, env = pcall(getgenvFn)
		if got then
			addEnvironment(list, seen, env)
		end
	end

	addEnvironment(list, seen, _G)

	local gotShared, sharedEnv = pcall(function()
		return shared
	end)
	if gotShared then
		addEnvironment(list, seen, sharedEnv)
	end

	local gotThread, threadEnv = pcall(function()
		return getfenv(0)
	end)
	if gotThread then
		addEnvironment(list, seen, threadEnv)
	end

	local gotFunction, functionEnv = pcall(function()
		return getfenv(1)
	end)
	if gotFunction then
		addEnvironment(list, seen, functionEnv)
	end

	return list
end

local function readGlobal(name)
	for _, env in ipairs(environments()) do
		local ok, value = pcall(function()
			return env[name]
		end)
		if ok and value ~= nil then
			return value
		end
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

local function callNameGetter(getter)
	local ok, result = pcall(getter)
	if ok then
		return nameFromValue(result)
	end
	return nil
end

local function readName()
	local envs = environments()

	-- Executors commonly expose these only inside getgenv(), not in _G.
	for _, env in ipairs(envs) do
		for _, key in ipairs(ENV_GETTERS) do
			local value = env[key]
			if type(value) == "function" then
				local name = callNameGetter(value)
				if name then
					return name, key
				end
			else
				local name = meaningfulName(value)
				if name then
					return name, key
				end
			end
		end
	end

	-- Some executors put their name in a named environment table or marker.
	for _, env in ipairs(envs) do
		for key, label in pairs(MARKER_NAMES) do
			local value = env[key]
			if value ~= nil and value ~= false then
				if type(value) == "table" then
					for _, getterName in ipairs(ENV_GETTERS) do
						local getter = value[getterName]
						if type(getter) == "function" then
							local name = callNameGetter(getter)
							if name then
								return name, key .. "." .. getterName
							end
						end
					end
					return label, key
				elseif type(value) == "function" then
					-- is_sirhurt_closure is the only common function marker.
					if key == "is_sirhurt_closure" then
						return label, key
					end
				elseif value == true then
					return label, key
				end
			end
		end
	end

	-- Last resort: some executors publish their name as a plain environment value.
	for _, env in ipairs(envs) do
		for _, key in ipairs({ "ExecutorName", "EXECUTOR_NAME", "executor", "Executor" }) do
			local name = nameFromValue(env[key])
			if name then
				return name, key
			end
		end
	end

	return "Unknown", "none"
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
	local name, source = readName()
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
		Source = source,
		Capabilities = capabilities,
		DetectedAt = os.time(),
	}
end

return Executor
