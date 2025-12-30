# Custom-ServiceLoader for Roblox (Luau)

A modular, event-driven service loader for Roblox that centralizes actions on instances and data storage.  

This system uses a **ModuleLoader** to scan the folder containing APIs and passes them to **ServicesLoader**, which creates a global `CustomService` exposing two BindableEvents:

- **ObjectOriented** → handles instance actions (animations, MoveTo, Tp, etc.)  
- **DataStore** → handles data persistence operations (Create, Load, Save, GetValue, SetValue, FindValue)  

---

## Folder Structure
```
servicesapi/
├─ servicesloader -- central loader module
├─ apis/
│ ├─ ObjectOrientedAPI
│ └─ DataStoreAPI
└─ functions/
├─ shared/ -- shared utilities
├─ private/ -- server-only
└─ public/ -- client-only
Modules/
└─ ModulesLoader -- module that scans folders and requires modules
```

---

## Installation & Initialization

1. Place the `servicesapi` folder and `ModulesLoader` module in `ReplicatedStorage`.  
2. Use `ModulesLoader` to scan the folder before creating the service:

```lua
local Modules = game.ReplicatedStorage:WaitForChild("Modules")
local ModuleLoader = require(Modules:WaitForChild("ModulesLoader"))

local servicesapi = game.ReplicatedStorage:WaitForChild("servicesapi")
local ServicesLoaderScript = servicesapi:FindFirstChild("servicesloader")
local ServicesLoader

if ServicesLoaderScript then
    ServicesLoader = require(ServicesLoaderScript)
    
    -- Scan the entire servicesapi folder to collect all API modules
    local scannedServices = ModuleLoader:ScanFolder(servicesapi)

    -- Create the CustomService with the scanned modules
    ServicesLoader:Create({
        modules = scannedServices
    })
end
```
Important: ModuleLoader:ScanFolder(folder) must be called first to gather all APIs; otherwise, ServicesLoader will not have access to ObjectOrientedAPI or DataStoreAPI.

Accessing the Service
```lua
local CustomService = game:WaitForChild("CustomService")
local ObjectOrientedEvent = CustomService:WaitForChild("ObjectOriented")
local DataStoreEvent = CustomService:WaitForChild("DataStore")
Using ObjectOrientedAPI
Trigger actions on instances:
```
```lua
ObjectOrientedEvent:Fire(instances, actionData)
instances → single instance or table of instances.

actionData → table with action instructions.

Examples
Move a Rig
lua
Copy code
local rig = workspace.Rig

ObjectOrientedEvent:Fire(
    rig,
    {
        MoveTo = {
            target = Vector3.new(0, 0, 80),
            speed = 35,
            alignGround = false
        }
    }
)
```
Play an Animation

```lua
ObjectOrientedEvent:Fire(
    rig,
    {
        Animation = {
            animType = "Play",
            animId = "rbxassetid://110051715541872",
            looped = true
        }
    }
)
Teleport
```lua
ObjectOrientedEvent:Fire(
    workspace.Part,
    {
        Tp = {
            target = CFrame.new(10, 5, 20)
        }
    }
)
Using DataStoreAPI
Trigger data operations:
```
```lua
DataStoreEvent:Fire(actionName, eventData)
actionName → "Create", "Load", "Save", "GetValue", "SetValue", "FindValue".

eventData → table containing relevant parameters.
```
Example: Create a DataStore
```lua
DataStoreEvent:Fire("Create", {
    storeName = "PlayerData",
    defaultData = {Coins = 100, Inventory = {}}
})
```
Example: Set a Value
```lua
DataStoreEvent:Fire("SetValue", {
    player = game.Players.LocalPlayer,
    storeName = "PlayerData",
    key = "Coins",
    value = 200
})
```
Example: Get a Value
```lua
DataStoreEvent:Fire("GetValue", {
    player = game.Players.LocalPlayer,
    storeName = "PlayerData",
    key = "Coins",
    callback = function(value)
        print("Player has " .. value .. " coins")
    end
})
```
Advantages
Fully event-driven: scripts don’t need to require internal modules directly.

Centralized API handling simplifies maintenance.

Extensible: new actions can be added to ObjectOrientedAPI or DataStoreAPI without modifying calling scripts.

Supports both server and client contexts.
