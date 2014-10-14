require "GlobalVariables"

MonsterSlime = class("MonsterSlime",function ()
    return require "Base3D".create()
end)

function MonsterSlime:ctor()
	
end

function MonsterSlime.create(filename)
    
    local slime = MonsterSlime.new()
    slime:addSprite3D(filename)
    
    -- base
    slime:setRaceType(EnumRaceType.MONSTER)
    slime:initActions()    
    
    return slime
end

function MonsterSlime:addSprite3D(filename)
    self._sprite3d = cc.EffectSprite3D:create(filename)
    self:addChild(self._sprite3d)
    self._sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
    self._sprite3d:setRotation(-90)
end


function MonsterSlime:initActions()

end

MonsterDragon = class("MonsterDragon",function ()
    return require "Base3D".create()
end)

function MonsterDragon:ctor()

end

function MonsterDragon.create()

    local dragon = MonsterDragon.new()
    dragon:addSprite3D()

    -- base
    dragon:setRaceType(EnumRaceType.MONSTER)
    dragon:initActions()    

    return dragon
end

function MonsterDragon:addSprite3D()
    self._sprite3d = cc.EffectSprite3D:create(MonsterDragonValues.fileName)
    self:addChild(self._sprite3d)
    self._sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
    self._sprite3d:setRotation(-90)
end


function MonsterDragon:initActions()

end

MonsterRat = class("MonsterRat",function ()
    return require "Base3D".create()
end)

function MonsterRat:ctor()

end

function MonsterRat.create()

    local rat = MonsterRat.new()
    rat:addSprite3D()

    -- base
    rat:setRaceType(EnumRaceType.MONSTER)
    rat:initActions()    

    return rat
end

function MonsterRat:addSprite3D()
    self._sprite3d = cc.EffectSprite3D:create(MonsterRatValues.fileName)
    self._sprite3d:setTexture("model/rat/tou1.jpg")
    self:addChild(self._sprite3d)
    self._sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
    self._sprite3d:setRotation(-90)
end


function MonsterRat:initActions()

end

MonsterPiglet = class("MonsterPiglet",function ()
    return require "Base3D".create()
end)

function MonsterPiglet:ctor()

end

function MonsterPiglet.create()

    local piglet = MonsterPiglet.new()
    piglet:addSprite3D()

    -- base
    piglet:setRaceType(EnumRaceType.MONSTER)
    piglet:initActions()    

    return piglet
end

function MonsterPiglet:addSprite3D()
    self._sprite3d = cc.EffectSprite3D:create(MonsterPigletValues.fileName)
    self:addChild(self._sprite3d)
    self._sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
    self._sprite3d:setRotation(-90)
end

function MonsterPiglet:initActions()

end

