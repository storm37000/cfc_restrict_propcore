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
local function adminOnlyCondition( self, ... )
    if self.player:IsAdmin() then
        return true
    end

    return false, "Only Admins can use this function"
end

local function restrictedCondition( self, ... )
    local isInBuildMode = self.player:GetNWBool( "CFC_PvP_Mode" ) == false

    if disallowedRanks[self.player:GetUserGroup()] then
        return false, "You don't have access to this function"
    end


    if not isInBuildMode and not self.player:IsAdmin() then
        return false, "you can't use propcore in PvP"
    end
    
    return true
end

local function restrict( signatures, condition )
    for _, signature in pairs( signatures ) do
        local oldFunc = wire_expression2_funcs[signature][3]

        wire_expression2_funcs[signature][3] = function( self, ... )
            local canRun, reason = condition( self, ... )

            if canRun then
                return oldFunc( self, ... )
            else
                self.player:ChatPrint( "Couldn't run " .. signature .. ":" .. reason )
            end
        end
    end
end

function restrictPropCoreFunctions()
    restrict( restrictedFunctions, restrictedCondition )
    restrict( adminOnlyFunctions, adminOnlyCondition )
end
