require "Cocos2d"
require "GlobalVariables"
require "Helper"
require "Knight"
require "Slime"
require "Archer"
require "Mage"
require "Boss"
require "Rat"
require "Dragon"

--declare a class extends scene
local ActorTestScene = class("ActorTestScene",function()
    return cc.Scene:create()
end
)
function ActorTestScene:ctor()
    --get win size
    local size = cc.Director:getInstance():getVisibleSize()
    self.lay = cc.Node:create()
    self.act = nil
    self.lay:setPosition(size.width/2, size.height/2-50)
    self:addChild(self.lay)
    self.lay:setRotation3D(cc.V3(-65,0,0))
end

function ActorTestScene.create()
    local scene = ActorTestScene.new()
    --add layer


    local act = Boss:create()
    
--    act:setAIEnabled(false)
    act:setScale(1)
    
    scene.lay:addChild(act)
    scene:enableTouch()
    scene.act = act
    
    
    local function go()
        act:walkMode()
    end
    --delayExecute(act,go,2)
    
    local dur = 0.6
    local bsc = 17


--    act._sprite3d:runAction(cc.RepeatForever:create(
--        cc.Spawn:create(
--            cc.Sequence:create(
--                cc.DelayTime:create(dur/8),
--                cc.JumpBy3D:create(dur*7/8, cc.V3(0,0,0),30,1)
--            ),
--            cc.Sequence:create(
--                cc.EaseSineOut:create(cc.ScaleTo:create(dur/8, bsc*1.4, bsc*1.4, bsc*0.75)),
--                cc.EaseSineOut:create(cc.ScaleTo:create(dur/8, bsc*0.85, bsc*0.85, bsc*1.3)),
--                cc.EaseSineOut:create(cc.ScaleTo:create(dur/8, bsc*1.2, bsc*1.2, bsc*0.9)),
--                cc.EaseSineOut:create(cc.ScaleTo:create(dur/8, bsc*0.95, bsc*0.95, bsc*1.1)),
--                cc.EaseSineOut:create(cc.ScaleTo:create(dur*4/8, bsc, bsc, bsc))
--            )
--        )
--    ))
    
  
   
    return scene
end

function ActorTestScene:enableTouch()

    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(function(touches, event)
        if #touches == 1 then
            local touch = touches[1]
            local delta = touch:getDelta()
            
            local lrot = self.lay:getRotation3D()
            local arot = self.act:getRotation3D()
            self.lay:setRotation3D(cc.V3(lrot.x-delta.y,lrot.y,lrot.z))
            self.act:setRotation3D(cc.V3(arot.x, arot.y, arot.z-delta.x))
        end
    end, cc.Handler.EVENT_TOUCHES_MOVED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    
end

return ActorTestScene