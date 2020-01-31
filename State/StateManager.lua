
local StateObject = require("CoreLib.State.StateObject")
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

local function AddFadeLayer()

    fadeWindow_ = Window:new()

    -- Make the window a child of the root element, which fills the whole screen.
    ui.root:AddChild(fadeWindow_)
    fadeWindow_:SetSize(graphics.width, graphics.height)
    fadeWindow_:SetLayout(LM_FREE)
    -- Urho has three layouts: LM_FREE, LM_HORIZONTAL and LM_VERTICAL.
    -- In LM_FREE the child elements of this window can be arranged freely.
    -- In the other two they are arranged as a horizontal or vertical list.

    -- Center this window in it's parent element.
    fadeWindow_:SetAlignment(HA_CENTER, VA_CENTER)
    -- Black color
    fadeWindow_:SetColor(Color(0, 0, 0, 1))
    -- Make it topmost
    fadeWindow_:BringToFront()
end

-- updates transition frames
local function HandleUpdate(eventType, eventData)

    local timeStep = eventData["TimeStep"]:GetFloat()

    if fadeStatus_ == FADE_PREPARE then
        if state_ == nil then
            fadeStatus_ = FADE_CREATE_STATE
            return
        end
        AddFadeLayer();
        fadeWindow_.opacity = 0
        fadeTime_ = FADE_SPEED
        fadeStatus_ = FADE_OUT
        return
    end

    if fadeStatus_ == FADE_OUT then

        fadeTime_ = fadeTime_ - timeStep
        fadeWindow_.opacity = 1 - fadeTime_ / FADE_SPEED
        if fadeTime_ <= 0 then

            fadeStatus_ = FADE_RELEASE_STATE
        end
        return
    end

    if fadeStatus_ == FADE_RELEASE_STATE then
        if state_.Stop ~= nil then
            state_:Stop()
        end
        state_ = nil
        fadeStatus_ = FADE_CREATE_STATE
        return
    end

    if fadeStatus_ == FADE_CREATE_STATE then
        local nextState = stateQueue_[#stateQueue_]

        state_ = states_[nextState]
        state_:Start()

        previousState_ = currentState_
        currentState_ = nextState

        if fadeWindow_ ~= nil then
            fadeWindow_:Remove()
            fadeWindow_ = nil
        end

        AddFadeLayer()
        fadeWindow_.opacity = 1
        fadeTime_ = FADE_SPEED
        fadeStatus_ = FADE_IN

        return
    end

    if fadeStatus_ == FADE_IN then
        fadeTime_ = fadeTime_ - timeStep
        fadeWindow_.opacity = fadeTime_ / FADE_SPEED
        if fadeTime_ <= 0 then
            fadeStatus_ = FADE_FINISH
        end
        return
    end

    if fadeStatus_ == FADE_FINISH then
        fadeWindow_:Remove()
        fadeWindow_ = nil

        UnsubscribeFromEvent("Update")

        table.remove(stateQueue_)

        cache:ReleaseAllResources(false)

        if #stateQueue_ > 0 then
            SubscribeToEvent("Update", HandleUpdate)
            fadeStatus_ = FADE_PREPARE
            return
        end
    end
end

-- fired when a state change occurs
local function HandleChangeState(eventType, eventData)

    if #stateQueue_ == 0 then
        fadeStatus_ = FADE_PREPARE
    end

    if eventData["Name"] ~= nil then

        local name = eventData["Name"]:GetString()

        table.insert(stateQueue_, name)

        SubscribeToEvent("Update", HandleUpdate)
        print("State Change Queued: " .. name)
    else
        print("Name parameter missing in ChangeState event data")
    end
end

function StateManager:Init()
    SubscribeToEvent("ChangeState", HandleChangeState)
end

function StateManager:CreateState(stateName)
    local config = StateObject:new(stateName)
    states_[stateName] = config
    return config
end

function StateManager:Remove(stateName)
    states_[stateName] = nil
end

function StateManager:GetCurrentState()
    return currentState_
end

function StateManager:IsValid(stateName)
    return states_[stateName] ~= nil
end

function StateManager:ShowState(stateName)

    if self:IsValid(stateName) then
        local eventData = VariantMap()
        eventData["Name"] = stateName
        SendEvent("ChangeState", eventData)
    else
        -- attempt to load state object by name
        local state = require("States." .. stateName)

        if self:IsValid(stateName) == false then
            print("State name not found and unable to require state lua file: 'States." .. stateName .. "'")
            return
        end
        -- send state change event now that it is loaded
        local eventData = VariantMap()
        eventData["Name"] = stateName
        SendEvent("ChangeState", eventData)
    end
end


return StateManager
