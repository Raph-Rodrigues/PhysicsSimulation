local Button = require("classes.Button")

local Menu = {}
Menu.__index = Menu

function Menu:new(x, y, width, height, title)
    local obj = {}
    setmetatable(obj, Menu)

    obj.x = x or 0
    obj.y = y or 0
    obj.width = width or 300
    obj.height = height or 400
    obj.title = title or "Menu"
    obj.buttons = {}
    obj.visible = false

    return obj
end

function Menu:addButton(button)
    table.insert(self.buttons, button)
end

function Menu:draw(fonts)
    if not self.visible then return end

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 10)

    local titleFont = (type(fonts) == "table" and fonts.bold) or fonts or love.graphics.getFont()
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.title, self.x + 10, self.y + 10)

    for i, button in ipairs(self.buttons) do
        if button.draw then
            if type(fonts) == "table" then
                button:draw(fonts.normal)
            else
                button:draw(fonts)
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
end

function Menu:checkClick(x, y)
    if not self.visible then return false end

    for i, button in ipairs(self.buttons) do
        if button:containsPoint(x, y) then
            button:onClick()
            return true
        end
    end

    return false
end

function Menu:show()
    self.visible = true
end

function Menu:hide()
    self.visible = false
end

return Menu