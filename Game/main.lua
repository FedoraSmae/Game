function love.load()

    --Makes the windows resolution 1080p, standard for most modern day monitors, but is resizable

    window = love.window.setMode( 1920, 1080, {resizable=true, vsync=false, minwidth=400, minheight=300})

    --Loads necessary Libraries

    anim8 = require'libraries/anim8/anim8'
    sti = require'libraries/Simple-Tiled-Implementation/sti'
    cameraFile = require'libraries/hump/camera'
    require'libraries/show'
    require'libraries/TEsound'

    cam = cameraFile()

    --Saves data for the game, currently saves: Map Position, Player Health

    saveData = {}
    saveData.px = 360
    saveData.py = 500
    saveData.phealth = 100

    --Checks data.lua for existing saved data

    if love.filesystem.getInfo("data.lua") then
        local data = love.filesystem.load("data.lua")
        data()
    end

    --Sprite table, loads sprite files

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
    sprites.map = love.graphics.newImage('sprites/test6.png')

    local grid = anim8.newGrid(136, 184, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    --Animations table, loads animation files

    animations = {}
    animations.sidewalk = anim8.newAnimation(grid('1-4',1), 0.1)
    animations.backwalk = anim8.newAnimation(grid('1-4',2), 0.1)
    animations.frontwalk = anim8.newAnimation(grid('1-4',3), 0.1)
    animations.idle = anim8.newAnimation(grid('1-4',4), 0.5)

    music = {}
    music.mainmusic1 = love.audio.newSource('music/DieYoung.ogg', 'stream')
    music.mainmusic2 = love.audio.newSource('music/Tune Up vs Italobrothers - Colours Of The Rainbow.WAV', 'stream')

    --Loads the information for the hitbox world

    wf = require'libraries/windfield/windfield'
    world = wf.newWorld(0, 0, false)

    world:addCollisionClass('player')
    world:addCollisionClass('obstacle')
    world:addCollisionClass('bad')

    --Loads the player.lua file which contains all the player information

    require('player')

    --badthing = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "bad"})
    --badthing:setType('static')

    --Obstacle table, loads all obstacles on the map, is auto generated

    obstacles = {}

    --Loads the tilemap

    loadMap()

    --Selects a random song from the list and plays it, once its finished, it will randomly select it again.

    TEsound.playLooping({'music/DieYoung.ogg', 'music/Tune Up vs Italobrothers - Colours Of The Rainbow.WAV'}, 'stream')

end

function love.update(dt)

    --Updates the hitbox map, and the game map
    
    world:update(dt)
    gameMap:update(dt)
    TEsound.cleanup()

    --Calls playerUpdate function found in player.lua

    playerUpdate(dt)

    --Calculates camera position so it stays on the player

    local px, py = player:getPosition()
    cam:lookAt(px, py)

    --Assigns the value of px, and py to saveData, allowing for the position to be kept next time the game is loaded

    saveData.px = px-47
    saveData.py = py-65
    saveData.phealth = player.health
    love.filesystem.write("data.lua", table.show(saveData, "saveData"))

end

function love.draw()

    --Anything in cam:attach is drawn, but not tied to the screen, anything in cam:detach is tied to the screen

    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        gameMap:drawLayer(gameMap.layers["Objects"])
        --world:draw()
        drawPlayer()
    cam:detach()

    --Displays the co-ordinates and FPS when f3 is held down
    
    local px, py = player:getPosition()
    if love.keyboard.isDown('f3') then
        love.graphics.print("x ="..px)
        love.graphics.print("y ="..py, 0, 10)
        love.graphics.print("FPS:"..tostring(love.timer.getFPS()), 0, 20)
    end

    if love.keyboard.isDown('m') then
        love.graphics.draw(sprites.map, 0, 0, nil , 1)
    end

    --Creates the player's health bar, and colours it red, it drains as the players health decreases.

    love.graphics.push()
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", love.graphics.getWidth() - 75, love.graphics.getHeight() - 75, 50, saveData.phealth * -3)
        love.graphics.setColor(255, 255, 255)
    love.graphics.pop()

    --[[love.graphics.push()
        love.graphics.setColor(0, 255, 0)
        love.graphics.rectangle("fill", love.graphics.getWidth() - 125, love.graphics.getHeight() - 75, 50, player.stamina * -3)
        love.graphics.setColor(255, 255, 255)
    love.graphics.pop()]]


end

function spawnObstacles(x, y, width, height)

    --Creates obstacles/boundaries based on their position in the TileMap

    local obstacle = world:newRectangleCollider(x, y, width, height, {collision_class = "obstacle"})
    obstacle:setType('static')
    table.insert(obstacles, obstacle)
end

function loadMap()

    --Loads the TileMap, and calculates the positions of the obstacles/boundaries, and assigns it the the spawnObstacles function

    gameMap = sti("map/map.lua")
    for i, obj in pairs(gameMap.layers["Boundaries"].objects) do
        spawnObstacles(obj.x, obj.y, obj.width, obj.height)
    end
end
