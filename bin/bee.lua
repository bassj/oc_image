local shell = require("shell")
local component = require("component")
local term = require("term")

local gpu = component.gpu

local bassj = {
    text = require("bassj.text"),
}

local transposer

for component_id, component_type in component.list() do
    if component_type == "transposer" then
        transposer = component.proxy(component_id)
        break
    end
end

if transposer == nil then
    print("No transposer component found.")
    os.exit(1)
end

local function print_gene_info(gene)
    local production = math.floor(gene.speed * 100 + 0.5) .. "%"
    local flowers = gene.flowerProvider
    local pollination = gene.flowering
    local lifespan = gene.lifespan

    local speciesName = gene.species.name
    local jubilantTemp = gene.species.temperature
    local jubilantHumiditiy = gene.species.humidity

    local tempTolerance = gene.temperatureTolerance
    local humidityTolerance = gene.humidityTolerance

    local nocturnal = gene.nocturnal
    local caveDwelling = gene.caveDwelling
    local tolerantFlyer = gene.tolerantFlyer

    print("    Species: " .. speciesName)
    print("    Production Speed: " .. production)
    print("    Flowers: " .. flowers)
    print("    Pollination Speed: " .. pollination)
    print("    Lifespan: " .. lifespan)

    print("    Preferred Temperature: " .. jubilantTemp)
    print("    Preferred Humidity: " .. jubilantHumiditiy)

    print("    Temperature Tolerance: " .. tempTolerance)
    print("    Humidity Tolerance: " .. humidityTolerance)

    print("    Nocturnal: " .. tostring(nocturnal))
    print("    Cave Dwelling: " .. tostring(caveDwelling))
    print("    Tolerant Flyer: " .. tostring(tolerantFlyer))
end

local function print_bee_info(beeItemStack)
    local isScanned = beeItemStack.individual.isAnalyzed
    local isPristine = beeItemStack.individual.isNatural
    local generation = beeItemStack.individual.generation
    local label = beeItemStack.label

    local activeGene = beeItemStack.individual.active
    local inactiveGene = beeItemStack.individual.inactive

    gpu.setForeground(0x00FF00)
    term.write(label)

    if isPristine then
        gpu.setForeground(0xFF00FF)
        print(" (Pristine)")
    else
        gpu.setForeground(0xFFFFFF)
        print(" (Ignoble)")
    end

    gpu.setForeground(0xFFFFFF)

    if not isScanned then
        print("Bee has not been scanned")
        return
    end

    print(generation .. " generations in captivity")

    print("Active")
    print_gene_info(activeGene)
    print("Inactive")
    print_gene_info(inactiveGene)
end


local args, opts = shell.parse(...)

local beeSlot = tonumber(args[1]) or 1
local stackInfo = transposer.getStackInSlot(4, beeSlot)

print_bee_info(stackInfo)
