require "AttackCommand"
require "MessageDispatchCenter"

Boss = class("Boss", function()
    return require "Actor".create()
end)

local size = cc.Director:getInstance():getWinSize()
local scheduler = cc.Director:getInstance():getScheduler()
local filename = "model/warrior/warrior.c3b"

function Boss:ctor()
    self._useWeaponId = 0
    self._useArmourId = 0
    self._particle = nil
    self._attack = 100
end

function Boss.create()

    local boss = Boss.new()
    boss:AddSprite3D()

    -- base
    boss:setRaceType(EnumRaceType.MONSTER)
    boss:setState(EnumRaceType.STAND)
    boss:initActions()

    --self
    boss._weapon = math.random() .. ""

    local function MainLoop(dt)
        --getDebugStateType(boss)
        if EnumStateType.WALK == boss._statetype and boss._target ~= nil then
            local miniDistance = boss._attackRadius + boss._target._radius
            local p1 = getPosTable(boss)
            local p2 = getPosTable(boss._target)
            local distance = cc.pGetDistance(p1, p2)
            local angle = cc.pToAngleSelf(cc.pSub(p1, p2))
            p2 = cc.pRotateByAngle(cc.pAdd(cc.p(-miniDistance/2,0),p2), p2, angle)                
            if miniDistance < distance then
                boss:setPosition(getNextStepPos(p1, p2, boss._speed, dt))
            end

        elseif EnumStateType.STAND == boss._statetype then
            boss._statetype = EnumStateType.STANDING
            boss._sprite3d:runAction(boss._action.stand:clone())

        elseif EnumStateType.ATTACK == boss._statetype then
            boss._statetype = EnumStateType.ATTACKING
            local function sendKnockedMsg()
                AttackCommand.create(boss)
                --MessageDispatchCenter:dispatchMessage(MessageDispatchCenter.MessageType.KNOCKED, createKnockedMsgStruct(boss))
            end
            local function attackdone()
                boss:setState(EnumStateType.STAND)
            end
            local attack = cc.Sequence:create(boss._action.attack1:clone(),cc.CallFunc:create(sendKnockedMsg),boss._action.attack2,cc.CallFunc:create(attackdone))
            boss._sprite3d:runAction(attack)

        elseif EnumStateType.KNOCKED == boss._statetype then
            --self._knockedMsgStruct.attacker._attack
            local damage = 800
            boss._hp = boss._hp - damage
            if boss._hp <0 then
                boss._hp = 0
            end
            if boss._hp == 0 then
                boss._isalive = false
                boss:setState(EnumStateType.DEAD)
            else
                --cclog("boss knocked....")
                boss._statetype = EnumStateType.KNOCKING
                local function dropblood()
                    --cclog("boss dropblood")
                end
                local function knockdone()
                    boss:setState(EnumStateType.STAND)
                end
                boss._sprite3d:runAction(cc.Sequence:create(cc.Spawn:create(boss._action.knocked:clone(),cc.CallFunc:create(dropblood)),cc.CallFunc:create(knockdone))) 
            end

        elseif EnumStateType.DEFEND == boss._statetype then
            boss._statetype = EnumStateType.DEFENDING
            local function defenddone()
                boss:setState(EnumStateType.STAND)
            end
            boss._sprite3d:runAction(cc.Sequence:create(boss._action.defense:clone(),cc.CallFunc:create(defenddone)))

        elseif EnumStateType.DEAD == boss._statetype then
            boss._statetype = EnumStateType.DYING
            local deaddone = function ()
                boss:setState(EnumStateType.NULL)
            end
            boss._sprite3d:runAction(cc.Sequence:create(boss._action.dead:clone(), cc.CallFunc:create(deaddone)))
        end
    end

    --mainloop
    scheduler:scheduleScriptFunc(MainLoop, 0, false)    

    --regist message


--    local function knocked(msgStruct)
--        --stopAllActions and dropblood
--        if msgStruct.target == boss then 
--            boss._knockedMsgStruct = msgStruct
--            boss:setState(EnumStateType.KNOCKED)
--        end
--    end
--
--    MessageDispatchCenter:registerMessage(MessageDispatchCenter.MessageType.KNOCKED, knocked)

    return boss
end


function Boss:AddSprite3D()
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

function Boss:initActions()
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

function Boss:setState(type)
    if type == self._statetype then return end
    --cclog("Boss:setState(" .. type ..")")

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
function Boss:setDefaultEqt()
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
function Boss:switchWeapon()
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
function Boss:switchArmour()
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
function Boss:getWeaponID()
    return self._useWeaponId
end

-- get armour id
function Boss:getArmourID()
    return self._useArmourId
end

return Boss