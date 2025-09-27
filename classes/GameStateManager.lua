local GameStateManager = {}
GameStateManager.__index = GameStateManager

function GameStateManager:new(menus)
    local obj = {}
    setmetatable(obj, GameStateManager)
    
    obj.states = {
        menu = "menu",
        pause = "pause",
        levelMenu = "levelMenu",
        mru = "mru",
        mruv = "mruv",
        playing = "playing"
    }
    
    obj.menus = menus or {}
    obj.currentState = obj.states.menu
    obj.previousState = nil
    
    return obj
end

function GameStateManager:setState(newState)
    self.previousState = self.currentState
    self.currentState = newState

    -- Gerenciar a visibilidade dos menus automaticamente
    if self.menus.mainMenu then self.menus.mainMenu:hide() end
    if self.menus.levelMenu then self.menus.levelMenu:hide() end
    if self.menus.pauseMenu then self.menus.pauseMenu:hide() end

    if newState == self.states.menu then
        if self.menus.mainMenu then self.menus.mainMenu:show() end
    elseif newState == self.states.levelMenu then
        if self.menus.levelMenu then self.menus.levelMenu:show() end
    elseif newState == self.states.pause then
        if self.menus.pauseMenu then self.menus.pauseMenu:show() end
    end
end

function GameStateManager:getState()
    return self.currentState or self.states.menu
end

function GameStateManager:isGameRunning()
    local state = self:getState()
    return state == self.states.mru or 
           state == self.states.mruv or
           state == self.states.playing
end

return GameStateManager