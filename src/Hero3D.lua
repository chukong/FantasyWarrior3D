Hero3D = class("Hero3D", function()
    return require "Actor".create()
end)

local size = cc.Director:getInstance():getWinSize()
local scheduler = cc.Director:getInstance():getScheduler()

function Hero3D:ctor()
    self._useWeaponId = 0
    self._useArmourId = 0
    self._particle = nil
    self._arm = ""
    self._chest = ""
    self._weapon = ""
    self._attack = 300    
end

function Hero3D.create(type)
    
    local hero = Hero3D.new()
    hero:AddSprite3D(type)
    
    -- base
    hero:setRaceType(type)
    --self
    hero._weapon = math.random() .. ""

    local function MainLoop(dt)
        if EnumStateType.WALK == hero._statetype then
            --move
            local targetPos = {x=3000, y=0}
            local dis = hero._attackRadius
            if nil ~= hero._target then
                targetPos = getPosTable(hero._target)
                dis = hero._attackRadius+hero._target._radius
            end
            local curPos = getPosTable(hero)
            if cc.pGetDistance(curPos,targetPos)>(dis) then
                hero:setPosition(getNextStepPos(curPos, targetPos, hero._speed, dt))
            else 
                hero:setState(EnumStateType.STAND)
            end
        
        elseif EnumStateType.STAND == hero._statetype then
        end
    end
    
    --mainloop
    scheduler:scheduleScriptFunc(MainLoop, 0, false)    
        
    local function update(dt)
        if hero.FindEnemy2Attack == nil then return  end
        hero:FindEnemy2Attack()        
    end

    scheduler:scheduleScriptFunc(update, 0.5, false)    
    return hero
end


function Hero3D:AddSprite3D(type)
    
    local filename;
    if type == EnumRaceType.WARRIOR then --warrior
        filename = "model/warrior/warrior.c3b"
    elseif type == EnumRaceType.ARCHER then --archer
        filename = "Sprite3DTest/ReskinGirl.c3b"
    elseif type == EnumRaceType.WAGE then --wage
        filename = "Sprite3DTest/ReskinGirl.c3b"
    else
        filename = "Sprite3DTest/orc.c3b" 
    end
    self._sprite3d = cc.EffectSprite3D:create(filename)
    self._sprite3d:addEffect(cc.V3(0,0,0),0.01, -1)
    self:addChild(self._sprite3d)
    self._sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
    self._sprite3d:setRotation(-90)
            
    self._action.walk = filename
        
    --set default equipment
    --if type ~= EnumRaceType.DEBUG then
    --    self:setDefaultEqt()
    --end
end

-- set default equipments
function Hero3D:setDefaultEqt()
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
function Hero3D:switchWeapon()
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
function Hero3D:switchArmour()
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
function Hero3D:getWeaponID()
    return self._useWeaponId
end

-- get armour id
function Hero3D:getArmourID()
    return self._useArmourId
end


-- find enemy
function Hero3D:FindEnemy2Attack()
    if self._isalive == false then
        if self._scheduleAttackId ~= 0 then
            scheduler:unscheduleScriptEntry(self._scheduleAttackId)
            self._scheduleAttackId = 0
        end
        return
    end 

    if self._statetype == EnumStateType.ATTACK and self._scheduleAttackId == 0 then
        local function scheduleAttack(dt)
            if self._target == nil or self._target == 0 or self._target._isalive == false then
                scheduler:unscheduleScriptEntry(self._scheduleAttackId)
                self._scheduleAttackId = 0
                return
            end
            
            self._attackZone:runAction(cc.Sequence:create(cc.ProgressTo:create(0, 0), cc.ProgressTo:create(0.3, 25))) 
            self._target:hurt(self._attack)
        end    
        self._scheduleAttackId = scheduler:scheduleScriptFunc(scheduleAttack, 1, false)            
    end

    if self._statetype ~= EnumStateType.ATTACK and self._scheduleAttackId ~= 0 then
        scheduler:unscheduleScriptEntry(self._scheduleAttackId)
        self._scheduleAttackId = 0
    end  
end

function Hero3D:setState(type)
    --cclog("%d", type)
    if type == self._statetype then 
        return   	
    elseif type ~= EnumStateType.KNOCKED then
        self._sprite3d:stopActionByTag(self._statetype)    
        self._statetype = type
    end   
    
    if type == EnumStateType.STAND then
        self._sprite3d:stopAllActions()
        if self._particle ~= nil then self._particle:setEmissionRate(0) end

    elseif type == EnumStateType.WALK then
        self._sprite3d:stopAllActions()
        local animation3d = cc.Animation3D:create(self._action.walk)
        local animate3d = cc.Animate3D:create(animation3d, 227/30,(246.5-227)/30)
        animate3d:setSpeed(0.7)
        local act = cc.RepeatForever:create(animate3d)
        self._sprite3d:runAction(act)
        self._particle:setEmissionRate(5)

    elseif type == EnumStateType.DEAD then
        local rotateAngle = nil
        if self._racetype == EnumRaceType.DEBUG then
            rotateAngle = 90.0
        else 
            rotateAngle = -90.0
        end
        self._sprite3d:runAction(cc.RotateTo:create(0.5, cc.V3(0, 0, rotateAngle))) 
     elseif type == EnumStateType.ATTACK then
--        local animation = cc.Animation3D:create(self._action.attack)
--        local animate = cc.Animate3D:create(animation)
--        animate:setSpeed(self._speed)
--        local repeatAction = cc.RepeatForever:create(animate)
--        repeatAction:setTag(self._statetype) 
--        self._sprite3d:runAction(repeatAction)

    elseif type == EnumStateType.DEFEND then
        local x = 0
        if self._racetype == EnumRaceType.HERO then
            x = -15
        else
            x = 15
        end    
        local defendAction = cc.RotateBy:create(0.5, x)
        defendAction:setTag(self._statetype) 
        self._sprite3d:runAction(defendAction)     

    elseif type == EnumStateType.KNOCKED then
        local toRed = cc.TintTo:create(0, 255, 0, 0)
        local toRedBack = cc.TintTo:create(0.2, 255, 255, 255)
        self._sprite3d:runAction(cc.Sequence:create(toRed, toRedBack))
        --cclog("Hero is attacked!!!!")
    end
end

return Hero3D