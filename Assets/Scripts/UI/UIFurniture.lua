--!Type(UI)
--!Bind
local imageFurniture : UILabel = nil

--!SerializeField
local spriteFurnitureAvailable : Texture = nil
--!SerializeField
local spriteFurnitureOccupied : Texture = nil

local cam : GameObject

function self:ClientStart()
    cam = GameObject.Find("MainCamera")
    ChangeFurnitureOccupiedSprite(false)
end

function self:ClientUpdate()
    self.gameObject.transform:LookAt(cam.gameObject.transform.position)
end

function ChangeFurnitureOccupiedSprite(isOccupied)
    if(isOccupied == false) then
        imageFurniture.image = spriteFurnitureAvailable
    else
        imageFurniture.image = spriteFurnitureOccupied
    end
end
