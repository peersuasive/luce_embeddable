#!/usr/bin/env lua

local args = {...}

local demos = {
    GlyphDemo = "GlyphDemo",
    LineDemo  = "LineDemo"
}
local demo = "GlyphDemo"
local usage = function()
    print("Usage: Demo.lua [demo]")
    print("       demo: GlypDemo LineDemo")
    print()
end
if(#args)then
    for _,o in next, args do
    if("-h"==o) or ("--help"==o)then
        usage()
        os.exit()
    elseif(o:match("^%-"))then
        if("-o"==o)then
        else
            print(string.format("unknown option: %s\n", o))
            usage()
            os.exit(1)
        end
    else
        if not(demos[o])then
            print(string.format("Unknow demo '%s', using default (%s)", o, demo))
        end
        demo = demos[o] or "GlyphDemo"
    end
    end
end

local luce = require"luce"()

local mainWindow = luce:JUCEApplication()
local dw = luce:DocumentWindow("Document Window")
local mc = luce:MainComponent("Main Component")
mc:setSize{1,1}


local demoHolder = require"DemoHolder"(demo)

demoHolder.animations.animateRotation = true
demoHolder.animations.animatePosition = true
demoHolder.animations.animateShear    = true
demoHolder.animations.animateSize     = true

mc:resized(function()
    demoHolder:setBounds( luce:Rectangle(mc:getLocalBounds()) )
end)

mainWindow:initialise(function(...)
    mc:addAndMakeVisible( demoHolder )
    demoHolder:setBounds{ 0, 0, 800, 600 }
    demoHolder:startDemo()
    dw:setContentOwned( mc, true )
    dw:centreWithSize{800, 600}
    dw:setVisible(true)
    return dw
end)

mainWindow:systemRequestedQuit(function(...)
    mainWindow:shutdown()
    mainWindow:quit()
end)
luce:start(mainWindow)
luce:shutdown()
