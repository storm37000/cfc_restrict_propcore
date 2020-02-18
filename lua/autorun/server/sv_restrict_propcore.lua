-- Propcore is allowed to everyone, but functions in the restrictedFunctions array will be restricted to devotee+ only

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


    local adminOnlyFunctions = {
        "use(e:)"
    }

    restrict( restrictedFunctions, function( self,  ... )
        local isInBuildMode = self.player:GetNWBool( "CFC_Pvp_Mode" ) == false

        if disallowedRanks[self.player:GetUserGroup()] then
            return false, "You don't have access to this function"
        elseif isInBuildMode and not self.player:IsAdmin() then
             return false, "You can't use propcore in PvP"
        else
            return true
        end
    end)

    restrict( adminOnlyFunctions, function( self, ...)
        if self.player:IsAdmin() then
            return true
        else
            return false, "Only Admins can use this function"
        end
    end)
end



function restrict( signatures, condition )
    for _, signature in pairs( signatures ) do
        local oldFunc = wire_expression2_funcs[signature][3]

        wire_expression2_funcs[signature][3] = function( self, ... )
            canRun, reason = condition( self, ... )

            if canRun then
                return oldFunc( self, ... )
            else
                self.player:ChatPrint( "Couldn't run " .. signature .. ":" .. reason )
            end
        end
    end
end

