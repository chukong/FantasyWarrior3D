require "GlobalVariables"
require "Actor"

local BattlefieldUI = class("battlefieldUI",function() return cc.Layer:create() end)

function BattlefieldUI.create()
    local layer = BattlefieldUI.new()
	return layer
end

function BattlefieldUI:ctor()
    self:avatarInit()
    self:bloodbarInit()
    self:touchButtonInit()
--    ccexp.AudioEngine:play2d("audios/The Last Encounter Short Loop.mp3", true,100)
end

function BattlefieldUI:avatarInit()
    self.WarriorPng = cc.Sprite:create("battlefieldUI/UI-1136-640_03.png")
    self.WarriorPng:setPosition(90.5/1136*G.winSize.width,566.72/640*G.winSize.height)
    self.WarriorPng:setScale(0.70)
    self:addChild(self.WarriorPng,2)
       
    self.ArcherPng = cc.Sprite:create("battlefieldUI/UI-1136-640_11.png")
    self.ArcherPng:setPosition(200.5/1136*G.winSize.width,566.72/640*G.winSize.height)
    self.ArcherPng:setScale(0.70)
    self:addChild(self.ArcherPng,2)
    
    self.MagePng = cc.Sprite:create("battlefieldUI/UI-1136-640_18.png")
    self.MagePng:setPosition(310.5/1136*G.winSize.width,566.72/640*G.winSize.height)
    self.MagePng:setScale(0.70)    
    self:addChild(self.MagePng,2)
end

function BattlefieldUI:bloodbarInit()

    self.WarriorBlood = cc.ProgressTimer:create(cc.Sprite:create("battlefieldUI/UI-1136-640_36.png"))
    self.WarriorBlood:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.WarriorBlood:setBarChangeRate(cc.vertex2F(1,0))
    self.WarriorBlood:setMidpoint(cc.vertex2F(0,0))
    self.WarriorBlood:setPercentage(100)
    self.WarriorBlood:setPosition(self.WarriorPng:getPositionX(), (532/566.72)*self.WarriorPng:getPositionY())
    self.WarriorBlood:setScale(0.7)
    self:addChild(self.WarriorBlood,4)
        
    self.WarriorBloodClone = cc.ProgressTimer:create(cc.Sprite:create("battlefieldUI/UI-1136-640_36_clone.png"))
    self.WarriorBloodClone:setColor(cc.c3b(255,83,23))
    self.WarriorBloodClone:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.WarriorBloodClone:setBarChangeRate(cc.vertex2F(1,0))
    self.WarriorBloodClone:setMidpoint(cc.vertex2F(0,0))
    self.WarriorBloodClone:setPercentage(100)
    self.WarriorBloodClone:setPosition(self.WarriorPng:getPositionX(), (532/566.72)*self.WarriorPng:getPositionY())
    self.WarriorBloodClone:setScaleX(0.7)
    self:addChild(self.WarriorBloodClone,3)
        
    self.ArcherBlood = cc.ProgressTimer:create(cc.Sprite:create("battlefieldUI/UI-1136-640_36.png"))
    self.ArcherBlood:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.ArcherBlood:setMidpoint(cc.vertex2F(0,0))
    self.ArcherBlood:setBarChangeRate(cc.vertex2F(1,0))
    self.ArcherBlood:setPercentage(100)
    self.ArcherBlood:setPosition(self.ArcherPng:getPositionX(), (532/566.72)*self.ArcherPng:getPositionY())
    self.ArcherBlood:setScale(0.7)
    self.ArcherBlood:setOpacity(255*0.8)
    self:addChild(self.ArcherBlood,4)

    self.ArcherBloodClone = cc.ProgressTimer:create(cc.Sprite:create("battlefieldUI/UI-1136-640_36_clone.png"))
    self.ArcherBloodClone:setColor(cc.c3b(255,83,23))
    self.ArcherBloodClone:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.ArcherBloodClone:setBarChangeRate(cc.vertex2F(1,0))
    self.ArcherBloodClone:setMidpoint(cc.vertex2F(0,0))
    self.ArcherBloodClone:setPercentage(100)
    self.ArcherBloodClone:setPosition(self.ArcherPng:getPositionX(), (532/566.72)*self.ArcherPng:getPositionY())
    self.ArcherBloodClone:setScaleX(0.7)
    self:addChild(self.ArcherBloodClone,3)
 
    self.MageBlood = cc.ProgressTimer:create(cc.Sprite:create("battlefieldUI/UI-1136-640_36.png"))
    self.MageBlood:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.MageBlood:setMidpoint(cc.vertex2F(0,0))
    self.MageBlood:setBarChangeRate(cc.vertex2F(1,0))
    self.MageBlood:setPercentage(100)
    self.MageBlood:setPosition(self.MagePng:getPositionX(), (532/566.72)*self.MagePng:getPositionY())
    self.MageBlood:setScale(0.7)
    self.MageBlood:setOpacity(255*0.8)
    self:addChild(self.MageBlood,4)
    
    self.MageBloodClone = cc.ProgressTimer:create(cc.Sprite:create("battlefieldUI/UI-1136-640_36_clone.png"))
    self.MageBloodClone:setColor(cc.c3b(255,83,23))
    self.MageBloodClone:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.MageBloodClone:setBarChangeRate(cc.vertex2F(1,0))
    self.MageBloodClone:setMidpoint(cc.vertex2F(0,0))
    self.MageBloodClone:setPercentage(100)
    self.MageBloodClone:setPosition(self.MagePng:getPositionX(), (532/566.72)*self.MagePng:getPositionY())
    self.MageBloodClone:setScaleX(0.7)
    self:addChild(self.MageBloodClone,3)


end

function BattlefieldUI:touchButtonInit()
    self.DefenceBtn = ccui.Button:create("battlefieldUI/UI-1136-640_26.png","battlefieldUI/UI-1136-640_24.png","battlefieldUI/UI-1136-640_22.png",0)
    self.DefenceBtn:setPosition(1019.50/1136*G.winSize.width,109/640*G.winSize.height)
    self.DefenceBtn:setOpacity(255*0.9)
    self:addChild(self.DefenceBtn,3)

    self.SetBtn = ccui.Button:create("battlefieldUI/UI-1136-640_06.png","battlefieldUI/UI-1136-640_06.png","battlefieldUI/UI-1136-640_06.png",0)
    self.SetBtn:setPosition(1019.50/1136*G.winSize.width,570/640*G.winSize.height)
    self.SetBtn:setOpacity(255*0.9)
    self:addChild(self.SetBtn,3)
end

local scheduleID = nil

function BattlefieldUI:bloodDrop(dropValuePercent,hero)

    local progressTo = cc.ProgressTo:create(0.5,100-dropValuePercent)
    local progressToClone = cc.ProgressTo:create(1,100-dropValuePercent)

    if hero._racetype==EnumRaceType.WARRIOR then
        self.WarriorBlood:runAction(progressTo)
        self.WarriorBloodClone:runAction(progressToClone)
    end

    if hero._racetype==EnumRaceType.ARCHER then
        self.ArcherBlood:runAction(progressTo)
    end

    if hero._racetype==EnumRaceType.MAGE then
        self.MageBlood:runAction(progressTo)
    end
end

return BattlefieldUI