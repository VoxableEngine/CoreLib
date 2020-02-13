
local StringUtil = {}

local function switch(tbl)
    tbl.case = function (self, val, dt)
        local f=self[dt] or self.default
        if f then
            if type(f)=="function" then
                f(val, dt, self)
            else
                error("No implemented ToString utility function for type: "..dt)
            end
        end
    end
    return tbl
end

local toStringFunctions = switch({
    Vector2 = function (val) return "Vector2("..vec.x..", "..vec.y..")" end,
    Vector3 = function (val) return "Vector3("..vec.x..", "..vec.y..", "..vec.z..")" end,
    IntVector2 = function (val) return "IntVector2("..vec.x..", "..vec.y..")" end,
    IntVector3 = function (val) return "IntVecotr3("..vec.x..", "..vec.y..", "..vec.z..")" end,
    default = function (val, dt) return dt.."("..ToString(val)..")" end
})

function StringUtil.ToString(value)
    return toStringFunctions:case(value, tolua.type(value))
end


return StringUtil
