--!Type(UI)
--!Bind
local _content : VisualElement = nil
--!Bind
local _ranklist : VisualElement = nil

-- Require the PlayerTracker module
local playerTracker = require("PlayerTracker")

-- Function to update the leaderboard UI with the top players list
function UpdateLeaderboard(players)
  _ranklist:Clear() -- Clear the current leaderboard

   if not players or #players == 0 then return end -- Return if there are no players

   local count = #players -- Get the number of players
   if count > 8 then count = 8 end -- Display only the top 8 players

   for i = 1, count do
    -- Create a rank item for each player
    local _rankItem = VisualElement.new()
    _rankItem:AddToClassList("rank-item")

    local entry = players[i] -- Get the player entry

    local name = entry.gamesWon -- Get the player name
    local score = entry.gamesWon -- Get the player score

    -- Create a label for the player rank
    local _rankLabel = UILabel.new()
    _rankLabel:SetPrelocalizedText("#" .. i)
    _rankLabel:AddToClassList("rank-label")

    -- Create a label for the player name
    local _nameLabel = UILabel.new()
    _nameLabel:SetPrelocalizedText(name)
    _nameLabel:AddToClassList("name-label")

    -- Create a label for the player score
    local _scoreLabel = UILabel.new()
    _scoreLabel:SetPrelocalizedText(tostring(score))
    _scoreLabel:AddToClassList("score-label")


    -- Add the labels to the rank item
    _rankItem:Add(_rankLabel)
    _rankItem:Add(_nameLabel)
    _rankItem:Add(_scoreLabel)

    -- Add the placement class based on the rank
     if i == 1 then
      _rankItem:AddToClassList("first")
    elseif i == 2 then
      _rankItem:AddToClassList("second")
    elseif i == 3 then
      _rankItem:AddToClassList("third")
    end

    -- Add the rank item to the rank list
    _ranklist:Add(_rankItem)

   end
end

local players = {
  { name = "Player1", gamesWon = 100 },
  { name = "Player2", gamesWon = 90 },
  { name = "Player3", gamesWon = 80 },
  { name = "Player4", gamesWon = 70 },
  { name = "Player5", gamesWon = 60 },
  { name = "Player6", gamesWon = 50 },
  { name = "Player7", gamesWon = 40 },
  { name = "Player8", gamesWon = 30 }
}
