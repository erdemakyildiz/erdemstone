Game = {}
Game.__index = Game

function Game:create()
    local game = {}
    setmetatable(game, Game)

    -- 0 oynayan kişi, 1 bilgisayar
    game.activePlayer = nil
    game.activePlayerIndex = nil
    game.active = false
    game.activeAttack = false
    game.totalTurn = 0

    game.turnText = ""
    game.turnColor = {1, 1, 1}
    game.turnButtonSize = {x = 0, y = 0}
    game.turnButtonDimension = {
        x = (gameWidth - gameWidth / 4),
        y = (gameHeight / 2)
    }
    game.human = nil
    game.pc = nil

    return game
end

function Game:draw()
    -- el değiştirme butonu
    UI:drawRectangle(self.turnColor, 1, "line", self.turnButtonDimension.x,
                     self.turnButtonDimension.y - self.turnButtonSize.y,
                     self.turnButtonSize.x, self.turnButtonSize.y)

    UI:printText(self.turnColor, 25, self.turnText, self.turnButtonDimension.x + 25,
                 self.turnButtonDimension.y - self.turnButtonSize.y + 10)
end

function Game:start(human, pc)
    self.human = human
    self.pc = pc

    self:changeActivePlayer()
end

function Game:changeActivePlayer()
    -- aktif oyuncuyu değiştirmek için
    if self.activePlayer == nil or self.activePlayerIndex == 1 then
        self.activePlayerIndex = 0
        self.activePlayer = self.human

        self.activePlayer:turn()
    elseif self.activePlayerIndex == 0 then
        self.activePlayerIndex = 1
        self.activePlayer = self.pc

        self.activePlayer:turn()
        self.activePlayer:play()
    end

    self.totalTurn = self.totalTurn + 1
end

function Game:update(dt)

    -- elin kimde olduğunu gösterme ve el değiştirmek için
    if self.activePlayerIndex == 0 then
        game.turnButtonSize = {x = 130, y = 50}
        game.turnColor = {0, 1, 0}
        self.turnText = "Eli Bitir"

        local map = {
            x1 = self.turnButtonDimension.x,
            x2 = self.turnButtonDimension.x + self.turnButtonSize.x,
            y1 = (self.turnButtonDimension.y - self.turnButtonSize.y),
            y2 = self.turnButtonDimension.y
        }

        if self:detectCollision(map.x1, map.x2, map.y1, map.y2) then
            game.turnColor = {1, 1, 0}
        end

    elseif self.activePlayerIndex == 1 then
        game.turnButtonSize = {x = 230, y = 50}
        game.turnColor = {1, 0, 0}
        self.turnText = "Düşman Sırası"
    else
        self.turnText = ""
    end
end

function Game:mousePress(x, y, k)
    local map = {
        x1 = self.turnButtonDimension.x,
        x2 = self.turnButtonDimension.x + self.turnButtonSize.x,
        y1 = (self.turnButtonDimension.y - self.turnButtonSize.y),
        y2 = self.turnButtonDimension.y
    }

    if self:detectCollision(map.x1, map.x2, map.y1, map.y2) then
        self:changeActivePlayer()
    end
end

function Game:checkCard(card)
    if self.activePlayer.mana < card.manaPoint then
        -- mana, kartı atmak için yeterli değil
        return false
    elseif self.activePlayer.mana >= card.manaPoint then
        return true
    end
end

function Game:attack(card)
    UI:addInfoMessage(self.activePlayer.name .. " " .. card.manaPoint ..
                          " numaralı kart ile saldırdı.")

    -- kartın mana değeri kadar hasar veriliyor
    self.activePlayer.mana = self.activePlayer.mana - card.manaPoint

    local enemy = self.activePlayer == self.human and self.pc or self.human

    -- düşmanın canı düşürülüyor
    enemy.health = (enemy.health - card.manaPoint) <= 0 and 0 or
                       (enemy.health - card.manaPoint)

    -- kullanılan kart siliniyor
    self.activePlayer:removeCard(card)

    if enemy.health <= 0 then
        -- can sıfıra ulaşırsa sonucu göstermek için
        if enemy == self.pc then
            UI.mainMessageColor = {0, 1, 0}
            UI.mainMessage = "Kazandın"
        else
            UI.mainMessage = {1, 0, 0}
            UI.mainMessage = "Kaybettin"
        end

        game.active = false
    end

    if enemy.index == 0 or self.activePlayer.mana == 0 then
        game:changeActivePlayer()
    end
end

function Game:detectCollision(x1, x2, y1, y2)
    local mousex = love.mouse.getX()
    local mousey = love.mouse.getY()

    -- dört kenar çarpışma tespiti
    return mousex > x1 and mousex < x2 and mousey > y1 and mousey < y2
end
