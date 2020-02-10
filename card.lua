Card = {}
Card.__index = Card

function Card:create(point, enemy)
    -- oyuncu kartı oluşturmak için kullanılır

    local card = {}
    setmetatable(card, Card)
    card.manaPoint = point

    -- kartın varsayılan değerleri
    card.xPosition = 0
    card.yPosition = 0
    card.cardWitdth = 120
    card.cardHeight = 200
    card.enemy = enemy
    card.color = {0, 0, 1}
    card.textColor = {1, 1, 1}
    card.attack = false

    -- kartlara değerlerine göre renk atanıyor
    card:setColor(card)

    return card
end

function Card:draw()
    -- kartı ekrana çizmek için kullanılır
    UI:drawRectangle(self.color, nil, "fill", self.xPosition, self.yPosition,
                     self.cardWitdth, self.cardHeight)

    local t_x = self.xPosition + 2
    local t_y = self.yPosition + 2
    local b_x = self.xPosition + self.cardWitdth - 13
    local b_y = self.yPosition + self.cardHeight - 20

    UI:printText(self.textColor, 15, self.manaPoint, t_x, t_y)
    UI:printText(self.textColor, 15, self.manaPoint, b_x, t_y)
    UI:printText(self.textColor, 15, self.manaPoint, b_x, b_y)
    UI:printText(self.textColor, 15, self.manaPoint, t_x, b_y)
end

function Card:setColor()
    -- kart değerlerine göre renk atanıyor
    if self.manaPoint <= 4 then
        self.color = {0, 0.5, 1}
        self.textColor = {0, 0, 0}
    elseif self.manaPoint <= 6 then
        self.color = {1, 1, 0}
        self.textColor = {0, 0, 0}
    elseif self.manaPoint > 6 then
        self.color = {1, 0, 0}
        self.textColor = {1, 1, 1}
    end
end

function Card:update(dt)
    if self.attack then
        game.activeAttack = true

        local predicate = self.yPosition < 200
        if game.activePlayerIndex == 0 then
            self.yPosition = self.yPosition - (300 * dt)
        elseif game.activePlayerIndex == 1 then
            self.yPosition = self.yPosition + (300 * dt)
            predicate = self.yPosition > 200
        end

        if predicate then
            self.attack = false
            game.activeAttack = false
            game:attack(self)
        end
    end

    if self.enemy == false then
        -- dört kenar çarpışma tespiti
        if game:detectCollision(self.xPosition,
                                self.xPosition + self.cardWitdth,
                                self.yPosition, self.yPosition + self.cardHeight) then
            self.color = {1, 0.5, 1}
        else
            self:setColor()
        end
    end
end

function Card:mousePress(x, y, k)
    if self.enemy == false then
        if game:detectCollision(self.xPosition,
                                self.xPosition + self.cardWitdth,
                                self.yPosition, self.yPosition + self.cardHeight) then
            if game:checkCard(self) then self.attack = true end
        end
    end
end
