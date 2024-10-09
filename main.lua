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
--[[
Table to store the program states,
program.state[ 'solved' ] prints a message but has no functionality.
Can be used to export call that test is passed.
--]]
local program = {
    state = {
        intro = true,
        analysis = false,
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
    intro_state = {},
    analysis_state = {}
}
-- Helper functions to switch program states.

local function initiateAnalysis()
    program.state[ 'intro' ] = false
    program.state[ 'analysis' ] = true
    program.state[ 'test' ] = false
    program.state[ 'solved' ] = false
end

local function initiateTest()
    program.state[ 'intro' ] = false
    program.state[ 'analysis' ] = false
    program.state[ 'test' ] = true
    program.state[ 'solved' ] = false
end
-- This helper function is triggered when speed, trajectory, and sentience are verified.
-- Can also be used to export call that test is passed.
local function solveTest()
    program.state[ 'intro' ] = false
    program.state[ 'analysis' ] = false
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
local screenX = math.random( 10, 200 )
local screenY = math.random( 10, 200 )
-- table to store the path taken by the mouse.
local mousePath = {}
-- Function to analyze the mouse movement speed.
function analyzeMovement( pathDistance )
-- Variables to track the total distance and time
    local totalDistance = 0
    local totalTime = 0
    
    print( "Analyzing Movement..." )
    
-- Loop to compare consecutive points (start at index 2)
    if program.state[ 'analysis' ] then
        for i = 2, #pathDistance do
            local dx = pathDistance[ i ].x - pathDistance[ i - 1 ].x
            local dy = pathDistance[ i ].y - pathDistance[ i - 1 ].y
            local distance = math.sqrt( dx * dx + dy * dy )
            local timeDifference = pathDistance[ i ].time - pathDistance[ i - 1 ].time

            totalDistance = totalDistance + distance
            totalTime = totalTime + timeDifference
        end
    
-- If the totalTime is 0, prevent division by zero
        if totalTime == 0 then
            print( "Total Time is zero, cannot calculate average speed." )
            return "insufficient data"
        end
    
-- Calculate average speed
        local avgSpeed = totalDistance / totalTime
    
-- Print the total values and the calculated average speed
        print( string.format( "Total Distance: %.2f", totalDistance ) )
        print( string.format( "Total Time: %.2f", totalTime ) )
        print( string.format( "Average Speed: %.2f", avgSpeed ) )
    
        if avgSpeed > 900 then
            print( "Movement detected as bot-like" )
            return "bot-like"
        elseif avgSpeed > 0.1 and avgSpeed <= 900 then
            print( "Movement detected as human-like" )
            return "human-like"
        end
    end
end

function analyzeTrajectory( mousePositions )

-- Check the size of the mousePositions table
    print( "Number of mouse positions: " .. #mousePositions )

-- If there are not enough points, return early
    if #mousePositions < 3 then
        print( "Not enough points to analyze trajectory." )
        return "insufficient data"
    end

    local totalDeviation = 0
    local totalAngleChange = 0

    for i = 2, #mousePositions - 1 do
-- Calculate the distance from point ( i ) to the line formed by points ( i-1 ) and ( i+1 )
        local x1, y1 = mousePositions[ i-1 ].x, mousePositions[ i-1 ].y
        local x2, y2 = mousePositions[ i+1 ].x, mousePositions[ i+1 ].y
        local x, y = mousePositions[ i ].x, mousePositions[ i ].y

-- Deviation from the line ( using point-line distance formula that people with big brains created )
        local deviation = math.abs( ( y2 - y1 ) * x - ( x2 - x1 ) * y + x2 * y1 - y2 * x1 ) /
                          math.sqrt( ( y2 - y1 )^2 + ( x2 - x1 )^2 )

        totalDeviation = totalDeviation + deviation

-- Calculate the angle between consecutive movement vectors
        local vector1x, vector1y = x - x1, y - y1
        local vector2x, vector2y = x2 - x, y2 - y
        local dotProduct = vector1x * vector2x + vector1y * vector2y
        local magnitude1 = math.sqrt( vector1x^2 + vector1y^2 )
        local magnitude2 = math.sqrt( vector2x^2 + vector2y^2 )

        -- Check for valid dot product to avoid errors in acos
        if magnitude1 > 0 and magnitude2 > 0 then
            local angleChange = math.acos( dotProduct / ( magnitude1 * magnitude2 ) )
            totalAngleChange = totalAngleChange + angleChange
        else
            print( "Skipping angle change due to zero magnitude." )
        end
    end

    -- Define thresholds for what counts as "human-like" and "bot-like"
    local avgDeviation = totalDeviation / ( #mousePositions - 2 )
    local avgAngleChange = totalAngleChange / ( #mousePositions - 2 )

    print( string.format( "Deviation: %.2f", avgDeviation ) )
    print( string.format( "Angle Change: %.2f", totalAngleChange ) )

    if avgDeviation < 2 and avgAngleChange < math.rad( 5 ) then
        print( "Trajectory detected as bot-like" )
        return "bot-like-trajectory"
    else
        print( "Trajectory detected as human-like" )
        return "human-like-trajectory"
    end
end


function love.load()
-- Obfuscated font.
    falseFont = love.graphics.newFont( 'ZXX_False.otf', 32 )
-- Less obfuscated font.
    noiseFont = love.graphics.newFont( 'ZXX_Noise.otf', 32 )
    love.graphics.setFont( noiseFont )
-- set default filter for love.graphics to scale without antialiasing.
    love.graphics.setDefaultFilter( "nearest", "nearest" )
-- create button for the analysis phase, define the function and size.
    buttons.analysis_state.startTest = button( "Initiate", initiateTest, nil, 170, 40 )
    buttons.intro_state.startAnalysis = button( "Start", initiateAnalysis, nil, 110, 40 )
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
--[[
Below is the loop to index each character and iterate randomized positioning.
I used operands quite arbitrarily and played around until I was satisfied with the output.
I did about 100 tests and eyeballed it, this can be improved with more data
about the potential threat's capabilities.
--]]
-- Table to store indexes and later print them individually
    indexedCharacters = {}
    local PositionX = ( screenX + math.random( 6, 12 ) ) / 4
    for i = 1, #generatedString do
        local characterIndex = generatedString:sub( i, i )
        local characterWidth = ( love.graphics.getFont():getWidth( characterIndex ) )
        local PositionY = math.random( 6, 24 )
        local offset = math.random( 6, 30 )
        local offsetAngle = math.rad( math.random( -3, 3 ) )
        table.insert( indexedCharacters, { characterIndex = characterIndex, x = PositionX, y = PositionY, offsetAngle = offsetAngle } )
        PositionX = PositionX + characterWidth + offset
    end

end

function love.mousemoved( x, y, dx, dy, istouch )
    table.insert( mousePath, { x = x, y = y, time = love.timer.getTime() } )
end

-- Mouse pressed event to trigger analysis
function love.mousepressed(x, y, button, istouch, presses)
    if program.state['analysis'] then
        if button == 1 then
-- Only check if we have sufficient data
            if #mousePath > 50 then
                local movementResult = analyzeMovement(mousePath)
                local trajectoryResult = analyzeTrajectory(mousePath)

                if movementResult == "human-like" and trajectoryResult == "human-like-trajectory" then
                    for index in pairs(buttons.analysis_state) do
                        buttons.analysis_state[index]:checkPressed(x, y, cursor.radius)
                    end
                else
                    print("Bot-like behavior detected or insufficient data.")
                    love.load() -- Restart the test if bot-like movement is detected
                end
            else
                print("Not enough data to perform analysis.")
            end
        end
    elseif program.state[ 'intro' ] then
        if button == 1 then
            for index in pairs( buttons.intro_state ) do
                buttons.intro_state[index]:checkPressed( x, y, cursor.radius )
            end
        end
    end
end

-- Store user input as a string.
userInput = ""
-- This function is to append typed characters to the userInput string.
function love.textinput( t )
    local mappedChar = keymap[ t ]

    if mappedChar then
        userInput = userInput..mappedChar
    else
        userInput = userInput..t
    end

end
-- Humans make mistakes sometimes.
function love.keypressed( key )
    if key == 'backspace' then
        userInput = userInput:sub( 1, -2 )
    end

    if userInput == generatedString then
        solveTest()
    end
end

local timer = 0
local resetTime = 30

function love.update( dt )
    if program.state[ 'analysis' ] then
-- Updates the analysis of the movement and trajectory, the if loop ensures some movement occurs before a decision is made.
-- The idea is to block a cursor that would just instantiate on top of a button and forces human-like input to be produced.
        if #mousePath > 50 then
            local movementType = analyzeMovement( mousePath )
            local trajectoryType = analyzeTrajectory( mousePath )

            print( "Final Movement Analysis: " .. movementType )
            print( "Final Trajectory Analysis: " .. trajectoryType )

            if movementType == "bot-like" or trajectoryType == "bot-like-trajectory" then
                print( "Bot-like behavior detected." )
                love.load() -- Restart on bot-like detection
            elseif movementType == "human-like" and trajectoryType == "human-like-trajectory" then
                print( "Human-like behavior detected." )
            end
        end
    end

-- Timer logic for CATCHA phase
    if program.state[ 'test' ] then
        timer = timer + dt
        if timer >= resetTime then
            love.load()
            timer = 0
        end
    end
end

function love.draw()

-- outer border
    local outerX = 0
    local outerY = 0
    local outerWidth = 640
    local outerHeight = 480
-- inner border
    local innerX = outerX + 10
    local innerY = outerX + 10
    local innerWidth = outerWidth - 20
    local innerHeight = outerHeight - 20
-- draw UI borders with RGB values.
    love.graphics.setColor( 1, 0, 0 )
    love.graphics.rectangle( "fill", outerX, outerY, outerWidth, outerHeight )
    love.graphics.setColor( 0.2, 0.1, 0.1 )
    love.graphics.rectangle( "fill", innerX, innerY, innerWidth, innerHeight )
-- reset color to prevent drawing on other stuff
    love.graphics.setColor( 1, 1, 1 )

    if program.state[ 'intro' ] then
        buttons.intro_state.startAnalysis:draw( innerX + 6, innerY + 6, 2, 4 )
    
    elseif program.state[ 'test' ] then
-- prints deobfuscated user input, bot can read this but the input it writes will be wrong.
        love.graphics.print( userInput, innerX + 6, innerHeight - 38 )
-- Less obfuscated font for other text
        love.graphics.setFont( noiseFont )
        love.graphics.print( "Type the characters below and press return", innerX + 6, innerY + 6, nil, 0.6, 0.6 )
        local timeLeft = resetTime - timer
        love.graphics.print( math.floor( timeLeft ), innerWidth - 40, innerHeight - 20 )

-- This loop is to draw each characters individually and apply the tranformations
        for _, pos in ipairs( indexedCharacters ) do
-- Generates random RGB color for each character
            local red = math.random()
            local green = math.random()
            local blue = math.random()
            love.graphics.setColor( red, green, blue )
            love.graphics.setFont( falseFont )

            love.graphics.push()
            love.graphics.translate( ( pos.x + math.random( -1, 1 ) ), ( pos.y + math.random( -1, 1 ) ) )
            love.graphics.rotate( pos.offsetAngle )
            love.graphics.print( pos.characterIndex, screenX + 6, screenY + 6 )
            love.graphics.pop()
        end
-- Draw the button during the mouse analysis stage.
    elseif program.state[ 'analysis' ] then
        buttons.analysis_state.startTest:draw( innerWidth - 270, innerHeight - 40, 2, 4 )
    elseif program.state[ 'solved' ] then
-- Deobfuscate with the obfuscated-deobfuss...err wait...

        love.graphics.setColor( 0, 1, 0 )
        love.graphics.rectangle( "fill", outerX, outerY, outerWidth, outerHeight )
        love.graphics.setColor( 0.1, 0.2, 0.1 )
        love.graphics.rectangle( "fill", innerX, innerY, innerWidth, innerHeight )
-- reset color to prevent drawing on other stuff
        love.graphics.setColor( 1, 1, 1 )
        love.graphics.setFont( noiseFont )
        love.graphics.setColor( 0, 1, 0 )
        love.graphics.print( "Test Solved", innerWidth / 2 - 110, innerHeight / 2 - 16 )
    end
end