colors = {
    {
        {104,179,175},
        {135,189,177},
        {170,204,177},
        {195,219,180},
        {211,226,182},
    },
    {
        {22,147,165},
        {69,181,196},
        {126,206,202},
        {160,222,214},
        {199,237,232},
    },
    {
        {9,43,90},
        {9,115,138},
        {120,168,144},
        {158,209,183},
        {231,217,180},
    },
}

function posColor(r, pos)
    return r.colors[r.bounces - pos.c + 1]
end

function bouncePositionsInner(x, y, w, h, c, all)
    key = x .. ":" .. y
    if all[key] == nil then
        all[key] = {x=x, y=y, c=c}
    end

    if c > 0 then
        bouncePositionsInner(-x, y, w, h, c-1, all)
        bouncePositionsInner(x, -y, w, h, c-1, all)
        bouncePositionsInner(x, 2*h-y, w, h, c-1, all)
        bouncePositionsInner(2*w-x, y, w, h, c-1, all)
    end
end

function bouncePositions(x, y, c)
    w, h = love.graphics.getDimensions() -- SLOW?
    all = {}
    bouncePositionsInner(x, y, w, h, c, all)
    return all
end

function radius(r)
    return (love.timer.getTime() - r.started) * r.speed
end

return {
    new = function(x, y, speed, bounces)
        r = {
            started = love.timer.getTime(),
            pos = bouncePositions(x, y, bounces),
            speed = speed,
            bounces = bounces,
            colors = colors[love.math.random(1,table.getn(colors))],
        }
        return r
    end,

    canDie = function(r, w, h)
        rad = radius(r)
        return rad > w * (1 + r.bounces) or rad > h * (1 + r.bounces)
    end,

    draw = function(r)
        for _, pos in pairs(r.pos) do
            color = posColor(r, pos)
            love.graphics.setColor(color[1], color[2], color[3]);
            love.graphics.circle("line", pos.x, pos.y, radius(r), 100)
        end
    end,

    collided = function(r, x, y, rad)
        if love.timer.getTime() - r.started < 1 then
            return false
        end
        thisrad = radius(r)
        for _, pos in pairs(r.pos) do
            hs = math.pow(x-pos.x, 2) + math.pow(y-pos.y, 2)
            if hs > math.pow(thisrad+rad, 2) or math.sqrt(hs) <= math.abs(thisrad-rad) then
                --continue
            else
                return true
            end
        end
        return false
    end
}
