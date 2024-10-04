-- All you need is love, tu tu du du du duuuu
local love = require( 'love' )
local button = require( 'src.buttons' )
-- store variables that determines the area covered by the cursor
local cursor = {
    radius = 2,
    x = 1,
    y = 1
}

local program = {
    state = {
        intro = true,
        test = false,
        solved = false,
    }
}

-- table to initiate the button factory as defined on load.
local buttons = {
    intro_state = {}
}

local function initiateTest()
    program.state[ 'intro' ] = false
    program.state[ 'test' ] = true
    program.state[ 'solved' ] = false
end

local function solveTest()
    program.state[ 'intro' ] = false
    program.state[ 'test' ] = false
    program.state[ 'solved' ] = true
end

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

local screenX = 200
local screenY = 200

function love.load()
    noiseFont = love.graphics.newFont( 'zxx-noise.ttf', 26 )
    love.graphics.setFont( noiseFont )
    love.graphics.setDefaultFilter( "nearest", "nearest" )
    buttons.intro_state.startTest = button( "Initiate", initiateTest, nil, 140, 40 )
-- Load seed for math.random Lua function calls to update on load.
    math.randomseed( os.time() )
-- This static seed serves to adjust the probability while initiating stringGenerator.
    local inputRNG = 0.5
--[[
generatedString initiates the random stringGenerator and stores the output.
The first parameter is the desired length of the CAPTCHA.
It also defines the user input that is required for the solution.
--]]
    generatedString = stringGenerator( 10, inputRNG )

-- Table to store indexes and later print them individually
    indexedCharacters = {}
    local PositionX = ( screenX + math.random( 6, 12 ) ) / 4
--[[
Below is the loop to index each character and iterate randomized positioning.
I used operands quite arbitrarily and played around until I was satisfied with the output.
For some reason, multiples of 3 provided the lowest amount of failed tests during this phase.
Maybe it's because there are 3 coordinates? I don't know, I'm a programmer not a mathematician.
--]]
    for i = 1, #generatedString do
        local characterIndex = generatedString:sub( i, i )
        local characterWidth = ( love.graphics.getFont():getWidth( characterIndex ) )
        local PositionY = math.random( 6, 24 )
        local offset = math.random( 6, 30 )
        local offsetAngle = math.rad( math.random( -3, 3 ) )
        table.insert( indexedCharacters, { characterIndex = characterIndex, x = PositionX, y = PositionY, offsetAngle = offsetAngle } )
        PositionX = PositionX + characterWidth + offset
    end
-- registers any mouse button as long as the cursor is hovering a button.
    function love.mousepressed( x, y, button, istouch, presses )
        if not program.state[ 'test' ] then
            if button == 1 then
                if program.state[ 'intro' ] or program.state[ 'solved' ] then
                    for index in pairs( buttons.intro_state ) do
                        buttons.intro_state[ index ]:checkPressed( x, y, cursor.radius )
                    end
                end
            end 
        end
    end

end
-- Store user input as a string.
userInput = ""
-- This function is to append typed characters to the userInput string.
function love.textinput(t)
    userInput = userInput..t
end
-- Humans make mistakes sometimes. Bots too but we don't talk about that, life is unfair.
function love.keypressed(key)
    if key == 'backspace' then
        userInput = userInput:sub( 1, -2 )
    end

    if userInput == generatedString then
        solveTest()
    end
end

function love.update(dt)
    
end

function love.draw()

    love.graphics.rectangle( 'line', screenX, screenY, 420, 100 )


    if program.state[ 'test' ] then
        love.graphics.print(userInput)
        for _, pos in ipairs( indexedCharacters ) do
            love.graphics.push()
            love.graphics.translate( ( pos.x + math.random( -1, 1 ) ), ( pos.y + math.random( -1, 1 ) ) )
            love.graphics.rotate( pos.offsetAngle )
            love.graphics.print( pos.characterIndex, screenX + 6, screenY + 6 )
            love.graphics.pop()
        end
    elseif program.state['intro'] then
        buttons.intro_state.startTest:draw( 260, 220, 1, 1 )
    elseif program.state[ 'solved' ] then
        love.graphics.print("Test Solved", 10, 200)
    end
end