local GameObject = require("classes.GameObject")

local Circle = {}
Circle.__index = Circle
setmetatable(Circle, { __index = GameObject }) -- Circle herda GameObject

function Circle:new(x, y, radius)
    local obj = GameObject:new(x, y)
    setmetatable(obj, Circle)

    obj.radius = radius or 40
    obj.vx = 0
    obj.vy = 0
    obj.initialX = x
    obj.initialY = y

    return obj
end

function Circle:update(dt, acceleration, screenWidth, screenHeight)
    if acceleration then
        self.vx = self.vx + acceleration.x * dt
        self.vy = self.vy + acceleration.y * dt
    end

    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    -- Colisão com bordas
    if self.x - self.radius < 0 then
        self.x = self.radius
        self.vx = -self.vx
    elseif self.x + self.radius > screenWidth then
        self.x = screenWidth - self.radius
        self.vx = -self.vx
    end

    if self.y - self.radius < 0 then
        self.y = self.radius
        self.vy = -self.vy
    elseif self.y + self.radius > screenHeight then
        self.y = screenHeight - self.radius
        self.vy = -self.vy
    end
end

function Circle:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", self.x, self.y, self.radius)

    -- Vetor de velocidade (visual)
    love.graphics.setColor(1, 0, 0)
    love.graphics.line(self.x, self.y, self.x + self.vx / 10, self.y + self.vy / 10)
    love.graphics.setColor(1, 1, 1)
end

function Circle:reset(vx, vy)
    self.x = self.initialX
    self.y = self.initialY
    self.vx = vx or self.vx
    self.vy = vy or self.vy
end

function Circle:getSpeed()
    return math.sqrt(self.vx * self.vx + self.vy * self.vy)
end

return Circle