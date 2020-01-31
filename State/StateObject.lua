
local StateObject = {}

function StateObject:new(stateName)
    local o = {}
    o.name = stateName
    return o
end

return StateObject
