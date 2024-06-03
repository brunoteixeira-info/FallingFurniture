--!Type(Module)
--!SerializeField
local spawnCollider : Collider = nil
--!SerializeField
local furniture1 : GameObject = nil
--!SerializeField
local furniture2 : GameObject = nil
--!SerializeField
local furniture3 : GameObject = nil
--!SerializeField
local furniture4 : GameObject = nil

local gameStarted : boolean = false
ActivePlayers = 2
FurnitureOccupied = 0

arrayFurniturePrefabs = { furniture1, furniture2, furniture3, furniture4 }
arrayFurnitureInstantiated = {}

local gameManagerScript : module = require("GameManager")

function self:ClientStart()
    -- Create a new Timer object. Interval: 5, Callback:function()..end, Repeating: false
    local newTimer = Timer.new(5, function() SpawnFurniture() end, false)
end

function SpawnFurniture()
    minTime = 3
    maxTime = 6
    arrayFurnitureInstantiated = {}
    for i=1, ActivePlayers - 1 do
        local timeRoll = math.random(minTime, maxTime)
        print("Spawning Furniture #" .. i .. " in " .. timeRoll .. " seconds")
        local newTimer = Timer.new(timeRoll, function() SpawnRandomFurniture(i) end, false)
        minTime = minTime + 3
        maxTime = maxTime + 3
    end
end

function SpawnRandomFurniture(i)
    local furnitureRoll = math.random(1, #arrayFurniturePrefabs)
    
    local newFurniture = Object.Instantiate(arrayFurniturePrefabs[furnitureRoll])
    local furnitureX = math.random(spawnCollider.bounds.min.x, spawnCollider.bounds.max.x)
    local furnitureZ = math.random(spawnCollider.bounds.min.z, spawnCollider.bounds.max.z)

    newFurniture.transform.position = Vector3.new(furnitureX, 0, furnitureZ)
    arrayFurnitureInstantiated[i] = newFurniture
end

function OccupyFurniture()
    FurnitureOccupied = FurnitureOccupied + 1
    if(FurnitureOccupied == ActivePlayers - 1) then
        gameManagerScript.EliminatePlayers()
        for i=1, ActivePlayers - 1 do
            Object.Destroy(arrayFurnitureInstantiated[i])
        end
    end
end