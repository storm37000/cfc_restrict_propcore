CFCPropcoreRestrict = CFCPropcoreRestrict or {}

-- Conditions
local function adminOnlyCondition( self, ... )
    if self.player:IsAdmin() then
        return true
    end

    return false, "Only Admins can use this function"
end

local restrictedFunctions = {
    "applyForce(v)",
    "applyOffsetForce(vv)",
    "applyAngForce(a)",
    "applyTorque(v)",
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
    "use(e:)"
}

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
    restrict( restrictedFunctions, adminOnlyCondition )
end
