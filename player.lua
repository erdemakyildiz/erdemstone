Player = {}
Player.__index = Player

require "card"

function Player:create(index, name)
    -- oyuncu oluşturmak için kullanılır
    local player = {}
    setmetatable(player, Player)

    player.name = name
    player.health = 30
    player.maxHealth = 30
    player.mana = 0
    player.maxMana = 10
    player.activeCards = {}

    -- index'i 1 olan bot kabul ettim
    player.index = index
    player.turnCount = 0
    player.message = ""
    player.cardArray = {
        0, 0, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7, 8
    }

    player:createPlayerCards()

    return player
end

function Player:draw()
    -- Karaktere ait can ve mana barlarının çizimi
    local barDimension = {x = 250, y = 20}
    local playerBarPosition = {x = gameWidth / 4, y = (gameHeight / 4) * 3}

    if (self.index == 1) then
        playerBarPosition = {x = gameWidth / 4, y = gameHeight / 6}
    end

    font = love.graphics.newFont(12)
    love.graphics.setFont(font)

    -- can barı
    UI:drawRectangle({1, 1, 1}, 1, "line", playerBarPosition.x,
                     playerBarPosition.y, barDimension.x, barDimension.y)
    UI:printText({1, 1, 1}, 12, "Can = " .. self.health, playerBarPosition.x,
                 playerBarPosition.y - 20)

    local healthBarLenght = (barDimension.x / self.maxHealth) * self.health;
    healthBarLenght = healthBarLenght == 250 and 248 or healthBarLenght
    UI:drawRectangle({1, 0, 0}, nil, "fill", playerBarPosition.x + 1,
                     playerBarPosition.y + 1, healthBarLenght,
                     barDimension.y - 2)

    -- mana barı
    UI:drawRectangle({1, 1, 1}, 1, "line", playerBarPosition.x * 2,
                     playerBarPosition.y, barDimension.x, barDimension.y)
    UI:printText({1, 1, 1}, 12, "Mana = " .. self.mana, playerBarPosition.x * 2,
                 playerBarPosition.y - 20)

    local manaBarLenght = (barDimension.x / self.maxMana) * self.mana;
    manaBarLenght = manaBarLenght == 250 and 248 or manaBarLenght
    UI:drawRectangle({0, 0, 1}, 1, "fill", playerBarPosition.x * 2 + 1,
                     playerBarPosition.y + 1, manaBarLenght, barDimension.y - 2)

    -- destede kaç kart kaldığına dair bilgi mesajı
    UI:printText({1, 1, 1}, 15, self.message, playerBarPosition.x - 150,
                 playerBarPosition.y)

    self:drawPlayerCards()
end

function Player:removeCard(card)
    if (self:has_value(self.activeCards, card)) then
        self:removeValue(self.activeCards, card)
        self:calculateCartPosition()
    end
end

function Player:createPlayerCards() for j = 1, 3 do self:insertCard(true) end end

function Player:insertRandomCard()
    if self.turnCount == 1 then return end

    -- el kullanıcıya geçtiğinde rastgele bir kart çekiliyor
    if table.getn(self.activeCards) < 5 then
        self:insertCard(true)
    else
        self:insertCard(false)
    end
end

function Player:calculateCartPosition()
    if self.index == 0 then
        -- human

        for i, card in ipairs(self.activeCards) do
            card.xPosition = (card.cardWitdth + 40) * i
            card.yPosition = gameHeight - (card.cardHeight / 2)
        end
    end

    if self.index == 1 then
        -- pc

        for i, card in ipairs(self.activeCards) do
            card.xPosition = (card.cardWitdth + 40) * i
            card.yPosition = ((card.cardHeight / 2) * -1) - 30
        end
    end

end

function Player:insertCard(status)
    -- status değeri false ise çekilen kart çöpe atılıyor

    if table.getn(self.cardArray) <= 0 then
        game.activePlayer.message = "1 hasar aldın"
        game.activePlayer.health = game.activePlayer.health - 1

        return
    end

    number = love.math.random(1, table.getn(self.cardArray))

    if game.activePlayer ~= nil then
        game.activePlayer.message = table.getn(self.cardArray) .. " kart kaldı"
    end

    _c = Card:create(self.cardArray[number], self.index == 1)
    self:removeValue(self.cardArray, self.cardArray[number])

    if status then
        table.insert(self.activeCards, _c)
        self:calculateCartPosition()

        UI:addInfoMessage(self.name .. " " .. _c.manaPoint ..
                              " numaralı kartı aldı.")
    else
        UI:addInfoMessage(self.name .. " " .. _c.manaPoint ..
                              " numaralı kart çöpe atıldı.")
    end

end

function Player:has_value(tab, val)
    for index, value in ipairs(tab) do if value == val then return true end end

    return false
end

function Player:removeValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then table.remove(tab, index) end
    end
end

function Player:drawPlayerCards()
    for i, card in ipairs(self.activeCards) do card:draw() end
end

function Player:turn()
    self.turnCount = self.turnCount + 1
    self.mana = self.turnCount >= 10 and 10 or self.turnCount
    self:insertRandomCard()
end

function Player:update(dt)
    for i, card in ipairs(self.activeCards) do card:update(dt) end
end

function Player:mousePress(x, y, k)
    for i, card in ipairs(self.activeCards) do card:mousePress(x, y, k) end
end

function Player:play()
    -- üstün yapay zeka ile karşı hamle yapılıyor
    for i, card in ipairs(self.activeCards) do
        if self.mana >= card.manaPoint then
            card.attack = true
            return
        end
    end

    game:changeActivePlayer()
end
