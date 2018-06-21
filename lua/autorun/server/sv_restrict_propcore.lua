-- Propcore is allowed to everyone, but functions in the restricted_functions array will be restricted to devotee+ only

function restrict_propcore_functions()
    local disallowed_ranks = {}
    disallowed_ranks["user", "regular"] = true

    local restricted_functions = {
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

    for k, sig in pairs( restricted_functions ) do
        local old_func = wire_expression2_funcs[sig][3]

        wire_expression2_funcs[sig][3] = function( self, ... )
            if ( disallowed_ranks[self.player:GetUserGroup()] == nil ) then
                local isInBuildMode = self.player:GetNWBool("PVPMode", false) == false

                if( isInBuildMode or self.player:IsAdmin() ) then
                    return old_func( self, ... )
                else
                    self.player:ChatPrint( "You can't use PropCore in PvP mode" )
                end
            else
                self.player:ChatPrint( "You don't have access to " .. sig )
            end
        end
    end
end

hook.Add( "OnGamemodeLoaded","propCoreRestrict", restrict_propcore_functions )
