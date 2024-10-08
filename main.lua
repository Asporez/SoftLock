-- All you need is love, tu tu du du du duuuu
local love = require( 'love' )
local button = require( 'src.buttons' )
local keymap = require( 'src.keymap' )
-- Store variables that determines the area covered by the cursor
local cursor = {
    radius = 2,
    x = 1,
    y = 1
}
-- table to store stages for the program to be run in.
local program = {
    state = {
        intro = true,
        test = false,
        solved = false,
    }
}
--[[
table to initiate the button factory as defined on load.
to create buttons for different program states, add to this
list and include it in the button and mouse function on load.
--]]
local buttons = {
    intro_state = {}
}
-- Helper functions to switch program states.
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


-- This defines the initial coordinates of the CAPTCHA.
local screenX = math.random(10, 200)
local screenY = math.random(10, 200)
-- table to store the path taken by the mouse.
local mousePath = {}
-- Function to analyze the mouse movement.
function analyzeMovement(path)
-- Variables to track the total distance and time
    local totalDistance = 0
    local totalTime = 0
    
    print("Analyzing Movement...")
    
-- Loop to compare consecutive points (start at index 2)
    if program.state['intro'] then
        for i = 2, #path do
            local dx = path[i].x - path[i - 1].x
            local dy = path[i].y - path[i - 1].y
            local distance = math.sqrt(dx * dx + dy * dy)
            local timeDifference = path[i].time - path[i - 1].time
--[[ remove comment markers to get brain exploding amount of values printed in the console.
            print(string.format("Step %d: ", i))
            print(string.format("Previous Point: (%.2f, %.2f)", path[i - 1].x, path[i - 1].y))
            print(string.format("Current Point: (%.2f, %.2f)", path[i].x, path[i].y))
            print(string.format("dx: %.2f, dy: %.2f", dx, dy))
            print(string.format("Distance: %.2f", distance))
            print(string.format("Time Difference: %.2f", timeDifference))
--]]
            totalDistance = totalDistance + distance
            totalTime = totalTime + timeDifference
        end
    
-- If the totalTime is 0, prevent division by zero
        if totalTime == 0 then
            print("Total Time is zero, cannot calculate average speed.")
            return "insufficient data"
        end
    
-- Calculate average speed
        local avgSpeed = totalDistance / totalTime
    
-- Print the total values and the calculated average speed
        print(string.format("Total Distance: %.2f", totalDistance))
        print(string.format("Total Time: %.2f", totalTime))
        print(string.format("Average Speed: %.2f", avgSpeed))
    
-- Return movement type based on speed threshold TODO: THIS NEEDS ADJUSTING, I never made expert systems, terra incognita.
-- at around 500 I can trigger the bot-like response if I go really fast so let's start with that!
        if avgSpeed > 500 then
            print("Movement detected as bot-like")
            return "bot-like"
        elseif avgSpeed > 0.1 and avgSpeed <= 500 then
            print("Movement detected as human-like")
            return "human-like"
        end
    end
end

function love.load()
-- Obfuscated font.
    falseFont = love.graphics.newFont( 'ZXX_False.otf', 32 )
-- Less obfuscated font.
    noiseFont = love.graphics.newFont( 'ZXX_Noise.otf', 32 )
    love.graphics.setFont( noiseFont )
-- set default filter for love.graphics (removes autodithering)
    love.graphics.setDefaultFilter( "nearest", "nearest" )
    buttons.intro_state.startTest = button( "Initiate", initiateTest, nil, 160, 40 )
-- Load seed for math.random Lua function calls to update on load.
    math.randomseed( os.time() )
-- This static seed serves to adjust the probability while initiating stringGenerator.
    local inputRNG = 0.5
--[[
generatedString initiates the random stringGenerator and stores the output.
The first parameter is the desired length of the CAPTCHA.
It also defines the user input that is required for the solution.
--]]
    generatedString = stringGenerator( 8, inputRNG )

-- Table to store indexes and later print them individually
    indexedCharacters = {}
    local PositionX = ( screenX + math.random( 6, 12 ) ) / 4
--[[
Below is the loop to index each character and iterate randomized positioning.
I used operands quite arbitrarily and played around until I was satisfied with the output.
I did about 100 tests and eyeballed it, this can be improved with more data
about the potential threat's capabilities.
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

-- This singleton presses buttons with the mouse cursor.
    function love.mousepressed( x, y, button, istouch, presses )
        if program.state[ 'intro' ] then
            if button == 1 and analyzeMovement( mousePath ) == "human-like" then
                for index in pairs( buttons.intro_state ) do
                    buttons.intro_state[ index ]:checkPressed( x, y, cursor.radius )
                end 
            end 
        end
    end

end

function love.mousemoved(x, y, dx, dy, istouch)
    table.insert( mousePath, { x = x, y = y, time = love.timer.getTime() } )
end

-- Store user input as a string.
userInput = ""
-- This function is to append typed characters to the userInput string.
function love.textinput(t)
    local mappedChar = keymap[t]

    if mappedChar then
        userInput = userInput..mappedChar
    else
        userInput = userInput..t
    end

end
-- Humans make mistakes sometimes.
function love.keypressed(key)
    if key == 'backspace' then
        userInput = userInput:sub( 1, -2 )
    end

    if userInput == generatedString then
        solveTest()
    end
end

local timer = 0
local resetTime = 30

function love.update(dt)
    if program.state[ 'intro' ] then
-- Call analyzeMovement and print debug info when relevant (e.g., after mouse movement)
        local movementType = analyzeMovement( mousePath )
        print( "Final Movement Analysis: " .. movementType )
        if movementType == "bot-like" or movementType == "insufficient data" then
            print( "FAIL" )
            love.load()
        elseif movementType == "human-like" then
            print( "PASS" )
        end

    end

    if program.state[ 'test' ] then
        timer = timer + dt

        if timer >= resetTime then
            love.load()
            timer = 0
        end

    end

end

function love.draw()

--[[ UI border stores
    local outerX, outerY, outerWidth, outerHeight = 0, 0, 640, 480
    local innerX, innerY, innerWidth, innerHeight = 10, 10, 620, 460
-- draw UI borders with RGB values.
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", outerX, outerY, outerWidth, outerHeight)
    love.graphics.setColor(1, 0.8, 0.8)
    love.graphics.rectangle("fill", innerX, innerY, innerWidth, innerHeight)
--]]

    if program.state[ 'test' ] then
        love.graphics.print( userInput )
        love.graphics.setFont(noiseFont) -- Set the noise font for the timer
        local timeLeft = resetTime - timer
        love.graphics.print(math.floor(timeLeft), 10, 10)

-- This loop is to draw each characters individually and apply the tranformations
        for _, pos in ipairs( indexedCharacters ) do
-- Generates random RGB color for each character
            local r = math.random()
            local g = math.random()
            local b = math.random()
            love.graphics.setColor( r, g, b )
            love.graphics.setFont( falseFont )

            love.graphics.push()
            love.graphics.translate( ( pos.x + math.random( -1, 1 ) ), ( pos.y + math.random( -1, 1 ) ) )
            love.graphics.rotate( pos.offsetAngle )
            love.graphics.print( pos.characterIndex, screenX + 6, screenY + 6 )
            love.graphics.pop()
        end
    elseif program.state[ 'intro' ] then
        buttons.intro_state.startTest:draw( 260, 220, 1, 1 )
    elseif program.state[ 'solved' ] then
-- Oh yeah right, gotta deobfuscate with the obfuscated-deobfuss...err wait...
-- I'll do it manually... "Gvhg Hloevw" = "Test Solved"
        love.graphics.print( "Gvhg Hloevw", 10, 200 )
    end
end