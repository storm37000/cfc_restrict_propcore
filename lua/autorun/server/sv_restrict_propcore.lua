-- Propcore is allowed to everyone, but functions in the restrictedFunctions array will be restricted to devotee+ only
local cfc_propcore_file_name = "cfc_propcore_whitelist"
local whitelistedPlayers = whitelistedPlayers or {}
CFCPropcoreRestrict = CFCPropcoreRestrict or {}

if not file.Exists( cfc_propcore_file_name .. ".txt", "DATA" ) then
    --Creating new data file
    file.Write( cfc_propcore_file_name .. ".txt", "" )
else
    local fileContents = file.Read( cfc_propcore_file_name .. ".txt" )
    local translated = util.JSONToTable( fileContents )
    whitelistedPlayers = translated or {}
end

local function saveWhitelistChanges()
    local translated = util.TableToJSON( whitelistedPlayers, true )

    file.Write( cfc_propcore_file_name .. ".txt", translated )
end

function CFCPropcoreRestrict.addPlayersToPropcoreWhitelist( players )
    for _, ply in pairs( players ) do
        whitelistedPlayers[ply:SteamID()] = true
    end

    saveWhitelistChanges()
end

function CFCPropcoreRestrict.removePlayersFromPropcoreWhitelist( players )
    for _, ply in pairs( players ) do
        whitelistedPlayers[ply:SteamID()] = nil
    end

    saveWhitelistChanges()
end

function CFCPropcoreRestrict.playerIsWhitelisted( ply )
    return whitelistedPlayers[ply:SteamID()] ~= nil
end

local disallowedRanks = {}
disallowedRanks["user"] = true

local function isCorrectRank( ply )
    return not disallowedRanks[ply:GetUserGroup()]
end

-- Conditions
local function adminOnlyCondition( self, ... )
    if self.player:IsAdmin() then
        return true
    end

    return false, "Only Admins can use this function"
end

local function restrictedCondition( self, ... )
    local canUse, message = hook.Run( "CFC_RestrictPropCore_CanUse", self.player, self )
    if canUse ~= nil then return canUse, message end

    if self.player:IsAdmin() then return true end

    if CFCPropcoreRestrict.playerIsWhitelisted( self.player ) then return true end
    if not isCorrectRank( self.player ) then return false, "Incorrect Rank" end

    return true
end

-- Must be correct user, and not in PvP mode
local restrictedFunctions = {
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
    "setPos(e:v)",
    "reposition(e:v)",
    "propManipulate(e:vannn)",
    --"propBreak(e:)"
    "use(e:)"
}

local adminOnlyFunctions = {}

local function restrict( signatures, condition )
    for _, signature in pairs( signatures ) do
        local oldFunc = wire_expression2_funcs[signature][3]

        wire_expression2_funcs[signature][3] = function( self, ... )
            local canRun, reason = condition( self, ... )

            if not canRun then
                return self.player:ChatPrint( "Couldn't run " .. signature .. ":" .. reason )
            end

            return oldFunc( self, ... )
        end
    end
end

function restrictPropCoreFunctions()
    restrict( restrictedFunctions, restrictedCondition )
    restrict( adminOnlyFunctions, adminOnlyCondition )
end
