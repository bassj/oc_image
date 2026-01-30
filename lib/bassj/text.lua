local function pprint(tbl, indent)
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
            pprint(v, indent + 1)
        elseif type(v) == "string" then
            print(string.format("%q", v))
        else
            print(tostring(v))
        end
    end
    print(formatting .. "}")
end

return {
    pprint = pprint
}