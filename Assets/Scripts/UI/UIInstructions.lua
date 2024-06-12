--!Type(UI)
--!Bind
local textPanelTop : UILabel = nil
--!Bind
local buttonTutorial : UIButton = nil
--!Bind
local buttonClose : UIButton = nil
--!Bind
local buttonPreviousPage : UIButton = nil
--!Bind
local textButtonPreviousPage : UILabel = nil
--!Bind
local buttonNextPage : UIButton = nil
--!Bind
local textButtonNextPage : UILabel = nil
--!Bind
local tutorialPanelTop : UIImage = nil
--!Bind
local tutorialPanel1 : UIImage = nil
--!Bind
local textPanel1 : UILabel = nil
--!Bind
local tutorialPanel2 : UIImage = nil
--!Bind
local imagePanel2 : UIImage = nil
--!Bind
local textPanel2 : UILabel = nil
--!Bind
local tutorialPanel3 : UIImage = nil
--!Bind
local imagePanel3 : UIImage = nil
--!Bind
local textPanel3 : UILabel = nil
--!Bind
local tutorialPanel4 : UIImage = nil
--!Bind
local imagePanel4 : UIImage = nil
--!Bind
local textPanel4 : UILabel = nil
--!Bind
local tutorialPanel5 : UIImage = nil
--!Bind
local imagePanel5 : UIImage = nil
--!Bind
local textPanel5 : UILabel = nil
--!Bind
local tutorialPanel6 : UIImage = nil
--!Bind
local imagePanel6 : UIImage = nil
--!Bind
local textPanel6 : UILabel = nil

--!SerializeField
local sfx_uiOpen : AudioShader = nil
--!SerializeField
local sfx_uiClose : AudioShader = nil
--!SerializeField
local sfx_uiNextPage : AudioShader = nil


local currentPage : number = 1
pages = {}

Page1 = { name = "Welcome!", panel = tutorialPanel1}
Page2 = { name = "Pets!", panel = tutorialPanel2}
Page3 = { name = "Dig in!", panel = tutorialPanel3}
Page4 = { name = "Gachapon!", panel = tutorialPanel4}
Page5 = { name = "Collect em all!", panel = tutorialPanel5}
Page6 = { name = "Next stage!", panel = tutorialPanel6}

pages = { Page1, Page2, Page3, Page4, Page5, Page6}

textPanelTop:SetPrelocalizedText("Tutorial")
textButtonPreviousPage:SetPrelocalizedText("Previous")
textButtonNextPage:SetPrelocalizedText("Next")
textPanel1:SetPrelocalizedText("Welcome to SeaPetGo!\nYour objective is to be\nthe best shell catcher in the world!\nWith the help of cute little buddies,\n<b>are you ready for this adventure?!</b>")
textPanel2:SetPrelocalizedText("<b>Pets</b>, your partners, are very important.\nWith them you can start your journey\nand collect shells.")
textPanel3:SetPrelocalizedText("You collect shells\nby <b>clicking on a sandpile</b>\nwhen you have a pet following you.")
textPanel4:SetPrelocalizedText("But how do you obtain pets? Simple!\nJust <b>find the red bottle and click on it</b>\nwhen you have enough shells!\nAs a courtesy, you have 100 shells\nyou can spend right away!")
textPanel5:SetPrelocalizedText("After obtaining a Pet, <b>equip them by\nopening the inventory (Heart Icon)</b>,\nselect it and click the 'Equip Button'")
textPanel6:SetPrelocalizedText("  With that said, you can open up the\n  next step of your journey with shells.\n  <b>Find the big yellow barrier</b> and\n  spend some so you can keep going!\n  With each stage there's\n  new Pets available! Good luck!")

function self:ClientStart()
    for i = 2, #pages do
        pages[i].panel:AddToClassList("hide")
    end

    buttonClose:RegisterPressCallback(function () CloseTutorial() end)   
    buttonTutorial:RegisterPressCallback(function () OpenTutorial() end)   
    buttonNextPage:RegisterPressCallback(function () SetPage(currentPage + 1) end)   
    buttonPreviousPage:RegisterPressCallback(function () SetPage(currentPage - 1) end)   
end

function OpenTutorial()
    SetPage(1)
    Audio:PlayShader(sfx_uiOpen)
end

function SetPage(page)
    print(page)

    if(page <= 0) then
        page = #pages 
    end

    if(page > #pages) then
        page = 1
    end

    buttonNextPage:RemoveFromClassList("hide")
    buttonPreviousPage:RemoveFromClassList("hide")
    tutorialPanelTop:RemoveFromClassList("hide")
    buttonTutorial:AddToClassList("hide")

    pages[currentPage].panel:AddToClassList("hide")
    currentPage = page
    textPanelTop:SetPrelocalizedText(pages[currentPage].name)
    pages[currentPage].panel:RemoveFromClassList("hide")
    Audio:PlayShader(sfx_uiNextPage)    
end

function CloseTutorial()
    buttonNextPage:AddToClassList("hide")
    buttonPreviousPage:AddToClassList("hide")
    tutorialPanelTop:AddToClassList("hide")
    for i = 1, #pages do
        pages[i].panel:AddToClassList("hide")
    end
    buttonTutorial:RemoveFromClassList("hide")
    Audio:PlayShader(sfx_uiClose)   
end
