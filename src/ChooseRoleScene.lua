require "Cocos2d"
require "Cocos2dConstants"
require "Actor"
require "Knight"
require "Archer"
require "Mage"

--tag 3hero:1~3
--tag bag:10 weapon:11 armour:12 helmet:13
--tag actorinfo:101 actortext:102

local ChooseRoleScene  = class("ChooseRoleScene",function ()
	return cc.Scene:create()
end)

local sortorder = {1,2,3} --hero's tag
local rtt = {{x=-90,y=-60,z=0},{x=-90,y=-70,z=0},{x=-90,y=-60,z=0}}
local pos = {{x=160,y=200,z=-180},{x=380,y=160,z=-40},{x=530,y=200,z=-180}} --heroes' pos
local weapon_item_pos = {x=832,y=280}
local armour_item_pos = {x=916,y=280}
local helmet_item_pos = {x=1000,y=280}
local isMoving = false
local direction = 0
local heroSize = cc.rect(155,120,465,420)


function ChooseRoleScene.create()
    local scene = ChooseRoleScene.new()
    local layer = scene:createLayer()
    scene:addChild(layer)
    scene:initTouchDispatcher()
    ccexp.AudioEngine:stopAll()
    AUDIO_ID.CHOOSEROLESCENEBGM = ccexp.AudioEngine:play2d(BGM_RES.CHOOSEROLESCENEBGM, true,1)
    return scene
end

function ChooseRoleScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
end

function ChooseRoleScene:addBag()
    local bag = cc.Sprite:create("chooseRole/cr_bag.png")
    bag:setTag(10)
    bag:setAnchorPoint(1.0,0)
    self._bag = bag
    self:switchTextWhenRotate()

    self._weaponItem = cc.Sprite:create("equipment/cr_w_w_1.jpg")
    self._weaponItem:setTag(11)
    self._weaponItem:setScale(0.4)
    self._weaponItem:setPosition(weapon_item_pos)
    self.layer:addChild(self._weaponItem,2)
    
    self._armourItem = cc.Sprite:create("equipment/cr_w_a_1.jpg")
    self._armourItem:setTag(12)
    self._armourItem:setScale(0.4)
    self._armourItem:setPosition(armour_item_pos)
    self.layer:addChild(self._armourItem,2)
    
    self._helmetItem = cc.Sprite:create("equipment/cr_w_h_1.jpg")
    self._helmetItem:setTag(13)
    self._helmetItem:setScale(0.4)
    self._helmetItem:setPosition(helmet_item_pos)
    self.layer:addChild(self._helmetItem,2)

    bag:setPosition(self.origin.x + self.visibleSize.width - 10,self.origin.y + 50)
    self.layer:addChild(bag)
    
    return bag
end

function ChooseRoleScene:addButton()
    --button
    local touch_return = false
    local touch_next = false
    local function touchEvent_return(sender,eventType)
        if touch_return == false then
            touch_return = true
            if eventType == ccui.TouchEventType.began then
                ccexp.AudioEngine:play2d(BGM_RES.MAINMENUSTART, false,1)
                cc.Director:getInstance():replaceScene(require("MainMenuScene"):create())
            end
        end
    end  

    local return_Button = ccui.Button:create()
    return_Button:setTouchEnabled(true)
    return_Button:loadTextures("chooseRole/cr_arrow.png", "chooseRole/cr_arrow.png", "")
    return_Button:setAnchorPoint(0,1)
    return_Button:setPosition(20,600)
    return_Button:addTouchEventListener(touchEvent_return)        
    self.layer:addChild(return_Button)

    local function touchEvent_next(sender,eventType)
        if touch_next == false then
            touch_next = true
            if eventType == ccui.TouchEventType.began then
                ReSkin.knight = {weapon = self.layer:getChildByTag(2):getWeaponID(),
                                 armour = self.layer:getChildByTag(2):getArmourID(),
                                 helmet = self.layer:getChildByTag(2):getHelmetID()}
                ReSkin.arhcer = {weapon = self.layer:getChildByTag(1):getWeaponID(),
                                 armour = self.layer:getChildByTag(1):getArmourID(),
                                 helmet = self.layer:getChildByTag(1):getHelmetID()}
                ReSkin.mage = {weapon = self.layer:getChildByTag(3):getWeaponID(),
                                 armour = self.layer:getChildByTag(3):getArmourID(),
                                 helmet = self.layer:getChildByTag(3):getHelmetID()}

                ccexp.AudioEngine:play2d(BGM_RES.MAINMENUSTART, false,1)
                local scene = require("BattleScene")
                cc.Director:getInstance():replaceScene(scene.create())
            end
        end
    end  

    local next_Button = ccui.Button:create()
    next_Button:setTouchEnabled(true)
    next_Button:loadTextures("chooseRole/cr_arrow.png", "chooseRole/cr_arrow.png", "")
    next_Button:setFlippedX(true)
--    next_Button:setTitleText("Next")
    next_Button:setAnchorPoint(0,1)
    next_Button:setPosition(580,600)
    next_Button:addTouchEventListener(touchEvent_next)        
    self.layer:addChild(next_Button)
end

function ChooseRoleScene:addHeros()
    local knight = Knight.create()
    knight:setTag(2)
    knight:setRotation3D(rtt[2])
    knight:setPosition3D(pos[2])
    knight:setAIEnabled(false)
    knight:setScale(1.3)
    self.layer:addChild(knight)

    local archer = Archer.create()
    archer:setTag(1)
    archer:setRotation3D(rtt[1])
    archer:setPosition3D(pos[1])
    archer:setAIEnabled(false)
    archer:setScale(1.3)
    self.layer:addChild(archer)

    local mage = Mage.create()
    mage:setTag(3)
    mage:setRotation3D(rtt[3])
    mage:setPosition3D(pos[3])
    mage:setAIEnabled(false)
    mage:setScale(1.3)
    self.layer:addChild(mage)
end

function ChooseRoleScene:addBk()
	local bk = cc.Sprite:create("chooseRole/cr_bk.png")
    bk:setAnchorPoint(0.5,0.5)
    bk:setPosition(self.origin.x + self.visibleSize.width/2, self.origin.y + self.visibleSize.height/2)
    self.layer:addChild(bk)
end

function ChooseRoleScene:createLayer()
    
    --create layer
    self.layer = cc.Layer:create()
    
    --create bk
    self:addBk()
           
    --create heros
    self:addHeros() 
    
    --create arrow
    self:addButton()    
    
    --create bag
    self:addBag()
    
    return self.layer
end

--touch relative
function ChooseRoleScene:initTouchDispatcher()
    local isRotateavaliable = false
    local isWeaponItemavaliable = false
    local isArmourItemavaliable = false
    local isHelmetItemavaliable = false
    local touchbeginPt
    local listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
        touchbeginPt = touch:getLocation()
        if cc.rectContainsPoint(heroSize,touchbeginPt) then --rotate
            isRotateavaliable = true
        elseif cc.rectContainsPoint(self._weaponItem:getBoundingBox(),touchbeginPt) then --weapon
            isWeaponItemavaliable = true
            self._weaponItem:setScale(0.5)
            self._weaponItem:setOpacity(100)
        elseif cc.rectContainsPoint(self._armourItem:getBoundingBox(),touchbeginPt) then --armour
            isArmourItemavaliable = true
            self._armourItem:setScale(0.5)
            self._armourItem:setOpacity(100)
        elseif cc.rectContainsPoint(self._helmetItem:getBoundingBox(),touchbeginPt) then --helmet
            isHelmetItemavaliable = true
            self._helmetItem:setScale(0.5)
            self._helmetItem:setOpacity(100)
        end
        
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
        if isRotateavaliable == true and isMoving == false then --rotate
            local dist = touch:getLocation().x - touchbeginPt.x
            if dist>50 then
                --right
                self:rotate3Heroes(true)
                isRotateavaliable = false	
            elseif dist<-50 then
                --left
                self:rotate3Heroes(false)
                isRotateavaliable = false
            else
        
            end
        elseif isWeaponItemavaliable then --weapon
            self._weaponItem:setPosition(touch:getLocation())
        elseif isArmourItemavaliable then --armour
            self._armourItem:setPosition(touch:getLocation())
        elseif isHelmetItemavaliable then --helmet
            self._helmetItem:setPosition(touch:getLocation())
        end
    end,cc.Handler.EVENT_TOUCH_MOVED )
    listenner:registerScriptHandler(function(touch, event)
        if isRotateavaliable then --rotate
            isRotateavaliable = false
        elseif isWeaponItemavaliable then
            isWeaponItemavaliable = false
            self._weaponItem:setPosition(weapon_item_pos)
            self._weaponItem:setScale(0.4)
            self._weaponItem:setOpacity(255)
            self.layer:getChildByTag(sortorder[2]):switchWeapon()
            self._weaponItem:setTexture(self:getWeaponTextureName())
        elseif isArmourItemavaliable then
            isArmourItemavaliable = false
            self._armourItem:setPosition(armour_item_pos)
            self._armourItem:setScale(0.4)
            self._armourItem:setOpacity(255)
            self.layer:getChildByTag(sortorder[2]):switchArmour()
            self._armourItem:setTexture(self:getArmourTextureName())
        elseif isHelmetItemavaliable then
            isHelmetItemavaliable = false
            self._helmetItem:setPosition(helmet_item_pos)
            self._helmetItem:setScale(0.4)
            self._helmetItem:setOpacity(255)
            self.layer:getChildByTag(sortorder[2]):switchHelmet()
            self._helmetItem:setTexture(self:getHelmetTextureName())
        end
    end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self.layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.layer)
end

function ChooseRoleScene:rotate3Heroes(isRight)
    local rotatetime = 0.6
    if isRight then
        local middle = self.layer:getChildByTag(sortorder[2])
        middle:runAction(cc.Sequence:create(
            cc.CallFunc:create(function() isMoving = true end), 
            cc.Spawn:create(
                cc.EaseCircleActionInOut:create(cc.MoveTo:create(rotatetime,pos[3]))
            ),
            cc.CallFunc:create(function() 
                isMoving = false
                self:playAudioWhenRotate()
            end)))
        local left = self.layer:getChildByTag(sortorder[1])
        left:runAction(cc.EaseCircleActionInOut:create(cc.MoveTo:create(rotatetime,pos[2])))
        local right = self.layer:getChildByTag(sortorder[3])
        right:runAction(cc.EaseCircleActionInOut:create(cc.MoveTo:create(rotatetime,pos[1])))
        local t = sortorder[3]
        sortorder[3]=sortorder[2]
        sortorder[2]=sortorder[1]
        sortorder[1]=t
    else
        local middle = self.layer:getChildByTag(sortorder[2])
        middle:runAction(cc.Sequence:create(
            cc.CallFunc:create(function() 
                isMoving = true
            end), 
            cc.Spawn:create(
                cc.EaseCircleActionInOut:create(cc.MoveTo:create(rotatetime,pos[1]))
            ),
            cc.CallFunc:create(function()
                isMoving = false 
                self:playAudioWhenRotate()
            end)))
        local left = self.layer:getChildByTag(sortorder[1])
        left:runAction(cc.EaseCircleActionInOut:create(cc.MoveTo:create(rotatetime,pos[3])))
        local right = self.layer:getChildByTag(sortorder[3])
        right:runAction(cc.EaseCircleActionInOut:create(cc.MoveTo:create(rotatetime,pos[2])))
        local t = sortorder[1]
        sortorder[1]=sortorder[2]
        sortorder[2]=sortorder[3]
        sortorder[3]=t
    end

    self:switchItemtextureWhenRotate()
    self:switchTextWhenRotate()
end

function ChooseRoleScene:getWeaponTextureName()
    local hero = self.layer:getChildByTag(sortorder[2])
    if hero._name == "Knight" then --warriors
        if hero:getWeaponID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_w_1.jpg")
    elseif hero:getWeaponID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_w_0.jpg")
        end
    elseif hero._name == "Archer" then --archer
        if hero:getWeaponID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_w_1.jpg")
        elseif hero:getWeaponID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_w_0.jpg")
        end
    elseif hero._name == "Mage" then --sorceress
        if hero:getWeaponID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_w_1.jpg")
        elseif hero:getWeaponID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_w_0.jpg")
        end
    end
end

function ChooseRoleScene:getArmourTextureName()
    local hero = self.layer:getChildByTag(sortorder[2])
    if hero._name == "Knight" then --warriors
        if hero:getArmourID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_a_1.jpg")
    elseif hero:getArmourID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_a_0.jpg")
        end
    elseif hero._name == "Archer" then --archer
        if hero:getArmourID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_a_1.jpg")
        elseif hero:getArmourID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_a_0.jpg")
        end
    elseif hero._name == "Mage" then --sorceress
        if hero:getArmourID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_a_1.jpg")
        elseif hero:getArmourID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_a_0.jpg")
        end
    end
end

function ChooseRoleScene:getHelmetTextureName()
    local hero = self.layer:getChildByTag(sortorder[2])
    if hero._name == "Knight" then --warriors
        if hero:getHelmetID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_h_1.jpg")
    elseif hero:getHelmetID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_h_0.jpg")
        end
    elseif hero._name == "Archer" then --archer
        if hero:getHelmetID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_h_1.jpg")
        elseif hero:getHelmetID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_h_0.jpg")
        end
    elseif hero._name == "Mage" then --sorceress
        if hero:getHelmetID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_h_1.jpg")
        elseif hero:getHelmetID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_h_0.jpg")
        end
    end
end

function ChooseRoleScene:switchItemtextureWhenRotate()
	local hero = self.layer:getChildByTag(sortorder[2])
	local xxx = sortorder[2]
	local weaponTexture
	local armourTexture
    local helmetTexture
	local type = hero:getRaceType();
	
    if hero._name == "Knight" then --warroir
	   if hero:getWeaponID() == 0 then
            weaponTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_w_1.jpg")
   	   else
        weaponTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_w_0.jpg")
	   end
       if hero:getArmourID() == 0 then
        armourTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_a_1.jpg")
       else
        armourTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_a_0.jpg")
       end
       if hero:getHelmetID() == 0 then
        helmetTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_h_1.jpg")
       else
        helmetTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_h_0.jpg")
       end
	end
	
    if hero._name == "Archer" then --archer
        if hero:getWeaponID() == 0 then
            weaponTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_w_1.jpg")
        else
        weaponTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_w_0.jpg")
        end
        if hero:getArmourID() == 0 then
        armourTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_a_1.jpg")
        else
        armourTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_a_0.jpg")
        end
        if hero:getHelmetID() == 0 then
        helmetTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_h_1.jpg")
        else
        helmetTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_h_0.jpg")
        end
    end
    
    if hero._name == "Mage" then --sorceress
        if hero:getWeaponID() == 0 then
            weaponTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_w_1.jpg")
        else
        weaponTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_w_0.jpg")
        end
        if hero:getArmourID() == 0 then
        armourTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_a_1.jpg")
        else
        armourTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_a_0.jpg")
        end
        if hero:getHelmetID() == 0 then
        helmetTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_h_1.jpg")
        else
        helmetTexture = cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_h_0.jpg")
        end
    end
	self._weaponItem:setTexture(weaponTexture)
	self._armourItem:setTexture(armourTexture)
    self._helmetItem:setTexture(helmetTexture)
end

function ChooseRoleScene:switchTextWhenRotate()
    --get hero type
    local hero = self.layer:getChildByTag(sortorder[2])
    local type = hero:getRaceType()
    --get bag , bagSize and judge if has child
    local bag = self._bag
    local size = bag:getContentSize()
    local actor = bag:getChildByTag(101)
    if actor ~= nil then
        bag:removeChildByTag(101)
        bag:removeChildByTag(102)
    end
    --actor point
    local point = 0
    
    --label
    local ttfconfig = {outlineSize=0,fontSize=15,fontFilePath="chooseRole/actor_param.ttf"}
    local text = "LEVEL".."\n".."ATT".."\n".."HP".."\n".."DEF".."\n".."AGI".."\n".."CRT".."\n".."S.ATT"
    local attr = nil
    
    --set actor and label
    if hero._name == "Knight" then --warriors
        actor = cc.Sprite:create("chooseRole/knight.png")
        point = cc.p(size.width*0.395,size.height*0.9)
        attr = "1".."\n"..KnightValues._normalAttack.damage.."\n"..KnightValues._hp.."\n"..KnightValues._defense.."\n"..(KnightValues._AIFrequency*100).."\n"..KnightValues._specialAttack.damage.."\n"..KnightValues._specialAttack.damage
    elseif hero._name == "Archer" then --archer
        actor = cc.Sprite:create("chooseRole/archer.png")
        point = cc.p(size.width*0.4,size.height*0.905)
        attr = "1".."\n"..ArcherValues._normalAttack.damage.."\n"..ArcherValues._hp.."\n"..ArcherValues._defense.."\n"..(ArcherValues._AIFrequency*100).."\n"..ArcherValues._specialAttack.damage.."\n"..ArcherValues._specialAttack.damage
    elseif hero._name == "Mage" then --sorceress
        actor = cc.Sprite:create("chooseRole/mage.png")
        point = cc.p(size.width*0.38,size.height*0.9)
        attr = "1".."\n"..MageValues._normalAttack.damage.."\n"..MageValues._hp.."\n"..MageValues._defense.."\n"..(MageValues._AIFrequency*100).."\n"..MageValues._specialAttack.damage.."\n"..MageValues._specialAttack.damage
    end
    
    --add to bag
    actor:setPosition(point)
    local text_label = cc.Label:createWithTTF(ttfconfig,text,cc.TEXT_ALIGNMENT_RIGHT,400)
    text_label:setPosition(cc.p(size.width*0.4,size.height*0.68))
    text_label:enableShadow(cc.c4b(92,50,31,255),cc.size(1,-2),0)
    
    local attr_label = cc.Label:createWithTTF(ttfconfig,attr,cc.TEXT_ALIGNMENT_CENTER,400)
    attr_label:setPosition(cc.p(size.width*0.7,size.height*0.68))
    attr_label:enableShadow(cc.c4b(92,50,31,255),cc.size(1,-2),0)
    bag:addChild(actor,1,101)
    bag:addChild(text_label,1)
    bag:addChild(attr_label,1,102)
end

function ChooseRoleScene:playAudioWhenRotate()
	
    local hero = self.layer:getChildByTag(sortorder[2])
    local type = hero:getRaceType()
    if hero._name == "Knight" then
        ccexp.AudioEngine:play2d(WarriorProperty.kickit, false,1)
    elseif hero._name == "Archer" then
        ccexp.AudioEngine:play2d(Archerproperty.cheers, false,1)
    elseif hero._name == "Mage" then
        ccexp.AudioEngine:play2d(MageProperty.alright, false,1)
    end
end

return ChooseRoleScene