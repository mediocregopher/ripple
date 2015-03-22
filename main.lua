pp = require 'inspect'
ripple = require 'ripple'

function newGame()
    game = {
        ripples = {},
        dude = {
            pos = {x = w/2, y = h/2},
            radius = 10,
            speed = 150,
            inAir = false,
            zBump = 0,
            zVel = 0,
        },
        progress = {
            died = false,
            jumps = 0,
        }
    }
    return game
end

function love.load()
    love.math.setRandomSeed(love.timer.getTime())
    love.window.setMode(1024, 1024, {
        --fullscreen = true,
        vsync = true,
    })
    love.mouse.setVisible(false)
    love.graphics.setBackgroundColor(248, 252, 255)
    w, h = love.graphics.getDimensions()

    fontPath = 'assets/GenW-Light.ttf'
    fonts = {
        ["title"] = {
            font = love.graphics.newFont(fontPath, 128),
            color = {120,168,144},
        },
        ["instr"] = {
            font = love.graphics.newFont(fontPath, 48),
            color = {120,168,144},
        },
        ["count"] = {
            font = love.graphics.newFont(fontPath, 56),
            color = {120,168,144},
        },
    }

    game = newGame()
end

function setFont(f)
    font = fonts[f]
    love.graphics.setColor(font.color[1], font.color[2], font.color[3])
    love.graphics.setFont(font.font)
end

function isDown(keys)
    for _, k in pairs(keys) do
        if love.keyboard.isDown(k) then
            return true
        end
    end
end

-- This needs to be here and not the normal key handling because we don't want
-- it to be able to be held down and continue to jump, which using isDown
-- wouldn't allow
function love.keypressed(key, isrepeat)
    if key == "space" and not game.dude.inAir then
        game.dude.inAir = true
        game.dude.zVel = 10
    end
end

function math.clamp(low, n, high) return math.min(math.max(n, low), high) end

function love.update(dt)

    -- Always want to be able to quit
    if isDown({"escape"}) then
        love.event.quit()
    end

    -- Always want to be able to restart
    if isDown({"r"}) then
        game = newGame()
        return
    end

    if game.progress.died then
        return
    end

    w, h = love.graphics.getDimensions()
    for r in pairs(game.ripples) do
        if ripple.canDie(r, w, h) then
            game.ripples[r] = nil
        end
    end

    if isDown({"w", "up"}) then
        game.dude.pos.y = math.clamp(game.dude.pos.y - (dt * game.dude.speed), 0, h)
    end
    if isDown({"s", "down"}) then
        game.dude.pos.y = math.clamp(game.dude.pos.y + (dt * game.dude.speed), 0, h)
    end
    if isDown({"a", "left"}) then
        game.dude.pos.x = math.clamp(game.dude.pos.x - (dt * game.dude.speed), 0, w)
    end
    if isDown({"d", "right"}) then
        game.dude.pos.x = math.clamp(game.dude.pos.x + (dt * game.dude.speed), 0, w)
    end

    game.dude.zBump = game.dude.zBump + game.dude.zVel
    if game.dude.zBump > 0 then
        game.dude.zVel = game.dude.zVel - 1
    elseif game.dude.zBump < 0 then
        game.dude.zBump = 0
        game.dude.zVel = 0
        game.dude.inAir = false
        game.progress.jumps = game.progress.jumps + 1

        speed = love.math.random(w/20, w/15)
        bounces = love.math.random(1,2)
        r = ripple.new(game.dude.pos.x, game.dude.pos.y, speed, bounces)
        game.ripples[r] = true
    end

    if not game.dude.inAir then
        for r in pairs(game.ripples) do
            if ripple.collided(r, game.dude.pos.x, game.dude.pos.y, game.dude.radius) then
                game.progress.died = true
                return
            end
        end
    end
end

function love.draw()
    for r in pairs(game.ripples) do
        ripple.draw(r)
    end
    drawDude()
    drawUI()
end

function drawDude()
    -- blink when dead
    if game.progress.died then
        period = 0.25
        if love.timer.getTime() % period < period / 2 then
            return
        end
    end

    love.graphics.setColor(120,168,144)
    rad = game.dude.radius + (game.dude.zBump / 5)
    love.graphics.circle("fill", game.dude.pos.x, game.dude.pos.y - game.dude.zBump, rad, 50)
end

function drawUI()

    if game.progress.jumps == 0 then
        setFont("title")
        love.graphics.printf("Ripple", 0, h/2 - 300, w, "center")
        setFont("instr")
        love.graphics.printf("Arrow/WASD to move\nSpace to jump", 0, h/2 + 200, w, "center")
    else
        setFont("count")
        love.graphics.printf(game.progress.jumps, w - 80, 10, 60, "right")
    end

    if game.progress.died then
        setFont("instr")
        love.graphics.printf("r to Restart\nESC to quit", 0, h/2 + 200, w, "center")
    end
end
