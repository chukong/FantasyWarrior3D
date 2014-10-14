require "Helper"
require "Base3D"
require "Monster"
require "Boss"
require "Manager"
require "Warrior"

local size = cc.Director:getInstance():getWinSize()
local scheduler = cc.Director:getInstance():getScheduler()
local gloableZOrder = 1
local touchPos = nil
local currentLayer = nil
local heroOriginPositionX = -2900
local currentStep = 1;

--hero ref
local warrior
local archer
local mage

local function collisionDetect()
    --cclog("collisionDetect")
    for val = 1, List.getSize(HeroManager) do
        local sprite = HeroManager[val-1]
        if sprite._isalive == true then
            collision(sprite)
            isOutOfBound(sprite)
        else
            List.remove(HeroManager, val-1)
            break
        end
    end

    for val = 1, List.getSize(MonsterManager) do
        local sprite = MonsterManager[val-1]
        if sprite._isalive == true then
            collision(sprite)
            isOutOfBound(sprite)            
        else
            List.remove(MonsterManager, val-1)
            break
        end
    end    

    for val = 1, List.getSize(BossManager) do
        local sprite = BossManager[val-1]
        if sprite._isalive == true then
            collision(sprite)
            isOutOfBound(sprite)            
        else
            List.remove(BossManager, val-1)
            break
        end
    end        
end

local function findEnmey(object, manager)
    if object == nil or object._isalive == false then return end

    local find = false            
    local shortest_distance = 500
    for var = 1, List.getSize(manager) do
        local objectTemp = manager[var-1]
        local dis = cc.pGetDistance(getPosTable(object),getPosTable(objectTemp))
        if dis < shortest_distance and objectTemp._isalive then
            object:setTarget(objectTemp)
            shortest_distance = dis
            find = true                      
        end
    end
    
    if find == false then
        object:setState(EnumStateType.WALK)
        object:setTarget(nil)
    else
        if isInCircleSector(object, object._target) then
            object:setState(EnumStateType.ATTACK)
        else
            object:setState(EnumStateType.WALK)        
            faceToEnmey(object, object._target)
        end
    end
end

local function findAllEnemy()
    local tempSize1 = List.getSize(MonsterManager)
    findEnmey(warrior, MonsterManager)
    findEnmey(archer, MonsterManager)
    findEnmey(mage, MonsterManager)
        
   for var = 1, tempSize1 do
       local objectTemp = MonsterManager[var-1]
       findEnmey(objectTemp, HeroManager)
   end

    local tempSize2 = List.getSize(BossManager)
    if tempSize2 > 0 then        
        findEnmey(warrior, BossManager)
        findEnmey(archer, BossManager)
        findEnmey(mage, BossManager)
        
        for var = 1, tempSize2 do
            local objectTemp = BossManager[var-1]
            findEnmey(objectTemp, HeroManager)
        end          
    end   

end

local function moveCamera(dt)
    --cclog("moveCamera")
    if camera and List.getSize(HeroManager) > 0 then
        local position = cc.pLerp({x=camera:getPositionX(),y=0},{x=getFocusPointOfHeros().x,y=0},2*dt)
        camera:setPositionX(position.x)
        camera:lookAt({x=position.x, y=size.width/2, z=0.0}, {x=0.0, y=1.0, z=0.0})
    end
end

local function updateParticlePos()
    --cclog("updateParticlePos")
    if warrior ~= nil and warrior._particle ~= nil then
        warrior._particle:setPosition(getPosTable(warrior))
    end
    if archer ~= nil and archer._particle ~= nil then
        archer._particle:setPosition(getPosTable(archer))
    end
    if mage ~= nil and mage._particle ~= nil then
        mage._particle:setPosition(getPosTable(mage))
    end
end

local function jumpdone()
    warrior:setState(EnumStateType.WALK)
end

local function addParticleToRole(role)
    role._particle = cc.BillboardParticleSystem:create("effect/walkingPuff.plist")
    role._particle:setDepthTestEnabled(true)
    role._particle:setScale(1)
    role._particle:setPositionZ(15)
    role._particle:setDuration(-1)    
    role._particle:setStartColor({r=234,g=123,b=245,a=255})
    currentLayer:addChild(role._particle,5)
    role._particle:setEmissionRate(0)
end

local function addNewSprite(x, y, tag)
    local sprite = nil
    local animation = nil
    if tag == EnumRaceType.DEBUG then
        sprite = Warrior.create()
        sprite._sprite3d:setScale(25)
        List.pushlast(HeroManager, sprite)
    elseif tag == EnumRaceType.MONSTER then
        sprite = Monster.create()
        sprite._sprite3d:setScale(15)
        List.pushlast(MonsterManager, sprite)
    elseif tag == EnumRaceType.BOSS then
        sprite = Boss.create()
        sprite._sprite3d:setScale(1)
        sprite:setState(EnumStateType.ATTACK)
        List.pushlast(BossManager, sprite)
    else
        return
    end

    sprite:setPosition(cc.p(x, y))
    gloableZOrder = gloableZOrder + 1
    sprite:setGlobalZOrder(gloableZOrder)
    currentLayer:addChild(sprite)

    local rand2 = math.random()
    local speed = 1.0

    if rand2 < 1/3 then
        speed =  math.random()  
    elseif rand2 < 2/3 then
        speed = - 0.5 *  math.random()
    end

    sprite.speed =  speed + 0.5
    sprite.priority = sprite.speed        

    sprite:setState(EnumStateType.STAND)

    return sprite    
end

local function createBackground()
    local spriteBg = cc.Sprite3D:create("Sprite3DTest/scene/DemoScene.c3b")
    local children = spriteBg:getChildren()
    for key1, var1 in ipairs(children) do
        if key1 ~= 2 then
            var1:setVisible(false)
        else
            for key2, var2 in ipairs(var1:getChildren()) do
                if key2 ~=2 then
                    var2:setVisible(false)
                end
            end
        end
    end

    currentLayer:addChild(spriteBg)
    spriteBg:setScaleX(300)
    spriteBg:setScaleY(100)
    spriteBg:setPosition3D(cc.V3(size.width/2, size.height/2, 0))
    spriteBg:setRotation3D(cc.V3(90,0,0))
end

local function createEnmey(step)
    if  step ~= currentStep  then return end

    if currentStep == 1 then
        addNewSprite(size.width/2-1900, size.height/2-200, EnumRaceType.MONSTER)
        addNewSprite(size.width/2-2000, size.height/2-200, EnumRaceType.MONSTER)
        addNewSprite(size.width/2-2000, size.height/2-100, EnumRaceType.MONSTER)
        currentStep = currentStep + 1    
    elseif currentStep == 2 then
        addNewSprite(size.width/2, size.height/2-200, EnumRaceType.MONSTER)
        addNewSprite(size.width/2+100, size.height/2-200, EnumRaceType.MONSTER)
        addNewSprite(size.width/2+100, size.height/2-100, EnumRaceType.MONSTER)
        currentStep = currentStep + 1   
    elseif currentStep == 3 then
        addNewSprite(size.width/2+2000, size.height/2-100, EnumRaceType.BOSS)
        currentStep = currentStep + 1                    
    end
end

local function createRole()
 
    warrior = addNewSprite(heroOriginPositionX, 0, EnumRaceType.DEBUG)
    addParticleToRole(warrior)    
    warrior:setState(EnumStateType.STAND)
    warrior:runAction(cc.Sequence:create(cc.JumpBy3D:create(0.8,{x=200,y=0,z=0},300,1),cc.CallFunc:create(jumpdone)))
    
    archer = addNewSprite(heroOriginPositionX, 300, EnumRaceType.DEBUG)
    addParticleToRole(archer)    
    archer:setState(EnumStateType.WALK)

    mage = addNewSprite(heroOriginPositionX, -300, EnumRaceType.DEBUG)
    addParticleToRole(mage)
    mage:setState(EnumStateType.WALK)
end

local function setCamera()
    camera = cc.Camera:createPerspective(60.0, size.width/size.height, 1.0, 2000.0)
    camera:setPosition3D(cc.V3(getFocusPointOfHeros().x, getFocusPointOfHeros().y-size.height*1.2, size.width/2))
    camera:lookAt(cc.V3(getFocusPointOfHeros().x, getFocusPointOfHeros().y, 0.0), cc.V3(0.0, 1.0, 0.0))
    currentLayer:addChild(camera)
end

local function gameController(dt)
    collisionDetect()
    findAllEnemy()
    moveCamera(dt)
    updateParticlePos()

    local tempPos = camera:getPositionX()
    --cclog("%f", tempPos)
    if tempPos > -2500 and tempPos < -2400 then
        createEnmey(1)    
    elseif  tempPos > -1000 and tempPos < -900 then
        createEnmey(2)
    elseif  tempPos > 1000 and tempPos < 1100 then
        createEnmey(3)        
    end
end

local function initUILayer()
    uiLayer = require("BattleFieldUI").create()

    uiLayer:setPositionZ(-cc.Director:getInstance():getZEye())
    uiLayer:setScale(1)
    uiLayer:ignoreAnchorPointForPosition(false)
    uiLayer:setGlobalZOrder(999)
    camera:addChild(uiLayer)
    cclog("cc.Director:getInstance():getZEye() is %f",cc.Director:getInstance():getZEye())
    --currentLayer:addChild(uiLayer)
end

local TestAIScene = class("TestAIScene",function()
    return cc.Scene:create()
end)

function TestAIScene.create()

    local scene = TestAIScene:new()
    currentLayer = cc.Layer:create()
    scene:addChild(currentLayer)

    createBackground()
    createRole()
    setCamera()
    initUILayer()
    
    if warrior ~= nil then
        warrior._particle:setCamera(camera)
    end
    if archer ~= nil then
        archer._particle:setCamera(camera)
    end
    if mage ~= nil then
        mage._particle:setCamera(camera)
    end
    
    scheduler:scheduleScriptFunc(gameController, 0, false)
    
    return scene
end

return TestAIScene
