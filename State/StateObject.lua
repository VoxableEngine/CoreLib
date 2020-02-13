
local Class = require("CoreLib.SimpleLuaClasses.Class")
local StateObject = Class()

function StateObject:init(name)
    self.name = name
    self.objectList = {}
end

function StateObject:AddObject(key, obj)
    self.objectList[key] = obj
end

function StateObject:GetObject(key)
    return self.objectList[key]
end

function StateObject:GetHandler(method)
    local other = self
    return function(eventType, eventData)
        return other[method](other, eventType, eventData)
    end
end

function StateObject:SubscribeToEvent(obj, eventType, handlerName)
    SubscribeToEvent(obj, eventType, self:GetHandler(handlerName))
end

function StateObject:ReleaseObjects()
    for key, obj in pairs(self.objectList) do
        obj:Remove()
    end
    self.objectList = {}
end

return StateObject
