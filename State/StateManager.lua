
local StateManager = {}

local states_ = {}
local state_ = nil
local currentState_ = ""
local previousState_ = ""
local stateQueue_ = {}

local FADE_PREPARE = 0
local FADE_OUT = 1
local FADE_RELEASE_STATE = 2
local FADE_CREATE_STATE = 3
local FADE_IN = 4
local FADE_FINISH = 5
local FADE_SPEED = 0.3

local fadeWindow_ = nil
local fadeStatus_ = FADE_PREPARE
local fadeTime_ = 0.0

local function HandleChangeState(eventType, eventData)
    
end

function StateManager:Init()
    SubscribeToEvent("ChangeState", HandleChangeState);
end

function StateManager:Add(stateConfig)
    states_[stateConfig.name] = CreateState(stateConfig)
end

function StateManager:Remove(stateName)
    states_[stateName] = nil
end

function StateManager:SetState(stateName)
    states_[stateConfig.name] = CreateState(stateConfig)
end

function StateManager:GetCurrentState()
    return currentState_
end

function StateManager:IsValid(stateName)
    return states_[stateConfig.name] ~= nil
end

function StateManager:ShowState(stateName)

end

return StateManager