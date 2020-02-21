-- Propcore is allowed to everyone, but functions in the restrictedFunctions array will be restricted to devotee+ only

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

local function checkForPvP( player )
    local isInBuildMode = player:GetNWBool( "CFC_PvP_Mode" )

    if not isInBuildMode and not player:IsAdmin() then
        return false, "You can't use propcore in PvP"

    end
end

local function restrict( signatures, condition )
    for _, signature in pairs( signatures ) do
        local oldFunc = wire_expression2_funcs[signature][3]

        wire_expression2_funcs[signature][3] = function( self, ... )
            local canRun, reason = condition( s, ... )

            if not canRun then
                return s.player:ChatPrint( "Couldn't run " .. signature .. ":" .. reason )
            end

            return oldFunc( self, ... )
        end
    end
end

function restrictPropCoreFunctions()
    restrict( restrictedFunctions, restrictedCondition )
    restrict( adminOnlyFunctions, adminOnlyCondition )
end
