--!Type(Module)
addPointsToPlayerRequest = Event.new("AddPointsToPlayerRequest")
addPointsToPlayerResponse = Event.new("AddPointsToPlayerResponse")

changePlayerStateRequest = Event.new("ChangePlayerStateRequest")
changePlayerStateResponse = Event.new("ChangePlayerStateResponse")

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
            if(state == 3) then            
                client.localPlayer.character:Teleport(areaSpectator.transform.position)
            end
        end
    end)

    function EliminatePlayers()
        eliminatePlayersRequest:FireServer()
    end

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

    eliminatePlayersRequest:Connect(function(player) -- Here the player is just the client that sent the request to the server, so when AddShells() is called it gives Shells to whoever calls it
        for i=1, #players do
            local playerInfo = players[i]
            if(playerInfo.currentState.value == 1) then
                changePlayerStateResponse:FireAllClients(player, 3)         
            end
        end
    end)
end