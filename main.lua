-- All you need is love, tu tu du du du duuuu
local love = require( 'love' )
-- This function generates a random string, parameters are length and seed, and both defined in the load function below.
local function stringGenerator( Length, inputRNG )
-- Stored variables for the random stringGenerator.
    local letterStore = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    local digitStore = "0123456789"
-- Stored output of the random stringGenerator
    local resultString = ""
--[[
This loop creates a randomized chance of picking from either Store,
adds the result to the index until desired length then returns resultString.
--]]
    for i = 1, Length do
        local idxGen = math.random()
        if idxGen < inputRNG then
            local letterIndex = math.random( #letterStore )
            resultString = resultString..letterStore:sub( letterIndex, letterIndex )
        else
            local digitIndex = math.random( #digitStore )
            resultString = resultString..digitStore:sub( digitIndex, digitIndex )
        end
    end
    return resultString
end

-- Load function is built in the Love2D framework.
function love.load()
    love.graphics.setDefaultFilter( "nearest", "nearest" )
-- Load seed for math.random Lua function calls to update on load.
    math.randomseed(os.time())
-- This static seed serves to adjust the probability while initiating stringGenerator.
    local inputRNG = 0.5
--[[
generatedString initiates the random stringGenerator and stores the output.
The first parameter is the desired length of the CAPTCHA.
--]]
    generatedString = stringGenerator( 10, inputRNG )

-- Table to store indexes and later print them individually
    indexedCharacters = {}
    local PositionX = math.random( 1, 40 )
-- This loop is to single out each character and iterate randomized positioning.
    for i = 1, #generatedString do
        local characterIndex = generatedString:sub( i, i )
        local characterWidth = love.graphics.getFont():getWidth( characterIndex )
        local PositionY = math.random( 1, 30 )
        local offset = math.random( 1, 25 )
        local offsetAngle = math.rad( math.random( -15, 15 ) )
        table.insert( indexedCharacters, { characterIndex = characterIndex, x = PositionX, y = PositionY, offsetAngle = offsetAngle } )
        PositionX = PositionX + characterWidth + offset
    end

end

local screenX = 20
local screenY = 150

function love.draw()

    for _, pos in ipairs( indexedCharacters ) do
        love.graphics.push()
        love.graphics.translate( pos.x, pos.y )
        love.graphics.rotate( pos.offsetAngle )
        love.graphics.print( pos.characterIndex, 0, 0, nil, 3, 3 )
        love.graphics.pop()
    end
end