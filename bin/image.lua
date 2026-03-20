local shell = require("shell")

local repo = "https://raw.githubusercontent.com/bassj/oc_image"
local branch = "main"

local function download_file(path)
    local v = tostring(math.random(1, 10000000000))
    local cmd = string.format('wget -f %s/refs/heads/%s%s?v=%s %s', repo, branch, path, v, path)
    shell.execute(cmd)
end

for _, dir in ipairs({
    "/lib/bassj",
}) do
    shell.execute("mkdir " .. dir)
end

for _, file in ipairs({
    "/bin/image.lua",
    "/bin/component.lua",
    "/bin/bee.lua",
    "/bin/ae.lua",

    "/lib/json.lua",
    "/lib/bassj/text.lua",
    "/lib/bassj/datasink.lua"
}) do
    download_file(file)
end
