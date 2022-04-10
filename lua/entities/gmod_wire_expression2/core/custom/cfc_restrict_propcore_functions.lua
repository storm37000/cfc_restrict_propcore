E2Lib.RegisterExtension( "cfc_propcore_restrictions", true, "Rank and pvp based restrictions for propcore")

local disallowedRanks = {}

-- In seconds, minimum delay between uses
local throttleConfig = {
	default = 0.1
}

local function isCorrectRank( ply )
	return not disallowedRanks[ply:GetUserGroup()], "Incorrect rank to use this function"
end

local function setLastUse( chip, funcName )
	local ply = chip.player

	local throttles = ply.streamcoreThrottle
	if not throttles then
		throttles = {}
		ply.streamcoreThrottle = throttles
	end

	throttles[funcName] = CurTime()
end

local function isThrottled( chip, funcName )
	local ply = chip.player

	local throttles = ply.streamcoreThrottle
	if not throttles then
		throttles = {}
		ply.streamcoreThrottle = throttles
	end

	local lastUse = throttles[funcName]
	if not lastUse then
		lastUse = 0
		throttles[funcName] = 0
	end

	local delay = throttleConfig[funcName] or throttleConfig.default

	return CurTime() < lastUse + delay
end

-- Conditions
local function adminOnlyCondition( self )
	if self.player:IsAdmin() then
		return true
	end

	return false, "Only Admins can use this function"
end

local function restrictedCondition( self )
	if self.player:IsAdmin() then return true end
	if not isCorrectRank( self.player ) then return false, "Incorrect Rank" end

	return true
end

local function restrictedRate( self, funcName )
	if isThrottled( self, funcName ) then return false, "Your using this function too often" end
	setLastUse( self, funcName )
	return true
end

local function restrict( signatures, condition )
	for _, signature in ipairs( signatures ) do
		local old = wire_expression2_funcs[signature]
		if old == nil then print("no e2 function " .. signature) continue end
		local oldFunc = old[3]

		wire_expression2_funcs[signature][3] = function( self, ... )
			local canRun, reason = condition( self, signature )

			if not canRun then
				return self.player:ChatPrint( "Couldn't run " .. signature .. ":" .. reason )
			end
			return oldFunc( self, ... )
		end
	end
end

registerCallback("postinit", function()
--	timer.Simple(4,function()
		--restrict( restrictedFunctions, restrictedCondition )
		restrict({
			"soundDuration(s)",
			"setTrails(e:nnnsvn)",
			"setTrails(e:nnnsvnnn)",
			"vonEncode(r)",
			"vonEncode(t)",
			"vonEncode(s)",
			"vonDecode(s)",
			"vonDecodeTable(s)"
		},restrictedRate)
		restrict({
			"propSpawn(sn)",
			"propSpawn(en)",
			"propSpawn(svn)",
			"propSpawn(evn)",
			"propSpawn(san)",
			"propSpawn(ean)",
			"propSpawn(svan)",
			"propSpawn(evan)",
			"seatSpawn(sn)",
			"seatSpawn(svan)",
			"propBreak(e:)",
			"deparent(e:)",
			"propDraw(e:n)",
			"use(e:)",
			"jsonDecode(s)",
			"jsonEncode(t)",
			"jsonEncode(tn)"
		},adminOnlyCondition)
--	end)
end)