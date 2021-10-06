function love.load()

    sprites = {}
    sprites.player = love.graphics.newImage("sprites/player.png")
    sprites.bullet = love.graphics.newImage("sprites/bullet.png")
    sprites.invader = love.graphics.newImage("sprites/invader.png")
    sprites.barrier = {}
    sprites.barrier.state1 = love.graphics.newImage("sprites/barrier_state1.png")
    sprites.barrier.state2 = love.graphics.newImage("sprites/barrier_state2.png")
    sprites.barrier.state3 = love.graphics.newImage("sprites/barrier_state3.png")

    player = {}
    player.x = 0
    player.y = love.graphics.getHeight() - 100
    player.alive = true
    player.speed = 5

    bullets = {}
    bulletDebounce = 0.3
    bulletTimer = bulletDebounce

    enemySpace = 0.75
    enemySpaceOffset = 0.125

    enemyStartY = 100
    enemyRowStepAmount = 25
    enemyPerRow = 5
    enemyRows = 5
    enemies = {}

    enemyStepTimer = 1
    minTimer = 0.5
    enemyStepAmount = 20
    enemyStepDirection = 1
    changedStepDirection = false
    enemyTurnPoint = 20
    timer = enemyStepTimer

    barrierYPos = love.graphics.getHeight() - 150
    barrierCount = 3
    barriers = {}

    gamestate = 1
    score = 0
    gameoverMessage = ""

end

function love.update(dt)
    if gamestate == 2 then

        for i, b in ipairs(bullets) do 
            b.y = b.y - b.speed * dt
        end

        for i = #bullets, 1, -1 do
            local b = bullets[i]
            if b.y < 0 or b.y > love.graphics.getHeight() or b.dead then
                table.remove(bullets, i)
            end
        end

        for i = #enemies, 1, -1 do
            local e = enemies[i]
            if e.dead then
                table.remove(enemies, i)
            end
        end

        for i = #barriers, 1, -1 do
            local b = barriers[i]
            if b.health <= 0 then
                table.remove(barriers, i)
            end
        end

        for i, e in ipairs(enemies) do
            for j, b in ipairs(bullets) do
                if distanceBetween(e.x, e.y, b.x, b.y) < 20 and b.tag == "good" then
                    e.dead = true
                    b.dead = true
                    score = score + 1
                    speedUpInvaders()
                end
            end

            e.timer = e.timer + dt
            if(e.timer > e.fireTimer) then
                invaderFireBullet(e)
            end
        end

        for i, b in ipairs(bullets) do
            if distanceBetween(player.x, player.y, b.x, b.y) < 20 and b.tag == "bad" then
                gamestate = 1
                gameoverMessage = "You were shot down!"
            end
        end

        for i, r in ipairs(barriers) do
            for j, b in ipairs(bullets) do
                if distanceBetween(r.x, r.y, b.x, b.y) < 10 then
                    r.health = r.health - 1
                    b.dead = true
                end
            end
        end

        timer = timer - dt
        if timer <= 0 then
            speedUpInvaders()
            timer = enemyStepTimer

            for i, e in ipairs(enemies) do
                if(changedStepDirection == false) then
                    if e.x + (enemyStepAmount * enemyStepDirection) > love.graphics.getWidth() - enemyTurnPoint then
                        enemyStepDirection = -1
                        changedStepDirection = true
                    elseif  e.x + (enemyStepAmount * enemyStepDirection) < 0 + enemyTurnPoint then
                        enemyStepDirection = 1
                        changedStepDirection = true
                    end
                end
            end

            if changedStepDirection then
                for i, e in ipairs(enemies) do
                    e.y = e.y + enemyStepAmount

                    if(e.y > love.graphics.getHeight() - 200) then
                        gamestate = 1
                        gameoverMessage = "The aliens have landed!"
                    end
                end
                changedStepDirection = false
            else 
                for i, e in ipairs(enemies) do        
                    e.x = e.x + (enemyStepAmount * enemyStepDirection)
                end
            end

        end

        player.x = love.mouse.getX()
        bulletTimer = bulletTimer - dt

        if #enemies == 0 then
            gamestate = 1
            gameoverMessage = "A winner is you!"
        end

    else
        for i = #bullets, 1, -1 do
            table.remove(bullets, i)
        end

        for i = #enemies, 1, -1 do
            table.remove(enemies, i)
        end

        for i = #barriers, 1, -1 do
            table.remove(barriers, i)
        end
    end
end

function speedUpInvaders ()  
    if enemyStepTimer > minTimer then
        enemyStepTimer = 0.975 * enemyStepTimer
    end
end

function love.draw()

    if gamestate == 1 then
        love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center") 

        if gameoverMessage then 
            love.graphics.printf(gameoverMessage, 0, 100, love.graphics.getWidth(), "center") 
        end
    end
    -- love.graphics.printf("enemy count" .. #enemies, 0, 0, love.graphics.getWidth(), "center") 
    
    if gamestate == 2 then
        love.graphics.setColor(1, 0, 0)
        for i, v in ipairs(enemies) do
            love.graphics.draw(sprites.invader, v.x, v.y, nil, 2, nil, sprites.invader:getWidth()/2, sprites.invader:getHeight()/2)
        end
    end

    --player
    love.graphics.setColor(0, 1, 0)
    if gamestate == 2 then
        love.graphics.draw(sprites.player, player.x, player.y, nill, 2)

        love.graphics.rectangle("fill", 0, love.graphics.getHeight() - 200, love.graphics.getWidth(), 2)

        for i, b in ipairs(bullets) do
            if b.tag == "good" then
                love.graphics.setColor(0, 1, 0)
            else 
                love.graphics.setColor(1, 0, 0)
            end
            love.graphics.draw(sprites.bullet, b.x, b.y, nil, 2)
        end

        for i, b in ipairs(barriers) do
            if b.health == 3 then
                love.graphics.setColor(0, 1, 0)
                love.graphics.draw(sprites.barrier.state1, b.x, b.y, nil, 3, nil, sprites.barrier.state1:getWidth()/2, sprites.barrier.state1:getHeight()/2)
            elseif b.health == 2 then
                love.graphics.setColor(.3, .8, .3)
                love.graphics.draw(sprites.barrier.state2, b.x, b.y, nil, 3, nil, sprites.barrier.state2:getWidth()/2, sprites.barrier.state2:getHeight()/2)
            else
                love.graphics.setColor(.7, .5, .5)
                love.graphics.draw(sprites.barrier.state3, b.x, b.y, nil, 3, nil, sprites.barrier.state3:getWidth()/2, sprites.barrier.state3:getHeight()/2)
            end
        end
    end
end


function invaderFireBullet(e) 
    fireBullet(e, -1, "bad")
    e.timer = 0
    e.fireTimer = math.random(5, 20)
end
function fireBullet (pos, direction, tag) 
    local bullet = {}
    bullet.x = pos.x
    bullet.y = pos.y
    bullet.speed = 500 * direction
    bullet.tag = tag
    table.insert(bullets, bullet)
end

function getEnemySpace () 
    return (love.graphics.getWidth() * enemySpace)
end

function spawnInvaders () 
    for i = 0, enemyRows, 1 do
        for j = 0, enemyPerRow, 1 do
            local enemy = {}
            enemy.x = ((getEnemySpace() / enemyPerRow) * j) + (love.graphics.getWidth() * enemySpaceOffset)
            enemy.y = enemyStartY + (enemyRowStepAmount * i)

            enemy.fireTimer = math.random(5, 20)
            enemy.timer = 0

            table.insert(enemies, enemy)
        end
    end
end

function spawnBarriers () 
    for i = 0, barrierCount, 1 do 
        local barrier = {}
        barrier.x = ((getEnemySpace() / barrierCount) * i) + (love.graphics.getWidth() * enemySpaceOffset)
        barrier.y = barrierYPos
        barrier.health = 3
        table.insert(barriers, barrier)
    end
end

function love.mousepressed(x,y,button)
    if button == 1 and gamestate == 1 then
        gamestate = 2
        spawnInvaders()
        spawnBarriers()
        enemyStepTimer = 1
        timer = enemyStepTimer
        enemyStepDirection = 1
    elseif button == 1 and gamestate == 2 and bulletTimer <= 0 then
        fireBullet(player, 1, "good")
        bulletTimer = bulletDebounce
    end
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt ( (x2 - x1)^2 + (y2 - y1)^2)
end