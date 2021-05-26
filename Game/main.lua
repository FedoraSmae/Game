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
    saveData.px = 5000
    saveData.py = 5000
    saveData.phealth = 100
    saveData.stamina = 100
    saveData.CurrentLevel = "Map"

    --Checks data.lua for existing saved data

    if love.filesystem.getInfo("data.lua") then
        local data = love.filesystem.load("data.lua")
        data()
    end

    ui = {}
    ui.statusUI = love.graphics.newImage('Textures/GUI/StatusUI.png')
    ui.map = love.graphics.newImage('Textures/GUI/test6.png')
    --Sprite table, loads sprite files

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('Textures/sprites/playerSheet.png')

    local grid = anim8.newGrid(136, 184, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    --Animations table, loads animation files

    animations = {}
    animations.sidewalk = anim8.newAnimation(grid('1-4',1), 0.1)
    animations.backwalk = anim8.newAnimation(grid('1-4',2), 0.1)
    animations.frontwalk = anim8.newAnimation(grid('1-4',3), 0.1)
    animations.idle = anim8.newAnimation(grid('1-4',4), 0.5)

    music = {}
    music.mainmusic1 = love.audio.newSource('music/main.wav', 'stream')
    music.mainmusic2 = love.audio.newSource('music/Tune Up vs Italobrothers - Colours Of The Rainbow.WAV', 'stream')
    music.Tavern = love.audio.newSource('music/rock08.WAV', 'stream')
    music.Forest = love.audio.newSource('music/Forest.wav', 'stream')

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

    TavernDoorX = 0
    TavernDoorY = 0
    ForestlX = 0
    ForestlY = 0
    ForestrX = 0
    ForestrY = 0

    --Variable for the current level, can be changed and saved

    currentLevel = saveData.currentLevel

    --currentMusic = music.mainmusic1

    --love.audio.play(currentMusic)

    --Loads the tilemap

    loadMap(currentLevel)


    f3 = false

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

    --Tells the game what to do when the player collides with the TavernDoor

    local colliders = world:queryCircleArea(TavernDoorX, TavernDoorY, 50, {'player'})
    if #colliders > 0 then
        if currentLevel == "map" then
            loadMap("Tavern")
            player:setPosition(1216, 1549)
            love.audio.stop()
            love.audio.play(music.Tavern)
        elseif currentLevel == "Tavern" then
            loadMap("map")
            player:setPosition(5831, 6980)
            love.audio.stop()
            love.audio.play(music.mainmusic1)
        end
    end

    --Tells the game what to do when the player collides with the Left Forest Enterance

    local colliders = world:queryCircleArea(ForestlX, ForestlY, 50, {'player'})
    if #colliders > 0 then
        if currentLevel == "map" then
            loadMap("EvilForest")
            player:setPosition(708, 1216)
            love.audio.stop()
            love.audio.play(music.Tavern)
        elseif currentLevel == "EvilForest" then
            loadMap("map")
            player:setPosition(9379, 6012)
            love.audio.stop()
            love.audio.play(music.mainmusic1)
        end
    end

    --Tells the game what to do when the player collides with the Right Forest Enterance

    local colliders = world:queryCircleArea(ForestrX, ForestrY, 50, {'player'})
    if #colliders > 0 then
        if currentLevel == "map" then
            loadMap("EvilForest")
            player:setPosition(5608, 1229)
            love.audio.stop()
            love.audio.play(music.Tavern)
        elseif currentLevel == "EvilForest" then
            loadMap("map")
            player:setPosition(10873, 4716)
            love.audio.stop()
            love.audio.play(music.mainmusic1)
        end
    end

    --Assigns the value of px, and py to saveData, allowing for the position to be kept next time the game is loaded

    saveData.px = px-47
    saveData.py = py-65
    saveData.phealth = player.health
    saveData.currentLevel = currentLevel
    love.filesystem.write("data.lua", table.show(saveData, "saveData"))

    --Sets the music for the current map

    if currentLevel == "Tavern" then
        love.audio.pause()
        love.audio.play(music.Tavern)
    elseif currentLevel == "map" then
        love.audio.pause()
        love.audio.play(music.mainmusic1)
    elseif currentLevel == "EvilForest" then
        love.audio.pause()
        love.audio.play(music.Forest)
    end

end

function love.draw()

    --Anything in cam:attach is drawn, but not tied to the screen, anything in cam:detach is tied to the screen

    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        gameMap:drawLayer(gameMap.layers["Objects"])
        world:draw()
        drawPlayer()
        gameMap:drawLayer(gameMap.layers["Foreground"])
    cam:detach()

    --Displays the co-ordinates and FPS when f3 is held down
    
    local px, py = player:getPosition()
    if f3 == true then
        love.graphics.print("x ="..px)
        love.graphics.print("y ="..py, 0, 10)
        love.graphics.print("FPS:"..tostring(love.timer.getFPS()), 0, 20)
    end

    --Displays Map

    if love.keyboard.isDown('m') then
        love.graphics.draw(ui.map, 0, 0, nil , 1)
    end

    --Creates the player's health bar, and colours it red, it drains as the players health decreases.

    love.graphics.push()
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", love.graphics.getWidth() - 65, love.graphics.getHeight() - 75, 40, saveData.phealth * -2.1)
        love.graphics.setColor(255, 255, 255)
    love.graphics.pop()

    love.graphics.push()
        love.graphics.setColor(0, 255, 0)
        love.graphics.rectangle("fill", love.graphics.getWidth() - 125, love.graphics.getHeight() - 75, 40, player.stamina * -2.1)
        love.graphics.setColor(255, 255, 255)
    love.graphics.pop()

    --Draws the UI for the player stats

    love.graphics.draw(ui.statusUI, love.graphics.getWidth() - 135, love.graphics.getHeight() - 328)


end

function love.keypressed(key)
    if key == "f3" then
        f3 = true
    end
    if key == "r" then
        loadMap("Tavern")
    end
end

function spawnObstacles(x, y, width, height)

    --Creates obstacles/boundaries based on their position in the TileMap

    local obstacle = world:newRectangleCollider(x, y, width, height, {collision_class = "obstacle"})
    obstacle:setType('static')
    table.insert(obstacles, obstacle)
end

function destroyAll()

    --Allows for map transition, deletes all objects and enemies as it changes maps.(Can be copied)

    local i = #obstacles
    while i > -1 do
        if obstacles[i] ~= nil then
            obstacles[i]:destroy()
        end

    table.remove(obstacles, i)
    i = i - 1
    end

    --local i = #enemies
    --while i > -1 do
        --if enemies[i] ~= nil then
            --enemies[i]:destroy()
        --end

    --table.remove(obstacles, i)
    --i = i - 1
    --end
end

function loadMap(mapName)
    currentLevel = mapName
    destroyAll()
    --Loads the TileMap, and calculates the positions of the obstacles/boundaries, and assigns it the the spawnObstacles function

    gameMap = sti("map/" .. mapName .. ".lua")
    for i, obj in pairs(gameMap.layers["Boundaries"].objects) do
        spawnObstacles(obj.x, obj.y, obj.width, obj.height)
    end

    --Loads and creates all the necessary triggers for Map

    if currentLevel == "map" then
        for i, obj in pairs(gameMap.layers["TavernDoor"].objects) do
            TavernDoorX = obj.x
            TavernDoorY = obj.y
        end
        for i, obj in pairs(gameMap.layers["ForestLeft"].objects) do
            ForestlX = obj.x
            ForestlY = obj.y
        end
        for i, obj in pairs(gameMap.layers["ForestRight"].objects) do
            ForestrX = obj.x
            ForestrY = obj.y
        end

    --Loads and creates all the necessary triggers for Tavern

    elseif currentLevel == "Tavern" then
        for i, obj in pairs(gameMap.layers["TavernDoor"].objects) do
            TavernDoorX = obj.x
            TavernDoorY = obj.y
        end

    --Loads and creates all the necessary triggers for EvilForest

    elseif currentLevel =="EvilForest" then
        for i, obj in pairs(gameMap.layers["ForestLeft"].objects) do
            ForestlX = obj.x
            ForestlY = obj.y
        end
        for i, obj in pairs(gameMap.layers["ForestRight"].objects) do
            ForestrX = obj.x
            ForestrY = obj.y
        end
    end

end