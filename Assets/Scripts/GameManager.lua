--!Type(Module)
addScoreToPlayerRequest = Event.new("AddScoreToPlayerRequest")
addScoreToPlayerResponse = Event.new("AddScoreToPlayerResponse")

changePlayerStateRequest = Event.new("ChangePlayerStateRequest")
changePlayerStateResponse = Event.new("ChangePlayerStateResponse")

eliminatePlayersRequest = Event.new("EliminatePlayersRequest")
eliminatePlayersResponse = Event.new("EliminatePlayersResponse")

teleportPlayerRequest = Event.new("TeleportPlayerRequest")
teleportPlayerResponse = Event.new("TeleportPlayerResponse")

occupyFurnitureRequest = Event.new("OccupyFurnitureRequest")
occupyFurnitureResponse = Event.new("OccupyFurnitureResponse")

destroyFurnitureRequest = Event.new("DestroyFurnitureRequest")
destroyFurnitureResponse = Event.new("DestroyFurnitureResponse")

players = {}

local uiManagerScript : UIManager
local roundManagerScript : module = require("RoundManager") 

--!SerializeField
local music : AudioShader = nil
--!SerializeField
local areaSpectator : GameObject = nil

-- Current State:
-- 0 -> In Lobby
-- 1 -> In Game
-- 2 -> Protected inside Furniture
-- 3 -> Spectating

local function TrackPlayers(game, characterCallback)
    scene.PlayerJoined:Connect(function(scene, player)
        players[player] = {
            player = player,
            score = IntValue.new("score" .. tostring(player.id), 0),
            currentState = IntValue.new("state" .. tostring(player.id), 0)
        }

        player.CharacterChanged:Connect(function(player, character) 
            local playerinfo = players[player]
            if (character == nil) then
                return
            end 

            if characterCallback then
                characterCallback(playerinfo)
            end
        end)


    end)

    game.PlayerDisconnected:Connect(function(player)
        players[player] = nil
    end)
end

function self:ClientAwake()
    --Audio:PlayMusic(music, 0.4)

    function OnCharacterInstantiate(playerinfo)
        local player = playerinfo.player
        local character = player.character
    end

   --AddShells() adds Shells to whichever client calls the function
   function AddScoreToPlayer(amount)
    addScoreToPlayerRequest:FireServer(amount)
   end

   addScoreToPlayerResponse:Connect(function(player, score)
        if(player == client.localPlayer) then
            --uiManagerScript.SetPlayerShells(shells)
        end
    end)

    function ChangePlayerState(state)
        changePlayerStateRequest:FireServer(state)
    end

    changePlayerStateResponse:Connect(function(player, state)
        if(player == client.localPlayer) then
            print("Changing Player State to " .. state)
        end
    end)

    eliminatePlayersResponse:Connect(function(players, state)
        print("Client: Eliminate Players.")
        print("Player is Client. Current State: " .. players[client.localPlayer].currentState.value)
        if(players[client.localPlayer].currentState.value == 0) then
            print("Teleporting Player")            
            --client.localPlayer.character:Teleport(areaSpectator.transform.position)
            TeleportPlayer(players[client.localPlayer])
        end
    end)

    function TeleportPlayer(player)
        teleportPlayerRequest:FireServer(player)
    end

    teleportPlayerResponse:Connect(function(player)
        player.character:Teleport(areaSpectator.transform.position)
    end)

    function OccupyFurniture(furniture, teleportTo)
        occupyFurnitureRequest:FireServer(player, furniture, teleportTo)
    end

    occupyFurnitureResponse:Connect(function(player, furniture, teleportTo)
       player.character:Teleport(teleportTo.transform.position)
       player.character:PlayEmote("sit-idle", true)
    end)

    destroyFurnitureResponse:Connect(function(player, arrayFurniture)
        roundManagerScript.DestroyFurniture(arrayFurniture)
    end)

   --local uiManager = GameObject.Find("UIManager")
   --uiManagerScript = uiManager.gameObject:GetComponent(UIManager)
   TrackPlayers(client, OnCharacterInstantiate)
end

function self:ServerAwake()
    TrackPlayers(server)

    addScoreToPlayerRequest:Connect(function(player, amount) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        local playerInfo = players[player]
        local playerScore = playerInfo.score.value
        local playerScore = playerScore + amount
        playerInfo.score.value = playerScore
        addScoreToPlayerResponse:FireAllClients(player, playerInfo.score.value)
    end)

    changePlayerStateRequest:Connect(function(player, state) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        local playerInfo = players[player]
        playerInfo.currentState.value = state
        changePlayerStateResponse:FireAllClients(player, playerInfo.currentState.value)
    end)

    function EliminatePlayers()
        print("Server: Eliminate Players.")
        eliminatePlayersResponse:FireAllClients(players, 3)
    end

    teleportPlayerRequest:Connect(function(player) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        teleportPlayerResponse:FireAllClients(player)
        roundManagerScript.ActivePlayers = roundManagerScript.ActivePlayers - 1
    end)

    occupyFurnitureRequest:Connect(function(player, furniture, teleportTo) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        roundManagerScript.OccupyFurniture()
        occupyFurnitureResponse:FireAllClients(player, furniture, teleportTo)
    end)

    function SpawnFurniture(timeToSpawn)
        roundManagerScript.StartFurnitureSpawn(timeToSpawn)
    end

    function DestroyFurniture(arrayFurniture)
        print("Server: Destroy Furniture.")
        destroyFurnitureResponse:FireAllClients(players, arrayFurniture)
        roundManagerScript.FurnitureOccupied = 0
    end
end