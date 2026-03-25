local filesystem = require("filesystem")
local shell = require("shell")

local repo = "https://raw.githubusercontent.com/bassj/oc_image"
local branch = "main"


local function download_file(path)
    local v = string.format("%d", math.random(1, 10000000000))
    local cmd = string.format('wget -f %s/refs/heads/%s%s?v=%s %s', repo, branch, path, v, path)
    shell.execute(cmd)
end

for _, dir in ipairs({
    "/lib/bassj/",
}) do
    if not filesystem.isDirectory(dir) then
        shell.execute("mkdir " .. dir)
    end
end

local args = {...}

if #args < 1 then
    print("Path Required")
    return
end

local path = args[1]
download_file(path)
