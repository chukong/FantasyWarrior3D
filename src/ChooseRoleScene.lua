require "Cocos2d"
require "Cocos2dConstants"
require "Actor"

--tag 3hero:1~3
--tag bag:10 weapon:11 armour:12

local ChooseRoleScene  = class("ChooseRoleScene",function ()
	return cc.Scene:create()
end)

local sortorder = {1,2,3} --hero's tag
local pos = {{x=210,y=160,z=-120},{x=400,y=120,z=0},{x=530,y=160,z=-120}} --heroes' pos
local weapon_item_pos = {x=834,y=274}
local armour_item_pos = {x=918,y=274}
local isMoving = false
local direction = 0
local heroSize = cc.rect(155,120,465,420)


function ChooseRoleScene.create()
    local scene = ChooseRoleScene.new()
    local layer = scene:createLayer()
    scene:addChild(layer)
    scene:initTouchDispatcher()
    return scene
end

function ChooseRoleScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
end

function ChooseRoleScene:addHero(hero_type, pos)
    local hero3d = require("Hero3D")
    local hero = hero3d.create(hero_type)
    hero:setScale(8)
    hero:setRotation3D({x=-90,y=-90,z=0})
    hero:setPosition(pos)    
    
    return hero
end

function ChooseRoleScene:addBag()
    local bag = cc.Sprite:create("chooseRole/cr_bag.png")
    bag:setTag(10)
    bag:setAnchorPoint(1.0,0)
    
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
    
    return bag
end

function ChooseRoleScene:addButton()
    -- rotate button
    local function touchEvent_arrowleft(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            direction = 1
        elseif eventType == ccui.TouchEventType.ended then
            direction = 0
        elseif eventType == ccui.TouchEventType.canceled then
            direction = 0
        end
    end

    local function touchEvent_arrowright(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            direction = 2
        elseif eventType == ccui.TouchEventType.ended then
            direction = 0
        elseif eventType == ccui.TouchEventType.canceled then
            direction = 0
        end
    end

    local function touchEvent_arrowreset(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self.layer:getChildByTag(sortorder[2]):setRotation3D({x=0,y=50,z=0})
        end
    end

    local picfileName = "chooseRole/cr_rotate.png"
    local button_left = ccui.Button:create()
    button_left:loadTextures(picfileName,picfileName,"")
    button_left:setPosition(300,50)
    button_left:addTouchEventListener(touchEvent_arrowleft)
    self.layer:addChild(button_left)

    picfileName = "chooseRole/cr_rotate.png"
    local button_right = ccui.Button:create()
    button_right:loadTextures(picfileName,picfileName,"")
    button_right:setFlippedX(true)
    button_right:setPosition(500,50)
    button_right:addTouchEventListener(touchEvent_arrowright)
    self.layer:addChild(button_right)

    picfileName = "chooseRole/cr_reset.png"
    local button_reset = ccui.Button:create()
    button_reset:loadTextures(picfileName,picfileName,"")
    button_reset:setPosition(400,50)
    button_reset:addTouchEventListener(touchEvent_arrowreset)
    self.layer:addChild(button_reset)
    
    --button
    local function touchEvent_return(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
--            print("return to main menu")
            cc.Director:getInstance():replaceScene(require("MainMenuScene"):create())
        end
    end  

    local return_Button = ccui.Button:create()
    return_Button:setTouchEnabled(true)
    return_Button:loadTextures("chooseRole/cr_arrow.png", "chooseRole/cr_arrow.png", "")
--    return_Button:setTitleText("Return")
    return_Button:setAnchorPoint(0,1)
    return_Button:setPosition(20,600)
    return_Button:addTouchEventListener(touchEvent_return)        
    self.layer:addChild(return_Button)

    local function touchEvent_next(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("go to game")
            local scene = require("BattleScene")
            cc.Director:getInstance():replaceScene(scene.create())
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

function ChooseRoleScene:createLayer()
    
    --create layer
    self.layer = cc.Layer:create()
    
    --create bk
    local bk = cc.Sprite:create("chooseRole/cr_bk.jpg")
    bk:setAnchorPoint(0.5,0.5)
    bk:setPosition(self.origin.x + self.visibleSize.width/2, self.origin.y + self.visibleSize.height/2)
    self.layer:addChild(bk)
    
    --create bag
    local bag = self:addBag()
    bag:setPosition(self.origin.x + self.visibleSize.width - 10,self.origin.y + 50)
    self.layer:addChild(bag)
        
    --create warrior,archer,sorceress
    local warrior = self:addHero(EnumRaceType.WARRIOR,pos[2])
    warrior:setTag(2)
    self.layer:addChild(warrior)
    local xxx = warrior._type
    
    --create warrior,archer,sorceress
    
    local archer = self:addHero(EnumRaceType.ARCHER,pos[1])
    archer:setPositionZ(-100)
    archer:setTag(1)
    self.layer:addChild(archer)
    
    --create warrior,archer,sorceress
    local sorceress = self:addHero(EnumRaceType.WAGE,pos[3])
    sorceress:setPositionZ(-100)
    sorceress:setTag(3)
    self.layer:addChild(sorceress)
    
    --test
--    local test = cc.Sprite3D:create("Sprite3DTest/zhanshi_v002fixed.c3b")
--    test:setTexture("Sprite3DTest/ZHANSHI_type01_head.jpg")
--    --test:setTexture("Sprite3DTest/ZHANSHI_type01_body.jpg")
--    test:setScale(50.0)
--    test:setRotation3D({x=0,y=30,z=0})
--    test:setPosition(300,500)
--    self.layer:addChild(test)
    
    --create arrow
    self:addButton()
    
    local selflayer = self.layer;
    
    --update scheduler
    local function update(dt)
        if direction == 1  then --left
            local t = self.layer:getChildByTag(sortorder[2]):getRotation3D()
            self.layer:getChildByTag(sortorder[2]):setRotation3D({x=0,y=t.y-5,z=0})
        elseif direction == 2 then --right
            local t = self.layer:getChildByTag(sortorder[2]):getRotation3D()
            self.layer:getChildByTag(sortorder[2]):setRotation3D({x=0,y=t.y+5,z=0})
        else
        
        end
    end
    
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(update,0,false)
    
    return self.layer
end

--touch relative
function ChooseRoleScene:initTouchDispatcher()
    local isRotateavaliable = false
    local isWeaponItemavaliable = false
    local isArmourItemavaliable = false
    local touchbeginPt
    local listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
        touchbeginPt = touch:getLocation()
        if cc.rectContainsPoint(heroSize,touchbeginPt) then --rotate
            isRotateavaliable = true
        elseif cc.rectContainsPoint(self._weaponItem:getBoundingBox(),touchbeginPt) then -- weapon
            isWeaponItemavaliable = true
            self._weaponItem:setScale(0.5)
            self._weaponItem:setOpacity(100)
        elseif cc.rectContainsPoint(self._armourItem:getBoundingBox(),touchbeginPt) then --armour
            isArmourItemavaliable = true
            self._armourItem:setScale(0.5)
            self._armourItem:setOpacity(100)
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
        end
    end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self.layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.layer)
end

function ChooseRoleScene:getWeaponTextureName()
    local hero = self.layer:getChildByTag(sortorder[2])
    local type = hero:getRaceType()
    if hero:getRaceType() == EnumRaceType.WARRIOR then --warriors
        if hero:getWeaponID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_w_1.jpg")
        elseif hero:getWeaponID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_w_0.jpg")
        end
    elseif hero:getRaceType() == EnumRaceType.ARCHER then --archer
        if hero:getWeaponID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_w_1.jpg")
        elseif hero:getWeaponID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_w_0.jpg")
        end
    elseif hero:getRaceType() == EnumRaceType.WAGE then --sorceress
        if hero:getWeaponID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_w_1.jpg")
        elseif hero:getWeaponID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_w_0.jpg")
        end
    end
end

function ChooseRoleScene:getArmourTextureName()
    local hero = self.layer:getChildByTag(sortorder[2])
    if hero:getRaceType() == EnumRaceType.WARRIOR then --warriors
        if hero:getArmourID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_a_1.jpg")
    elseif hero:getArmourID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_w_a_0.jpg")
        end
    elseif hero:getRaceType() == EnumRaceType.ARCHER then --archer
        if hero:getArmourID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_a_1.jpg")
        elseif hero:getArmourID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_a_a_0.jpg")
        end
    elseif hero:getRaceType() == EnumRaceType.WAGE then --sorceress
        if hero:getArmourID() == 0 then
            return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_a_1.jpg")
        elseif hero:getArmourID() ==1 then
        return cc.Director:getInstance():getTextureCache():addImage("equipment/cr_s_a_0.jpg")
        end
    end
end

function ChooseRoleScene:rotate3Heroes(isRight)
    local rotatetime = 0.3
    if isRight then
        local middle = self.layer:getChildByTag(sortorder[2])
        middle:runAction(cc.Sequence:create(
                cc.CallFunc:create(function() isMoving = true end), 
                cc.Spawn:create(
                    cc.MoveTo:create(rotatetime,pos[3])
                    ),
                cc.CallFunc:create(function() 
                    isMoving = false
                    for i=1,3 do
                        --self.layer:getChildByTag(sortorder[i]):setRotation3D({x=0,y=50,z=0})
                    end
                    end)))
        local left = self.layer:getChildByTag(sortorder[1])
        left:runAction(cc.Spawn:create(cc.MoveTo:create(rotatetime,pos[2])))
        local right = self.layer:getChildByTag(sortorder[3])
        right:runAction(cc.Spawn:create(cc.MoveTo:create(rotatetime,pos[1])))
    	local t = sortorder[3]
    	sortorder[3]=sortorder[2]
    	sortorder[2]=sortorder[1]
    	sortorder[1]=t
    else
        local middle = self.layer:getChildByTag(sortorder[2])
        middle:runAction(cc.Sequence:create(
            cc.CallFunc:create(function() 
                isMoving = true
                for i=1,3 do
                    --self.layer:getChildByTag(sortorder[i]):setRotation3D({x=0,y=50,z=0})
                end
            end), 
            cc.Spawn:create(
                cc.MoveTo:create(rotatetime,pos[1])
                ),
            cc.CallFunc:create(function() isMoving = false end)))
        local left = self.layer:getChildByTag(sortorder[1])
        left:runAction(cc.Spawn:create(cc.MoveTo:create(rotatetime,pos[3])))
        local right = self.layer:getChildByTag(sortorder[3])
        right:runAction(cc.Spawn:create(cc.MoveTo:create(rotatetime,pos[2])))
        local t = sortorder[1]
        sortorder[1]=sortorder[2]
        sortorder[2]=sortorder[3]
        sortorder[3]=t
    end
    
    self:switchItemtextureWhenRotate()
end



function ChooseRoleScene:switchItemtextureWhenRotate()
	local hero = self.layer:getChildByTag(sortorder[2])
	local xxx = sortorder[2]
	local weaponTexture
	local armourTexture
	local type = hero:getRaceType();
	
    if hero:getRaceType() == EnumRaceType.WARRIOR then --warroir
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
	end
	
    if hero:getRaceType() == EnumRaceType.ARCHER then --archer
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
    end
    
    if hero:getRaceType() == EnumRaceType.WAGE then --sorceress
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
    end
	self._weaponItem:setTexture(weaponTexture)
	self._armourItem:setTexture(armourTexture)
end

function ChooseRoleScene:switchTextWhenRotate()
    --
end
return ChooseRoleScene