require "AttackCommand"
require "MessageDispatchCenter"

Monster = class("Monster", function()
    return require "Actor".create()
end)

local size = cc.Director:getInstance():getWinSize()
local scheduler = cc.Director:getInstance():getScheduler()
local filename = "model/warrior/warrior.c3b"

function Monster:ctor()
    self._useWeaponId = 0
    self._useArmourId = 0
    self._particle = nil
    self._attack = 200  
end

function Monster.create()

    local monster = Monster.new()
    monster:AddSprite3D()

    -- base
    monster:setRaceType(EnumRaceType.MONSTER)
    monster:setState(EnumRaceType.STAND)
    monster:initActions()

    --self
    monster._weapon = math.random() .. ""

    local function MainLoop(dt)
--        getDebugStateType(monster)
        if EnumStateType.WALK == monster._statetype and monster._target ~= nil then
            local miniDistance = monster._attackRadius + monster._target._radius
            local p1 = getPosTable(monster)
            local p2 = getPosTable(monster._target)
            local distance = cc.pGetDistance(p1, p2)
            local angle = cc.pToAngleSelf(cc.pSub(p1, p2))
            p2 = cc.pRotateByAngle(cc.pAdd(cc.p(-miniDistance/2,0),p2), p2, angle)              
            if miniDistance < distance then
                monster:setPosition(getNextStepPos(p1, p2, monster._speed, dt))
            end                       
        elseif EnumStateType.STAND == monster._statetype then
            monster._statetype = EnumStateType.STANDING
            monster._sprite3d:runAction(monster._action.stand:clone())

        elseif EnumStateType.ATTACK == monster._statetype then
            monster._statetype = EnumStateType.ATTACKING
            local function sendKnockedMsg()
                AttackCommand.create(monster)
                --MessageDispatchCenter:dispatchMessage(MessageDispatchCenter.MessageType.KNOCKED, createKnockedMsgStruct(monster))
            end
            local function attackdone()
                monster:setState(EnumStateType.STAND)
            end
            local attack = cc.Sequence:create(monster._action.attack1:clone(),cc.CallFunc:create(sendKnockedMsg),monster._action.attack2,cc.CallFunc:create(attackdone))
            monster._sprite3d:runAction(attack)

        elseif EnumStateType.KNOCKED == monster._statetype then
            --self._knockedMsgStruct.attacker._attack
            local damage = 300
            monster._hp = monster._hp - damage
            if monster._hp <0 then
                monster._hp = 0
            end
            if monster._hp == 0 then
                monster._isalive = false
                monster:setState(EnumStateType.DEAD)
            else
                --cclog("monster knocked....")
                monster._statetype = EnumStateType.KNOCKING
                local function dropblood()
                    --cclog("monster dropblood")
                end
                local function knockdone()
                    monster:setState(EnumStateType.STAND)
                end
                monster._sprite3d:runAction(cc.Sequence:create(cc.Spawn:create(monster._action.knocked:clone(),cc.CallFunc:create(dropblood)),cc.CallFunc:create(knockdone))) 
            end

        elseif EnumStateType.DEFEND == monster._statetype then
            monster._statetype = EnumStateType.DEFENDING
            local function defenddone()
                monster:setState(EnumStateType.STAND)
            end
            monster._sprite3d:runAction(cc.Sequence:create(monster._action.defense:clone(),cc.CallFunc:create(defenddone)))

        elseif EnumStateType.DEAD == monster._statetype then
            monster._statetype = EnumStateType.DYING
            local deaddone = function ()
                monster:setState(EnumStateType.NULL)
                local function disappear()
                    monster:removeFromParent()
                end
                monster:runAction(cc.Sequence:create(cc.MoveBy:create(1.0,cc.V3(0,0,-50)),cc.CallFunc:create(disappear)))
            end
            monster._sprite3d:runAction(cc.Sequence:create(monster._action.dead:clone(), cc.CallFunc:create(deaddone)))
        end
    end

    --mainloop
    scheduler:scheduleScriptFunc(MainLoop, 0, false)    

    --regist message


--    local function knocked(msgStruct)
--        --stopAllActions and dropblood
--        if msgStruct.target == monster then 
--            monster._knockedMsgStruct = msgStruct
--            monster:setState(EnumStateType.KNOCKED)
--        end
--    end
--
--    MessageDispatchCenter:registerMessage(MessageDispatchCenter.MessageType.KNOCKED, knocked)

    return monster
end


function Monster:AddSprite3D()
    self._sprite3d = cc.EffectSprite3D:create(filename)
    self._sprite3d:addEffect(cc.V3(0,0,0),0.01, -1)
    self:addChild(self._sprite3d)
    self._sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
    self._sprite3d:setRotation(-90)

    --    self:setDefaultEqt()
end

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

function Monster:initActions()
    local stand = createAnimationStruct(267,283,0.7)
    local walk = createAnimationStruct(227,246,0.7)
    local attack1 = createAnimationStruct(103,129,0.7)
    local attack2 = createAnimationStruct(130,154,0.7)
    local specialattack = createAnimationStruct(160,220,0.7)
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
    self._action.specialattack = createAnimation(specialattack, false)
    self._action.specialattack:retain()
    self._action.defend = createAnimation(defend, false)
    self._action.defend:retain()
    self._action.knocked = createAnimation(knocked, false)
    self._action.knocked:retain()
    self._action.dead = createAnimation(dead, false)
    self._action.dead:retain()

end

function Monster:setState(type)
    if type == self._statetype then return end
    --cclog("Monster:setState(" .. type ..")")

    if type == EnumStateType.STAND then
        if EnumStateType.STANDING == self._statetype then return end
        self._statetype = type
        self._sprite3d:stopAllActions()
        if self._particle ~= nil then self._particle:setEmissionRate(0) end


    elseif type == EnumStateType.WALK then
        if EnumStateType.ATTACKING == self._statetype then return end
        if EnumStateType.KNOCKING == self._statetype then return end
        self._statetype = type
        self._sprite3d:stopAllActions()
        self._sprite3d:runAction(self._action.walk:clone())
        if self._particle ~= nil then self._particle:setEmissionRate(5) end

    elseif type == EnumStateType.KNOCKED then
        if EnumStateType.KNOCKING == self._statetype then return end
        self._statetype = type
        self._sprite3d:stopAllActions()

    elseif type == EnumStateType.ATTACK then
        if EnumStateType.ATTACKING == self._statetype then return end
        if EnumStateType.KNOCKING == self._statetype then return end
        if EnumStateType.KNOCKED == self._statetype then return end
        self._statetype = type
        self._sprite3d:stopAllActions()

    elseif type == EnumStateType.SPECIALATTACK then
        self._statetype = type
        self._sprite3d:stopAllActions()
        self._sprite3d:runAction(self._action.specialattack:clone())

    elseif type == EnumStateType.DEFEND then
        self._statetype = type
        self._sprite3d:stopAllActions()

    elseif type == EnumStateType.DEAD then
        self._statetype = type
        self._sprite3d:stopAllActions()

    elseif type == EnumStateType.NULL then
        self._statetype = type
    end
end

-- set default equipments
function Monster:setDefaultEqt()
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
function Monster:switchWeapon()
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
function Monster:switchArmour()
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
function Monster:getWeaponID()
    return self._useWeaponId
end

-- get armour id
function Monster:getArmourID()
    return self._useArmourId
end

return Monster