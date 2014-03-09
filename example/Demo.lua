#!/usr/bin/env lua

print("arg")
local android = os.getenv('ANDROID_DATA') and true

-- issue with KitKat, 3rd party apps can't write to external sdcard anymore
local out = (android) and io.open("/data/data/org.peersuasive.luce.demo/outdebug.log", "wb") or io.stdout
local function log(msg, ...)
    local msg = (msg or "").."\n"
    out:write(string.format(msg, ...))
    out:flush()
end

local args = {...}

local demos = {
    GlyphDemo = "GlyphDemo",
    LinesDemo  = "LinesDemo"
}
local animations = {
    rotation = true,
    position = true,
    shear    = true,
    size     = true,
}
local demo = "GlyphDemo"
local usage = function()
    log("Usage: Demo.lua [options] [demo]")
    log(" demo: one of GlypDemo, LinesDemo (default: GlyphDemo)")
    log("options:")
    log(" -d <animation> [-d ...]    disable selected animation")
    log("                can be one of rotation, position, shear, size or all (default: all enabled)")  
    log()
end
if(#args>0)then
    for i,o in next, args do
    if("-h"==o) or ("--help"==o)then
        usage()
        os.exit()
    elseif(o:match("^%-"))then
        if("-d"==o)then
            local a = args[i+1]
            if("all"==a)then
                animations.rotation = false
                animations.position = false
                animations.shear    = false
                animations.size     = false
            elseif( animations[a] ) then
                animations[a] = false
            else 
                log(string.format("unknown animation: %s, ignoring", a))
            end
            args[i+1] = ""
        else
            log(string.format("unknown option: %s\n", o))
            usage()
            os.exit(1)
        end
    else
        if not(""==o)then
        if not(demos[o])then
            log(string.format("Unknow demo '%s', using default (%s)", o, demo))
        end
        end
        demo = demos[o] or "GlyphDemo"
    end
    end
end
log("1")
local luce = require"luce"()
log("2", luce)
local mainWindow = luce:JUCEApplication()
log("3", mainWindow)

local dw, mc, demoHolder = nil, nil, nil
local function start()
    log("start")
    local dw = luce:DocumentWindow("Document Window")
    log("4")
    local mc = luce:MainComponent("Main Component")
    log("5")
    mc:setSize{1,1}
    log("6")
    ---[[
    local demoHolder = require"DemoHolder"(demo)
    log("7")
    demoHolder.animations.animateRotation = animations.rotation
    demoHolder.animations.animatePosition = animations.position
    demoHolder.animations.animateShear    = animations.shear
    demoHolder.animations.animateSize     = animations.size

    log("8")
    mc:resized(function()
        demoHolder:setBounds( luce:Rectangle(mc:getLocalBounds()) )
    end)
    --]]
    --[[
    mc:paint(function(g)
        log("***************** paint!!!!!!!!!!!!!!!!!!!!!!!!!")
        log("1")
        g:fillAll(luce:Colour(0xffeeddff))
        log("2")
        g:setFont(16.0)
        log("3")
        g:setColour(luce:Colour(luce.Colours.black))
        log("4")
        g:drawText("Hello World!", mc:getLocalBounds(), luce.JustificationType.centred, true);
        log("5")
    end)
    --]]
    log("9")
    return dw, mc, demoHolder
end

--if not(android) then dw, mc, demoHolder = start() end

mainWindow:initialise(function(...)
    dw, mc, demoHolder = start()
    mc:addAndMakeVisible( demoHolder )
    demoHolder:setBounds{ 0, 0, 800, 600 }
    demoHolder:startDemo()
    dw:setContentOwned( mc, true )
    if(android)then
        dw:setFullScreen(true)
        --dw:setKioskMode(true,false) -- not implemented by JUCE
    else
        dw:centreWithSize{800, 600}
    end
    dw:setVisible(true)
    return dw
end)

mainWindow:resumed(function(...)
    --
end)

local stop_now = false
mainWindow:systemRequestedQuit(function(...)
    mainWindow:shutdown()
    mainWindow:quit()
    stop_now = true
    --if(android)then luce:shutdown() end
end)
luce:start(mainWindow)
if not(android) then luce:shutdown() end
