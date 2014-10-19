require "GlobalVariables"
require "MessageDispatchCenter"
require "Helper"
require "AttackCommand"

local file = "model/warrior/warrior.c3b"

Knight = class("Knight", function()
    return require "Actor".create()
end)

function Knight:ctor()
    self._useWeaponId = 0
    self._useArmourId = 0
    self._particle = nil
    self._attack = 300  
    self:init3D()
    self:initActions()
end

function Knight.create()
    local ret = Knight.new()
    --ret:setRaceType(EnumRaceType.WARRIOR)
    
    
    --=====Testing block
    ret:idleMode()
    function test()
--        ret:walkMode()
--        ret._targetFacing = DEGREES_TO_RADIANS(120)
        ret._AIEnabled = true
    end
    function test2()
        ret:idleMode()
        ret._targetFacing = 0
    end
    function test3()
        ret:attackMode()
    end
    function test4()
        ret:knockMode({x=-1000,y=00}, 150)
    end

    delayExecute(ret,test,0.5)

--    delayExecute(ret,test2,2.5)
--    delayExecute(ret,test,3.5)
--    delayExecute(ret,test3,4.5)
    --=====testing block
    
    --this update function do not do AI
    function update(dt)
        ret:baseUpdate(dt)
        ret:stateMachineUpdate(dt)
        ret:movementUpdate(dt)
    end
    ret:scheduleUpdateWithPriorityLua(update, 0) 
    return ret
end





function Knight:init3D()
    self._sprite3d = cc.EffectSprite3D:create(file)
    self._sprite3d:setScale(25)
    self._sprite3d:addEffect(cc.V3(1,0,0),0.01, -1)
    self:addChild(self._sprite3d)
    self._sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
    self._sprite3d:setRotation(-90)
end



-- init knight animations=============================
do
    Knight._action = {
        idle = createAnimation(file,267,283,0.7),
        walk = createAnimation(file,227,246,0.5),
        attack1 = createAnimation(file,103,129,0.7),
        attack2 = createAnimation(file,130,154,0.7),
        specialattack1 = createAnimation(file,160,190,0.3),
        specialattack2 = createAnimation(file,191,220,0.4),
        defend = createAnimation(file,92,96,0.7),
        knocked = createAnimation(file,254,260,0.7),
        dead = createAnimation(file,0,77,1)
    }
end
-- end init knight animations========================
function Knight:initActions()
    self._action = Knight._action
end