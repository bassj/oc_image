local shell = require("shell")

local repo = "https://raw.githubusercontent.com/bassj/oc_image"
local branch = "main"

local function download_file(path)
    local cmd = string.format('wget -f %s/refs/heads/%s%s %s', repo, branch, path, path)
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

    "/lib/bassj/text.lua",
}) do
    download_file(file)
end