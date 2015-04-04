pp = require 'inspect'
ripple = require 'ripple'

-- We only do this once, not on every newGame
introFade = 255

-- How many seconds the dude should fade out for on death (times 255)
deathFadeScale = 1 * 255

-- The font to use
fontPath = 'assets/Roboto-Thin.ttf'

-- Color palettes available. One will be chosen at random on every newGame. The
-- index of the color will be used as the color of a ripple with that many
-- bounces in it. So a ripple with no bounces will use the first color, one
-- bounce will use the second color, etc... The final color is also used as the
-- color of the dude.
colors = {
    { -- The River
        {159,180,159},
        {78,144,135},
        {52,98,100},
        {37,66,71},
    },
    { -- River Dance
        {162,212,224},
        {114,198,219},
        {68,169,194},
        {50,122,140},
        {48,71,77},
    },
    { -- Rivers of Babylon
        {196,231,242},
        {150,224,235},
        {104,216,227},
        {6,153,173},
        {85,100,105},
    },
}

function newGame()
    c = colors[love.math.random(1,table.getn(colors))]
    cn = table.getn(c)
    game = {
        colors = c,
        fonts = {
            ["title"] = {
                font = love.graphics.newFont(fontPath, 128),
                color = c[cn-1],
            },
            ["instr"] = {
                font = love.graphics.newFont(fontPath, 48),
                color = c[cn-1],
            },
            ["count"] = {
                font = love.graphics.newFont(fontPath, 56),
                color = c[cn],
            },
        },
        ripples = {
        },
        dude = {
            pos = {x = w/2, y = h/2},
            radius = 10,
            speed = 150,
            inAir = false,
            zBump = 0,
            zVel = 0,
            color = c[cn],
        },
        progress = {
            died = false,
            diedTS = 0,
            jumps = 0,
            outroFade = 255,
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

    game = newGame()
    addRipple(w/2, h/2, w/5, 0)
end

function setFont(f, alpha)
    if not alpha then alpha = 255 end
    font = game.fonts[f]
    love.graphics.setColor(font.color[1], font.color[2], font.color[3], alpha)
    love.graphics.setFont(font.font)
end

function isDown(keys)
    for _, k in pairs(keys) do
        if love.keyboard.isDown(k) then
            return true
        end
    end
end

-- These keys have special properties which require them to be here and not in
-- the normal key handling:
-- * Space: we don't want the player to be able to continuously jump
-- * r: this needs debouncing or else when you press it you'll actually be
-- making 4 or 5 new games
function love.keypressed(key, isrepeat)
    if key == "space" and not game.dude.inAir then
        game.dude.inAir = true
        game.dude.zVel = 12

    elseif key == "r" then
        game = newGame()
    end
end

function math.clamp(low, n, high) return math.min(math.max(n, low), high) end

function addRipple(x, y, speed, bounces)
    r = ripple.new(x, y, speed, bounces, game.colors)
    game.ripples[r] = true
end

function love.update(dt)

    -- Always want to be able to quit
    if isDown({"escape"}) then
        love.event.quit()
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

    minx = game.dude.radius
    miny = game.dude.radius
    maxx = w - game.dude.radius
    maxy = h - game.dude.radius

    if isDown({"w", "up"}) then
        game.dude.pos.y = math.clamp(miny, game.dude.pos.y - (dt * game.dude.speed), maxy)
    end
    if isDown({"s", "down"}) then
        game.dude.pos.y = math.clamp(miny, game.dude.pos.y + (dt * game.dude.speed), maxy)
    end
    if isDown({"a", "left"}) then
        game.dude.pos.x = math.clamp(minx, game.dude.pos.x - (dt * game.dude.speed), maxx)
    end
    if isDown({"d", "right"}) then
        game.dude.pos.x = math.clamp(minx, game.dude.pos.x + (dt * game.dude.speed), maxy)
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
        addRipple(game.dude.pos.x, game.dude.pos.y, speed, bounces)
    end

    if not game.dude.inAir then
        for r in pairs(game.ripples) do
            if ripple.collided(r, game.dude.pos.x, game.dude.pos.y, game.dude.radius) then
                game.progress.died = true
                game.progress.diedTS = love.timer.getTime()
                return
            end
        end
    end

    introFade = math.clamp(0, introFade - 5, 255)
    if game.progress.jumps > 0 then
        game.progress.outroFade = math.clamp(0, game.progress.outroFade -  5, 255)
    end
end

function love.draw()
    for r in pairs(game.ripples) do
        ripple.draw(r)
    end
    drawDude()
    drawUI()

    if introFade > 1 then
        love.graphics.setColor(255, 255, 255, introFade)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end
end

function drawDude()
    red = game.dude.color[1]
    green = game.dude.color[2]
    blue = game.dude.color[3]
    alpha = 255
    if game.progress.died then
        alpha = 255 - math.clamp(0, (love.timer.getTime() - game.progress.diedTS) * deathFadeScale, 255)
    end
    love.graphics.setColor(red, green, blue, alpha)

    rad = game.dude.radius + (game.dude.zBump / 8)
    love.graphics.circle("fill", game.dude.pos.x, game.dude.pos.y - game.dude.zBump, rad, 50)
end

function drawUI()
    if game.progress.died then
        setFont("instr")
        love.graphics.printf("Restart: r\nQuit: esc", 0, h/2 + 200, w, "center")

    elseif game.progress.outroFade > 0 then
        setFont("title", game.progress.outroFade)
        love.graphics.printf("RIPPLE", 0, h/2 - 300, w, "center")
        setFont("instr", game.progress.outroFade)
        love.graphics.printf("Move: arrows/wasd\nJump: space", 0, h/2 + 200, w, "center")
    end

    if game.progress.jumps > 0 then
        setFont("count")
        love.graphics.printf(game.progress.jumps, w - 80, 10, 60, "right")
    end

end
