--!Type(Module)
addScoreToPlayerRequest = Event.new("AddScoreToPlayerRequest")
addScoreToPlayerResponse = Event.new("AddScoreToPlayerResponse")

changePlayerStateRequest = Event.new("ChangePlayerStateRequest")
changePlayerStateResponse = Event.new("ChangePlayerStateResponse")

changePlayerInGameStateResponse = Event.new("ChangePlayerInGameStateResponse")

changeAllPlayersStateResponse = Event.new("ChangeAllPlayersStateResponse")

eliminatePlayersRequest = Event.new("EliminatePlayersRequest")
eliminatePlayersResponse = Event.new("EliminatePlayersResponse")

eliminateSpecificPlayerRequest = Event.new("EliminateSpecificPlayerRequest")

teleportPlayerToGameRequest = Event.new("TeleportPlayerToGameRequest")
teleportPlayerToGameResponse = Event.new("TeleportPlayerToGameResponse")

teleportPlayerToSpectatorRequest = Event.new("TeleportPlayerToSpectatorRequest")
teleportPlayerToSpectatorResponse = Event.new("TeleportPlayerToSpectatorResponse")

teleportAllPlayersToGameResponse = Event.new("TeleportAllPlayersToGameResponse")
teleportAllPlayersToSpectatorResponse = Event.new("TeleportAllPlayersToSpectatorResponse")

updateGameStartTimerResponse= Event.new("UpdateGameStartTimerResponse")

occupyFurnitureRequest = Event.new("OccupyFurnitureRequest")
occupyFurnitureResponse = Event.new("OccupyFurnitureResponse")

destroyFurnitureRequest = Event.new("DestroyFurnitureRequest")
destroyFurnitureResponse = Event.new("DestroyFurnitureResponse")

instantiatePlayerSlotRequest = Event.new("InstantiatePlayerSlotRequest")
instantiatePlayerSlotResponse = Event.new("InstantiatePlayerSlotResponse")

setPlayerMatchRankResponse = Event.new("SetPlayerMatchRankResponse")
setPlayerWinnerResponse = Event.new("SetPlayerWinnerResponse")

displayPlayerMatchRankResponse = Event.new("DisplayPlayerMatchRankResponse")
hidePlayerMatchRankResponse = Event.new("HidePlayerMatchRankResponse")

addGamesWonRequest = Event.new("AddGamesWonRequest")

-- Event for requesting top players list from server
local GetTopPlayersRequest = Event.new("GetTopPlayersRequest") 
-- Event for receiving top players list from server
local GetTopPlayersResponse = Event.new("GetTopPlayersResponse") 

players = {}
topPlayers = {} -- Table to store top players
PlayersInGame = 0

local uiManagerScript : UIManager
local uiLeaderboard : UILeaderboard
local roundManagerScript : module = require("RoundManager") 

--!SerializeField
local music : AudioShader = nil
--!SerializeField
local areaSpectator : GameObject = nil
--!SerializeField
local areaGame : GameObject = nil

-- Current State:
-- 0 -> In Lobby
-- 1 -> In Game
-- 2 -> Protected inside Furniture

local function TrackPlayers(game, characterCallback)
    scene.PlayerJoined:Connect(function(scene, player)
        players[player] = {
            player = player,
            score = IntValue.new("score" .. tostring(player.id), 0),
            gamesWon = IntValue.new("gamesWon" .. tostring(player.id), 0),
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

        PlayersInGame = PlayersInGame + 1
        print("Player joined the Lobby. Total Players: " .. PlayersInGame)

    end)

    game.PlayerDisconnected:Connect(function(player)
        players[player] = nil
        PlayersInGame = PlayersInGame - 1
        print("Player left the Lobby. Total Players: " .. PlayersInGame)
    end)
end

-- Function to get and sort top players list
GetTopPlayers = function()
    -- Sort top players list
    if topPlayers ~= nil and #topPlayers > 0 then
      table.sort(topPlayers, function(a, b)
        return a.gamesWon > b.gamesWon
      end)
    end
  
    return topPlayers
end

function self:ClientAwake()
    --Audio:PlayMusic(music, 0.4)

    function OnCharacterInstantiate(playerinfo)
        local player = playerinfo.player
        local character = player.character
        --InstantiatePlayerSlot()
    end

    -- Request the top players from the server when the client initializes
    GetTopPlayersRequest:FireServer()

    -- Handle response from server containing top players list
    GetTopPlayersResponse:Connect(function(newTopPlayers)
    -- Override the local top players list with the updated list from the server
        topPlayers = newTopPlayers
        uiLeaderboard = GameObject.Find("Leaderboards"):GetComponent(UILeaderboard)
        uiLeaderboard.UpdateLeaderboard(topPlayers)
    end)

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
        print("Client Request: Change Player State.")
        changePlayerStateRequest:FireServer(state)
    end

    changePlayerStateResponse:Connect(function(player, state)
        print("Client Response: Change Player State.")
        if(player == client.localPlayer) then
            print("Changing Player State to " .. state)
        end
    end)

    changePlayerInGameStateResponse:Connect(function(players, stateFrom, stateTo)
        print("Client Response: Change Player In Game State.")
        if(players[client.localPlayer].currentState.value == stateFrom) then
            local PlayerController = require("PlayerCharacterController")
            PlayerController.options.enabled = true
            client.localPlayer.character:PlayEmote("emoji-thumbsup", false)
            ChangePlayerState(stateTo)
        end
    end)

    changeAllPlayersStateResponse:Connect(function(player, state)
        print("Client Response: Change All Players State.")
        changePlayerStateRequest:FireServer(client.localPlayer, state)
    end)

    eliminatePlayersResponse:Connect(function(players, state)
        print("Client Response: Eliminate Players.")
        print("Player is Client. Current State: " .. players[client.localPlayer].currentState.value)

        if(players[client.localPlayer].currentState.value == 1) then
            print("Teleporting Player")            
            TeleportPlayerToSpectator(players[client.localPlayer])
            eliminateSpecificPlayerRequest:FireServer(client.localPlayer)
            ChangePlayerState(0)
            local PlayerController = require("PlayerCharacterController")
            PlayerController.options.enabled = true
        end
    end)

    setPlayerWinnerResponse:Connect(function(players, state)
        print("Client Response: Set Player Winner.")
        print("Player is Client. Current State: " .. players[client.localPlayer].currentState.value)

        if(players[client.localPlayer].currentState.value == 1) then
            print("Setting Player as Winner")            
            eliminateSpecificPlayerRequest:FireServer(client.localPlayer)
            ChangePlayerState(0)
            local PlayerController = require("PlayerCharacterController")
            PlayerController.options.enabled = true
            addGamesWonRequest:FireServer(client.localPlayer)
        end
    end)


    function TeleportPlayerToGame(player)
        print("Client Request: Teleport Player To Game.")
        teleportPlayerToGameRequest:FireServer(player)
    end

    teleportPlayerToGameResponse:Connect(function(player)
        print("Client Response: Teleport Player To Game.")
        player.character:Teleport(areaGame.transform.position)
    end)

    teleportAllPlayersToGameResponse:Connect(function(players)
        print("Client Request: Teleport All Players.")
        TeleportPlayerToGame(players[client.localPlayer].player)
        ChangePlayerState(1)
    end)

    function TeleportPlayerToSpectator(player)
        print("Client Request: Teleport Player To Spectator.")
        teleportPlayerToSpectatorRequest:FireServer(player)
    end

    teleportPlayerToSpectatorResponse:Connect(function(player)
        print("Client Response: Teleport Player To Spectator.")
        player.character:Teleport(areaSpectator.transform.position)
        Chat:DisplayTextMessage(general, player, "Eliminated.")
    end)

    teleportAllPlayersToSpectatorResponse:Connect(function(players)
        print("Client Request: Teleport All Players.")
        TeleportPlayerToSpectator(players[client.localPlayer].player)
        ChangePlayerState(0)
    end)

    function OccupyFurniture(furniture, teleportTo)
        occupyFurnitureRequest:FireServer(furniture, teleportTo)
    end

    occupyFurnitureResponse:Connect(function(player, furniture, teleportTo)
       player.character:Teleport(teleportTo)
       player.character:PlayEmote("sit-idle", true)
       furniture.OccupyFurniture()
    end)

    destroyFurnitureResponse:Connect(function(player, arrayFurniture)
        roundManagerScript.DestroyFurniture(arrayFurniture)
    end)

    updateGameStartTimerResponse:Connect(function(player, time)
        roundManagerScript.UpdateTimer(time)
    end)

    function InstantiatePlayerSlot()
        instantiatePlayerSlotRequest:FireServer(client.localPlayer)
    end

    instantiatePlayerSlotResponse:Connect(function(player)
        roundManagerScript.CreateUISlot()
    end)

    setPlayerMatchRankResponse:Connect(function(player, slot, playerName)
        roundManagerScript.SetPlayerMatchRank(slot, playerName)
    end)

    displayPlayerMatchRankResponse:Connect(function(player)
        roundManagerScript.DisplayPlayerMatchRank()
    end)

    hidePlayerMatchRankResponse:Connect(function(player)
        roundManagerScript.HidePlayerMatchRank()
    end)

    ---------------------------------CHAT---------------------------------
    local general = nil
    Chat.PlayerJoinedChannel:Connect(function(channelInfo, player)
        general = channelInfo
    end)
    
    Chat.TextMessageReceivedHandler:Connect(function(channelInfo, player, message)
        Chat:DisplayTextMessage(channelInfo, player, message)
    end)

   --local uiManager = GameObject.Find("UIManager")
   --uiManagerScript = uiManager.gameObject:GetComponent(UIManager)
   TrackPlayers(client, OnCharacterInstantiate)
end

function self:ClientStart()
    uiLeaderboard = GameObject.Find("Leaderboards"):GetComponent(UILeaderboard)
end

function self:ServerAwake()
    TrackPlayers(server)

    -- Retrieve the top players list from storage
    Storage.GetValue("TopPlayers", function(oldList)
    if oldList == nil then oldList = {} end
    topPlayers = oldList
    end)

    -- Handle request for top players list from client
    GetTopPlayersRequest:Connect(function()
    -- Retrieve the top players list from storage
    Storage.GetValue("TopPlayers", function(oldList)
      if oldList == nil then oldList = {} end
      topPlayers = oldList

      -- Send the top players list to the client
      GetTopPlayersResponse:FireAllClients(topPlayers)
    end)
    end)

    addScoreToPlayerRequest:Connect(function(player, amount) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        local playerInfo = players[player]
        local playerScore = playerInfo.score.value
        local playerScore = playerScore + amount
        playerInfo.score.value = playerScore
        addScoreToPlayerResponse:FireAllClients(player, playerInfo.score.value)
    end)

    changePlayerStateRequest:Connect(function(player, state) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        print("Server: Change Player State.")
        local playerInfo = players[player]
        playerInfo.currentState.value = state
        changePlayerStateResponse:FireAllClients(player, playerInfo.currentState.value)
    end)

    function ChangeAllPlayersState(state)
        print("Server: Change All Players State.")
        local playerInfo = players[client.localPlayer]
        playerInfo.currentState.value = state
        changePlayerStateResponse:FireAllClients(client.localPlayer, playerInfo.currentState.value)
    end

    function ChangeAllPlayersInGameState(stateFrom, stateTo)
        print("Server: Change All Players In Game State.")
        changePlayerInGameStateResponse:FireAllClients(players, stateFrom, stateTo)
    end

    function EliminatePlayers()
        print("Server: Eliminate Players.")
        eliminatePlayersResponse:FireAllClients(players, 0)
    end

    function SetPlayerWinner()
        print("Server: Set Player Winner.")
        setPlayerWinnerResponse:FireAllClients(players, 0)
    end

    eliminateSpecificPlayerRequest:Connect(function(player) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        print("Server: Eliminate Specific Player.")
        print("Server: Active Players Before Elimination: " .. roundManagerScript.ActivePlayers)
        roundManagerScript.UpdateActivePlayers()
        print("Server: Active Players After: " .. roundManagerScript.ActivePlayers)
        setPlayerMatchRankResponse:FireAllClients(player, roundManagerScript.ActivePlayers + 1, player.name)
    end)

    teleportPlayerToGameRequest:Connect(function(player) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        print("Server: Teleport Player To Game.")
        teleportPlayerToGameResponse:FireAllClients(player)
    end)

    teleportPlayerToSpectatorRequest:Connect(function(player) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        print("Server: Teleport Player To Spectator.")
        teleportPlayerToSpectatorResponse:FireAllClients(player)
    end)

    occupyFurnitureRequest:Connect(function(player, furniture, teleportTo) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        print("Server: Occupy Furniture.")
        roundManagerScript.OccupyFurniture()
        occupyFurnitureResponse:FireAllClients(player, furniture, teleportTo)
    end)

    function SpawnFurniture(timeToSpawn)
        print("Server: Spawn Furniture.")
        roundManagerScript.StartFurnitureSpawn(timeToSpawn)
    end

    function DestroyFurniture(arrayFurniture)
        print("Server: Destroy Furniture.")
        destroyFurnitureResponse:FireAllClients(players, arrayFurniture)
        roundManagerScript.FurnitureOccupied = 0
    end

    function GameStart()
        print("Server: Game Start.")
        print("Server: Getting Players in lobby: " .. PlayersInGame)
        if(PlayersInGame >= 2) then
            roundManagerScript.ActivePlayers = PlayersInGame
            roundManagerScript.GameStarted = true
            roundManagerScript.TimeRemainingForGameStart = 20
            SpawnFurniture(5)
            teleportAllPlayersToGameResponse:FireAllClients(players)
        else
           roundManagerScript.TimeRemainingForGameStart = 45
        end
    end

    function GameEnd()
        print("Server: Game End.")
        roundManagerScript.GameStarted = false
        setPlayerWinnerResponse:FireAllClients(players, 1)
        local newTimer = Timer.new(0.1, function() DisplayMatchRanks() end, false)
    end

    function DisplayMatchRanks()
        print("Server: Display Match Ranks.")
        displayPlayerMatchRankResponse:FireAllClients(players)

       -- Create a new Timer object. Interval: 5, Callback:function()..end, Repeating: false
       local newTimer = Timer.new(10, function() AfterDisplayMatchRanks(players) end, false)     
    end

    function AfterDisplayMatchRanks(players)
        teleportAllPlayersToSpectatorResponse:FireAllClients(players)
        hidePlayerMatchRankResponse:FireAllClients(players)       
    end

    function UpdateGameStartTimer(time)
        updateGameStartTimerResponse:FireAllClients(players, time)
    end

    instantiatePlayerSlotRequest:Connect(function(player) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        print("Server: Instantiate Player Slot.")
        instantiatePlayerSlotResponse:FireAllClients(player)
    end)

    addGamesWonRequest:Connect(function(player) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        print("Server: Add Games Won to Player.")
            
        local playerInfo = players[player]
        local playerGamesWon = playerInfo.gamesWon.value
        local playerGamesWon = playerGamesWon + 1
        playerInfo.gamesWon.value = playerGamesWon

        -- Update top players list
        local playerEntry = { name = player.name, gamesWon = playerGamesWon }

        -- Check if the player is already in the top players list
        local found = false
        for i = 1, #topPlayers do 
        if topPlayers[i].name == player.name then
            topPlayers[i] = playerEntry
            found = true
            break
        end
        end

        -- If the player is not in the top players list, add them
        if not found then
        table.insert(topPlayers, playerEntry)
        end

        -- Update the top players list on all clients
        GetTopPlayersResponse:FireAllClients(topPlayers) 
        -- Save the updated top players list to storage
        Storage.SetValue("TopPlayers", topPlayers)
    end)
end