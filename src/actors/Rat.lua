require "GlobalVariables"
require "MessageDispatchCenter"
require "Helper"
require "AttackCommand"

local file = "model/rat/laoshu_ani_v03.c3b"

Rat = class("Rat", function()
    return require "Actor".create()
end)

function Rat:ctor()
    copyTable(ActorCommonValues, self)
    copyTable(RatValues,self)

    self:init3D()
    self:initActions()
end

function Rat:reset()
    copyTable(ActorCommonValues, self)
    copyTable(RatValues,self)
    self:walkMode()
    self:setPositionZ(0)
end

function Rat.create()
    local ret = Rat.new()
    ret._AIEnabled = true

    --this update function do not do AI
    function update(dt)
        ret:baseUpdate(dt)
        ret:stateMachineUpdate(dt)
        ret:movementUpdate(dt)
    end
    ret:scheduleUpdateWithPriorityLua(update, 0.5) 
    return ret
end

function Rat:dyingMode(knockSource, knockAmount)
    self:setStateType(EnumStateType.DYING)
    self:playAnimation("dead")
    
    --Twice play in order to inhance the sounds,
    --todo:zijian.
    -- ccexp.AudioEngine:play2d(MonsterPigletValues.dead, false,1)
    
    if knockAmount then
        local p = getPosTable(self)
        local angle = cc.pToAngleSelf(cc.pSub(p, knockSource))
        local newPos = cc.pRotateByAngle(cc.pAdd({x=knockAmount,y=0}, p),p,angle)
        self:runAction(cc.EaseCubicActionOut:create(cc.MoveTo:create(self._action.knocked:getDuration()*3,newPos)))
    end
    self._AIEnabled = false
    List.removeObj(MonsterManager,self) 
    local function recycle()
        self:setVisible(false)
        kill_count = kill_count + 1
        --self:reset()
        List.pushlast(RatPool,self)
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.MoveBy:create(1.0,cc.V3(0,0,-50)),cc.CallFunc:create(recycle)))
end

function Rat:attackUpdate(dt)
    self._attackTimer = self._attackTimer + dt
    if self._attackTimer > self._attackFrequency then
        self._attackTimer = self._attackTimer - self._attackFrequency
        local function playIdle()
            self:playAnimation("idle", true)
            self._cooldown = false
        end
        --time for an attack, which attack should i do?
        local function createCol()
            self:normalAttack()
        end
        local attackAction = cc.Sequence:create(self._action.attack1:clone(),cc.CallFunc:create(createCol),self._action.attack2:clone(),cc.CallFunc:create(playIdle))
        self._sprite3d:stopAction(self._curAnimation3d)
        self._sprite3d:runAction(attackAction)
        self._curAnimation = attackAction
        self._cooldown = true
    end
end

function Rat:_findEnemy()
    local shortest = self._searchDistance
    local target = nil
    local allDead = true
    for val = HeroManager.first, HeroManager.last do
        local temp = HeroManager[val]
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

function Rat:init3D()
    self:initShadow()
    self._sprite3d = cc.EffectSprite3D:create(file)
--    self._sprite3d:getMeshByName("laoshu_tou"):setTexture("model/rat/laoshu_tex_tou.jpg")
--    self._sprite3d:getMeshByName("laoshu_wuqi"):setTexture("model/rat/shenti.png")
--    self._sprite3d:getMeshByName("laoshu_shenti"):setTexture("model/rat/shenti.png")
    self._sprite3d:setScale(10)
    self._sprite3d:addEffect(cc.V3(0,0,0),0.05, -1)
    self:addChild(self._sprite3d)
    self._sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
    self._sprite3d:setRotation(-90)

    local mesh = self._sprite3d:getMesh()
    for k,v in pairs(mesh) do
        print(v:getName())
    end
end

-- init Rat animations=============================
do
    Rat._action = {
        idle = createAnimation(file,0,23,0.7),
        knocked = createAnimation(file,30,37,0.7),
        dead = createAnimation(file,41,76,1),
        attack1 = createAnimation(file,81,99,0.7),
        attack2 = createAnimation(file,99,117,0.7),
        walk = createAnimation(file,122,142,0.7)
    }
end
-- end init Rat animations========================
function Rat:initActions()
    self._action = Rat._action
end