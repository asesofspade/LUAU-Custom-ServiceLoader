local Modules = game.ReplicatedStorage:WaitForChild("Modules")
local ModuleLoader = require(Modules:WaitForChild("ModulesLoader"))

local servicesapi = game.ReplicatedStorage:WaitForChild("servicesapi")
local ServicesLoaderScript = servicesapi:FindFirstChild("ServicesLoader")
local ServicesLoader
if ServicesLoaderScript then
    ServicesLoader = require(ServicesLoaderScript)

    local scannedServices = ModuleLoader:ScanFolder(servicesapi)

    ServicesLoader:Create({
        modules = scannedServices
    })
end
