function posColor(r, pos)
    return r.colors[pos.c + 1]
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
    new = function(x, y, speed, bounces, colors)
        r = {
            started = love.timer.getTime(),
            pos = bouncePositions(x, y, bounces),
            speed = speed,
            bounces = bounces,
            colors = colors,
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
            love.graphics.setLineWidth(pos.c+1)
            love.graphics.circle("line", pos.x, pos.y, radius(r), 100)
        end
    end,

    collided = function(r, x, y, rad)
        thisrad = radius(r)
        if thisrad < rad * 1.05 then
            return false
        end
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
