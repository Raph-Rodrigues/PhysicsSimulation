function love.conf(t)
    t.window.title = "PhysicsSimulation"
    t.window.width = 800
    t.window.height = 600
    -- Se estiver em mobile (Android ou iOS) ativa fullscreen; caso contrário, modo janela
    if os.getenv("ANDROID_ARGUMENT") or os.getenv("IPHONEOS") then
         t.window.fullscreen = true
         t.window.fullscreentype = "desktop"
    else
         t.window.fullscreen = false
    end
end
