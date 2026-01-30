local shell = require("shell")
local component = require("component")

local function is_uuid_v4(str)
    local pattern = "^[0-9a-fA-F]{8}%-%x%x%x%x%-4%x%x%x%-[89aAbB]%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"
    return str:match(pattern) ~= nil
end

local function pretty_print(tbl, indent)
    indent = indent or 0
    local formatting = string.rep("  ", indent)

    if type(tbl) ~= "table" then
        print(tbl)
        return
    end

    print("{")
    for k, v in pairs(tbl) do
        local key
        if type(k) == "string" then
            key = string.format("%q", k)
        else
            key = tostring(k)
        end

        io.write(formatting .. " [" .. key .. "] = ")

        if type(v) == "table" then
            pretty_print(v, indent + 1)
        elseif type(v) == "string" then
            print(string.format("%q", v))
        else
            print(tostring(v))
        end
    end
    print(formatting .. "}")
end

local function print_usage()
    print("Usage: component [component_name] [command]")
end

local function list_components()
    local components = component.list()
    print("Components:")
    pretty_print(components, 1)
end

local function print_component_methods(component_id)
    local methods = component.methods(component_id)
    for m, _ in pairs(methods) do
        print(m .. ": " .. component.doc(component_id, m))
    end
end

local function component_subcommand_field(component_id, field, args)
    print("TODO")
    assert(false)
end

local function component_subcommand_method(component_id, method, args)
    local params = {}
    for i, v in ipairs(args) do
        local f, err = load("return (" .. v .. ")")
        if f == nil then
            print(err)
            return
        end

        local val = f()
        table.insert(params, val)
    end

    local ret = component.invoke(component_id, method, table.unpack(params))
    io.write(method .. ": ")
    pretty_print(ret)
end

local function component_subcommand(filter, args)
    local components = component.list()
    local component_id
    for k, v in pairs(components) do
        if v == filter then
            component_id = k
            break
        end
    end

    if components[filter] ~= nil then
        component_id = filter
    end

    if component_id == nil then
        local addr, err = component.get(filter)
        if addr ~= nil then
            component_id = addr
        end
    end

    if component_id == nil then
        print("Could not find component: " .. filter)
        os.exit(1)
    end

    local fields = component.fields(component_id)
    local methods = component.methods(component_id)

    local subcmd = table.remove(args, 1)
    if subcmd == nil then
        print("Methods: ")
        print_component_methods(component_id)
        print("\nFields: ")
        pretty_print(fields)
    elseif fields[subcmd] ~= nil then
        component_subcommand_field(component_id, subcmd, args)
    elseif methods[subcmd] ~= nil then
        component_subcommand_method(component_id, subcmd, args)
    else
        print("No such field or method: " .. subcmd)
    end
end

local args, options = shell.parse(...)

local cmd = table.remove(args, 1)

if cmd == nil then
    list_components()
elseif type(cmd) == "string" then
    component_subcommand(cmd, args)
else
    print("Unknown subcommand: " .. cmd)
    print_usage()
end
