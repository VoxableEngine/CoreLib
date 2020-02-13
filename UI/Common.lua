
local Common = {}

function Common.MakeSoundHandler(state, fxSource, effectPath)
    return function(self, eventType, eventData)
        local fx = cache:GetResource("Sound", effectPath)
        state:GetObject(fxSource):Play(fx)
    end
end

function Common.ButtonEvents(state, element, buttonName, clickMethod, hoverMethod)
    local button = element:GetChild(buttonName, true)
    if button ~= nil then
        state:SubscribeToEvent(button, "Released", clickMethod)
        state:SubscribeToEvent(button, "HoverBegin", hoverMethod)
    end
end

return Common
