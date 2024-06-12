--!Type(UI)
--!Bind
local textTimer : UILabel = nil
--!Bind
local containerSlotPlayers : UIImage = nil
--!Bind
local textLeaderboard : UILabel = nil
--!Bind
local buttonCloseContainerSlots : UIButton = nil
--!Bind
local slotPlayer : UIImage = nil
--!Bind
local textSlotPlayerName : UILabel = nil
--!Bind
local imageSlotPlayerRank : UIImage = nil

arrayPlayersMatch = {}

textTimer:SetPrelocalizedText("Game starting soon")
textLeaderboard:SetPrelocalizedText("Leaderboard")
textSlotPlayerName:SetPrelocalizedText("#00 - PlayerName")

function self:ClientStart()
    for i=1, 8 do
        CreatePlayerSlot()
    end
    buttonCloseContainerSlots:RegisterPressCallback(function () HidePlayerMatchRank() end)
    containerSlotPlayers:AddToClassList("hide")
end

function UpdateUITimer(time)
    textTimer:SetPrelocalizedText(time)
end

function CreatePlayerSlot()
    local slotPlayerUI = UIImage.new()   
    slotPlayerUI:AddToClassList("slotPlayer")
    containerSlotPlayers:Add(slotPlayerUI)

    local textPlayerName = UILabel.new()
    textPlayerName:AddToClassList("textSlotPlayerName")
    textPlayerName:SetPrelocalizedText("")
    slotPlayerUI:Add(textPlayerName)

    local imagePlayerRank = UIImage.new()
    imagePlayerRank:AddToClassList("imageSlotPlayer")
    slotPlayerUI:Add(imagePlayerRank)

    playerInfo = { uiSlot = slotPlayerUI, uiSlotPlayerNameText = textPlayerName, uiSlotPlayerRankImage = imagePlayerRank } 
    arrayPlayersMatch[#arrayPlayersMatch + 1] = playerInfo
end

function SetPlayerMatchRank(slot, playerName)
    print("#" .. slot .. " - " .. playerName)
    arrayPlayersMatch[slot].uiSlotPlayerNameText:SetPrelocalizedText("#" .. slot .. " - " .. playerName)
end

function DisplayPlayerMatchRank()
    containerSlotPlayers:RemoveFromClassList("hide")
end

function HidePlayerMatchRank()
    containerSlotPlayers:AddToClassList("hide")
end