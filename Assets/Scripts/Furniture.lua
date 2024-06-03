--!Type(ClientAndServer)
--!SerializeField
local objSittable : GameObject = nil

local isOccupied : boolean = false
local gameManagerScript : module = require("GameManager")
local roundManagerScript : module = require("RoundManager")

function self:ClientAwake()
    self.gameObject:GetComponent(TapHandler).Tapped:Connect(function() 
        SitPlayer()
    end)
end

function SitPlayer()
    if(isOccupied == false) then
        print("Player Sitting")
        client.localPlayer.character:Teleport(objSittable.transform.position)
        client.localPlayer.character:PlayEmote("sit-idle", true)
        isOccupied = true
        roundManagerScript.OccupyFurniture()
        gameManagerScript.ChangePlayerState(2)
    end
end