function love.load()
    sound = {}
    sound.grassrun = love.audio.newSource("audio/grassrun.mp3", "stream")
    sound.grasswalk = love.audio.newSource("audio/grassslow.mp3", "stream")

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.flower = love.graphics.newImage('sprites/FlowerFrontx8.png')
    sprites.flowerb = love.graphics.newImage('sprites/FlowerBackx8.png')
    sprites.flowerl = love.graphics.newImage('sprites/FlowerLeftx8.png')
    sprites.flowerR = love.graphics.newImage('sprites/FlowerRightx8.png')
    sprites.flowerC = love.graphics.newImage('sprites/FlowerCoolx8.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.tb = love.graphics.newImage('sprites/TB.png')
    sprites.main = sprites.flower

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 120
end

function love.update(dt)

    --Controls player movability

    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed*dt
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed*dt
    end
    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed*dt
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed*dt
    end

    --Enables sprinting, and controls the audio for walking, and running

    if love.keyboard.isDown("lctrl") and love.keyboard.isDown("d", "a", "w", "s") then
        player.speed = 240
        love.audio.play(sound.grassrun)
    elseif love.keyboard.isDown("d", "a", "w", "s") then
        player.speed = 120
        love.audio.stop(sound.grassrun)
        love.audio.play(sound.grasswalk)
    else
        player.speed = 120
        love.audio.stop(sound.grassrun)
        love.audio.pause(sound.grasswalk)
    end
    
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)

    love.graphics.draw(sprites.main, player.x, player.y, nil, 0.5, 0.5)

    --Character Sprite rotation when walking

    if love.keyboard.isDown("w") then
        sprites.main = sprites.flowerb
    elseif love.keyboard.isDown("a") then
        sprites.main = sprites.flowerl
    elseif love.keyboard.isDown("d") then
        sprites.main = sprites.flowerR
    elseif love.keyboard.isDown("c") and love.keyboard.isDown("o") then
        sprites.main = sprites.flowerC
    else
        sprites.main = sprites.flower
    end
end
