CATEGORY_NAME = "CFC"

local function addToWhitelist( callingPlayer, targetPlayers )
    local affected_plys = {}

    for _, ply in pairs( targetPlayers ) do
        local isPlyWhitelisted = CFCPropcoreRestrict.playerIsWhitelisted( ply )

        if isPlyWhitelisted then
            ULib.tsayError( callingPlayer, ply:Name() .. " is already whitelisted!", true )
        else
            table.insert( affected_plys, ply )
        end
    end

    CFCPropcoreRestrict.addPlayersToPropcoreWhitelist( affected_plys )
    ulx.fancyLogAdmin( callingPlayer, true, "#A added #T to the propcore whitelist", affected_plys )
end

local PCWhitelistAdd = ulx.command( CATEGORY_NAME, "ulx allowpropcore", addToWhitelist, "!allowpropcore" )
PCWhitelistAdd:addParam{ type = ULib.cmds.PlayersArg }
PCWhitelistAdd:defaultAccess( ULib.ACCESS_ADMIN )
PCWhitelistAdd:help( "Adds specified target(s) to a propcore whitelist" )

local function removeFromWhitelist( callingPlayer, targetPlayers )
    local affected_plys = {}

    for _, ply in pairs( targetPlayers ) do
        local isPlyWhitelisted = CFCPropcoreRestrict.playerIsWhitelisted( ply )

        if not isPlyWhitelisted then
            ULib.tsayError( callingPlayer, ply:Name() .. " is not whitelisted!", true )
        else
            table.insert( affected_plys, ply )
        end
    end

    CFCPropcoreRestrict.removePlayersFromPropcoreWhitelist( affected_plys )
    ulx.fancyLogAdmin( callingPlayer, true, "#A removed #T from the propcore whitelist", affected_plys )
end

local PCWhitelistRemove = ulx.command( CATEGORY_NAME, "ulx denypropcore", removeFromWhitelist, "!denypropcore" )
PCWhitelistRemove:addParam{ type = ULib.cmds.PlayersArg }
PCWhitelistRemove:defaultAccess( ULib.ACCESS_ADMIN )
PCWhitelistRemove:help( "Removes specified target(s) from the propcore whitelist" )