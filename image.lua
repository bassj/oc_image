local shell = require("shell")

local repo = "https://raw.githubusercontent.com/bassj/oc_image/"
local branch = "main"

local function download_file(path)
    shell.execute(string.format('wget -f %s/refs/heads/%s/%s', repo, branch, path))
end

for _, file in ipairs({
    "image.lua",
}) do
    download_file(file)
end