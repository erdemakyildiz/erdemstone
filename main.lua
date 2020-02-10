local push = require "push"
require "card"
require "player"
require "game"
require "ui"

-- sanal çözünürlük kütüphanesi
gameWidth, gameHeight = 1080, 720
push:setupScreen(gameWidth, gameHeight, gameWidth, gameHeight,
                 {fullscreen = false})

UI = nil

function love.load()
    UI = Ui:create()

    -- oyun oluşturuluyor
    game = Game:create()
    game.active = true
    game.activeAttack = false

    -- iki oyuncu ekleniyor
    -- 1 olan bot olarak tanımlı
    player_0 = Player:create(0, "Erdem")
    player_1 = Player:create(1, "Bot")

    -- oyun başlatılıyor
    game:start(player_0, player_1)
end

function love.update(dt)
    if game.active then
        player_0:update(dt)
        player_1:update(dt)
        game:update(dt)
    end
end

function love.draw()
    push:start()

    UI:draw()
    game:draw()
    player_0:draw()
    player_1:draw()

    push:finish()
end

function love.mousepressed(x, y, button)
    -- mouse event'i aktif bir saldırı yoksa ve oyund evam ediyorsa çalışması için
    -- koşul ekledim
    if game.active and game.activeAttack == false then
        game:mousePress(x, y, button)
        player_0:mousePress(x, y, button)
    end
end
