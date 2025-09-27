local GameObject = require("classes.GameObject")

local Button = {}
Button.__index = Button
setmetatable(Button, { __index = GameObject }) -- Button herda GameObject

function Button:new(x, y, width, height, text, action)
    local obj = GameObject:new(x, y)
    setmetatable(obj, Button) -- obj.__index -> Button

    obj.width = width or 100
    obj.height = height or 40
    obj.text = text or "Button"
    obj.action = action or function() end
    obj.color = {0.7, 0.7, 0.7}
    obj.textColor = {0, 0, 0}

    return obj
end

function Button:draw(font)
    local drawFont
    if type(font) == "table" then
        drawFont = font.normal or font.medium or font.bold or love.graphics.getFont()
    else
        drawFont = font or love.graphics.getFont()
    end
    
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
    love.graphics.setColor(self.textColor)
    love.graphics.setFont(drawFont)
    
    local textWidth = drawFont:getWidth(self.text)
    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - drawFont:getHeight()) / 2
    
    love.graphics.print(self.text, textX, textY)
    love.graphics.setColor(1, 1, 1)
end

function Button:onClick()
    if self.action then
        self.action()
    end
end

return Button