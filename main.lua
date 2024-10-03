local function stringGenerator( Length, inputRNG )
    
    local letterInput = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    
    local digitInput = "0123456789"
    
    local resultString = ""
    
    for i = 1, Length do

        local idxGen = math.random()

        if idxGen < inputRNG then
            local letterIndex = math.random( #letterInput )
            resultString = resultString..letterInput:sub( letterIndex, letterIndex )
        else
            local digitIndex = math.random( #digitInput )
            resultString = resultString..digitInput:sub( digitIndex, digitIndex )
        end

    end
    return resultString
end

function love.load()

    math.randomseed(os.time()) -- RNG seed
    local inputRNG = 0.5
    generatedString = stringGenerator( 9, inputRNG )

end

function love.draw()
    local integ = "1234"
    love.graphics.push()
    --love.graphics.rotate( math.random(#integ), math.random(#integ) )
    love.graphics.translate( ( math.random( #integ ) / ( math.random( #integ ) ) ), ( math.random( #integ ) / ( math.random( #integ ) ) ) )
    love.graphics.print( generatedString, love.graphics:getWidth() / 2.5, love.graphics:getHeight() / 2.25, nil, 2, 2 )
    love.graphics.pop()
end