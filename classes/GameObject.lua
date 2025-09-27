local GameObject = {}
GameObject.__index = GameObject

function GameObject:new(x, y)
    local obj = {}
    setmetatable(obj, GameObject)
    
    obj.x = x or 0
    obj.y = y or 0
    obj.width = 0
    obj.height = 0
    obj.visible = true
    
    return obj
end

function GameObject:update(dt)
    -- Método a ser sobrescrito pelas classes filhas
end

function GameObject:draw()
    -- Método a ser sobrescrito pelas classes filhas
end

function GameObject:containsPoint(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

return GameObject