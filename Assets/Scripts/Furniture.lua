--!Type(ClientAndServer)
--!SerializeField
local objSittable : GameObject = nil
--!SerializeField
local objFurniture : GameObject = nil
--!SerializeField
local fx_circleAvailable : GameObject = nil
--!SerializeField
local fx_circleOccupied : GameObject = nil


IsOccupied = false
local gameManagerScript : module = require("GameManager")
local roundManagerScript : module = require("RoundManager")

function self:ClientAwake()
    self.gameObject:GetComponent(TapHandler).Tapped:Connect(function() 
        SitRequest()
    end)
end

function SitRequest()
    print("Request to sit")
    if(IsOccupied == false) then
        print("Player Sitting")
        client.localPlayer.character:Teleport(objSittable.transform.position)
        client.localPlayer.character:PlayEmote("sit-idle", true, objSittable)
        IsOccupied = true
        objFurniture:GetComponent(UIFurniture).ChangeFurnitureOccupiedSprite(true)
        fx_circleAvailable:SetActive(false)
        fx_circleOccupied:SetActive(true)
        local PlayerController = require("PlayerCharacterController")
        PlayerController.options.enabled = false
        gameManagerScript.OccupyFurniture(self, objSittable.transform.position)
        gameManagerScript.ChangePlayerState(2)
    end 
end

function OccupyFurniture()
    IsOccupied = true
    objFurniture:GetComponent(UIFurniture).ChangeFurnitureOccupiedSprite(true)
    fx_circleAvailable:SetActive(false)
    fx_circleOccupied:SetActive(true)
end