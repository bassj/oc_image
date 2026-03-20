local BASE_ENDPOINT = "https://gtnh.bassj.io/%s"
local EVENT_TYPES = {
    powerevents = true,
}

local json = require("json")
local internet = require("internet")

local function push_event(event_type, values)
    if not EVENT_TYPES[event_type] then
        error("Invalid event_type: " .. event_type)
    end

    local endpoint = string.format(BASE_ENDPOINT, event_type)
    local body = json.encode(values)
    local headers = {
        [ "Content-Type" ] = "application/json"
    }

    internet.request(endpoint, body, headers, "POST")
end

return {
    push_event = push_event
}
