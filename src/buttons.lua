-- local love = require "love"
--[[
Standalone factory pattern table that produces buttons as well as determine
(it looks like a class, but it's also just a table, welcome to Lua!)
functionality of those buttons from the main file.
--]]
-- text string, function, optional parameters, position X, position Y, text position X, text position Y
---@param text string
---@param func fun(...):void
---@param func_param any
---@param width? number
---@param height? number
---@return Button
function Button( text, func, func_param, width, height )
    return {
        width = width or 100,
        height = height or 100,
        func = func or function() print( "This button has no functions attached" ) end,
        func_param = func_param,
        text = text or "No Text",
        button_x = 0,
        button_y = 0,
        text_x = 0,
        text_y = 0,
-- Execute the button that is clicked on
        checkPressed = function ( self, mouse_x, mouse_y, cursor_radius )
            if ( mouse_x + cursor_radius >= self.button_x ) and ( mouse_x - cursor_radius <= self.button_x + self.width ) then
                if ( mouse_y + cursor_radius >= self.button_y ) and ( mouse_y - cursor_radius <= self.button_y + self.height ) then
                    if self.func_param then
                        self.func( self.func_param )
                    else
                        self.func()
                    end
                end    
            end
        end,
-- Determines the appearance of the buttons to be instantiated.
        ---@param self Button
        ---@param button_x? number
        ---@param button_y? number
        ---@param text_x? number
        ---@param text_y? number
        draw = function ( self, button_x, button_y, text_x, text_y )
            self.button_x = button_x or self.button_x
            self.button_y = button_y or self.button_y

            if text_x then
                self.text_x = text_x + self.button_x
            else
                self.text_x = self.button_x
            end

            if text_y then
                self.text_y = text_y + self.button_y
            else
                self.text_y = self.button_y
            end

            love.graphics.setColor( 0.8, 0.6, 0.6 )
            love.graphics.rectangle( "fill", self.button_x, self.button_y, self.width, self.height )

            love.graphics.setColor( 0, 0, 0 )
            love.graphics.print( self.text, self.text_x, self.text_y )

            love.graphics.setColor( 1, 1, 1 )
        end
    }
end

return Button