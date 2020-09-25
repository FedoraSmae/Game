--This file contains all information, and processes, involved with the Player

--Draws the Player hitbox

player = world:newRectangleCollider(saveData.px, saveData.py, 95.2, 128.8, {collision_class = "player"})
player:setFixedRotation(true)

--All the player related stats

player.speed = 120
player.animation = animations.idle
player.isMovingside = false
player.isMovingup = false
player.isMovingDown = false
player.direction = 1
player.health = saveData.phealth
player.stamina = saveData.stamina

--checks of the save data doesn't have a value set to it, if not then the health is set to 100

if saveData.phealth == nil then
    player.health = 100
end

if saveData.stamina == nil then
    player.stamina = 100
end

function playerUpdate(dt)

    --Everything to do with the players movement

    if player.body then
        player.isMovingside = false
        player.isMovingup = false
        player.isMovingDown = false
        local px, py = player:getPosition()
        if love.keyboard.isDown('d') then
            player:setX(px + player.speed*dt)
            player.isMovingside = true
            player.direction = 1
        end
        if love.keyboard.isDown('a') then
            player:setX(px - player.speed*dt)
            player.isMovingside = true
            player.direction = -1
        end
        if love.keyboard.isDown('w') then
            player:setY(py - player.speed*dt)
            player.isMovingup = true
        end
        if love.keyboard.isDown('s') then
            player:setY(py + player.speed*dt)
            player.isMovingDown = true
        end

        if player:enter('bad') then
            player:destroy()
        end
    end

    local run = false

    --Controls the players sprinting, and how fast they can go

    if love.keyboard.isDown('lctrl') and love.keyboard.isDown("d", "a", "w", "s") and player.stamina > 0 then
        player.speed = 240
        run = true
        player.stamina = player.stamina - 1
    elseif love.keyboard.isDown("d", "a", "w", "s") and player.stamina < 100 then
        player.speed = 120
        run = false
        player.stamina = player.stamina + 0.2
    elseif player.stamina < 100 then
        player.stamina = player.stamina + 1
    else
        player.speed = 120
        run = false
    end

    --Chooses which animation to display on screen based on which key is pressed and what the player is doing

    if player.isMovingside then
        player.animation = animations.sidewalk
    elseif player.isMovingup then
        player.animation = animations.backwalk
    elseif player.isMovingDown then
        player.animation = animations.frontwalk
    else
        player.animation = animations.idle

    end

    --Updates the animation so the next frame is displayed on screen

    player.animation:update(dt)

    if love.keyboard.isDown('p') then
        player.health = player.health - 1
    end

    --[[while player.stamina <= 0 and player.stamina < 101 and run == false do
        player.stamina = player.stamina + 1
    end]]



    --[[if player.health <= 0 then
        player:destroy()
    end]]

end

function drawPlayer()

    --Draws the players sprite in the correct position within the hitbox, as well as where it was last saved

    local px, py = player:getPosition()
    player.animation:draw(sprites.playerSheet, px, py, nil, 0.7 * player.direction, 0.7, 68, 92)
    
end