Ui = {}
Ui.__index = Ui

mainMessage = ""
mainMessageColor = {1, 0, 0}
infoMessage = ""
infoMessageArray = {}

function Ui:create()
    local ui = {}
    setmetatable(ui, Ui)

    return ui
end

function Ui:drawRectangle(color, lineWidth, type, x, y, x1, y1)
    setColor(color)
    love.graphics.setLineWidth(lineWidth == nil and 0 or lineWidth)
    love.graphics.rectangle(type, x, y, x1, y1)
end

function Ui:printText(color, fontSize, text, x, y)
    setColor(color)
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)
    love.graphics.print(text, x, y)
end

function setColor(color) if color ~= nil then love.graphics.setColor(color) end end

function Ui:draw()
    -- bilgilendirme amaçlı yazılar
    UI:printText(mainMessageColor, 50, mainMessage, 300, gameHeight - 420)
    UI:printText({1, 1, 1}, 13, infoMessage, 50, 200)
    -- bilgilendirme amaçlı yazılar
end

function Ui:addInfoMessage(msg)
    -- hareket dökümü
    infoMessage = ""

    table.insert(infoMessageArray, msg)

    if table.getn(infoMessageArray) >= 15 then
        table.remove(infoMessageArray, 1)
    end

    for index, value in ipairs(infoMessageArray) do
        infoMessage = infoMessage .. "\n" .. value
    end
end
