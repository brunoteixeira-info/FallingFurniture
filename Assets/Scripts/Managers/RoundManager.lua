--!Type(Module)
--!SerializeField
local furniture1 : GameObject = nil
--!SerializeField
local furniture2 : GameObject = nil
--!SerializeField
local furniture3 : GameObject = nil
--!SerializeField
local furniture4 : GameObject = nil

local uiRoundManager : UIRoundManager = nil

GameStarted = false
ActivePlayers = 1
FurnitureOccupied = 0
TimeRemainingForGameStart = 10
arrayFurniturePrefabs = { furniture1, furniture2, furniture3, furniture4 }
arrayFurnitureInstantiated = {}

local gameManagerScript : module = require("GameManager")

function self:ClientStart()
    uiRoundManager = self.gameObject:GetComponent(UIRoundManager)
end

function self:ServerStart()
    TimeRemainingForGameStart = 10
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
    
    local furnitureX = math.random(4, 22)
    local furnitureZ = math.random(-8, 8)

    arrayFurnitureInstantiated[i] = Object.Instantiate(arrayFurniturePrefabs[furnitureRoll], Vector3.new(furnitureX, 0, furnitureZ), Vector3.new(0, 0, 0))
    print(arrayFurnitureInstantiated[i])
end

function OccupyFurniture()
    FurnitureOccupied = FurnitureOccupied + 1
    if(FurnitureOccupied == ActivePlayers - 1) then
        print("All Furniture Occupied. Proceed to eliminate players and furniture.")
        local newTimer = Timer.new(0.1, function() gameManagerScript.EliminatePlayers() end, false)
        gameManagerScript.DestroyFurniture(arrayFurnitureInstantiated)
        gameManagerScript.ChangeAllPlayersInGameState(2, 1)
        gameManagerScript.SpawnFurniture(2)
        TimeRemainingForGameStart = 20
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

function self:ServerUpdate()
    if(GameStarted == false) then
        if(gameManagerScript.PlayersInGame == 1) then
            gameManagerScript.UpdateGameStartTimer("Waiting for more players to start the match")
        else
            TimeRemainingForGameStart = TimeRemainingForGameStart - Time.deltaTime
            gameManagerScript.UpdateGameStartTimer("Game starts in " .. math.floor(TimeRemainingForGameStart))
            if(TimeRemainingForGameStart <= 0) then
                gameManagerScript.GameStart()
            end
        end
    else
        TimeRemainingForGameStart = TimeRemainingForGameStart - Time.deltaTime
        gameManagerScript.UpdateGameStartTimer("Find and sit on a furniture to survive!\nRound ends in " .. math.floor(TimeRemainingForGameStart))
        if(TimeRemainingForGameStart <= 0) then
            print("Round Time Over. Proceed to eliminate players and furniture.")
            gameManagerScript.EliminatePlayers()
            gameManagerScript.DestroyFurniture(arrayFurnitureInstantiated)
            gameManagerScript.ChangeAllPlayersInGameState(2, 1)
            gameManagerScript.SpawnFurniture(2)
            TimeRemainingForGameStart = 20
        end        
    end
end

function UpdateTimer(time)
    if(uiRoundManager ~= nil) then
        uiRoundManager.UpdateUITimer(time)
    else
        uiRoundManager = self.gameObject:GetComponent(UIRoundManager)    
    end
end

function UpdateActivePlayers()
    ActivePlayers = ActivePlayers - 1
    if(ActivePlayers == 1) then
        gameManagerScript.DestroyFurniture(arrayFurnitureInstantiated)
        local newTimer = Timer.new(0.1, function() gameManagerScript.ChangeAllPlayersInGameState(2, 1) end, false)
        local newTimer = Timer.new(0.2, function() gameManagerScript.GameEnd() end, false)
        TimeRemainingForGameStart = 10
    end
end

function CreateUISlot()
    self.gameObject:GetComponent(UIRoundManager).CreatePlayerSlot()
end

function SetPlayerMatchRank(slot, playerName)
    self.gameObject:GetComponent(UIRoundManager).SetPlayerMatchRank(slot, playerName)
end

function DisplayPlayerMatchRank()
    self.gameObject:GetComponent(UIRoundManager).DisplayPlayerMatchRank()
end

function HidePlayerMatchRank()
    self.gameObject:GetComponent(UIRoundManager).HidePlayerMatchRank()
end


