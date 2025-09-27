local Circle = require("classes.Circle")
local Button = require("classes.Button")
local Menu = require("classes.Menu")
local GameStateManager = require("classes.GameStateManager")

function love.load()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    -- Criar círculo
    circle = Circle:new(screenWidth / 2, screenHeight / 2, 40)

    -- Variáveis para medições
    elapsedGameTime = 0 -- Nosso novo cronômetro
    totalDistance = 0
    lastX = circle.x
    lastY = circle.y

    -- Aceleração para MRUV
    acceleration = {x = 0, y = 100}

    -- Fontes
    fonts = {
        normal = love.graphics.newFont(12),
        medium = love.graphics.newFont(20),
        bold = love.graphics.newFont(22)
    }

    -- Criar menus
    mainMenu = createMainMenu()
    levelMenu = createLevelMenu()
    pauseMenu = createPauseMenu()

    local menus = { mainMenu = mainMenu, levelMenu = levelMenu, pauseMenu = pauseMenu }
    gameStateManager = GameStateManager:new(menus)
    gameStateManager:setState("menu") -- Exibe o menu inicial

    -- Botão de pausa
    pauseButton = Button:new(
        screenWidth - 80, 20, 60, 60, "II", 
        function() gameStateManager:setState("pause") end
    )
end

function createMainMenu()
    local menu = Menu:new(screenWidth/2 - 120, screenHeight/2 - 150, 280, 280, "MENU PRINCIPAL")
    menu:addButton(Button:new(
        screenWidth/2 - 110, screenHeight/2 - 50, 160, 40, "Jogar",
        function() gameStateManager:setState("levelMenu") end
    ))
    menu:addButton(Button:new(
        screenWidth/2 - 110, screenHeight/2 + 20, 160, 40, "Sair do jogo",
        function() love.event.quit() end
    ))
    return menu
end

function createLevelMenu()
    local menu = Menu:new(screenWidth/2 - 120, screenHeight/2 - 150, 280, 280, "ESCOLHA O MODO")
    menu:addButton(Button:new(
        screenWidth/2 - 110, screenHeight/2 - 50, 220, 40, "MRU - Movimento Uniforme",
        function()
            resetCircle()
            circle.vx = 200
            circle.vy = 0
            gameStateManager:setState("mru")
        end
    ))
    menu:addButton(Button:new(
        screenWidth/2 - 110, screenHeight/2 + 20, 220, 40, "MRUV - Com Aceleração",
        function()
            resetCircle()
            circle.vx = 0
            circle.vy = 0
            gameStateManager:setState("mruv")
        end
    ))
    menu:addButton(Button:new(
        screenWidth/2 - 110, screenHeight/2 + 90, 220, 40, "Voltar",
        function() gameStateManager:setState("menu") end
    ))
    return menu
end

function createPauseMenu()
    local menu = Menu:new(screenWidth/2 - 120, screenHeight/2 - 150, 280, 280, "JOGO PAUSADO")
    menu:addButton(Button:new(
        screenWidth/2 - 110, screenHeight/2 - 50, 160, 40, "Continuar",
        function() gameStateManager:setState(gameStateManager.previousState or "mru") end
    ))
    menu:addButton(Button:new(
        screenWidth/2 - 110, screenHeight/2 + 20, 160, 40, "Menu Inicial",
        function() gameStateManager:setState("menu") end
    ))
    return menu
end

function love.update(dt)
    if not gameStateManager:isGameRunning() then return end

    -- Incrementa o tempo de jogo apenas quando a simulação está rodando
    elapsedGameTime = elapsedGameTime + dt

    local prevX, prevY = circle.x, circle.y
    if gameStateManager:getState() == "mru" then
        circle:update(dt, nil, screenWidth, screenHeight)
    elseif gameStateManager:getState() == "mruv" then
        circle:update(dt, acceleration, screenWidth, screenHeight)
    end

    local dx = circle.x - prevX
    local dy = circle.y - prevY
    totalDistance = totalDistance + math.sqrt(dx * dx + dy * dy)
end

function love.draw()
    -- Define a cor de fundo
    love.graphics.setColor(0.1, 0.1, 0.3)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    local state = gameStateManager:getState()
    
    -- Desenha os elementos do jogo se estiver em um estado de gameplay OU pausado
    if state == "mru" or state == "mruv" or state == "pause" then
        circle:draw()
        drawGameInfo()
        pauseButton:draw(fonts.bold)
    end
    
    -- Se você usar o GameStateManager refatorado, as 3 linhas abaixo são suficientes.
    -- O gerenciador de estado controlará qual menu é visível.
    mainMenu:draw(fonts)
    levelMenu:draw(fonts)
    pauseMenu:draw(fonts)
end

function drawGameInfo()
    -- Usa nossa variável de tempo de jogo, que já está "pausada"
    local elapsedTime = elapsedGameTime
    local averageSpeed = elapsedTime > 0 and totalDistance / elapsedTime or 0

    love.graphics.setFont(fonts.normal)
    love.graphics.print("Toque para resetar a posição", 10, 10)
    love.graphics.print("Posição X: " .. math.floor(circle.x), 10, 30)
    love.graphics.print("Posição Y: " .. math.floor(circle.y), 10, 50)
    love.graphics.print("Velocidade horizontal: " .. string.format("%.1f", circle.vx) .. " px/s", 10, 70)
    love.graphics.print("Velocidade vertical: " .. string.format("%.1f", circle.vy) .. " px/s", 10, 90)
    love.graphics.print("Velocidade instantânea: " .. string.format("%.1f", circle:getSpeed()) .. " px/s", 10, 110)
    love.graphics.print("Velocidade média: " .. string.format("%.1f", averageSpeed) .. " px/s", 10, 130)
    love.graphics.print("Distância percorrida: " .. math.floor(totalDistance) .. " px", 10, 150)
    love.graphics.print("Tempo: " .. string.format("%.1f", elapsedTime) .. " s", 10, 170)

    if gameStateManager:getState() == "mru" then
        love.graphics.print("Movimento Retilíneo Uniforme (MRU)", 10, 200)
    elseif gameStateManager:getState() == "mruv" then
        love.graphics.print("Movimento Retilíneo Uniformemente Variado (MRUV)", 10, 200)
        love.graphics.print("Aceleração vertical: " .. string.format("%.1f", acceleration.y) .. " px/s²", 10, 220)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if mainMenu:checkClick(x, y) then return end
    if levelMenu:checkClick(x, y) then return end
    if pauseMenu:checkClick(x, y) then return end

    if pauseButton:containsPoint(x, y) and gameStateManager:isGameRunning() then
        -- Lógica do botão de pausa já está definida no próprio botão
        pauseButton:onClick()
        return
    end

    if gameStateManager:isGameRunning() then
        resetCircle()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        love.touchpressed(1, x, y, 0, 0, 1)
    end
end

function resetCircle()
    local state = gameStateManager:getState()
    if state == "mru" then
        circle:reset(200, 0)
    elseif state == "mruv" then
        circle:reset(0, 0)
    else
        circle:reset(love.math.random(-900, 900), love.math.random(-900, 900))
    end
    
    -- Zera o nosso cronômetro e a distância percorrida
    elapsedGameTime = 0
    totalDistance = 0
end