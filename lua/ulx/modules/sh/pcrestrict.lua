local CATEGORY_NAME = "User Management"

local function handleWhitelistActions( callingPlayer, targetPlayers, shouldRemove )
    local affectedPlys = {}
    local message = "#A added #T to the propcore whitelist"

    if shouldRemove then
        message = "#A removed #T from the propcore whitelist"
    end

    for _, ply in pairs( targetPlayers ) do
        local plyWhitelisted = CFCPropcoreRestrict.playerIsWhitelisted( ply )

        if plyWhitelisted and shouldRemove then
            table.insert( affectedPlys, ply )
        elseif plyWhitelisted and not shouldRemove then
            ULib.tsayError( callingPlayer, ply:Name() .. " is already whitelisted!", true )
        elseif not plyWhitelisted and shouldRemove then
            ULib.tsayError( callingPlayer, ply:Name() .. " is not whitelisted!", true )
        elseif not plyWhitelisted and not shouldRemove then
            table.insert( affectedPlys, ply )
        end
    end

    if shouldRemove then
        CFCPropcoreRestrict.removePlayersFromPropcoreWhitelist( affectedPlys )
    else
        CFCPropcoreRestrict.addPlayersToPropcoreWhitelist( affectedPlys )
    end

    ulx.fancyLogAdmin( callingPlayer, true, message, affectedPlys )
end

local PCWhitelistAdd = ulx.command( CATEGORY_NAME, "ulx allowpropcore", handleWhitelistActions, "!allowpropcore" )
PCWhitelistAdd:addParam{ type = ULib.cmds.PlayersArg }
PCWhitelistAdd:addParam{ type = ULib.cmds.BoolArg, invisible = true }
PCWhitelistAdd:defaultAccess( ULib.ACCESS_ADMIN )
PCWhitelistAdd:help( "Adds/Removes specified target(s) to a propcore whitelist" )
PCWhitelistAdd:setOpposite( "ulx denypropcore", {_, _, true}, "!denypropcore" )

local function isInPropcoreWhitelist( callingPlayer, targetPlayers )
    for _, ply in pairs( targetPlayers ) do
        if CFCPropcoreRestrict.playerIsWhitelisted( ply ) then
            ULib.tsayError( callingPlayer, ply:Name() .. " is whitelisted", true )
        else
            ULib.tsayError( callingPlayer, ply:Name() .. " is NOT whitelisted!", true )
        end
    end
end

local PCInWhitelist = ulx.command( CATEGORY_NAME, "ulx propcoreexists", isInPropcoreWhitelist, "!propcoreexists" )
PCInWhitelist:addParam{ type = ULib.cmds.PlayersArg }
PCInWhitelist:defaultAccess( ULib.ACCESS_ADMIN )
PCInWhitelist:help( "Checks if a player is in the propcore whitelist" )