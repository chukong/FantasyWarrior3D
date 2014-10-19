require "Helper"
require "Actor"
require "Monster"
require "Boss"
require "Manager"
require "Warrior"
require "Mage"
require "MessageDispatchCenter"
require "AttackCommand"
require "knight"

local size = cc.Director:getInstance():getWinSize()
local scheduler = cc.Director:getInstance():getScheduler()
local gloableZOrder = 1
local touchPos = nil
local currentLayer = nil
local heroOriginPositionX = -2900
local currentStep = 1;
local uiLayer = nil

local function collisionDetect()
    --cclog("collisionDetect")
    for val = HeroManager.first, HeroManager.last do
        local sprite = HeroManager[val]
        if sprite._isalive == true then
            collision(sprite)
            isOutOfBound(sprite)
        else
            List.remove(HeroManager, val)
            break
        end
    end

    for val = MonsterManager.first, MonsterManager.last do
        local sprite = MonsterManager[val]
        if sprite._isalive == true then
            collision(sprite)
            isOutOfBound(sprite)            
        else
            List.remove(MonsterManager, val)
            break
        end
    end    

    for val = BossManager.first, BossManager.last do
        local sprite = BossManager[val]
        if sprite._isalive == true then
            collision(sprite)
            isOutOfBound(sprite)            
        else
            List.remove(BossManager, val)
            break
        end
    end        
end

local function findEnmey(object, manager)
    if object == nil or object._isalive == false then return end

    local find = false
    local shortest_distance = 1000
    for val = manager.first, manager.last do
        local objectTemp = manager[val]
        local dis = cc.pGetDistance(getPosTable(object),getPosTable(objectTemp))
        if dis < shortest_distance and objectTemp._isalive then
            object:setTarget(objectTemp)
            shortest_distance = dis
            find = true
        end
    end
    
    if find == false then
        object:setRotation(0)
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
    if currentStep > 3 and findAliveBoss() == 0 and findAliveMonster() == 0 then
        return
    end

    local monsterSize = List.getSize(MonsterManager)
    local bossSize = List.getSize(BossManager)    
    --hero find monster and boss
    for val = HeroManager.first, HeroManager.last do
        local sprite = HeroManager[val]
        findEnmey(sprite, MonsterManager)
    end
        
    if bossSize > 0 then  
        for val = HeroManager.first, HeroManager.last do
            local sprite = HeroManager[val]
            findEnmey(sprite, BossManager)
        end           
    end        
        
    --monster and boss find hero
    for val = MonsterManager.first, MonsterManager.last do
       local objectTemp = MonsterManager[val]
       findEnmey(objectTemp, HeroManager)
   end

    if bossSize > 0 then  
        for val = BossManager.first, BossManager.last do
            local objectTemp = BossManager[val]
            findEnmey(objectTemp, HeroManager)
        end          
    end   
end

local function moveCamera(dt)
    --cclog("moveCamera")
    if camera and List.getSize(HeroManager) > 0 then
        local position = cc.pLerp({x=camera:getPositionX(),y=0},{x=getFocusPointOfHeros().x+size.width/5,y=0},2*dt)
        camera:setPositionX(position.x)
        camera:lookAt({x=position.x, y=size.width/2, z=0.0}, {x=0.0, y=1.0, z=0.0})
    end
end

local function updateParticlePos()
    --cclog("updateParticlePos")
    for val = HeroManager.first, HeroManager.last do
        local sprite = HeroManager[val]
        if sprite._particle ~= nil then        
            sprite._particle:setPosition(getPosTable(sprite))
        end
    end
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

local function addNewSprite(x, y, raceType, isVisible)
    local sprite = nil
    local animation = nil
    if raceType == EnumRaceType.WARRIOR then
        sprite = Warrior.create()    
    elseif raceType == EnumRaceType.MAGE then
        sprite = Mage.create()
    elseif raceType == EnumRaceType.MONSTER then
        sprite = Monster.create()
        sprite._sprite3d:setScale(15)
        List.pushlast(MonsterPool, sprite)
    elseif raceType == EnumRaceType.BOSS then
        sprite = Boss.create()
        sprite._sprite3d:setScale(35)        
        List.pushlast(BossPool, sprite)
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
    sprite:setVisible(isVisible)
    return sprite    
end

local function createBackground()
    local spriteBg = cc.Sprite3D:create("model/scene1.c3b", "model/zhenghe.png")
    --local spriteBg = cc.Sprite3D:create("model/changjing.c3b")
    --spriteBg:setTexture(cc.Director:getInstance():getTextureCache():addImage("model/zhenghe.png"))


    
    currentLayer:addChild(spriteBg)
    spriteBg:setScale(2.5)
    spriteBg:setGlobalZOrder(-9)
    spriteBg:setPosition3D(cc.V3(-3500,0,0))
    spriteBg:setRotation3D(cc.V3(90,0,0))
    
    local water = cc.Water:create("shader3D/water.png", "shader3D/wave1.png", "shader3D/18.jpg", {width=4500, height=400}, 0.77, 0.3797, 1.2)
    currentLayer:addChild(water)
    water:setPosition3D(cc.V3(-3500,-400,-35))
    water:setAnchorPoint(0,0)
    water:setGlobalZOrder(-9)
end

local function createEnmey(step)
    if  step ~= currentStep  then return end

    --On step 1&2, three monsters would attack you
    --On step 3, boss would bite you 
    if currentStep == 1 or currentStep == 2 then
        for val = 1, 3 do
            local sprite = List.popfirst(MonsterPool)
            sprite:setVisible(true)
            List.pushlast(MonsterManager, sprite)
        end
        currentStep = currentStep + 1
    elseif currentStep == 3 then
        local sprite = List.popfirst(BossPool)
        sprite:setVisible(true)    
        List.pushlast(BossManager, sprite)
        currentStep = currentStep + 1                    
    end    
end

local function createRole()

    local hero = addNewSprite(heroOriginPositionX, 300, EnumRaceType.WARRIOR, true)

    addParticleToRole(hero)    
    hero:setState(EnumStateType.WALK)
    hero:runAction(cc.JumpBy3D:create(0.8,{x=200,y=0,z=0},300,1))
    List.pushlast(HeroManager, hero)

   hero = addNewSprite(heroOriginPositionX, 600, EnumRaceType.WARRIOR, true)
   addParticleToRole(hero)    
   hero:setState(EnumStateType.WALK)
   List.pushlast(HeroManager, hero)

   hero = addNewSprite(heroOriginPositionX, 0, EnumRaceType.MAGE, true)
   addParticleToRole(hero)
   hero:setState(EnumStateType.WALK)
   List.pushlast(HeroManager, hero)
   
   local test = Knight:create()
   test:setPosition(heroOriginPositionX+500, 300)
    currentLayer:addChild(test)

    addNewSprite(size.width/2-1900, size.height/2-200, EnumRaceType.MONSTER, false)
    addNewSprite(size.width/2-2000, size.height/2-200, EnumRaceType.MONSTER, false)
    addNewSprite(size.width/2-2000, size.height/2-100, EnumRaceType.MONSTER, false)
    addNewSprite(size.width/2, size.height/2-200, EnumRaceType.MONSTER, false)
    addNewSprite(size.width/2+100, size.height/2-200, EnumRaceType.MONSTER, false)
    addNewSprite(size.width/2+100, size.height/2-100, EnumRaceType.MONSTER, false)
    addNewSprite(size.width/2+2000, size.height/2-100, EnumRaceType.BOSS, false)
end

local function setCamera()
    camera = cc.Camera:createPerspective(60.0, size.width/size.height, 1.0, 2000.0)
    camera:setPosition3D(cc.V3(getFocusPointOfHeros().x, getFocusPointOfHeros().y-size.height*1.45, size.height/2+50))
    camera:lookAt(cc.V3(getFocusPointOfHeros().x, getFocusPointOfHeros().y, 0.0), cc.V3(0.0, 1.0, 0.0))
    currentLayer:addChild(camera)
    camera:setGlobalZOrder(10)
end

local function enemyEncounter()
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

--dropValuePercent is the dropValue/bloodValue*100
local function sendDropBlood(dropValuePercent, hero)
    local function initBloodDrop(dropValuePercent, hero)
        if uiLayer~=nil then
            uiLayer:bloodDrop(dropValuePercent,hero)    
        end
    end

    MessageDispatchCenter:dispatchMessage(MessageDispatchCenter.MessageType.BLOOD_DROP, initBloodDrop(dropValuePercent, hero))  
end

local function registerBloodDrop(struct)


end

local function gameController(dt)
    collisionDetect()
    moveCamera(dt)
    updateParticlePos()

    enemyEncounter()
    findAllEnemy()
    commandControl()
end

local function initUILayer()
    uiLayer = require("BattleFieldUI").create()

    uiLayer:setPositionZ(-cc.Director:getInstance():getZEye())
    uiLayer:setScale(1)
    uiLayer:ignoreAnchorPointForPosition(false)
    uiLayer:setLocalZOrder(999)
    camera:addChild(uiLayer)
end


local BattleScene = class("BattleScene",function()
    return cc.Scene:create()
end)

function BattleScene.create()

    local scene = BattleScene:new()
    currentLayer = cc.Layer:create()
    scene:addChild(currentLayer)

    createBackground()
    createRole()
    setCamera()
    initUILayer()

    MessageDispatchCenter:registerMessage(MessageDispatchCenter.MessageType.BLOOD_DROP,registerBloodDrop)
    
    for val = HeroManager.first, HeroManager.last do
        local sprite = HeroManager[val]
        sprite._particle:setCamera(camera)
    end    

    scheduler:scheduleScriptFunc(gameController, 0, false)
    
    return scene
end

return BattleScene
