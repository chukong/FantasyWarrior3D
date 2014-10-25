require "Cocos2d"
require "extern"

-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    
    cc.FileUtils:getInstance():addSearchPath("src")
    cc.FileUtils:getInstance():addSearchPath("src/actors")
    cc.FileUtils:getInstance():addSearchPath("res")
    
    --show frame
    cc.Director:getInstance():setDisplayStats(true)
    
    --adaptation
    local pEGLView = cc.Director:getInstance():getOpenGLView()
    local frameSize = pEGLView:getFrameSize()
    local winSize = {width=1136,height=640}

    local widthRate = frameSize.width/winSize.width
    local heightRate = frameSize.height/winSize.height

    if widthRate > heightRate then
        pEGLView:setDesignResolutionSize(winSize.width,
            winSize.height*heightRate/widthRate, 1)
    else
        pEGLView:setDesignResolutionSize(winSize.width*widthRate/heightRate, winSize.height,
            1)
    end
    
    cc.Director:getInstance():setDisplayStats(true)

    --create scene
    local scene = require("ActorTestScene")
--    local scene = require("ChooseRoleScene")
--   local scene = require("BattleScene")
--    local scene = require("LoadingScene")
--    local scene = require("MainMenuScene")
    local activateGameScene = scene.create()
    --activateGameScene:playBgMusic()
    
    
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(activateGameScene)
    else
        cc.Director:getInstance():runWithScene(activateGameScene)
    end

end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
