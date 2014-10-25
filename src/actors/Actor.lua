require "Helper"
require "AttackCommand"
--type



local Actor = class ("Actor", function ()
	return cc.Node:create()
end)

function Actor:ctor()
    self._action = {}
    copyTable(ActorDefaultValues,self)
    copyTable(ActorCommonValues, self)
    
    --dropblood
    self._hpCounter = require "HPCounter":create()
    self:addChild(self._hpCounter)
    self._effectNode = cc.Node:create()
    self._monsterHeight = 70
    self._heroHeight = 150
    if uiLayer~=nil then
        currentLayer:addChild(self._effectNode)
    end
end

function Actor:addEffect(effect)
    effect:setPosition(cc.pAdd(getPosTable(self),getPosTable(effect)))
    if self._racetype ~= EnumRaceType.MONSTER then
        effect:setPositionZ(self:getPositionZ()+self._heroHeight)
    else
        effect:setPositionZ(self:getPositionZ()+self._monsterHeight)
    end
    currentLayer:addChild(effect)
end

function Actor.create()
    local base = Actor.new()	
	return base
end
function Actor:initShadow()
    self._circle = cc.Sprite:createWithSpriteFrameName("shadow.png")
    --use Shadow size for aesthetic, use radius to see collision size
    --self._circle:setScale(self._shadowSize/16)
    self._circle:setScale(self._radius/8)
	self._circle:setOpacity(255*0.7)
	self:addChild(self._circle)
end

function Actor:playAnimation(name, loop)
    if self._curAnimation ~= name then --using name to check which animation is playing
        self._sprite3d:stopAllActions()
        if loop then
            self._curAnimation3d = cc.RepeatForever:create(self._action[name]:clone())
        else
            self._curAnimation3d = self._action[name]:clone()
        end
        self._sprite3d:runAction(self._curAnimation3d)
        self._curAnimation = name
    end
end

function Actor:setState(type)
    if self._statetype == type then return end
    
    self._statetype = type
end

--getter & setter

-- get hero type
function Actor:getRaceType()
    return self._racetype
end

function Actor:setRaceType(type)
	self._racetype = type
end

function Actor:getStateType()
    return self._statetype
end

function Actor:setStateType(type)
	self._statetype = type
end

function Actor:setTarget(target)
    if self._target ~= target then
        self._target = target
    end
end
function Actor:setFacing(degrees)
    self._curFacing = DEGREES_TO_RADIANS(degrees)
    self._targetFacing = self._curFacing
    self:setRotation(degrees)
end

function Actor:getAIEnabled()
    return self._AIEnabled
end

function Actor:setAIEnabled(enable)
    self._AIEnabled = enable
end

function Actor:hurtSoundEffects()
-- to override
end

function Actor:hurt(collider)
    if self._isalive == true then 
        --TODO add sound effect
                    
        local damage = collider.damage
        --calculate the real damage
        damage = damage + damage * math.random(-1,1) * 0.15        
        damage = damage - self._defense
        damage = math.floor(damage)
        if damage <= 0 then
            damage = 1
        end
        
        --critical attact by random
        if math.random(0,1) > collider.criticalChance then
            damage = damage + collider.damage*2
        end

        self._hp = self._hp - damage
        
        if self._hp > 0 then
            if collider.knock then
                self:knockMode(getPosTable(collider),collider.knock)
                self:hurtSoundEffects()
            end
        else
            self._hp = 0
            self._isalive = false
            self:dyingMode(getPosTable(collider),collider.knock)        
        end
        
        --three param judge if crit
        local blood = self._hpCounter:showBloodLossNum(damage,self,false)
        self:addEffect(blood)

        local loseBlood = {_name = self._name, _racetype = self._racetype, _maxhp= self._maxhp, _hp = self._hp, _bloodBar=self._bloodBar, _bloodBarClone=self._bloodBarClone,_avatar =self._avatar}
        MessageDispatchCenter:dispatchMessage(MessageDispatchCenter.MessageType.BLOOD_DROP, loseBlood)
    end
end

function Actor:normalAttackSoundEffects()
-- to override
end

function Actor:specialAttackSoundEffects()
-- to override
end

--======attacking collision check
function Actor:normalAttack()
    BasicCollider.create(getPosTable(self), self._curFacing, self._normalAttack)
    self:normalAttackSoundEffects()
end
function Actor:specialAttack()
    BasicCollider.create(getPosTable(self), self._curFacing, self._specialAttack)
    self:specialAttackSoundEffects()
end
--======State Machine switching functions
function Actor:idleMode() --switch into idle mode
    self:setStateType(EnumStateType.IDLE)
    self:playAnimation("idle", true)
end
function Actor:walkMode() --switch into walk mode
    self:setStateType(EnumStateType.WALKING)
    self:playAnimation("walk", true)
end
function Actor:attackMode() --switch into walk mode
    self:setStateType(EnumStateType.ATTACKING)
    self:playAnimation("idle", true)
    self._attackTimer = self._attackFrequency*3/4
end
function Actor:knockMode(knockSource, knockAmount)
    self:setStateType(EnumStateType.KNOCKING)
    self:playAnimation("knocked")
    self._timeKnocked = self._aliveTime
    if knockAmount then
        local p = getPosTable(self)
        local angle = cc.pToAngleSelf(cc.pSub(p, knockSource))
        local newPos = cc.pRotateByAngle(cc.pAdd({x=knockAmount,y=0}, p),p,angle)
        self:runAction(cc.EaseCubicActionOut:create(cc.MoveTo:create(self._action.knocked:getDuration()*3,newPos)))
    end
end

function Actor:playDyingEffects()
   -- override
end

function Actor:dyingMode(knockSource, knockAmount)
    self:setStateType(EnumStateType.DYING)
    self:playAnimation("dead")
    self:playDyingEffects()
    uiLayer:heroDead(self)    
    
    if knockAmount then
        local p = getPosTable(self)
        local angle = cc.pToAngleSelf(cc.pSub(p, knockSource))
        local newPos = cc.pRotateByAngle(cc.pAdd({x=knockAmount,y=0}, p),p,angle)
        self:runAction(cc.EaseCubicActionOut:create(cc.MoveTo:create(self._action.knocked:getDuration()*3,newPos)))
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.MoveBy:create(1.0,cc.V3(0,0,-50)),cc.RemoveSelf:create()))
end
--=======Base Update Functions
function Actor:stateMachineUpdate(dt)
    local state = self:getStateType()
    if state == EnumStateType.WALKING  then
        self:walkUpdate(dt)
    elseif state == EnumStateType.IDLE then
        --do nothing :p
    elseif state == EnumStateType.ATTACKING then
        --I am attacking someone, I probably has a target
        self:attackUpdate(dt)
    elseif state == EnumStateType.DEFENDING then
        --I am trying to defend from an attack, i need to finish my defending animation
        --TODO: update for defending
    elseif state == EnumStateType.KNOCKING then
        --I got knocked from an attack, i need time to recover
        self:knockingUpdate(dt)
    elseif state == EnumStateType.DYING then
        --I am dying.. there is not much i can do right?
        
    end
end
function Actor:_findEnemy()
    local shortest = self._searchDistance
    local target = nil
    local allDead = true
    for val = MonsterManager.first, MonsterManager.last do
        local temp = MonsterManager[val]
        local dis = cc.pGetDistance(self._myPos,getPosTable(temp))
        if temp._isalive then
            if dis < shortest then
                shortest = dis
                target = temp
            end
            allDead = false
        end
    end
    return target, allDead
end
function Actor:_inRange()
    if not self._target then
        return false
    elseif self._target._isalive then
        local attackDistance = self._attackRange + self._target._radius -1
        local p1 = self._myPos
        local p2 = getPosTable(self._target)
        return (cc.pGetDistance(p1,p2) < attackDistance)
    end
end
--AI function does not run every tick
function Actor:AI()
    if self._isalive then
        local state = self:getStateType()
        local allDead
        self._target, allDead = self:_findEnemy()
        --if i can find a target
        if self._target then
            local p1 = self._myPos
            local p2 = getPosTable(self._target)
            self._targetFacing = cc.pToAngleSelf(cc.pSub(p2, p1))
            local isInRange = self:_inRange()
            -- if im (not attacking, or not walking) and my target is not in range
            if (not self._cooldown or state ~= EnumStateType.WALKING) and not isInRange then
                self:walkMode()
                return
            --if my target is in range, and im not already attacking
            elseif isinRange and state ~= EnumStateType.ATTACKING then
                self:attackMode()
                return
--            else 
--                --Since im attacking, i cant just switch to another mode immediately
--                --print( self._name, "says : what should i do?", self._statetype)
            end
        --i did not find a target, and im not attacking or not already idle
        elseif not self._cooldown or state ~= EnumStateType.IDLE then
            self:idleMode()
            return
        end
    else
        -- logic when im dead 
    end
end
function Actor:baseUpdate(dt)
    self._myPos = getPosTable(self)
    self._aliveTime = self._aliveTime+dt
    if self._AIEnabled then
        self._AITimer = self._AITimer+dt
        if self._AITimer > self._AIFrequency then
            self._AITimer = self._AITimer-self._AIFrequency
            self:AI()
        end
    end
end
function Actor:knockingUpdate(dt)
    if self._aliveTime - self._timeKnocked > self._recoverTime then
        --i have recovered from a knock
        self._timeKnocked = nil
        if self:_inRange() then
            self:attackMode()
        else
            self:walkMode()
        end
    end
end
function Actor:attackUpdate(dt)   
    self._attackTimer = self._attackTimer + dt
    if self._attackTimer > self._attackFrequency then
        self._attackTimer = self._attackTimer - self._attackFrequency
        local function playIdle()
            self:playAnimation("idle", true)
            self._cooldown = false
        end
        --time for an attack, which attack should i do?
        local random_special = math.random()
        if random_special > self._specialAttackChance then
            local function createCol()
                self:normalAttack()
            end
            local attackAction = cc.Sequence:create(self._action.attack1:clone(),cc.CallFunc:create(createCol),self._action.attack2:clone(),cc.CallFunc:create(playIdle))
            self._sprite3d:stopAction(self._curAnimation3d)
            self._sprite3d:runAction(attackAction)
            self._curAnimation = attackAction
            self._cooldown = true
        else
            local function createCol()
                self:specialAttack()
            end
            if self._racetype == EnumRaceType.HERO then
                local messageParam = {speed = self._action.specialattack1:getSpeed(), pos = self._myPos}
                --cclog("calf speed:%.2f", messageParam.speed)
                MessageDispatchCenter:dispatchMessage(MessageDispatchCenter.MessageType.SPECIAL_PERSPECTIVE, messageParam)                    	
            end
            
            local attackAction = cc.Sequence:create(self._action.specialattack1:clone(),cc.CallFunc:create(createCol),self._action.specialattack2:clone(),cc.CallFunc:create(playIdle))
            self._sprite3d:stopAction(self._curAnimation3d)
            self._sprite3d:runAction(attackAction)
            self._curAnimation = attackAction
            self._cooldown = true
        end
    end
end
function Actor:walkUpdate(dt)
    --Walking state, switch to attack state when target in range
    if self._target and self._target._isalive then
        local attackDistance = self._attackRange + self._target._radius -1
        local p1 = self._myPos
        local p2 = getPosTable(self._target)
        self._targetFacing = cc.pToAngleSelf(cc.pSub(p2, p1))
        --print(RADIANS_TO_DEGREES(self._targetFacing))
        if cc.pGetDistance(p1,p2) < attackDistance then
            --we are in range, lets switch to attack state
            self:attackMode()
        end
    else
        --our hero doesn't have a target, lets move
        self._target = self:_findEnemy()
        local curx,cury = self:getPosition()
        if self._goRight then
            self._targetFacing = 0
        else
            self:idleMode()
        end
    end
end
function Actor:movementUpdate(dt)
    --Facing
    if self._curFacing ~= self._targetFacing then
        local angleDt = self._curFacing - self._targetFacing
        if angleDt >= math.pi then angleDt = angleDt-2*math.pi
        elseif angleDt <=-math.pi then angleDt = angleDt+2*math.pi end
        local turnby = self._turnSpeed*dt
        if self._curFacing > self._targetFacing then
            if turnby > angleDt then 
                self._curFacing = self._targetFacing
            else
                self._curFacing = self._curFacing - turnby
            end
        elseif self._curFacing < self._targetFacing then
            if turnby < angleDt then
                self._curFacing = self._targetFacing
            else
                self._curFacing = self._curFacing + turnby
            end
        end
        self:setRotation(-RADIANS_TO_DEGREES(self._curFacing))
    end
    --position update
    if self:getStateType() ~= EnumStateType.WALKING then
        --if I am not walking, i need to slow down
        self._curSpeed = cc.clampf(self._curSpeed - self._decceleration*dt, 0, self._speed)
    elseif self._curSpeed < self._speed then
        --I am in walk mode, if i can speed up, then speed up
        self._curSpeed = cc.clampf(self._curSpeed + self._acceleration*dt, 0, self._speed)
    end
    if self._curSpeed > 0 then
        local p1 = self._myPos
        local targetPosition = cc.pRotateByAngle(cc.pAdd({x=self._curSpeed*dt,y=0},p1),p1,self._targetFacing)
        self:setPosition(targetPosition)
    end
end

return Actor