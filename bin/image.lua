local shell = require("shell")

local repo = "https://raw.githubusercontent.com/bassj/oc_image"
local branch = "main"

local function download_file(path)
    local cmd = string.format('wget -f %s/refs/heads/%s/%s', repo, branch, path)
    print(cmd)
    shell.execute(cmd)
end

for _, file in ipairs({
    "bin/image.lua",
    "bin/component.lua",
}) do
    download_file(file)
end