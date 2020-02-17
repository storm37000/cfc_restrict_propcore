local CATEGORY_NAME = "User Management"

local function addToWhitelist( callingPlayer, targetPlayers, should_remove )
    local affected_plys = {}

    for _, ply in pairs( targetPlayers ) do
        local isPlyWhitelisted = CFCPropcoreRestrict.playerIsWhitelisted( ply )

        if isPlyWhitelisted and not should_remove then
            ULib.tsayError( callingPlayer, ply:Name() .. " is already whitelisted!", true )
        elseif not isPlyWhitelisted and should_remove then
            ULib.tsayError( callingPlayer, ply:Name() .. " is not whitelisted!", true )
        else
            table.insert( affected_plys, ply )
        end
    end

    CFCPropcoreRestrict.addPlayersToPropcoreWhitelist( affected_plys )
    ulx.fancyLogAdmin( callingPlayer, true, "#A added #T to the propcore whitelist", affected_plys )
end

local PCWhitelistAdd = ulx.command( CATEGORY_NAME, "ulx allowpropcore", addToWhitelist, "!allowpropcore" )
PCWhitelistAdd:addParam{ type = ULib.cmds.PlayersArg }
PCWhitelistAdd:addParam{ type = ULib.cmds.BoolArg, invisible = false }
PCWhitelistAdd:defaultAccess( ULib.ACCESS_ADMIN )
PCWhitelistAdd:help( "Adds specified target(s) to a propcore whitelist" )
PCWhitelistAdd:setOpposite( "ulx denypropcore", {_, _, true}, "!denypropcore" )