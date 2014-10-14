require "GlobalVariables"
require "Base3D"

local BattlefieldUI = class("battlefieldUI",function() return cc.Layer:create() end)

function BattlefieldUI.create()
    local layer = BattlefieldUI.new()
	return layer
end

function BattlefieldUI:ctor()
    self:avatarInit()
    self:bloodbarInit()
    self:touchButtonInit()

end

function BattlefieldUI:avatarInit()
    self.WarriorPng = cc.Sprite:create("battlefieldUI/UI-1136-640_03.png")
    self.WarriorPng:setPosition(90.5,566.72)
    self.WarriorPng:setScale(0.70)
    self.WarriorPng:setOpacity(255*0.7)
    self:addChild(self.WarriorPng,2)
       
    self.ArcherPng = cc.Sprite:create("battlefieldUI/UI-1136-640_11.png")
    self.ArcherPng:setPosition(200.5,566.72)
    self.ArcherPng:setScale(0.70)
    self.ArcherPng:setOpacity(255*0.7)
    self:addChild(self.ArcherPng,2)
    
    self.MagePng = cc.Sprite:create("battlefieldUI/UI-1136-640_18.png")
    self.MagePng:setPosition(310.5,566.72)
    self.MagePng:setScale(0.70)    
    self.MagePng:setOpacity(255*0.7)
    self:addChild(self.MagePng,2)
end

function BattlefieldUI:bloodbarInit()
    self.WarriorBlood = ccui.LoadingBar:create("battlefieldUI/UI-1136-640_36.png",100)
    self.WarriorBlood:setPosition(self.WarriorPng:getPositionX(), (532/566.72)*self.WarriorPng:getPositionY())
    self.WarriorBlood:setScale(0.7)
    self.WarriorBlood:setOpacity(255*0.6)
    self:addChild(self.WarriorBlood,3)
    
    self.ArcherBlood = ccui.LoadingBar:create("battlefieldUI/UI-1136-640_36.png",100)
    self.ArcherBlood:setPosition(self.ArcherPng:getPositionX(), (532/566.72)*self.ArcherPng:getPositionY())
    self.ArcherBlood:setScale(0.7)
    self.ArcherBlood:setOpacity(255*0.6)
    self:addChild(self.ArcherBlood,3)
    
    self.MageBlood = ccui.LoadingBar:create("battlefieldUI/UI-1136-640_36.png",100)
    self.MageBlood:setPosition(self.MagePng:getPositionX(), (532/566.72)*self.MagePng:getPositionY())
    self.MageBlood:setScale(0.7)
    self.MageBlood:setOpacity(255*0.6)
    self:addChild(self.MageBlood,3)
end

function BattlefieldUI:touchButtonInit()
    self.DefenceBtn = ccui.Button:create("battlefieldUI/UI-1136-640_26.png","battlefieldUI/UI-1136-640_24.png","battlefieldUI/UI-1136-640_22.png",0)
    self.DefenceBtn:setPosition(1019.50,109)
    self.DefenceBtn:setOpacity(255*0.9)
    self:addChild(self.DefenceBtn,3)

    self.SetBtn = ccui.Button:create("battlefieldUI/UI-1136-640_06.png","battlefieldUI/UI-1136-640_06.png","battlefieldUI/UI-1136-640_06.png",0)
    self.SetBtn:setPosition(1019.50,570)
    self.SetBtn:setOpacity(255*0.9)
    self:addChild(self.SetBtn,3)
end

local scheduleID = nil

function BattlefieldUI:bloodDrop(dropValuePercent,hero)

    if hero._racetype==EnumRaceType.WARRIOR then
        self.WarriorBlood:setPercent(100-dropValuePercent)
    end

    if hero._racetype==EnumRaceType.ARCHER then
        self.ArcherBlood:setPercent(100-dropValuePercent)
    end

    if hero._racetype==EnumRaceType.SORCERESS then
        self.MageBlood:setPercent(100-dropValuePercent)
    end    
--    local function update(dt)
--        if self.WarriorBlood:getPercent()>(100-dropValuePercent) then
--            self.WarriorBlood:setPercent(self.WarriorBlood:getPercent()-G.bloodPercentDropSpeed)
--        elseif scheduleID ~= nil then
--            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
--        end
--    end
--    
--    scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update,0,false)
end

return BattlefieldUI