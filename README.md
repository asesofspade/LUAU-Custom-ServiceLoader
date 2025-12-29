# Custom-ServiceLoader-luau

A ModuleScript-based service loader for Roblox that creates a global service called **ObjectOrientedService**.

This service can be accessed from **any Script or LocalScript** in your project using `game:WaitForChild`, allowing you to trigger actions on instances (such as rigs) in a centralized and object-oriented way.

---

## Overview

This module creates a service named **ObjectOrientedService**, which exposes an **Action** object.

Using this system, you can fire actions on any instance without directly requiring modules everywhere, keeping your codebase cleaner and more scalable.

You can also modify this module to behave like a normal ModuleScript and use `require()` instead of the custom `:Create(data)` function.

---

## How Actions Work

Actions are triggered using the following method:

```lua
Action:Fire(instance, actionName, data)
instance: The object the action will affect

actionName: The name of the action to execute

data: A table containing parameters for the action

Basic Usage Example
lua
Copy code
local ObjectOrientedService = game:WaitForChild("ObjectOrientedService")
local Action = ObjectOrientedService:WaitForChild("Action")

local rig = workspace.Rig

Action:Fire(
    rig,
    "MoveTo",
    {
        target = Vector3.new(0, 0, 80),
        speed = 35,
        alignGround = false
    }
)
Playing Animations Example
lua
Copy code
Action:Fire(
    rig,
    "Animation",
    {
        animType = "Play",
        animId = "rbxassetid://110051715541872",
        looped = true
    }
)
