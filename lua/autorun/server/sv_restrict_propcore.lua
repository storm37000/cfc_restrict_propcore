-- Propcore is allowed to everyone, but functions in the restrictedFunctions array will be restricted to devotee+ only
local file_name = "cfc_propcore_whitelist"
local whitelistedPlayers = whitelistedPlayers or {}
CFCPropcoreRestrict = CFCPropcoreRestrict or {}

if not file.Exists( file_name .. ".txt", "DATA" ) then
    --Creating new data file
    file.Write( file_name .. ".txt", "" )
else
    local fileContents = file.Read( file_name .. ".txt" )
    local translated = util.JSONToTable( fileContents )
    whitelistedPlayers = translated or {}
end

local function saveWhitelistChanges()
    local translated = util.TableToJSON( whitelistedPlayers, true )

    file.Write( file_name .. ".txt", translated )
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

function restrictPropCoreFunctions()
    local disallowedRanks = {}
    disallowedRanks["user"] = true
    disallowedRanks["regular"] = true

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
        "propManipulate(e:vannn)"
        --"propBreak(e:)"
    }

    for _, signature in pairs( restrictedFunctions ) do
        if wire_expression2_funcs then
            local oldFunc = wire_expression2_funcs[signature][3]

            wire_expression2_funcs[signature][3] = function( self, ... )
                if disallowedRanks[self.player:GetUserGroup()] == nil or CFCPropcoreRestrict.playerIsWhitelisted( self.player ) then

                    local isInBuildMode = self.player:GetNWBool("CFC_PvP_Mode", false) == false

                    if isInBuildMode or self.player:IsAdmin() then
                        return oldFunc( self, ... )
                    else
                        self.player:ChatPrint( "You can't use PropCore in PvP mode" )
                    end
                else
                    self.player:ChatPrint( "You don't have access to " .. signature )
                end
            end
        end
    end
end

