--!Type(Module)
--!SerializeField
local furniture1 : GameObject = nil
--!SerializeField
local furniture2 : GameObject = nil
--!SerializeField
local furniture3 : GameObject = nil
--!SerializeField
local furniture4 : GameObject = nil

local gameStarted : boolean = false
ActivePlayers = 3
FurnitureOccupied = 0

arrayFurniturePrefabs = { furniture1, furniture2, furniture3, furniture4 }
arrayFurnitureInstantiated = {}

local gameManagerScript : module = require("GameManager")

function self:ServerStart()
    StartFurnitureSpawn(5)
end

function SpawnFurniture()
    minTime = 3
    maxTime = 6
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
    
    local furnitureX = math.random(-3, 3)
    local furnitureZ = math.random(-3, 3)

    arrayFurnitureInstantiated[i] = Object.Instantiate(arrayFurniturePrefabs[furnitureRoll], Vector3.new(furnitureX, 0, furnitureZ), Vector3.new(0, 0, 0))
    print(arrayFurnitureInstantiated[i])
end

function OccupyFurniture()
    FurnitureOccupied = FurnitureOccupied + 1
    if(FurnitureOccupied == ActivePlayers - 1) then
        print("All Furniture Occupied. Proceed to eliminate players and furniture.")
        gameManagerScript.EliminatePlayers()
        gameManagerScript.DestroyFurniture(arrayFurnitureInstantiated)
        gameManagerScript.SpawnFurniture(5)
    end
end

function DestroyFurniture(arrayFurniture)
    arrayFurnitureInstantiated = arrayFurniture
    for i=1, #arrayFurnitureInstantiated do
        Object.Destroy(arrayFurnitureInstantiated[i])           
    end
end

function StartFurnitureSpawn(timeToSpawn)
    print("Spawning Furniture in " .. timeToSpawn .. " seconds.")
    -- Create a new Timer object. Interval: 5, Callback:function()..end, Repeating: false
    local newTimer = Timer.new(timeToSpawn, function() SpawnFurniture() end, false)
end

