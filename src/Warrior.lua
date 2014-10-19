require "GlobalVariables"
require "MessageDispatchCenter"
require "Helper"
require "AttackCommand"

Warrior = class("Warrior", function()
    return require "Actor".create()
end)

local size = cc.Director:getInstance():getWinSize()
local scheduler = cc.Director:getInstance():getScheduler()
local filename  = "model/warrior/warrior.c3b"

function Warrior:ctor()
    self._useWeaponId = 0
    self._useArmourId = 0
    self._particle = nil
    self._attack = 300  
end

function Warrior.create()
    
    local mainloop_schedulerid

    local hero = Warrior.new()
    hero:init3D()

    -- base
    hero:setRaceType(EnumRaceType.WARRIOR)
    hero:setState(EnumStateType.STAND)
    hero:initActions()
    
    local function MainLoop(dt)
        
--     getDebugStateType(hero)
        if EnumStateType.WALK == hero._statetype then
            hero:walkUpdate(dt)
        elseif EnumStateType.STAND == hero._statetype then
            hero._statetype = EnumStateType.STANDING
            hero._sprite3d:runAction(hero._action.stand:clone())

        elseif EnumStateType.NORMALATTACK == hero._statetype then
            hero._statetype = EnumStateType.NORMALATTACKING
            local function sendKnockedMsg()
                --MessageDispatchCenter:dispatchMessage(MessageDispatchCenter.MessageType.KNOCKED, createKnockedMsgStruct(hero))
                --cclog("warrior send msg....")
                AttackCommand.create(hero)
            end
            local function attackdone()
                hero:setState(EnumStateType.STAND)
            end
            local attack = cc.Sequence:create(hero._action.attack1:clone(),cc.CallFunc:create(sendKnockedMsg),hero._action.attack2,cc.CallFunc:create(attackdone))
            hero._sprite3d:runAction(attack)
        elseif EnumStateType.SPECIALATTACK == hero._statetype then
            hero._statetype = EnumStateType.SPECIALATTACKING
            local function sendKnockedMsg()
                --MessageDispatchCenter:dispatchMessage(MessageDispatchCenter.MessageType.KNOCKEDAOE, createKnockedMsgStruct(hero))
                --cclog("warrior send msg....")
                AttackCommand.create(hero)
            end
            local function attackdone()
                hero:setState(EnumStateType.STAND)
            end
            local attack = cc.Sequence:create(hero._action.specialattack1:clone(),cc.CallFunc:create(sendKnockedMsg),hero._action.specialattack2,cc.CallFunc:create(attackdone))
            hero._sprite3d:runAction(attack)

        elseif EnumStateType.KNOCKED == hero._statetype then
            --self._knockedMsgStruct.attacker._attack
            local damage = 200
            hero._hp = hero._hp - damage
            if hero._hp <0 then
                hero._hp = 0
            end
            if hero._hp == 0 then
                hero._isalive = false
                hero:setState(EnumStateType.DEAD)
            else
                hero._statetype = EnumStateType.KNOCKING
                local function dropblood()
                    --cclog("dropblood")
                end
                local function knockdone()
                    hero:setState(EnumStateType.STAND)
                end
                hero._sprite3d:runAction(cc.Sequence:create(cc.Spawn:create(hero._action.knocked:clone(),cc.CallFunc:create(dropblood)),cc.CallFunc:create(knockdone))) 
            end
        
        elseif EnumStateType.DEFEND == hero._statetype then
            hero._statetype = EnumStateType.DEFENDING
            local function defenddone()
                hero:setState(EnumStateType.STAND)
            end
            hero._sprite3d:runAction(cc.Sequence:create(hero._action.defense:clone(),cc.CallFunc:create(defenddone)))

        elseif EnumStateType.DEAD == hero._statetype then
            hero._statetype = EnumStateType.DYING
            local deaddone = function ()
                hero:setState(EnumStateType.NULL)
--                local function disappear()
--                    hero._particle:removeFromParent()
--                    hero._particle = nil
--                    scheduler:unscheduleScriptEntry(mainloop_schedulerid)
--                    hero:removeFromParent()
--                end
                hero:runAction(cc.Sequence:create(cc.MoveBy:create(1.0,cc.V3(0,0,-50)),cc.RemoveSelf:create()))
            end
            hero._sprite3d:runAction(cc.Sequence:create(hero._action.dead:clone(), cc.CallFunc:create(deaddone)))
        end
    end

    --mainloop
    mainloop_schedulerid = scheduler:scheduleScriptFunc(MainLoop, 0, false)    

    --regist message

    
--    local function knocked(msgStruct)
--        --stopAllActions and dropblood
--        if msgStruct.target == hero then 
--            hero._knockedMsgStruct = msgStruct
--            hero:setState(EnumStateType.KNOCKED)
--        end
--    end
--    
--    local function knockedAll(msgStruct)
--        --stopAllActions and dropblood
--        attackAll(msgStruct.attacker)
--    end    
--
--    MessageDispatchCenter:registerMessage(MessageDispatchCenter.MessageType.KNOCKED, knocked)
--    MessageDispatchCenter:registerMessage(MessageDispatchCenter.MessageType.KNOCKEDAOE, knockedAll)

    --List.pushlast(HeroPool, hero)

    return hero
end


function Warrior:init3D()
    self._sprite3d = cc.EffectSprite3D:create(filename)
    self._sprite3d:setScale(25)
    self._sprite3d:addEffect(cc.V3(0,0,0),0.01, -1)
    self:addChild(self._sprite3d)
    self._sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
    self._sprite3d:setRotation(-90)

    --cclog(self._sprite3d:getMeshNum())
--    self:setDefaultEqt()
end


local function createAnimation(animationStruct, isloop)
    local animation3d = cc.Animation3D:create(filename)
    local animate3d = cc.Animate3D:create(animation3d, animationStruct.begin/30,(animationStruct.ended-animationStruct.begin)/30)
    animate3d:setSpeed(animationStruct.speed)
    if isloop then
        return cc.RepeatForever:create(animate3d)
    else
        return animate3d
    end
end


function Warrior:initActions()
    local function createAnimation(animationStruct, isloop )
        local animation3d = cc.Animation3D:create(filename)
        local animate3d = cc.Animate3D:create(animation3d, animationStruct.begin/30,(animationStruct.ended-animationStruct.begin)/30)
        animate3d:setSpeed(animationStruct.speed)
        if isloop then
            return cc.RepeatForever:create(animate3d)
        else
            return animate3d
        end
    end
    local stand = createAnimationStruct(267,283,0.7)
    local walk = createAnimationStruct(227,246,0.7)
    local attack1 = createAnimationStruct(103,129,0.7)
    local attack2 = createAnimationStruct(130,154,0.7)
    local specialattack1 = createAnimationStruct(160,190,0.3)
    local specialattack2 = createAnimationStruct(191,220,0.4)
    local defend = createAnimationStruct(92,96,0.7)
    local knocked = createAnimationStruct(254,260,0.7)
    local dead = createAnimationStruct(0,77,0.7)

    self._action.stand = createAnimation(stand, true)
    self._action.stand:retain()
    self._action.walk = createAnimation(walk, true)
    self._action.walk:retain()
    self._action.attack1 = createAnimation(attack1, false)
    self._action.attack1:retain()
    self._action.attack2 = createAnimation(attack2, false)
    self._action.attack2:retain()
    self._action.specialattack1 = createAnimation(specialattack1, false)
    self._action.specialattack1:retain()
    self._action.specialattack2 = createAnimation(specialattack2, false)
    self._action.specialattack2:retain()
    self._action.defend = createAnimation(defend, false)
    self._action.defend:retain()
    self._action.knocked = createAnimation(knocked, false)
    self._action.knocked:retain()
    self._action.dead = createAnimation(dead, false)
    self._action.dead:retain()

end

function Warrior:setState(type)
--    getDebugStateType(type)
    if type == self._statetype then return end
    --cclog("Warrior:setState(" .. type ..")")

    if type == EnumStateType.STAND then
        if EnumStateType.STANDING == self._statetype then return end
        self._statetype = type
        self._sprite3d:stopAllActions()
        if self._particle ~= nil then self._particle:setEmissionRate(0) end

    elseif type == EnumStateType.WALK then
        if EnumStateType.SPECIALATTACKING == self._statetype or EnumStateType.NORMALATTACKING == self._statetype then return end
        if EnumStateType.KNOCKING == self._statetype then return end
        self._statetype = type
        self._sprite3d:stopAllActions()
        self._sprite3d:runAction(self._action.walk:clone())
        if self._particle ~= nil then self._particle:setEmissionRate(5) end

    elseif type == EnumStateType.KNOCKED then
        if EnumStateType.SPECIALATTACKING == self._statetype then return end
        if EnumStateType.KNOCKING == self._statetype then return end
        self._statetype = type
        self._sprite3d:stopAllActions()

    elseif type == EnumStateType.ATTACK then
        if EnumStateType.SPECIALATTACKING == self._statetype or EnumStateType.NORMALATTACKING == self._statetype then return end
        if EnumStateType.KNOCKING == self._statetype then return end
        if EnumStateType.KNOCKED == self._statetype then return end
        math.randomseed(os.time()) 
        local random_special = math.random()
        --cclog(random_special)
        if random_special < WarriorProperty.special_attack_chance then
            self._statetype = EnumStateType.SPECIALATTACK
        else    
            self._statetype = EnumStateType.NORMALATTACK
        end
        self._sprite3d:stopAllActions()
        if self._particle ~= nil then self._particle:setEmissionRate(0) end

    elseif type == EnumStateType.DEFEND then
        self._statetype = type
        self._sprite3d:stopAllActions()

    elseif type == EnumStateType.DEAD then
        self._statetype = type
        self._sprite3d:stopAllActions()
        if self._particle ~= nil then self._particle:setEmissionRate(0) end

    elseif type == EnumStateType.NULL then
        self._statetype = type
    end
end


function Warrior:walkUpdate(dt)
    if self._target ~= nil  then
        local miniDistance = self._attackRadius + self._target._radius
        local p1 = getPosTable(self)
        local p2 = getPosTable(self._target)
        local distance = cc.pGetDistance(p1, p2)
        local angle = cc.pToAngleSelf(cc.pSub(p1, p2))
        p2 = cc.pRotateByAngle(cc.pAdd(cc.p(-miniDistance/2,0),p2), p2, angle)       
        self:setPosition(getNextStepPos(p1, p2, self._speed, dt))
    else
        --our hero doesn't have a target, lets move right
        local curx,cury = self:getPosition()
        self:setPosition(curx+self._speed*dt, cury)           
    end            
end




-- set default equipments
function Warrior:setDefaultEqt()
    local girl_lowerbody = self._sprite3d:getMeshByName("Girl_LowerBody01")
    girl_lowerbody:setVisible(false)
    local girl_shoe = self._sprite3d:getMeshByName("Girl_Shoes01")
    girl_shoe:setVisible(false)
    local girl_hair = self._sprite3d:getMeshByName("Girl_Hair01")
    girl_hair:setVisible(false)
    local girl_upperbody = self._sprite3d:getMeshByName("Girl_UpperBody01")
    girl_upperbody:setVisible(false)
end

--swicth weapon
function Warrior:switchWeapon()
    self._useWeaponId = self._useWeaponId+1
    if self._useWeaponId > 1 then
        self._useWeaponId = 0;
    end
    if self._useWeaponId == 1 then
        local girl_lowerbody = self._sprite3d:getMeshByName("Girl_LowerBody01")
        girl_lowerbody:setVisible(true)
        local girl_lowerbody = self._sprite3d:getMeshByName("Girl_LowerBody02")
        girl_lowerbody:setVisible(false)
        local girl_shoe = self._sprite3d:getMeshByName("Girl_Shoes01")
        girl_shoe:setVisible(true)
        local girl_shoe = self._sprite3d:getMeshByName("Girl_Shoes02")
        girl_shoe:setVisible(false)
    else
        local girl_lowerbody = self._sprite3d:getMeshByName("Girl_LowerBody01")
        girl_lowerbody:setVisible(false)
        local girl_lowerbody = self._sprite3d:getMeshByName("Girl_LowerBody02")
        girl_lowerbody:setVisible(true)
        local girl_shoe = self._sprite3d:getMeshByName("Girl_Shoes01")
        girl_shoe:setVisible(false)
        local girl_shoe = self._sprite3d:getMeshByName("Girl_Shoes02")
        girl_shoe:setVisible(true)
    end
end



--switch armour
function Warrior:switchArmour()
    self._useArmourId = self._useArmourId+1
    if self._useArmourId > 1 then
        self._useArmourId = 0;

    end
    if self._useArmourId == 1 then
        local girl_lowerbody = self._sprite3d:getMeshByName("Girl_Hair01")
        girl_lowerbody:setVisible(true)
        local girl_lowerbody = self._sprite3d:getMeshByName("Girl_Hair02")
        girl_lowerbody:setVisible(false)
        local girl_shoe = self._sprite3d:getMeshByName("Girl_UpperBody01")
        girl_shoe:setVisible(true)
        local girl_shoe = self._sprite3d:getMeshByName("Girl_UpperBody02")
        girl_shoe:setVisible(false)
    else
        local girl_lowerbody = self._sprite3d:getMeshByName("Girl_Hair01")
        girl_lowerbody:setVisible(false)
        local girl_lowerbody = self._sprite3d:getMeshByName("Girl_Hair02")
        girl_lowerbody:setVisible(true)
        local girl_shoe = self._sprite3d:getMeshByName("Girl_UpperBody01")
        girl_shoe:setVisible(false)
        local girl_shoe = self._sprite3d:getMeshByName("Girl_UpperBody02")
        girl_shoe:setVisible(true)
    end
end


-- get weapon id
function Warrior:getWeaponID()
    return self._useWeaponId
end

-- get armour id
function Warrior:getArmourID()
    return self._useArmourId
end

return Warrior