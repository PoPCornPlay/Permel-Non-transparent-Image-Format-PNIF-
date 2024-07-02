
local pnifLib = {}

local colors = {
    background = 0x2e2e2d,  
    text = 0xa3a3a0        
}

function pnifLib.load(path)
    local file = io.open(path, "rb")
    if not file then
        error("Unable to open file: " .. path)
    end

    local image = {}
    local byte = file:read(1)
    local pixels = {}

    while byte do
        table.insert(pixels, string.byte(byte))
        byte = file:read(1)
    end

    file:close()

    local width = 16
    local height = #pixels / width

    for y = 1, height do
        local row = {}
        for x = 1, width do
            local index = (y - 1) * width + x
            local color = bit.band(pixels[index], 0xF)
            local character = pixels[index + 1]
            table.insert(row, {color = color, character = character})
        end
        table.insert(image, row)
    end

    return image
end

function pnifLib.draw(image, xPos, yPos)
    term.setCursorPos(xPos, yPos)

    for _, row in ipairs(image) do
        for _, pixel in ipairs(row) do
            term.setTextColor(colors.text)
            term.setBackgroundColor(colors.background)
            term.write(string.char(pixel.character))
        end
        term.setCursorPos(xPos, term.getCursorY() + 1)
    end
end

function pnifLib.save(image, path)
    local file = io.open(path, "wb")
    if not file then
        error("Unable to open file for writing: " .. path)
    end

    local width = #image[1]
    local height = #image

    for y = 1, height do
        for x = 1, width do
            local pixel = image[y][x]
            local colorByte = bit.lshift(pixel.color, 4)
            local characterByte = pixel.character
            file:write(string.char(colorByte + characterByte))
        end
    end

    file:close()
end

function pnifLib.convertToNft(image)
    local nftImage = {}
    for _, row in ipairs(image) do
        local nftRow = {}
        for _, pixel in ipairs(row) do
            local colorByte = bit.lshift(pixel.color, 4)
            local backgroundByte = colors.background
            local textColorByte = colors.text
            table.insert(nftRow, {color = colorByte, background = backgroundByte, textcolor = textColorByte, character = pixel.character})
        end
        table.insert(nftImage, nftRow)
    end
    return nftImage
end

return pnifLib


